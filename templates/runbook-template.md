# Runbook Title

## Runbook Info

| Field               | Value                                                  |
| ------------------- | ------------------------------------------------------ |
| Runbook ID          | RUNXXX                                                 |
| Description         | What is this runbook for? What is the desired outcome? |
| Tools Used          | Tools                                                  |
| Special Permissions | Permissions                                            |
| Runbook Author      | AA. Gargoura                                           |
| Last Updated        | YYYY-MM-DD                                             |
| Escalation POC      | Team Lead / Service Owner                              |

---

## Desired Outcome

Describe the expected operational result after this runbook is completed.

Example:

> The affected service is reachable again, the root symptom is identified, and escalation or mitigation has been performed if needed.

---

## Scope

This runbook applies to:

* Linux servers
* systemd-based services
* cloud or VM-based workloads
* staging, development, or production-like environments

This runbook does not apply to:

* managed services where the operating system is not accessible
* application-level bugs without infrastructure symptoms
* security incidents requiring a dedicated security response process

---

## Preconditions

Before starting, confirm:

* You have SSH or console access to the host.
* You have permission to run diagnostic commands.
* You know the affected hostname, service name, port, or endpoint.
* You understand whether the environment is production, staging, or development.
* You know the escalation contact.

---

## Impact Assessment

Answer these questions before mitigation:

1. Which service, host, or endpoint is affected?
2. Is the issue affecting one user, one environment, or all users?
3. Is this production, staging, or development?
4. When did the issue start?
5. Was there a recent deployment, configuration change, certificate change, DNS change, or infrastructure change?
6. Is there customer or business impact?

---

## Steps

### 1. Confirm the symptom

```bash
# Example command
curl -v http://<host>:<port>/health
```

Expected result:

```text
HTTP 200 OK or expected health response
```

Abnormal result:

```text
Connection refused, timeout, TLS error, 5xx response, or unexpected response
```

---

### 2. Check system status

```bash
uptime
df -h
free -h
```

Expected result:

```text
System is reachable, disk is not full, memory is available, and load is within normal range.
```

---

### 3. Check service status

```bash
systemctl status <service> --no-pager
journalctl -u <service> -n 100 --no-pager
```

Expected result:

```text
Service is active/running and logs do not show repeated failures.
```

---

### 4. Check network/listening port

```bash
ss -tulpen | grep <port>
```

Expected result:

```text
Service is listening on the expected port and interface.
```

---

### 5. Check recent changes

Review:

* recent deployments
* configuration changes
* package updates
* certificate changes
* DNS changes
* infrastructure changes
* scheduled jobs or backups

---

## Error Handling

If a command fails:

1. Capture the exact error message.
2. Do not retry destructive commands blindly.
3. Check whether the failure is permission-related, service-related, or host-related.
4. Escalate if the failure affects production or customer-facing systems.

---

## Escalation Criteria

Escalate if:

* production impact is confirmed
* the service cannot be restored after initial checks
* data loss or data corruption is suspected
* security impact is suspected
* root cause is outside your ownership
* rollback or restart requires approval
* the issue persists beyond the expected recovery window

---

## Validation

After mitigation, validate:

```bash
systemctl status <service> --no-pager
curl -v http://<host>:<port>/health
journalctl -u <service> -n 50 --no-pager
```

Successful validation means:

* service is running
* endpoint is reachable
* logs show no repeated critical errors
* monitoring/alerts return to normal

---

## Prevention / Follow-up

After the incident or task:

* update this runbook if any step was missing
* add or improve monitoring
* add alerting if detection was late
* add automation for repeated manual checks
* add regression test or release validation if caused by deployment
* document root cause and corrective actions
* create follow-up ticket if long-term fix is needed

---

## Related Scripts

* `scripts/check_service.sh`
* `scripts/check_port.sh`
* `scripts/collect_incident_context.sh`

