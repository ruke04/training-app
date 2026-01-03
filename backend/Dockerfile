FROM python:3.11
WORKDIR /app
COPY backend/requirements.txt .
RUN pip install -r requirements.txt
COPY backend/src/ /app/src
COPY frontend/hidden-site /app/protected_site
CMD uvicorn src.app:app --host 0.0.0.0 --port 8000