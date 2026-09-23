# Speech Therapy Tracker — Web + Express wire contract

Documented seam between the Next.js web app and the companion Express API.

## 1. Contract summary

| Field | Value |
|-------|-------|
| **Product name** | Speech Therapy Tracker |
| **Web repo** | https://github.com/Luckee-Core/speech-therapy-tracker-web |
| **Express repo** | https://github.com/Luckee-Core/speech-therapy-tracker-express-server |
| **Default web port** | 3010 |
| **Default API port** | 3011 |
| **Bind address** | `127.0.0.1` only |
| **API base env (web)** | `NEXT_PUBLIC_API_URL` |
| **Health endpoint** | `GET /api/health` |
| **API docs catalog** | None — static page at web `/docs/api` |
| **Success JSON** | `{ success: true, data?, count?, message? }` |
| **Error JSON** | `{ success: false, error: string, message? }` |
| **Auth (OSS default)** | None — open API on localhost for trusted local use |
| **Database** | **Postgres** via `DATABASE_URL` |

## 2. Environment variables

### 2.1 Web (`speech-therapy-tracker-web`)

| Variable | Client-visible? | Required | Purpose |
|----------|-----------------|----------|---------|
| `NEXT_PUBLIC_API_URL` | **Yes** | Rec (defaults `http://127.0.0.1:3011`) | Browser → Express base URL |
| `NEXT_PUBLIC_GITHUB_ORG` | **Yes** | No | Docs GitHub org |
| `NEXT_PUBLIC_GITHUB_WEB_URL` | **Yes** | No | Override web repo URL in docs |
| `NEXT_PUBLIC_GITHUB_API_URL` | **Yes** | No | Override API repo URL in docs |
| `NEXT_PUBLIC_DOCS_URL` | **Yes** | No | Override docs link (default `/docs`) |
| `NEXT_PUBLIC_THT_URL` | **Yes** | No | TroutHouseTech link on landing |

**Rule:** Never put server secrets in `NEXT_PUBLIC_*`. `DATABASE_URL` and `ANTHROPIC_API_KEY` belong only on Express.

### 2.2 Express (`speech-therapy-tracker-express-server`)

| Variable | Required | Purpose |
|----------|----------|---------|
| `PORT` | No (default 3011) | Listen port |
| `NODE_ENV` | No | `development` / `production` |
| `DATABASE_URL` | **Yes** | Postgres connection string |
| `PG_POOL_MAX` | No | Pool cap (default 10) |
| `ANTHROPIC_API_KEY` | For photo import | Vision preview only |

## 3. HTTP routing map

```text
{NEXT_PUBLIC_API_URL}/api/health
{NEXT_PUBLIC_API_URL}/api/data/therapy-exercises
{NEXT_PUBLIC_API_URL}/api/data/therapy-exercise-logs
{NEXT_PUBLIC_API_URL}/api/data/speech-therapy-consumption
{NEXT_PUBLIC_API_URL}/api/data/therapy-exercise-imports/preview
{NEXT_PUBLIC_API_URL}/api/data/therapy-exercise-imports/commit
{NEXT_PUBLIC_API_URL}/api/data/therapy-exercise-import-ai-exchanges
{NEXT_PUBLIC_API_URL}/api/data/feed-formulas
{NEXT_PUBLIC_API_URL}/api/data/feed-logs
```

| Method | Path | Notes |
|--------|------|-------|
| `GET` | `/api/health` | `{ success, data: { status, message, timestamp, environment } }` |
| `GET/POST` | `/api/data/therapy-exercises` | Catalog; `PATCH/DELETE` `/:id` |
| `GET` | `/api/data/therapy-exercise-logs` | Daily logs |
| `POST` | `/api/data/therapy-exercise-logs/increment` | Completed count |
| `POST` | `/api/data/therapy-exercise-logs/skip` | Skip |
| `POST` | `/api/data/therapy-exercise-logs/due` | Due |
| `GET` | `/api/data/speech-therapy-consumption` | Ice-cube rows |
| `POST` | `/api/data/speech-therapy-consumption/increment` | Quantity delta |
| `POST` | `/api/data/therapy-exercise-imports/preview` | Multipart file; needs Anthropic |
| `POST` | `/api/data/therapy-exercise-imports/commit` | Commit preview |
| `GET` | `/api/data/therapy-exercise-import-ai-exchanges` | Import exchanges |
| `GET/POST` | `/api/data/feed-formulas` | Catalog; `PATCH/DELETE` `/:id` |
| `GET` | `/api/data/feed-logs` | Pump snapshots |
| `PUT` | `/api/data/feed-logs` | Upsert by `log_date` |
| `DELETE` | `/api/data/feed-logs/:id` | Delete snapshot |

## 4. Postgres runbook

1. Use the same local Postgres database as My Health (`my_health`).
2. Set `DATABASE_URL` in `.env`.
3. Apply schema:

```bash
psql "$DATABASE_URL" -f migrations/setup.sql
```

`setup.sql` uses `IF NOT EXISTS` for therapy, ice-cube, tube-feed, and import tables. Re-running it against the existing `my_health` database is safe.

## 5. Setup verification

### Express

```bash
cp .env.example .env
# DATABASE_URL=...
psql "$DATABASE_URL" -f migrations/setup.sql
npm install
npm run dev
curl http://127.0.0.1:3011/api/health
```

### Web

```bash
cp .env.example .env.local
# NEXT_PUBLIC_API_URL=http://127.0.0.1:3011
npm install
npm run dev
# Open http://127.0.0.1:3010 — landing
# Open http://127.0.0.1:3010/dashboard — dashboard
# Open http://127.0.0.1:3010/docs — in-app docs
```

## 6. Governance

See [docs/oss/README.md](./README.md) and [release-readiness-score.md](./release-readiness-score.md).
