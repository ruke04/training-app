# Training App for Robot Framework Bootcamp

A minimal full‑stack app used to practice end‑to‑end UI automation with Robot Framework.

### What’s included
- **Backend**: FastAPI service with auth: `POST /register`, `POST /login`, `GET /me`
- **Database**: Postgres (via Docker) with SQLAlchemy models
- **Frontend**: Static HTML + JS (NGINX) with signup, login, and profile fetch
- **E2E Tests**: Robot Framework Browser covering register + login flow
- **Containerization**: `docker-compose` spins up DB, backend, and frontend

## Project structure
```
backend/
  Dockerfile
  requirements.txt
  src/app.py          # FastAPI app with /login endpoint
  src/database.py     # SQLAlchemy engine/session
  src/models.py       # User model
  src/auth.py         # Password hashing + JWT helpers
frontend/
  Dockerfile          # NGINX serving static files
  src/index.html
  src/app.js          # fetch -> http://localhost:8000/login
robot-tests/
  tests/web_login_test.robot
  resources/login_keywords.robot
docker-compose.yml
```

## Quick start (Docker)
1) Build and start services
```bash
docker compose up --build -d
```
2) Open the app UI: `http://localhost:8080`

3) Create an account, then login. The UI exposes both flows.

4) Stop everything
```bash
docker compose down
```

## Local development (without Docker)
Run backend (Python 3.11+):
```bash
cd backend
pip install -r requirements.txt
uvicorn src.app:app --host 0.0.0.0 --port 8000
```

Serve frontend (any static server). Example using Python:
```bash
cd frontend/src
python -m http.server 8080
```
Open `http://localhost:8080` and use the same credentials above.

Note: Because the frontend (8080) calls the backend (8000), CORS is enabled and defaults to `http://localhost:8080` when running via compose.

## API Reference
`POST /register`
- Body: `{ "username": string, "password": string }`
- 201 Created: `{ "token": string }` and creates the user
- 409 Conflict if username already exists

`POST /login`
- Body: `{ "username": string, "password": string }`
- 200 OK: `{ "token": string }` when credentials are valid
- 401 Unauthorized otherwise

`GET /me`
- Header: `Authorization: Bearer <token>`
- 200 OK: `{ "username": string }`
- 401 Unauthorized if missing/invalid

Example:
```bash
curl -i -X POST \
  -H 'Content-Type: application/json' \
  -d '{"username":"student","password":"12345"}' \
  http://localhost:8000/login
```

## Running Robot Framework tests
Install Robot Framework Browser library and browsers locally:
```bash
pip install robotframework-browser
rfbrowser init
```

Start the app first (via Docker or locally), then run:
```bash
robot -d results robot-tests/tests
```
The included test `web_login_test.robot` registers a new user, logs in, and fetches profile using the UI.

## Jenkins CI/CD

This project includes a Jenkins pipeline for continuous integration and deployment.

### Quick Start with Jenkins

1. **Install required Jenkins plugins:**
   - Robot Framework Plugin
   - HTML Publisher Plugin
   - Docker Pipeline

2. **Create a new Pipeline job** in Jenkins:
   - Point to your repository
   - Use the included `Jenkinsfile`

3. **Run the pipeline** - it will:
   - Build Docker images
   - Start services
   - Run Robot Framework tests
   - Test API endpoints
   - Publish test results

See [JENKINS.md](JENKINS.md) for detailed setup instructions and configuration options.

## Troubleshooting
- If the browser console shows CORS errors, set env var `CORS_ORIGIN=http://localhost:8080` for the backend.
- Ensure ports aren’t in use: backend `8000`, frontend `8080`.
- Rebuild containers after changes: `docker compose up --build -d`.

## License
For educational use during the Robot Framework bootcamp.
