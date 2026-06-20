# Service Unreachable

## Runbook Info

| Field               | Value                                                                                         |
| ------------------- | --------------------------------------------------------------------------------------------- |
| Runbook ID          | RUN001                                                                                        |
| Description         | Diagnose and restore a Linux-hosted service that is unreachable from local or remote clients. |
| Tools Used          | `systemctl`, `journalctl`, `ss`, `curl`, `nc`, `dig`, `iptables/ufw`                          |
| Special Permissions | SSH access, sudo for service/log/firewall checks                                              |
| Runbook Author      | AA. Gargoura                                                                                  |
| Last Updated        | 2026-06-20                                                                                    |
| Escalation POC      | Team Lead / Service Owner                                                                     |

---

## Desired Outcome

The affected service is reachable again, the failure layer is identified, and mitigation or escalation is completed with clear evidence.

---

## Scope

This runbook applies to Linux services running on VMs, cloud instances, or bare-metal hosts where the operator has OS-level access.

---

## Impact Assessment

Before changing anything, answer:

1. Which service or endpoint is unreachable?
2. Is the failure local, remote, or both?
3. Is the issue affecting production, staging, or development?
4. When did the issue start?
5. Was there a recent deployment, configuration change, DNS change, certificate change, or firewall change?
6. Are users affected, or is this only a monitoring alert?

---

## Steps

### 1. Confirm the symptom

From the affected host:

```bash
curl -v http://localhost:<port>/health
```

From a remote host or client machine:

```bash
curl -v http://<host>:<port>/health
nc -zv <host> <port>
```

Expected result:

```text
The health endpoint returns a valid response, or the TCP port is reachable.
```

Abnormal result:

```text
Connection refused, timeout, DNS failure, TLS error, or HTTP 5xx response.
```

---

### 2. Check service status

```bash
systemctl status <service> --no-pager
```

Expected result:

```text
Active: active (running)
```

If the service is failed, inspect logs:

```bash
journalctl -u <service> -n 100 --no-pager
```

Look for:

* startup failure
* missing configuration
* permission error
* port already in use
* dependency failure
* crash loop

---

### 3. Check if the service is listening

```bash
ss -tulpen | grep <port>
```

Expected result:

```text
The service is listening on the expected port.
```

Important interpretation:

* `127.0.0.1:<port>` means local-only access.
* `0.0.0.0:<port>` means listening on all IPv4 interfaces.
* A private IP binding means the service listens only on that interface.

If the service is not listening, focus on service startup, configuration, or application logs.

---

### 4. Check local firewall

```bash
sudo ufw status
sudo iptables -L -n
```

Expected result:

```text
The required port is allowed by local firewall rules.
```

If a cloud environment is used, also check:

* security group
* network ACL
* route table
* load balancer target health

---

### 5. Check DNS resolution

```bash
dig <service-domain>
cat /etc/resolv.conf
cat /etc/hosts
```

Expected result:

```text
The domain resolves to the expected IP address.
```

Common issues:

* wrong DNS record
* stale DNS cache
* `/etc/hosts` override
* VPN or split-horizon DNS
* resolver misconfiguration

---

### 6. Check TLS if HTTPS is used

```bash
openssl s_client -connect <host>:443 -servername <host>
```

Check for:

* expired certificate
* hostname mismatch
* missing intermediate certificate
* wrong certificate served by load balancer
* client trust-store issue
* system clock skew

---

### 7. Check recent changes

Review:

* recent deployment
* config change
* certificate rotation
* DNS change
* firewall/security group update
* package update
* service restart
* infrastructure change

If the issue started immediately after a change, consider rollback according to the deployment rollback runbook.

---

## Error Handling

If a diagnostic command fails:

1. Capture the exact command and error output.
2. Check whether the command requires sudo.
3. Avoid restarting services blindly in production.
4. Confirm business impact before mitigation.
5. Escalate if the affected system is customer-facing.

---

## Mitigation

Possible mitigations:

* restart the service if safe and approved

```bash
sudo systemctl restart <service>
```

* roll back recent deployment or configuration change
* correct firewall or security group rules
* fix DNS record or endpoint target
* renew or correct TLS certificate
* remove unhealthy backend from load balancer
* escalate to service owner if application-level failure is suspected

---

## Escalation Criteria

Escalate if:

* production impact is confirmed
* the service does not recover after restart or rollback
* root cause appears to be application code
* TLS/security issue is suspected
* customer data or data integrity is at risk
* network or cloud infrastructure ownership belongs to another team

---

## Validation

After mitigation, validate locally:

```bash
systemctl status <service> --no-pager
curl -v http://localhost:<port>/health
journalctl -u <service> -n 50 --no-pager
```

Validate remotely:

```bash
curl -v http://<host>:<port>/health
nc -zv <host> <port>
```

Successful validation means:

* service is active
* expected port is listening
* endpoint is reachable
* logs show no repeated critical errors
* monitoring/alerts recover

---

## Prevention / Follow-up

After resolution:

* add or improve health checks
* add service availability alert
* add port listener check
* add DNS/TLS monitoring if relevant
* document the failure mode
* update this runbook if any step was missing
* create automation for repeated diagnostic checks
* create RCA or post-incident note if production impact occurred

---

## Related Scripts

* `scripts/check_service.sh`
* `scripts/check_port.sh`
* `scripts/collect_incident_context.sh`
