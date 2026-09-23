# Contributing to Speech Therapy Tracker (Express)

Thank you for contributing to the Speech Therapy Tracker open-source pair.

## Repositories

| Repo | Role |
|------|------|
| [speech-therapy-tracker-web](https://github.com/Luckee-Core/speech-therapy-tracker-web) | Next.js dashboard, tube feed, exercises, ice cubes, and `/docs` |
| [speech-therapy-tracker-express-server](https://github.com/Luckee-Core/speech-therapy-tracker-express-server) | Postgres Express API for those screens |

See the [wire contract](./docs/oss/wire-contract.md) before changing routes or JSON envelopes.

## Before you code

1. Read [.cursor/architecture/README.md](./.cursor/architecture/README.md).
2. Read [.cursor/rules/AGENTS.md](./.cursor/rules/AGENTS.md).
3. Keep CRUD in `src/data/{table}/`, types in `src/model/`, and HTTP/business logic in `src/services/`.

## Development setup

```bash
cp .env.example .env
# set DATABASE_URL, then apply migrations/setup.sql if this is a fresh database
npm install
npm run dev
```

The process binds to **`127.0.0.1:3011`**. Photo import needs `ANTHROPIC_API_KEY`; the rest of the API works without it.

## Pull requests

- Keep PRs focused.
- Run `npm run build` before opening a PR.
- Keep `ANTHROPIC_API_KEY` and `DATABASE_URL` server-only.
- Do not commit secrets or `.env` files.

## Questions

Open a GitHub issue for bugs or feature discussion.
