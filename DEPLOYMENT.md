# Nirapod AI deployment

## Supabase PostgreSQL

1. Create a Supabase project and copy its PostgreSQL pooler connection string.
2. Keep the connection string private. Set it locally as `DATABASE_URL` only
   while migrating and add the same value as a Render secret.
3. From `backend`, install requirements and run:

   ```powershell
   $env:DATABASE_URL = "postgresql://..."
   .\.venv\Scripts\python.exe migrate_sqlite_to_postgres.py
   Remove-Item Env:DATABASE_URL
   ```

The application continues using its PBKDF2 password hashes and SHA-256 session
token hashes. Supabase Auth is not used.

## Render

Connect the repository as a Render Blueprint. `render.yaml` configures the
FastAPI service. Enter `DATABASE_URL`, allowed web origins, and optional API
keys in Render's secret manager. Never commit those values.

After deployment, verify `https://YOUR-SERVICE.onrender.com/health` and `/docs`.

## Flutter release

Build with the deployed HTTPS API URL:

```powershell
flutter build apk --release `
  --dart-define=API_BASE_URL=https://YOUR-SERVICE.onrender.com
```

The app intentionally has no production backend URL embedded in source. This
prevents accidentally shipping a private laptop address or a stale deployment.
