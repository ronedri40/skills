# Security Review Checklist

Use this checklist during Step 4 (manual review) of the security-scan skill.
Items here require human judgement — the automated scanner cannot catch them reliably.

---

## Authentication

- [ ] Every non-public endpoint verifies the caller is authenticated before doing any work.
- [ ] Authentication failures return `401`, not `403` or `200`.
- [ ] Tokens/sessions are validated server-side — not trusted from client input alone.
- [ ] Token expiry is enforced; expired tokens are rejected, not silently accepted.
- [ ] No endpoint is accidentally excluded from the auth middleware (e.g. via regex mismatch).

## Authorization

- [ ] After authenticating WHO the caller is, the code checks WHAT they are allowed to do.
- [ ] Resource ownership is verified — a user cannot access another user's data by guessing IDs.
- [ ] Privilege escalation paths are absent (user cannot elevate to admin via a parameter).
- [ ] Bulk operations enforce the same per-item authorization as individual operations.

## Input validation

- [ ] All external input (query params, headers, body, path segments) is validated before use.
- [ ] File paths derived from user input are sanitized — no `../` traversal possible.
- [ ] Integer inputs are bounded; no unchecked large values that could cause denial-of-service.
- [ ] Uploaded file types are validated by content, not by extension or MIME header alone.

## Secrets and configuration

- [ ] No credentials, tokens, or keys appear in source code, even in comments.
- [ ] Secrets are loaded from environment variables or a secrets manager, not config files.
- [ ] `.env` and secret files are listed in `.gitignore`.
- [ ] Default credentials (admin/admin, test/test) are absent.

## Data exposure

- [ ] API responses return only the fields the caller needs — no accidental over-fetching.
- [ ] Error messages do not reveal internal paths, stack traces, DB schema, or user data.
- [ ] Logs do not contain PII, card numbers, tokens, or passwords.
- [ ] Debug endpoints or verbose logging modes are disabled in production.

## Dependencies

- [ ] New packages added in this PR are necessary (no unused additions).
- [ ] New packages do not have known critical CVEs (check `pip audit` or `npm audit`).
- [ ] Pinned versions are used — no unbounded `>=` ranges for security-sensitive packages.

## Cryptography

- [ ] Passwords are hashed with bcrypt, argon2, or scrypt — never MD5, SHA-1, or plain SHA-256.
- [ ] Random values used for security (tokens, nonces) use a cryptographically secure source.
- [ ] TLS is enforced on all external connections — no `verify=False` or `check_hostname=False`.

## Rate limiting and abuse prevention

- [ ] Authentication endpoints have rate limiting to prevent brute force.
- [ ] Expensive operations (file upload, external API calls) are rate-limited per user.
- [ ] Bulk endpoints have a maximum page size that is enforced, not just suggested.
