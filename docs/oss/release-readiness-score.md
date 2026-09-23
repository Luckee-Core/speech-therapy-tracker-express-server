# OSS release readiness score — Speech Therapy Tracker pair

Scored against the [release readiness checklist](https://github.com/Luckee-Core/mentorai-server/blob/main/data/open-source/oss-release-readiness-checklist.md) (Pair column). Date: 2026-09-23.

**Verdict: Ship** — Required (R) items pass for a localhost Postgres tracker.

## 1. Legal and community

| # | Item | Score |
|---|------|-------|
| 1.1 | LICENSE (MIT, both repos) | pass |
| 1.2 | CONTRIBUTING.md | pass |
| 1.3 | CODE_OF_CONDUCT | pass |
| 1.4 | CHANGELOG | pass |
| 1.5 | No secrets in tracked files | pass |

## 2. Product and documentation

| # | Item | Score |
|---|------|-------|
| 2.1 | README (what, run, architecture) | pass |
| 2.2 | Companion repo + governance links | pass |
| 2.3 | .env.example with comments | pass |
| 2.4 | SECURITY.md | pass |
| 2.5 | Threat model | pass |
| 2.6 | Wire contract filled | pass |
| 2.7 | In-app OSS onboarding | pass (`/docs`) |
| 2.8 | Postgres runbook | pass (`migrations/setup.sql`) |

## 3. Frontend shape

| # | Item | Score |
|---|------|-------|
| 3.1 | src/packages + thin app | pass |
| 3.2 | Redux manual thunks | pass |
| 3.3 | Styles object pattern | pass |
| 3.4 | ADRs + AGENTS.md | pass |
| 3.5 | No dead exports | pass |

## 4. Express shape

| # | Item | Score |
|---|------|-------|
| 4.1 | Router factories + handlers | pass |
| 4.2 | /api/data aggregator | pass |
| 4.3 | CRUD in src/data/{table}/ | pass |
| 4.4 | Managed clients at startup | pass |
| 4.5 | Logging + error JSON | pass |
| 4.6 | ADR entity pattern | pass (`src/model/`) |
| 4.7 | Dev auth bypass | N/A (open localhost API documented) |

## 5–6. Security

| # | Item | Score |
|---|------|-------|
| 5.1 | NEXT_PUBLIC_* hygiene | pass |
| 6.2 | Env split | pass |
| 6.4 | Auth or local-only threat model | pass (127.0.0.1 bind) |
| 6.5 | CORS documented | pass (permissive CORS called out for bind changes) |
| 6.7 | npm audit in CI | partial (non-blocking step) |

## 7. Pair contract

| # | Item | Score |
|---|------|-------|
| 7.1 | API URL + port 3011 | pass |
| 7.2 | Health endpoint documented | pass |
| 7.3 | Error JSON shape | pass |
| 7.4 | No service-role in browser | pass (Anthropic + DATABASE_URL server-only) |

## 8. CI

| # | Item | Score |
|---|------|-------|
| 8.1 | CI build (+ lint web) | pass |
| 8.2 | Lockfile committed | pass |

## Manual verification

- [ ] Express: `npm run dev` + `curl http://127.0.0.1:3011/api/health`
- [ ] Apply `migrations/setup.sql` on a fresh database
- [ ] Web: `NEXT_PUBLIC_API_URL=http://127.0.0.1:3011` + `npm run dev` + dashboard smoke

## Ship with debt (Rec items)

- Blocking `npm audit` in CI
- Production auth if bind address ever changes
- GitHub private vulnerability reporting is a repo setting
