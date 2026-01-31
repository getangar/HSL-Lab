# Security Policy

## ⚠️ Important Disclaimer

This project is a **learning/lab environment** and is **NOT intended for production use**. It is designed for educational purposes to understand video streaming infrastructure, CDN caching, and QoS monitoring.

**Do not expose this lab to the public internet without proper security hardening.**

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |

As this is a learning project, only the latest version is actively maintained.

## Security Considerations

### Default Credentials

This lab uses default credentials for ease of setup:

| Service | Username | Password |
|---------|----------|----------|
| Grafana | `admin` | `streaming123` |

**If deploying beyond localhost:** Change these credentials immediately.

### Network Exposure

By default, services bind to `0.0.0.0`, making them accessible on all network interfaces. For local-only access, modify `docker-compose.yml`:

```yaml
ports:
  - "127.0.0.1:4006:3000"  # Grafana only on localhost
```

### Known Limitations

- No TLS/HTTPS configured (use a reverse proxy for production)
- No authentication on RTMP ingest
- No rate limiting configured
- Prometheus/Grafana have no authentication beyond default

## Reporting a Vulnerability

If you discover a security vulnerability in this project, please report it responsibly:

### How to Report

1. **Do NOT open a public issue** for security vulnerabilities
2. Send a private report via [GitHub Security Advisories](https://github.com/getangar/HSL-Lab/security/advisories/new)

### What to Include

- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

### Response Timeline

| Action | Timeframe |
|--------|-----------|
| Initial response | Within 72 hours |
| Status update | Within 7 days |
| Fix (if accepted) | Best effort basis |

### What to Expect

- **Accepted:** We'll work on a fix and credit you in the release notes (unless you prefer anonymity)
- **Declined:** We'll explain why (e.g., out of scope for a learning project, accepted risk)

## Security Best Practices for Users

If you use this lab in any environment beyond your local machine:

1. **Change default passwords**
   ```bash
   # In docker-compose.yml
   GF_SECURITY_ADMIN_PASSWORD=your-secure-password
   ```

2. **Use a firewall**
   ```bash
   # Only allow specific IPs
   sudo ufw allow from 192.168.1.0/24 to any port 4001:4008
   ```

3. **Use a reverse proxy with TLS** (nginx, Traefik, Caddy)

4. **Don't expose to the internet** without authentication

5. **Keep Docker and images updated**
   ```bash
   docker-compose pull
   docker-compose up -d
   ```

## Scope

### In Scope

- Docker configuration issues
- Default credentials in unexpected places
- Exposed sensitive data
- Container escape vulnerabilities

### Out of Scope

- Vulnerabilities in upstream images (nginx, prometheus, grafana) — report to those projects
- Issues requiring physical access
- Social engineering
- Denial of service (this is a lab, not production)

---

Thank you for helping keep this project safe! 🔒
