# Security Policy

## Reporting Vulnerabilities

Email laurie@codetonight.co.za with:

- Description of the vulnerability
- Steps to reproduce
- Potential impact

Do NOT open public issues for security vulnerabilities.

## Response Timeline

- Initial response: 48 hours
- Assessment: 7 days
- Fix (if applicable): 30 days

## Supported Versions

| Version | Supported |
|---------|-----------|
| 4.x     | Yes       |
| < 4.0   | No        |

## Security Best Practices

When using CIPS:

1. Never commit `.env` files containing credentials
2. Use the pre-commit hook to detect secrets
3. Rotate `CIPS_TEAM_PASSWORD` regularly
4. Keep sensitive data in `facts/` (excluded from public builds)

## Known Security Considerations

- Session files in `~/.claude/projects/` may contain conversation context
- Instance serialisation stores session state locally
- Team password enables shared access - use strong passwords
