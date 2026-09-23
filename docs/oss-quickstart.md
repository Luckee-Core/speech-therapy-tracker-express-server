# OSS quickstart (web + Express)

Run the **Speech Therapy Tracker** pair locally. Express binds to loopback only. Data lives in **Postgres**.

| Repo | URL |
|------|-----|
| Web | https://github.com/Luckee-Core/speech-therapy-tracker-web |
| Express | https://github.com/Luckee-Core/speech-therapy-tracker-express-server |

**Wire contract:** [`docs/oss/wire-contract.md`](./oss/wire-contract.md) (ports, env, routes, JSON envelopes).

---

## 1. Postgres

Use the same local database as My Health (`my_health`) and set `DATABASE_URL`. Then:

```bash
psql "$DATABASE_URL" -f migrations/setup.sql
```

If My Health already created these tables in `my_health`, skip this step. The script is safe to re-run.

---

## 2. Express API

```bash
cd speech-therapy-tracker-express-server
cp .env.example .env
# PORT=3011
# DATABASE_URL=postgresql://YOUR_MAC_USERNAME@127.0.0.1:5432/my_health
# ANTHROPIC_API_KEY=   # optional, photo import only

npm install
npm run dev
```

Default listen: **http://127.0.0.1:3011** (not `0.0.0.0`).

```bash
curl http://127.0.0.1:3011/api/health
# → { "success": true, "data": { "status": "ok", "message": "...", "timestamp": "...", "environment": "..." } }
```

---

## 3. Web app

```bash
cd speech-therapy-tracker-web
cp .env.example .env.local
# NEXT_PUBLIC_API_URL=http://127.0.0.1:3011

npm install
npm run dev
```

Open [http://127.0.0.1:3010](http://127.0.0.1:3010) → landing at `/`, dashboard at `/dashboard`, tube feed at `/tube-feed`, exercises at `/speech-therapy`, ice cubes at `/speech-therapy-consumption`, docs at `/docs`.

---

## 4. Smoke test

1. Express health returns `{ "success": true, "data": { "status": "ok", ... } }`
2. Web landing loads at `/`; dashboard loads at `/dashboard`
3. Open [http://127.0.0.1:3010/docs/api](http://127.0.0.1:3010/docs/api) — static API reference
4. Add a formula or exercise without setting Anthropic
5. Photo import fails gracefully when `ANTHROPIC_API_KEY` is unset

---

## Environment reference

See [`docs/oss/wire-contract.md`](./oss/wire-contract.md). Keep `DATABASE_URL` and `ANTHROPIC_API_KEY` on the server only.
