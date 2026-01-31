# Contributing to Streaming HLS Lab

First off, thank you for considering contributing to the Streaming HLS Lab! 🎉

This project is designed to help people learn about video streaming infrastructure, and your contributions help make it better for everyone.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Pull Request Process](#pull-request-process)
- [Style Guidelines](#style-guidelines)
- [Community](#community)

## Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior by opening an issue.

## How Can I Contribute?

### 🐛 Reporting Bugs

Before creating a bug report, please check existing issues to avoid duplicates.

When reporting a bug, include:

- **Clear title** describing the issue
- **Steps to reproduce** the behavior
- **Expected behavior** vs what actually happened
- **Environment details:**
  - OS and version
  - Docker version (`docker --version`)
  - Docker Compose version (`docker-compose --version`)
- **Logs** if applicable (`docker-compose logs`)
- **Screenshots** if helpful

### 💡 Suggesting Features

Feature suggestions are welcome! Please:

- Check existing issues/discussions first
- Clearly describe the feature and its use case
- Explain why it would benefit the project

### 📖 Improving Documentation

Documentation improvements are always appreciated:

- Fix typos or unclear explanations
- Add examples
- Improve wiki pages
- Translate documentation

### 🔧 Submitting Code Changes

We welcome code contributions for:

- Bug fixes
- New features
- Performance improvements
- Test coverage

## Getting Started

### Prerequisites

- Git
- Docker and Docker Compose
- FFmpeg (for testing)
- A text editor or IDE

### Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/HSL-Lab.git
   cd HSL-Lab
   ```
3. Add upstream remote:
   ```bash
   git remote add upstream https://github.com/getangar/HSL-Lab.git
   ```

### Create a Branch

Create a branch for your changes:

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/issue-description
```

Branch naming conventions:
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation changes
- `refactor/` - Code refactoring

## Development Setup

### Start the Lab

```bash
chmod +x scripts/*.sh
./scripts/setup.sh
docker-compose up -d
```

### Run a Test Stream

```bash
./scripts/test-stream.sh
```

### Verify Everything Works

```bash
# Check all containers are running
docker-compose ps

# Check Prometheus targets
curl http://localhost:4005/api/v1/targets | jq '.data.activeTargets[].health'

# Check HLS is working
curl http://localhost:4003/hls/test.m3u8
```

### Making Changes

1. Make your changes
2. Test thoroughly
3. Update documentation if needed
4. Commit with clear messages

## Pull Request Process

### Before Submitting

- [ ] Test your changes locally
- [ ] Update documentation if needed
- [ ] Add/update comments in code
- [ ] Run `docker-compose down && docker-compose up -d` to verify clean start
- [ ] Ensure no sensitive data (IPs, passwords) is committed

### Submitting

1. Push your branch:
   ```bash
   git push origin feature/your-feature-name
   ```

2. Open a Pull Request on GitHub

3. Fill out the PR template with:
   - Description of changes
   - Related issue (if any)
   - How to test
   - Screenshots (if UI changes)

### PR Review

- PRs require review before merging
- Address review feedback promptly
- Keep PRs focused — one feature/fix per PR

### After Merge

- Delete your branch
- Pull latest changes:
  ```bash
  git checkout main
  git pull upstream main
  ```

## Style Guidelines

### Git Commit Messages

- Use present tense: "Add feature" not "Added feature"
- Use imperative mood: "Fix bug" not "Fixes bug"
- Keep first line under 72 characters
- Reference issues when relevant: "Fix #123"

Examples:
```
Add cache hit ratio panel to Grafana dashboard

Fix Prometheus scrape config for edge exporter

Update README with troubleshooting section

Closes #42
```

### Code Style

#### Shell Scripts

- Use `#!/bin/bash` shebang
- Quote variables: `"$VAR"` not `$VAR`
- Use meaningful variable names
- Add comments for complex logic

#### NGINX Configuration

- Use consistent indentation (4 spaces)
- Comment configuration blocks
- Group related directives

#### YAML Files

- Use 2-space indentation
- Add comments for non-obvious settings
- Keep lines under 120 characters

#### Markdown

- Use ATX-style headers (`#`)
- Add blank lines around code blocks
- Use fenced code blocks with language identifier

### Documentation

- Write clear, concise explanations
- Include examples where helpful
- Keep README focused, details in wiki
- Update wiki for significant changes

## Project Structure

```
HSL-Lab/
├── docker-compose.yml      # Main orchestration
├── nginx-rtmp/             # Origin server config
├── nginx-edge/             # Edge/CDN config
├── player/                 # Web player
├── prometheus/             # Monitoring config
├── grafana/                # Dashboard config
├── scripts/                # Helper scripts
└── docs/                   # Additional documentation
```

### Key Files

| File | Purpose |
|------|---------|
| `docker-compose.yml` | Service definitions |
| `nginx-rtmp/nginx.conf` | RTMP and HLS config |
| `nginx-edge/nginx.conf` | Caching proxy config |
| `prometheus/prometheus.yml` | Scrape targets |
| `scripts/setup.sh` | Initial configuration |

## Testing

### Manual Testing Checklist

- [ ] `docker-compose up -d` starts all services
- [ ] FFmpeg stream reaches Origin
- [ ] HLS available through Edge
- [ ] Player can play stream
- [ ] Prometheus scrapes all targets
- [ ] Grafana dashboard shows data
- [ ] Cache headers present (X-Cache-Status)

### Testing Changes

```bash
# Clean start
docker-compose down -v
docker-compose up -d

# Wait for services
sleep 30

# Start test stream
./scripts/test-stream.sh &

# Verify
curl -I http://localhost:4003/hls/test.m3u8 | grep X-Cache
```

## Community

### Getting Help

- 💬 [GitHub Discussions](https://github.com/getangar/HSL-Lab/discussions) — Ask questions
- 🐛 [GitHub Issues](https://github.com/getangar/HSL-Lab/issues) — Report bugs
- 📖 [Wiki](https://github.com/getangar/HSL-Lab/wiki) — Documentation

### Recognition

Contributors are recognized in:
- GitHub contributors page
- Release notes (for significant contributions)

---

Thank you for contributing! 🙏

Every contribution, no matter how small, helps make this project better for everyone learning about streaming infrastructure.
