# ZeroShift 🛡️

> **Lightweight, Ultra-Fast Proactive Digital Defense Engine**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Build Status](https://img.shields.io/badge/build-passing-brightgreen.svg)]()
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

**ZeroShift** is a single-binary, high-performance CLI security engine engineered to transition organizations from reactive incident response to a **proactive digital defense posture**. Built with Go, it operates with zero external runtime dependencies and negligible memory overhead, making it ideal for developer workstations, production log monitors, and CI/CD pipelines.

---

## 💡 The Three Pillars of ZeroShift

ZeroShift unifies modern security operations into a single operational workflow:

```text
                      +-----------------------------+
                      |        ZeroShift CLI        |
                      +--------------+--------------+
                                     |
         +---------------------------+---------------------------+
         |                           |                           |
         v                           v                           v
+------------------+       +-------------------+       +-------------------+
|  1. SHIFT LEFT   |       |  2. THREAT HUNT   |       | 3. MENTOR GUIDE   |
| DevSecOps & Code |       | Proactive Anomaly |       | Human Capacity    |
|   Secret Audit   |       |   & Log Engine    |       |   & Hardening     |
+------------------+       +-------------------+       +-------------------+

```

## ✨ Features

- ⚡ **Blazing Fast & Portable:** Single compiled binary (~10 MB) with zero runtime requirements.
- 📦 **Embedded Detection Rules:** Detection logic is bundled directly inside the binary using Go's `embed` package.
- 🔄 **CI/CD Native:** Native exit status flags like `--fail-on-high` allow immediate pipeline blocking on critical security findings.
- 🎯 **YAML Detection Engine:** Fully customizable detection patterns using simple YAML and regular expressions.
- 🧠 **Interactive Mentor:** Step-by-step CLI companion guiding operators through system hardening.

---

## 🛠️ Installation

### Quick Install (Linux/macOS)
```bash

curl -sSL [https://raw.githubusercontent.com/mkfih3r/zeroshift/main/install.sh](https://raw.githubusercontent.com/your-username/zeroshift/main/install.sh) | bash

From Binary Releases
Download pre-compiled platform binaries from the Releases page:
# Example for Linux AMD64
curl -L -o zeroshift [https://github.com/mkfih3r/zeroshift/releases/latest/download/zeroshift_Linux_x86_64.tar.gz](https://github.com/your-username/zeroshift/releases/latest/download/zeroshift_Linux_x86_64.tar.gz)
tar -xvf zeroshift_Linux_x86_64.tar.gz
chmod +x zeroshift
sudo mv zeroshift /usr/local/bin/

Build from Source
Requires Go 1.21+:
git clone [https://github.com/mkfih3r/zeroshift.git](https://github.com/mkfih3r/zeroshift.git)
cd zeroshift
go build -ldflags="-s -w" -o zeroshift main.go

## 📖 Complete Command Guide
ZeroShift — Proactive Security Engine

Usage:
  zeroshift [command]

Available Commands:
  guide       Launch the interactive security mentor and hardening guide
  hunt        Perform proactive threat hunting on logs and system telemetry
  shift       Scan codebases and configurations for secrets and vulnerabilities
  help        Help about any command

Flags:
  -h, --help      Help for zeroshift
  -v, --verbose   Enable verbose debug logs

## Pillar 1: DevSecOps Code & Secret Audit (shift)
Scan local codebases, directories, or repository configurations for embedded credentials and high-risk leaks:
# Scan current working directory
zeroshift shift --path .

# Scan a specific repository directory
zeroshift shift --path /path/to/project

# Enforce pipeline failure if High/Critical issues are identified
zeroshift shift --path . --fail-on-high

Automating with Git Hooks
Enforce pre-commit scanning locally across engineering teams:
echo '#!/bin/sh' > .git/hooks/pre-commit
echo 'zeroshift shift --path . --fail-on-high' >> .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

## Pillar 2: Threat Hunting & Log Analysis (hunt)
Examine system access logs, authentication logs, or HTTP traffic streams for suspicious indicators and attack patterns:
# Inspect SSH authentication log for brute-force patterns
zeroshift hunt --log /var/log/auth.log

# Scan Nginx or Apache access logs for web injection payloads
zeroshift hunt --log /var/log/nginx/access.log

## Pillar 3: Interactive Security Mentor (guide)
Run the interactive terminal wizard to follow step-by-step security hardening checklists and verification workflows:
zeroshift guide

⚙️ Rule Configuration Architecture
Rules are defined in human-readable YAML files with regex pattern matching.
Secret Detection Rule (rules/secrets.yaml)
rules:
  - id: ZS-SEC-001
    name: "Hardcoded AWS Access Key"
    severity: "CRITICAL"
    pattern: "(?i)(A3T[A-Z0-9]|AKIA|AGPA|AIDA|AROA|AIPA|ANPA|ANVA|ASIA)[A-Z0-9]{16}"
    remediation: "Inject credentials via environment variables or secret store solutions instead of code."

Threat Hunting Rule (rules/threats.yaml)
rules:
  - id: ZS-TH-001
    name: "SQL Injection Attack Detected"
    severity: "HIGH"
    pattern: "(?i)(UNION\\s+SELECT|OR\\s+1=1|SELECT.*FROM|DROP\\s+TABLE)"
    remediation: "Enforce parameterized queries or ORM abstractions across web application handlers."

🤖 CI/CD Integration Examples
GitHub Actions Workflow
Add .github/workflows/security.yml to run automated scans on every Push and Pull Request:
name: ZeroShift Security Pipeline

on: [push, pull_request]

jobs:
  security-audit:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Setup Go
        uses: actions/setup-go@v5
        with:
          go-version: '1.21'

      - name: Run ZeroShift Shift-Left Scan
        run: |
          go build -o zeroshift main.go
          ./zeroshift shift --path . --fail-on-high

```

## 🗺️ Project Roadmap & Future Enhancements
ZeroShift is continuously evolving to support advanced enterprise security requirements.

```bash
Phase 1: Core Engine & CLI Stabilization (Current)
 * [x] High-performance Go CLI skeleton using cobra
 * [x] YAML and Regex pattern detection engine
 * [x] Single binary embedding (go:embed)
 * [x] Interactive Terminal Guide Module
 * [x] Automated multi-platform build releases (GoReleaser + GitHub Actions)

Phase 2: Enterprise Reporting & Integrations (Upcoming)
 * [ ] SARIF & JSON Export: Native output formats (--format json|sarif) for GitHub Security tab integration.
 * [ ] YARA Rule Support: Integration of native YARA match engines for deep file artifact analysis.
 * [ ] eBPF System Telemetry Monitoring: Kernel-level runtime observation for advanced threat detection.
 * [ ] SBOM Generation: Software Bill of Materials generation (CycloneDX / SPDX) for supply chain security.

Phase 3: AI-Assisted Security & Enterprise Scaling
 * [ ] AI Remediation Engine: Offline/Local LLM integration for contextual code patch generation.
 * [ ] Distributed Agent Mode: Lightweight daemon execution mode for continuous server monitoring.
 * [ ] Package Manager Distribution: Distribution through Homebrew, Apt, Yum, and Chocolatey.
```
 
## 🤝 Contributing
Contributions are welcome! Please feel free to open Issues, submit Pull Requests, or suggest new detection rules.
 * Fork the Project
 * Create your Feature Branch (git checkout -b feature/NewFeature)
 * Commit your Changes (git commit -m 'Add NewFeature')
 * Push to the Branch (git push origin feature/NewFeature)
 * Open a Pull Request


📄 License
Distributed under the MIT License. See LICENSE for details.
