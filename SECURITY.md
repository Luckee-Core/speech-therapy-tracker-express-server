# Security Policy

## Supported versions

| Version | Supported |
|---------|-----------|
| Latest release tag | Yes |
| `main` branch | Best-effort |

## Reporting a vulnerability

Please **do not** open a public GitHub issue for security vulnerabilities.

Report privately via GitHub Security Advisories on this repository, or email security concerns to the maintainers through your TroutHouseTech contact channel.

Include:

- Description of the issue
- Steps to reproduce
- Impact assessment
- Suggested fix (if any)

We aim to acknowledge reports within 7 days.

## Scope

This project is a **local-only** Postgres API for speech exercises, ice-cube counts, and peg-tube feed logs. It stores health-related rows on the operator's machine.

### In scope

- Secrets logged or leaked (`DATABASE_URL`, `ANTHROPIC_API_KEY`)
- Binding the server beyond `127.0.0.1` without documenting the risk
- Browser-visible env vars that should stay server-only
- SQL injection or unsanitized writes in handlers

### Known limitations (OSS v1)

- **No API authentication.** Intentional for trusted local use. Do not expose this API on a LAN or the internet.
- **Permissive CORS** (`cors()` with default options). Restrict origins if you ever change the bind address.
- Photo import sends homework images to Anthropic when `ANTHROPIC_API_KEY` is set.

Enable GitHub private vulnerability reporting on the public repo.

## Threat model

| Trust boundary | OSS default |
|----------------|-------------|
| Operator machine | Trusted — localhost only |
| Browser | Calls `http://127.0.0.1:3011`; no credentials |
| Postgres | Local `DATABASE_URL`; tube-feed, exercise, and ice-cube rows stay on this machine |
| Anthropic | Optional vision import; key is server-only |
| Internet | **Not supported** |

## Best practices for operators

1. Keep `app.listen(..., '127.0.0.1')`. Do not port-forward 3011.
2. Do not commit `.env`.
3. Keep `ANTHROPIC_API_KEY` out of `NEXT_PUBLIC_*` and the web repo.
4. Treat the Postgres database as private health data.
