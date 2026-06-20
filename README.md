# Linux Ops Runbooks  & Automation Toolkit

A practical Linux operations runbook library and Bash automation scripts for common production-support scenarios: service outages, high load, disk pressure, TLS failures, DNS issues, memory pressure, and deployment rollback.

The goal is to convert repeated troubleshooting steps into documented runbooks, safe automation scripts for Linux, DevOps, CloudOps, and SRE operational procedures.

A runbook is a documented process helps achieve a specific outcome. In cloud operations, runbooks reduce operational risk by providing step-by-step procedures, required tools, permissions, escalation paths, and consistent outcomes.

---

## Purpose

The goal of this repository is to convert repeated troubleshooting and operational tasks into:

* documented runbooks
* safe diagnostic procedures
* repeatable operational workflows
* Bash/Python automation scripts

---

## Runbook Library

| Runbook ID | Title                   | Focus Area                                | Status |
| ---------- | ----------------------- | ----------------------------------------- | ------ |
| RUN001     | Service Unreachable     | Linux service troubleshooting             | Draft  |
| RUN002     | Disk Full               | Storage, logs, inode exhaustion           | Draft  |
| RUN003     | High Load Average       | CPU, memory, I/O diagnostics              | Draft  |
| RUN004     | SSH Access Failure      | Access, networking, authentication        | Draft  |
| RUN005     | TLS Certificate Failure | HTTPS, certificates, trust chain          | Draft  |
| RUN006     | DNS Resolution Failure  | DNS, resolvers, cache, records            | Draft  |
| RUN007     | Service Not Starting    | systemd, logs, config validation          | Draft  |
| RUN008     | Memory Pressure / OOM   | memory, swap, OOM killer                  | Draft  |
| RUN009     | Deployment Rollback     | failed release, mitigation, validation    | Draft  |
| RUN010     | Incident Communication  | incident updates, escalation, RCA handoff | Draft  |

---

## Repository Structure

```text
linux-ops-runbooks/
├── README.md
├── templates/
│   └── runbook-template.md
├── runbooks/
│   ├── RUN001-service-unreachable.md
│   ├── RUN002-disk-full.md
│   ├── RUN003-high-load-average.md
│   ├── RUN004-ssh-access-failure.md
│   ├── RUN005-tls-certificate-failure.md
│   ├── RUN006-dns-resolution-failure.md
│   ├── RUN007-service-not-starting.md
│   ├── RUN008-memory-pressure.md
│   ├── RUN009-deployment-rollback.md
│   └── RUN010-incident-communication.md
└── scripts/
    ├── check_disk.sh
    ├── check_service.sh
    ├── check_port.sh
    ├── check_tls_expiry.sh
    └── collect_incident_context.sh
```

---

## Runbook Format

Each runbook follows this structure:

* Runbook title
* Runbook metadata
* Desired outcome
* Tools used
* Required permissions
* Step-by-step procedure
* Expected output
* Error handling
* Escalation criteria
* Validation
* Prevention / automation opportunities

---

## Automation Goal

The first version of each runbook is written as a manual Markdown procedure. Over time, frequently used steps will be automated with Bash or Python scripts.

Examples:

| Runbook                 | Automation Script                                      |
| ----------------------- | ------------------------------------------------------ |
| Disk Full               | `scripts/check_disk.sh`, `scripts/find_large_files.sh` |
| Service Unreachable     | `scripts/check_service.sh`, `scripts/check_port.sh`    |
| TLS Certificate Failure | `scripts/check_tls_expiry.sh`                          |
| Incident Investigation  | `scripts/collect_incident_context.sh`                  |

---

## Target Use Cases

This repository is useful for:

* Linux operations practice
* DevOps and CloudOps interview preparation
* SRE-style incident response learning
* documenting operational procedures
* building a public infrastructure reliability portfolio

---

## Author

- **Name:** Ahmed Amine Gargoura
- **Role:** DevOps / Cloud Operations Engineer
- **LinkedIn:** [linkedin.com/in/aagargoura](https://www.linkedin.com/in/aagargoura)
- **GitHub:** [github.com/aagargoura](https://github.com/aagargoura)
