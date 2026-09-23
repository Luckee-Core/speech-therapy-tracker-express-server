# Speech Therapy Tracker Express Server

Local Postgres API for speech exercises, ice-cube counts, and peg-tube feed logs. **MIT** licensed.

Binds to **`127.0.0.1:3011`** only — not exposed on the network.

Companion UI: [speech-therapy-tracker-web](https://github.com/Luckee-Core/speech-therapy-tracker-web).

- License: [LICENSE](./LICENSE)
- Security: [SECURITY.md](./SECURITY.md)
- Contributing: [CONTRIBUTING.md](./CONTRIBUTING.md)
- Quickstart: [docs/oss-quickstart.md](./docs/oss-quickstart.md)
- Wire contract: [docs/oss/wire-contract.md](./docs/oss/wire-contract.md)

## Quick start

```bash
git clone https://github.com/Luckee-Core/speech-therapy-tracker-express-server.git
cd speech-therapy-tracker-express-server
npm install
cp .env.example .env
# set DATABASE_URL, then apply schema if this is a fresh database
psql "$DATABASE_URL" -f migrations/setup.sql
npm run dev
```

Health: http://127.0.0.1:3011/api/health

```json
{ "success": true, "data": { "status": "ok", "message": "...", "timestamp": "...", "environment": "..." } }
```

## Postgres

Point `DATABASE_URL` at the same local Postgres database My Health uses (`my_health`). Then run `migrations/setup.sql` (`IF NOT EXISTS` for therapy, ice-cube, tube-feed, and import tables). If those tables already exist, the script is safe to re-run.

## API

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/` and `/api/health` | Liveness (`{ success, data }`) |
| `GET/POST/PATCH/DELETE` | `/api/data/therapy-exercises` | Homework catalog |
| `GET` | `/api/data/therapy-exercise-logs` | Daily logs |
| `POST` | `/api/data/therapy-exercise-logs/increment` | Increment completed count |
| `POST` | `/api/data/therapy-exercise-logs/skip` | Mark skipped |
| `POST` | `/api/data/therapy-exercise-logs/due` | Mark due |
| `GET` | `/api/data/speech-therapy-consumption` | Ice-cube rows |
| `POST` | `/api/data/speech-therapy-consumption/increment` | Apply quantity delta |
| `POST` | `/api/data/therapy-exercise-imports/preview` | Anthropic vision (multipart file) |
| `POST` | `/api/data/therapy-exercise-imports/commit` | Commit a previewed import |
| `GET` | `/api/data/therapy-exercise-import-ai-exchanges` | Import AI exchange rows |
| `GET/POST/PATCH/DELETE` | `/api/data/feed-formulas` | Formula catalog |
| `GET` | `/api/data/feed-logs` | Pump snapshots |
| `PUT` | `/api/data/feed-logs` | Upsert snapshot for `log_date` |
| `DELETE` | `/api/data/feed-logs/:id` | Delete a snapshot |

Photo import needs `ANTHROPIC_API_KEY`. Manual exercise CRUD works without it.

Success JSON: `{ "success": true, "data"? }`. Error JSON: `{ "success": false, "error": "..." }` with `400` or `500`.

## Pair with web UI

Run [speech-therapy-tracker-web](https://github.com/Luckee-Core/speech-therapy-tracker-web) on port **3010** with:

```env
NEXT_PUBLIC_API_URL=http://127.0.0.1:3011
```
