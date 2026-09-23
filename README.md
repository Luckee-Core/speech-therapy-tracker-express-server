# Speech Therapy Tracker — Express API

Postgres API for speech exercises, ice-cube counts, and peg-tube feed logs. Pair with **speech-therapy-tracker-web** (port 3010).

This API uses the **same Postgres database as My Health** (`my_health`). Point `DATABASE_URL` at that database so existing formulas, feed logs, exercises, and ice-cube rows show up here.

## Run

```bash
cp .env.example .env
# set DATABASE_URL to the same value as my-health-open-source-express-server
npm install
npm run dev
```

Default port is **3011**. Do not create a second database.

If this is a fresh machine with no My Health schema yet, apply My Health’s `migrations/setup.sql` (or this repo’s `migrations/setup.sql`, which is `IF NOT EXISTS` for the speech/tube-feed tables only). If My Health is already running locally, skip migrations — the tables already exist.

## Endpoints

- `GET /` and `GET /api/health` — health
- `GET/POST/PATCH/DELETE /api/data/therapy-exercises`
- `GET /api/data/therapy-exercise-logs` and increment / skip / due POSTs
- `GET /api/data/speech-therapy-consumption` and `POST .../increment`
- `POST /api/data/therapy-exercise-imports/preview` and `/commit` (Anthropic vision)
- `GET /api/data/therapy-exercise-import-ai-exchanges`
- `GET/POST/PATCH/DELETE /api/data/feed-formulas`
- `GET /api/data/feed-logs`, `PUT /api/data/feed-logs`, `DELETE /api/data/feed-logs/:id`

Photo import needs `ANTHROPIC_API_KEY`. Manual exercise CRUD works without it.

## Architecture

Follow `.cursor/rules/AGENTS.md` and `.cursor/architecture/`.
