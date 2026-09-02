# Nirapod AI backend

This service provides:

- Machine-learning URL phishing classification
- TF-IDF message scam classification
- Explainable warning reasons
- SQLite scan history
- Community report persistence

## Start

```text
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

API documentation is available at `http://127.0.0.1:8000/docs`.
