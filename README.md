# Training App

A full-stack web application for practicing UI automation with Robot Framework.

## Features

- **User Authentication**: Register, login, logout, password change
- **User Management**: List users, delete users, delete own account
- **Protected Site**: JWT-authenticated static site
- **API**: RESTful endpoints with Swagger documentation
- **CI/CD**: Jenkins pipeline with Robot Framework tests

## Architecture

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Frontend  │────▶│   Backend   │────▶│  PostgreSQL │
│   (Nginx)   │     │  (FastAPI)  │     │     (DB)    │
│   :8080     │     │    :8000    │     │    :5432    │
└─────────────┘     └─────────────┘     └─────────────┘
       │                   │
       │    /api/* proxy   │
       └───────────────────┘
```

## Quick Start

```bash
# Start all services
docker compose up --build -d

# Open the app
open http://localhost:8080

# Stop services
docker compose down
```

## Project Structure

```
training-app/
├── backend/
│   ├── src/
│   │   ├── app.py          # FastAPI application
│   │   ├── auth.py         # JWT & password hashing
│   │   ├── database.py     # SQLAlchemy setup
│   │   └── models.py       # User model
│   ├── Dockerfile
│   └── requirements.txt
├── frontend/
│   ├── src/
│   │   ├── index.html      # Main app UI
│   │   └── app.js          # Frontend logic
│   ├── hidden-site/        # Protected static site
│   ├── nginx.conf          # Nginx + API proxy config
│   └── Dockerfile
├── robot-tests/
│   ├── test/               # Test suites
│   ├── keywords/           # Shared keywords
│   └── pageobject/         # Page locators
├── docker-compose.yml
├── Jenkinsfile             # CI/CD pipeline
└── jenkins-local-setup.sh  # Jenkins setup script
```

## URLs

| Service | URL |
|---------|-----|
| Frontend | http://localhost:8080 |
| Backend API | http://localhost:8080/api |
| API Docs (Swagger) | http://localhost:8080/api/api-docs |
| Protected Site | http://localhost:8000/protected |
| Jenkins | http://localhost:8081 |

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/register` | Create new user |
| POST | `/api/login` | Authenticate user |
| POST | `/api/logout` | Clear auth cookie |
| GET | `/api/me` | Get current user |
| GET | `/api/users` | List all users |
| DELETE | `/api/users/{username}` | Delete user |
| DELETE | `/api/me` | Delete own account |
| PUT | `/api/me/password` | Change password |

See [API.md](API.md) for full documentation.

## Running Tests

### Using Make
```bash
make test
```

### Using Docker
```bash
docker run --rm --network host \
  -v $(pwd):/workspace \
  marketsquare/robotframework-browser:latest \
  bash -c "rfbrowser init chromium && robot -d /workspace/robot-results /workspace/robot-tests/test"
```

### Local Execution
```bash
pip install robotframework robotframework-browser
rfbrowser init
robot -d robot-tests/test_results robot-tests/test
```

## Test Suites

| Suite | Tests | Description |
|-------|-------|-------------|
| `user_registration.robot` | 2 | Registration flows |
| `user_login.robot` | 5 | Login scenarios |
| `Profile_management.robot` | 3 | Profile & logout |
| `user_management.robot` | 3 | User listing |

## Jenkins CI/CD

```bash
# Start Jenkins locally
./jenkins-local-setup.sh

# Access at http://localhost:8081
```

The pipeline:
1. Builds Docker images
2. Starts all services
3. Runs health checks
4. Executes API tests
5. Runs Robot Framework UI tests
6. Publishes test results

See [JENKINS.md](JENKINS.md) for detailed setup.

## Development

### Backend Only
```bash
cd backend
pip install -r requirements.txt
uvicorn src.app:app --reload --port 8000
```

### Frontend Only
```bash
cd frontend/src
python -m http.server 8080
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DATABASE_URL` | (see compose) | PostgreSQL connection |
| `JWT_SECRET` | `dev-secret-change-me` | JWT signing key |
| `CORS_ORIGIN` | `*` | Allowed origins |
| `PROTECTED_DIR` | `/app/protected_site` | Protected files path |

## Troubleshooting

### CORS Errors
The Nginx proxy handles CORS by routing `/api/*` to the backend. Access the app via `http://localhost:8080`.

### Port Already in Use
```bash
# Check what's using ports
lsof -i :8080
lsof -i :8000

# Stop and restart
docker compose down && docker compose up -d
```

### Protected Site Not Loading
```bash
docker compose restart backend
```

### Tests Failing
1. Ensure app is running: `docker compose ps`
2. Check logs: `docker compose logs`
3. Verify URL: `curl http://localhost:8080`

## Documentation

- [API.md](API.md) - API reference
- [JENKINS.md](JENKINS.md) - CI/CD setup
- [robot-tests/README-RF.md](robot-tests/README-RF.md) - Test automation guide

## License

For educational use.
