
import os
import base64
from typing import Optional

from fastapi import FastAPI, HTTPException, Depends, Header, Query, Cookie, Security
from fastapi.security import HTTPBasic, HTTPBasicCredentials, HTTPBearer, HTTPAuthorizationCredentials
from fastapi.responses import FileResponse, JSONResponse, RedirectResponse, Response
from fastapi.openapi.docs import get_swagger_ui_html, get_redoc_html
from fastapi.openapi.utils import get_openapi
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from .database import Base, engine, get_db
from .models import User
from .auth import hash_password, verify_password, create_access_token, decode_access_token


app = FastAPI(
    title="Training App API",
    description=(
        "Simple auth API with protected static site delivery.\n\n"
        "Authentication methods:\n"
        "- JWT: Use POST /register or /login to obtain a JWT, then call protected endpoints with "
        "Authorization: Bearer <token> or token query/cookie where supported.\n"
        "- Basic Auth: Use username and password directly with Authorization: Basic <base64(username:password)>"
    ),
    version="1.0.0",
    docs_url="/api-docs",
    redoc_url="/redoc",
)

# Security schemes
http_basic = HTTPBasic()
http_bearer = HTTPBearer(auto_error=False)

cors_origin = os.getenv("CORS_ORIGIN", "*")
app.add_middleware(
    CORSMiddleware,
    allow_origins=[cors_origin] if cors_origin != "*" else ["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class RegisterRequest(BaseModel):
    username: str = Field(min_length=3, max_length=255)
    password: str = Field(min_length=5, max_length=255)


class LoginRequest(BaseModel):
    username: str
    password: str


class TokenResponse(BaseModel):
    token: str


@app.on_event("startup")
def on_startup() -> None:
    Base.metadata.create_all(bind=engine)


# Public API docs endpoints (avoid auth)
@app.get("/api-docs", include_in_schema=False)
def swagger_ui() -> FileResponse:
    return get_swagger_ui_html(openapi_url="/openapi.json", title=app.title)


@app.get("/redoc", include_in_schema=False)
def redoc_ui() -> FileResponse:
    return get_redoc_html(openapi_url="/openapi.json", title=app.title)


@app.get("/openapi.json", include_in_schema=False)
def openapi_spec():
    return JSONResponse(custom_openapi())


@app.post("/register", response_model=TokenResponse, status_code=201, tags=["auth"])
def register(data: RegisterRequest, db: Session = Depends(get_db)):
    existing = db.query(User).filter(User.username == data.username).first()
    if existing:
        raise HTTPException(status_code=409, detail="Username already exists")

    user = User(username=data.username, password_hash=hash_password(data.password))
    db.add(user)
    db.commit()
    db.refresh(user)

    token = create_access_token(subject=user.username)
    return {"token": token}


@app.post("/login", response_model=TokenResponse, tags=["auth"])
def login(data: LoginRequest, db: Session = Depends(get_db)):
    user: Optional[User] = db.query(User).filter(User.username == data.username).first()
    if not user or not verify_password(data.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    token = create_access_token(subject=user.username)
    return {"token": token}


@app.post("/logout", tags=["auth"], summary="Logout and clear auth_token cookie")
@app.get("/logout", tags=["auth"], summary="Logout and clear auth_token cookie (GET for iframe)")
def logout():
    """Clear the auth_token cookie to log out the user. Does not require authentication."""
    # Return HTML that clears the cookie and can be used in an iframe
    html_content = """
    <!DOCTYPE html>
    <html>
    <head><title>Logout</title></head>
    <body>
        <script>
            // Clear cookie by setting it to expire
            document.cookie = 'auth_token=; Max-Age=0; Path=/; SameSite=Lax';
            // Also try to notify parent window if in iframe
            if (window.parent !== window) {
                window.parent.postMessage('logout-complete', '*');
            }
        </script>
        <p>Logged out successfully</p>
    </body>
    </html>
    """
    response = Response(content=html_content, media_type="text/html")
    # Also set the cookie header to clear it
    response.set_cookie(
        key="auth_token", 
        value="", 
        max_age=0, 
        path="/", 
        samesite="lax"
    )
    return response


@app.get("/me", tags=["auth"], summary="Get current user from JWT or Basic Auth")
def me(
    authorization: str = Header(default=""),
    bearer_token: Optional[HTTPAuthorizationCredentials] = Security(http_bearer),
    db: Session = Depends(get_db),
):
    """Get current user. Supports JWT Bearer token or Basic Auth."""
    # Try Basic Auth first
    if authorization.startswith("Basic "):
        try:
            encoded = authorization.split(" ", 1)[1]
            decoded = base64.b64decode(encoded).decode("utf-8")
            username, password = decoded.split(":", 1)
            credentials = HTTPBasicCredentials(username=username, password=password)
            username = _validate_basic_auth(credentials, db)
            return {"username": username}
        except Exception:
            raise HTTPException(status_code=401, detail="Invalid Basic Auth", headers={"WWW-Authenticate": "Basic"})
    
    # Try JWT Bearer token
    if bearer_token:
        username = _validate_jwt_token(bearer_token.credentials)
        return {"username": username}
    
    # Fallback to Authorization header parsing for JWT
    if authorization.startswith("Bearer "):
        token = authorization.split(" ", 1)[1]
        username = _validate_jwt_token(token)
        return {"username": username}
    
    raise HTTPException(status_code=401, detail="Missing authentication")


def _get_current_username(
    authorization: str = Header(default=""),
    bearer_token: Optional[HTTPAuthorizationCredentials] = Security(http_bearer),
    db: Session = Depends(get_db),
) -> str:
    """Helper function to get current username from JWT or Basic Auth."""
    # Try Basic Auth first
    if authorization.startswith("Basic "):
        try:
            encoded = authorization.split(" ", 1)[1]
            decoded = base64.b64decode(encoded).decode("utf-8")
            username, password = decoded.split(":", 1)
            credentials = HTTPBasicCredentials(username=username, password=password)
            return _validate_basic_auth(credentials, db)
        except Exception:
            raise HTTPException(status_code=401, detail="Invalid Basic Auth", headers={"WWW-Authenticate": "Basic"})
    
    # Try JWT Bearer token
    if bearer_token:
        return _validate_jwt_token(bearer_token.credentials)
    
    # Fallback to Authorization header parsing for JWT
    if authorization.startswith("Bearer "):
        token = authorization.split(" ", 1)[1]
        return _validate_jwt_token(token)
    
    raise HTTPException(status_code=401, detail="Missing authentication")


@app.get("/users", tags=["auth"], summary="List all users")
def list_users(
    authorization: str = Header(default=""),
    bearer_token: Optional[HTTPAuthorizationCredentials] = Security(http_bearer),
    db: Session = Depends(get_db),
):
    """List all users. Requires authentication."""
    _get_current_username(authorization, bearer_token, db)  # Verify authentication
    
    users = db.query(User).all()
    return {
        "users": [
            {
                "id": user.id,
                "username": user.username,
                "created_at": user.created_at.isoformat() if user.created_at else None
            }
            for user in users
        ]
    }


@app.delete("/me", tags=["auth"], summary="Delete current user account")
def delete_me(
    authorization: str = Header(default=""),
    bearer_token: Optional[HTTPAuthorizationCredentials] = Security(http_bearer),
    db: Session = Depends(get_db),
):
    """Delete the current user's account. Requires authentication."""
    username = _get_current_username(authorization, bearer_token, db)
    
    # Find and delete the user
    user = db.query(User).filter(User.username == username).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    db.delete(user)
    db.commit()
    
    return {"message": f"User '{username}' deleted successfully"}


@app.delete("/users/{username}", tags=["auth"], summary="Delete a specific user by username")
def delete_user(
    username: str,
    authorization: str = Header(default=""),
    bearer_token: Optional[HTTPAuthorizationCredentials] = Security(http_bearer),
    db: Session = Depends(get_db),
):
    """Delete a specific user by username. Requires authentication."""
    _get_current_username(authorization, bearer_token, db)  # Verify authentication
    
    # Find and delete the user
    user = db.query(User).filter(User.username == username).first()
    if not user:
        raise HTTPException(status_code=404, detail=f"User '{username}' not found")
    
    db.delete(user)
    db.commit()
    
    return {"message": f"User '{username}' deleted successfully"}


def _validate_basic_auth(credentials: HTTPBasicCredentials, db: Session) -> str:
    """Validate Basic Auth credentials and return username."""
    user = db.query(User).filter(User.username == credentials.username).first()
    if not user or not verify_password(credentials.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Invalid credentials", headers={"WWW-Authenticate": "Basic"})
    return user.username


def _validate_jwt_token(token: str) -> str:
    """Validate JWT token and return username."""
    payload = decode_access_token(token)
    if not payload:
        raise HTTPException(status_code=401, detail="Invalid token")
    return payload.get("sub") or ""


def _validate_token_from_header_or_query_or_cookie(
    authorization: str,
    token_qs: Optional[str],
    token_cookie: Optional[str],
    db: Session,
) -> str:
    """Validate authentication from JWT (Bearer/query/cookie) or Basic Auth."""
    # Try Basic Auth first
    if authorization.startswith("Basic "):
        try:
            encoded = authorization.split(" ", 1)[1]
            decoded = base64.b64decode(encoded).decode("utf-8")
            username, password = decoded.split(":", 1)
            credentials = HTTPBasicCredentials(username=username, password=password)
            return _validate_basic_auth(credentials, db)
        except Exception:
            raise HTTPException(status_code=401, detail="Invalid Basic Auth", headers={"WWW-Authenticate": "Basic"})
    
    # Try JWT token
    token_val: Optional[str] = None
    if authorization.startswith("Bearer "):
        token_val = authorization.split(" ", 1)[1]
    elif token_qs:
        token_val = token_qs
    elif token_cookie:
        token_val = token_cookie
    
    if not token_val:
        raise HTTPException(status_code=401, detail="Missing token")
    
    return _validate_jwt_token(token_val)


@app.get("/protected", tags=["protected"], summary="Serve protected index.html and set auth_token cookie")
def protected_root(
    authorization: str = Header(default=""),
    token: Optional[str] = Query(default=None),
    auth_token: Optional[str] = Cookie(default=None),
    db: Session = Depends(get_db),
):
    # Validate and capture token; also set cookie so subsequent asset requests work
    user = _validate_token_from_header_or_query_or_cookie(authorization, token, auth_token, db)
    base_dir = os.getenv("PROTECTED_DIR", "/app/protected_site")
    index_path = os.path.join(base_dir, "index.html")
    if not os.path.exists(index_path):
        raise HTTPException(status_code=404, detail="Protected file not found")
    resp = FileResponse(index_path, media_type="text/html")
    # Prefer the freshest token (query/header) for cookie value
    cookie_token = token or (authorization.split(" ", 1)[1] if authorization.startswith("Bearer ") else auth_token)
    if cookie_token:
        resp.set_cookie(key="auth_token", value=cookie_token, max_age=3600, path="/", samesite="lax")
    return resp


@app.get("/protected/{path:path}", tags=["protected"], summary="Serve nested protected files")
def protected_assets(
    path: str,
    authorization: str = Header(default=""),
    token: Optional[str] = Query(default=None),
    auth_token: Optional[str] = Cookie(default=None),
    db: Session = Depends(get_db),
):
    _validate_token_from_header_or_query_or_cookie(authorization, token, auth_token, db)
    base_dir = os.getenv("PROTECTED_DIR", "/app/protected_site")
    # Prevent path traversal
    safe_path = os.path.normpath(os.path.join(base_dir, path))
    if not safe_path.startswith(os.path.abspath(base_dir)):
        raise HTTPException(status_code=400, detail="Invalid path")
    if not os.path.exists(safe_path) or not os.path.isfile(safe_path):
        raise HTTPException(status_code=404, detail="Not found")
    return FileResponse(safe_path)


# Support root-relative asset paths used by the protected site, e.g. /img/foo.png, /logos/bar.svg
@app.get("/style.css", tags=["assets"])
def protected_style(
    authorization: str = Header(default=""),
    token: Optional[str] = Query(default=None),
    auth_token: Optional[str] = Cookie(default=None),
    db: Session = Depends(get_db),
):
    _validate_token_from_header_or_query_or_cookie(authorization, token, auth_token, db)
    base_dir = os.getenv("PROTECTED_DIR", "/app/protected_site")
    file_path = os.path.join(base_dir, "style.css")
    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="Not found")
    return FileResponse(file_path)


@app.get("/{path:path}", tags=["assets"], summary="Serve root-level protected files like /contact.html")
def protected_root_level_files(
    path: str,
    authorization: str = Header(default=""),
    token: Optional[str] = Query(default=None),
    auth_token: Optional[str] = Cookie(default=None),
    db: Session = Depends(get_db),
):
    # Exclude known API endpoints from this catch-all route - MUST check FIRST before any auth
    excluded_paths = ["logout", "register", "login", "me", "api-docs", "redoc", "openapi.json", "protected"]
    if path in excluded_paths or path.startswith("protected/") or path.startswith("api/"):
        raise HTTPException(status_code=404, detail="Not found")
    # Now validate authentication for actual protected files
    try:
        _validate_token_from_header_or_query_or_cookie(authorization, token, auth_token, db)
    except HTTPException:
        # If auth fails, still check if it's an excluded path (shouldn't happen, but safety check)
        if path not in excluded_paths:
            raise
        raise HTTPException(status_code=404, detail="Not found")
    base_dir = os.getenv("PROTECTED_DIR", "/app/protected_site")
    rel_path = path or "index.html"
    safe_path = os.path.normpath(os.path.join(base_dir, rel_path))
    if not safe_path.startswith(os.path.abspath(base_dir)):
        raise HTTPException(status_code=400, detail="Invalid path")
    if not os.path.exists(safe_path) or not os.path.isfile(safe_path):
        raise HTTPException(status_code=404, detail="Not found")
    return FileResponse(safe_path)


@app.get("/script.js", tags=["assets"])
def protected_script(
    authorization: str = Header(default=""),
    token: Optional[str] = Query(default=None),
    auth_token: Optional[str] = Cookie(default=None),
    db: Session = Depends(get_db),
):
    _validate_token_from_header_or_query_or_cookie(authorization, token, auth_token, db)
    base_dir = os.getenv("PROTECTED_DIR", "/app/protected_site")
    file_path = os.path.join(base_dir, "script.js")
    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="Not found")
    return FileResponse(file_path)


@app.get("/img/{asset_path:path}", tags=["assets"])
def protected_img(
    asset_path: str,
    authorization: str = Header(default=""),
    token: Optional[str] = Query(default=None),
    auth_token: Optional[str] = Cookie(default=None),
    db: Session = Depends(get_db),
):
    _validate_token_from_header_or_query_or_cookie(authorization, token, auth_token, db)
    base_dir = os.getenv("PROTECTED_DIR", "/app/protected_site")
    file_path = os.path.normpath(os.path.join(base_dir, "img", asset_path))
    if not file_path.startswith(os.path.abspath(base_dir)):
        raise HTTPException(status_code=400, detail="Invalid path")
    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="Not found")
    return FileResponse(file_path)


@app.get("/logos/{asset_path:path}", tags=["assets"])
def protected_logos(
    asset_path: str,
    authorization: str = Header(default=""),
    token: Optional[str] = Query(default=None),
    auth_token: Optional[str] = Cookie(default=None),
    db: Session = Depends(get_db),
):
    _validate_token_from_header_or_query_or_cookie(authorization, token, auth_token, db)
    base_dir = os.getenv("PROTECTED_DIR", "/app/protected_site")
    file_path = os.path.normpath(os.path.join(base_dir, "logos", asset_path))
    if not file_path.startswith(os.path.abspath(base_dir)):
        raise HTTPException(status_code=400, detail="Invalid path")
    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="Not found")
    return FileResponse(file_path)


def custom_openapi():
    if app.openapi_schema:
        return app.openapi_schema
    openapi_schema = get_openapi(
        title=app.title,
        version=app.version,
        description=app.description,
        routes=app.routes,
    )
    components = openapi_schema.setdefault("components", {}).setdefault("securitySchemes", {})
    components["bearerAuth"] = {
        "type": "http",
        "scheme": "bearer",
        "bearerFormat": "JWT",
    }
    components["basicAuth"] = {
        "type": "http",
        "scheme": "basic",
    }
    # apply globally so the UI shows lock icon; routes also accept query/cookie where noted
    openapi_schema["security"] = [{"bearerAuth": []}, {"basicAuth": []}]
    app.openapi_schema = openapi_schema
    return app.openapi_schema


app.openapi = custom_openapi
