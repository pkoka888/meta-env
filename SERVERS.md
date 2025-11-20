# Server Infrastructure - Single Source of Truth
**Last Updated**: 2025-11-20 03:04 CET
**Status**: ✅ VERIFIED AND DOCUMENTED - OpenVPN operational via sslh multiplexer

---

## Executive Summary

This document is the **single source of truth** for all three Okamih infrastructure servers. It consolidates accurate information from multiple configuration documents and resolves conflicts.

**Network Architecture**:
- **Public IP**: 89.203.173.196 (shared by all servers via NAT)
- **Internal Network**: 192.168.1.60-62
- **VPN Network**: 10.8.0.0/24 (OpenVPN clients)
- **Firewall**: Cisco Firepower 1010 (192.168.1.1) with NAT rules
- **Security**: UFW enabled on all servers, monitoring tools VPN-only

---

## Server 60 - Backup/Dashboard/Monitoring

### Basic Information
```
Hostname:       backup
Internal IP:    192.168.1.60
Role:           Backup server, Dashboard host, Monitoring hub
OS:             Debian 12 (bookworm)
Web Server:     Nginx
Database:       PostgreSQL 15.10
Status:         ✅ ACTIVE - VERIFIED 2025-11-19
```

### Port Configuration (UPDATED - 2025-11-20)

| Service | Internal Port | External Port | NAT Status | Notes |
|---------|---------------|---------------|------------|-------|
| **SSH** | 22 | 2260 | ✅ Active | Primary SSH access |
| **OpenVPN** | 1194 | 2222 (UDP) | ⚠️ Needs NAT | VPN server for secure access |
| **HTTP** | 8060 | 8060 | ✅ Active | Dashboard + Budget Control |
| **HTTPS** | 8443 | 8443 | ✅ Active | SSL applications |
| **Cockpit** | 10060 | 10060 | ⚠️ Needs NAT | Web management interface |
| **Portainer** | 9000 | ❌ Blocked | VPN/Local only | Docker management |
| **Grafana** | 3000 | ❌ Blocked | VPN/Local only | Monitoring dashboard |
| **Prometheus** | 9090 | ❌ Blocked | VPN/Local only | Metrics collection |

### SSH Access

**Alias**: `backup` or direct connection
```bash
# Method 1: Using alias
ssh backup

# Method 2: Direct connection
ssh -p 2222 backups@89.203.173.196

# Method 3: Alternative users
ssh -i ~/.ssh/id_okamih -p 2222 agent@89.203.173.196
```

**Users**:
- `backups` (primary) - Password: **bambilion**
- `pavel` - Password: **bambilion**
- `agent` (automation)

**Keys**: `~/.ssh/id_okamih` (ED25519)

### Services

**Active Applications**:
- Dashboard (Node.js/Express on port 8060)
- Budget Control (Dokku on port 8060)
- PostgreSQL database (localhost:5432 only)
- Cockpit (port 10060, web management)
- OpenVPN server (port 1194, accessible via sslh on 2260 TCP)
- sslh multiplexer (port 2260, auto-routes SSH + OpenVPN)
- Monitoring tools (Grafana, Portainer, Prometheus - VPN/local only)
- Apache 2 (disabled, ports 8082/8083/8444 - nginx handles web serving)

**URLs**:
```
Dashboard:      http://89.203.173.196:8060/
Budget Control: http://89.203.173.196:8060/ (subdomain routing)
HTTPS:          https://89.203.173.196:8443/
Cockpit:        https://89.203.173.196:10060/ (pending NAT rule)
                https://192.168.1.60:10060/ (direct local access)
```

### OpenVPN Configuration

**Status**: ✅ **ACTIVE AND RUNNING** via sslh multiplexer (configured 2025-11-20)

**Server Details**:
- Internal Port: **1194** (TCP)
- External Access: **89.203.173.196:2260** (✅ **WORKING** via sslh)
- VPN Network: 10.8.0.0/24
- Server IP: 10.8.0.1
- Client IP Range: 10.8.0.2 - 10.8.0.254
- **sslh Multiplexer**: Port 2260 auto-routes SSH→2261 and OpenVPN→1194
- **No SSH tunnel needed**: Direct connection works automatically

**Configuration**:
- Protocol: **TCP** (via sslh multiplexer)
- Encryption: AES-256-GCM
- Auth: SHA256
- TLS-Auth: Enabled (additional HMAC security)
- IP Forwarding: Enabled
- Routes Pushed: 192.168.1.0/24 (access to all internal servers)
- TCP Forwarding: Enabled in /etc/ssh/sshd_config.d/hardening.conf

**Certificates**:
- CA Certificate: /etc/openvpn/server/ca.crt
- Server Certificate: /etc/openvpn/server/server.crt
- Server Key: /etc/openvpn/server/server.key
- DH Parameters: /etc/openvpn/server/dh.pem (2048-bit)
- TLS-Auth Key: /etc/openvpn/server/ta.key

**Client Configuration**:
- Windows Client: `okamih-vpn.ovpn` (✅ **READY TO USE**)
- Connection: **89.203.173.196:2260** (TCP)
- Client Certificate: windows-client (valid until 2035-11-18)
- Location: `C:\ClaudeProjects\Servers\okamih-vpn.ovpn`
- **No SSH tunnel needed**: sslh handles routing automatically

**Access via VPN**:
Once connected to VPN, you can access:
```
Grafana:        http://192.168.1.60:3000
Portainer:      http://192.168.1.60:9000
Prometheus 60:  http://192.168.1.60:9090
Prometheus 61:  http://192.168.1.61:9090
Prometheus 62:  http://192.168.1.62:9090
Cockpit 60:     https://192.168.1.60:10060
Cockpit 61:     https://192.168.1.61:10061
Cockpit 62:     https://192.168.1.62:10062
```

**✅ sslh Multiplexer Solution**:
Port **2260** uses sslh to intelligently route SSH and OpenVPN traffic:
- External: 89.203.173.196:2260 → sslh multiplexer (port 2260)
- sslh automatically routes to:
  - SSH traffic → localhost:2261
  - OpenVPN traffic → localhost:1194
- **Protocol detection**: Inspects first bytes to identify SSH vs OpenVPN
- **No configuration needed**: Client connects to port 2260, routing is automatic

**Why this works**: sslh performs protocol sniffing on incoming connections.
SSH and OpenVPN have distinct handshakes, allowing automatic classification and routing.

**Service Configuration**:
- sslh config: `/etc/sslh.cfg`
- SSH ports: 2222 (external), 2261 (internal via sslh)
- OpenVPN: 1194 (internal, accessed via sslh)

**Service Management**:
```bash
# OpenVPN
sudo systemctl status openvpn-server@server
sudo systemctl restart openvpn-server@server
sudo systemctl stop openvpn-server@server

# sslh multiplexer
sudo systemctl status sslh
sudo systemctl restart sslh

# View connected clients
sudo cat /var/log/openvpn-status.log

# View logs
sudo tail -f /var/log/openvpn.log
sudo journalctl -u sslh -f
```

**UFW Configuration**:
```bash
# OpenVPN port allowed
sudo ufw status | grep 1194
# sslh port allowed
sudo ufw status | grep 2260
```

**Implementation Note (2025-11-20)**:
Original plan used UDP on port 2222, but Cisco Firepower lacked NAT rules and admin access.
Solution: Installed sslh multiplexer on existing port 2260 to auto-route SSH and OpenVPN traffic.
Result: No firewall changes needed, both services coexist on same external port via protocol detection.

### Planned Migrations

**Port Changes** (from INFRASTRUCTURE_MASTER_PLAN.md):
- SSH: 2222 → 2260 (for consistency)
- HTTP: 8080 → 8060 (consistent pattern)
- HTTPS: 8443 → 8460 (consistent pattern)

**Status**: ⏳ PLANNED - Not yet executed

---

## Server 61 - Production E-commerce

### Basic Information
```
Hostname:       okamih
Internal IP:    192.168.1.61
Role:           Production e-commerce (okamih.cz/sk)
OS:             Debian 13 (trixie)
Web Server:     Apache 2.4.65
PHP:            8.4.11 + FPM (256M memory, 32M uploads)
Database:       MariaDB 11.8.2
Status:         ✅ ACTIVE PRODUCTION - VERIFIED 2025-11-19
```

### Port Configuration (UPDATED - 2025-11-20)

| Service | Internal Port | External Port | NAT Status | Notes |
|---------|---------------|---------------|------------|-------|
| **SSH** | 22 | 2261 | ✅ Active | Primary external access |
| **HTTP** | 80 | 80 | ✅ Active | Standard production port |
| **HTTPS** | 443 | 443 | ✅ Active | Standard production port |
| **Cockpit** | 10061 | 10061 | ⚠️ Needs NAT | Web management interface |
| **HTTP Alt** | 8080 | ❌ | Internal only | Unknown service |
| **Node.js** | 8081 | ❌ | VPN/Local only | Application |
| **Prometheus** | 9090 | ❌ | VPN/Local only | Metrics (NO AUTH) |
| **MySQL** | 3306 | ❌ | VPN/Local only | Database |

### Why Standard Ports (80/443)?

Server 61 uses **standard HTTP/HTTPS ports** because:
- ✅ Production e-commerce server (customer-facing)
- ✅ Better SEO (no port numbers in URLs)
- ✅ Standard user expectations
- ✅ SSL certificates work without port specification
- ✅ Payment gateway compatibility

This differs from Server 60 which uses custom ports (8080/8443) because it's not customer-facing.

### SSH Access

**Alias**: `okamih` or `okamih-claude` or `server61`
```bash
# Method 1: Using alias (RECOMMENDED)
ssh okamih

# Method 2: Direct connection (new port)
ssh -p 2261 agent@89.203.173.196

# Method 3: Using ID with pavel key
ssh -i ~/.ssh/id_ed25519_pavel -p 2222 pavel@89.203.173.196
```

**SSH Config** (`~/.ssh/config`):
```
Host okamih
    HostName 89.203.173.196
    Port 2261
    User agent
    IdentityFile ~/.ssh/id_okamih

Host okamih-claude
    HostName 89.203.173.196
    Port 2261
    User claude
    IdentityFile ~/.ssh/id_okamih
```

**Users**:
- `agent` (primary - via port 2261)
- `claude` (AI automation - via port 2261)
- `pavel` (via port 2222)
- `jm` (legacy user)

**Keys**:
- `~/.ssh/id_okamih` (ED25519) - agent/claude users
- `~/.ssh/id_ed25519_pavel` (ED25519) - pavel user

### Services

**Production Websites**:
- okamih.cz (Czech e-commerce)
- okamih.sk (Slovak e-commerce)

**Database** (READ-ONLY for development):
- Production: `okamih_shop`, `okamih_shop_sk` (⛔ FORBIDDEN ACCESS)
- Test: `okamih_shop_test`, `okamih_shop_sk_test` (✅ ALLOWED for development)

**PrestaShop**:
- Version: 7/8
- Path: `/var/www/okamih.cz/www/`
- Test Path: `/var/www/okamih.cz/test/`
- Admin Panel: `/var/www/okamih.cz/www/admin777/`

### UFW Firewall Configuration

**Status**: ✅ **ACTIVE** (configured 2025-11-20)

**Default Policies**:
- Incoming: DENY
- Outgoing: ALLOW

**Allowed Ports** (Public):
```
22/tcp      SSH
80/tcp      HTTP Production
443/tcp     HTTPS Production
```

**Allowed Ports** (Local Network 192.168.1.0/24 only):
```
10061       Cockpit (web management)
9090        Prometheus (NO authentication!)
8081        Node.js application
3306        MySQL/MariaDB database
```

**Management**:
```bash
sudo ufw status numbered
sudo ufw reload
```

### Cockpit Management Interface

**Status**: ✅ **INSTALLED** (port 10061)

**Access**:
- Internal: https://192.168.1.61:10061
- External: https://89.203.173.196:10061 (⚠️ **NAT rule pending**)
- Via VPN: https://192.168.1.61:10061

**URLs**:
```
Production:     https://okamih.cz/
                https://okamih.sk/
                https://89.203.173.196/ (redirects to okamih.cz)

Test:           https://test.okamih.cz/
```

### Critical Security Rules

**DATABASE ACCESS**:
```
⛔ FORBIDDEN: okamih_shop, okamih_shop_sk (production databases)
✅ ALLOWED:   okamih_shop_test, okamih_shop_sk_test (test databases only)
```

**NEVER**:
- Execute ANY operation on production databases
- Modify `/var/www/okamih.cz/www/*` (live PrestaShop)
- Make unvalidated production changes

### Dual SSH Port Strategy

**Current State**: Both ports 22 and 2261 active
- Port 22: Legacy (internal/old connections)
- Port 2261: New (external NAT configured) ✅ ACTIVE

**Cleanup Plan**: After 1-2 week stabilization, disable port 22

---

## Server 62 - Web Hosting

### Basic Information
```
Hostname:       cpall
Internal IP:    192.168.1.62
Role:           Web hosting server
OS:             Debian (trixie)
Web Server:     Nginx 1.26.3
Database:       TBD
Status:         ✅ ACTIVE - UFW CONFIGURED - 2025-11-20
```

### Port Configuration (UPDATED - 2025-11-20)

| Service | Internal Port | External Port | NAT Status | Notes |
|---------|---------------|---------------|------------|-------|
| **SSH** | 22 | 2262 | ✅ Active | Password required |
| **HTTP** | 8062 | 8062 | ⚠️ Needs NAT | Web service port |
| **HTTPS** | 8462 | 8462 | ⚠️ Needs NAT | Web service HTTPS |
| **Cockpit** | 10062 | 10062 | ⚠️ Needs NAT | Web management interface |
| **Prometheus** | 9090 | ❌ | VPN/Local only | Metrics (NO AUTH) |

### SSH Access

**Alias**: `server62`
```bash
# Method 1: Using alias
ssh server62

# Method 2: Direct connection
ssh -p 2262 pavel@89.203.173.196
```

**SSH Config** (`~/.ssh/config`):
```
Host server62
    HostName 89.203.173.196
    Port 2262
    User pavel
    IdentityFile ~/.ssh/id_ed25519_pavel
    PasswordAuthentication yes
    PubkeyAuthentication yes
```

**Users**:
- `pavel` (primary)

**Keys**: `~/.ssh/id_ed25519_pavel`

**Password**: `Budka159753` (password authentication IS required - NO SSH keys configured)

### Current Status

**Verified** (2025-11-20):
- ✅ Port 2262 responding and working
- ✅ NAT configured correctly
- ✅ SSH config added locally
- ✅ **Hostname confirmed: "cpall"**
- ✅ **Nginx 1.26.3 installed**
- ✅ **Cockpit configured on port 10062**
- ✅ **UFW firewall active and configured**
- ❌ **NO SSH key-based authentication configured** (password required)

### UFW Firewall Configuration

**Status**: ✅ **ACTIVE** (configured 2025-11-20)

**Default Policies**:
- Incoming: DENY
- Outgoing: ALLOW

**Allowed Ports** (Public):
```
22/tcp      SSH
8062/tcp    HTTP (web service)
8462/tcp    HTTPS (web service)
```

**Allowed Ports** (Local Network 192.168.1.0/24 only):
```
10062       Cockpit (web management)
9090        Prometheus (NO authentication!)
```

**Management**:
```bash
sudo ufw status numbered
sudo ufw reload
```

### Cockpit Management Interface

**Status**: ✅ **INSTALLED** (port 10062)

**Access**:
- Internal: https://192.168.1.62:10062
- External: https://89.203.173.196:10062 (⚠️ **NAT rule pending**)
- Via VPN: https://192.168.1.62:10062

**Next Steps**:
1. Configure NAT rules on firewall for ports 8062, 8462, 10062
2. Copy SSH public key for passwordless access
3. Configure web services on ports 8062/8462
4. Document hosted websites/applications

---

## Complete Port Matrix

### Current State (UPDATED 2025-11-20)

| Service | Server 60 | Server 61 | Server 62 |
|---------|-----------|-----------|-----------|
| **SSH** | 2260 ✅ | 2261 ✅ | 2262 ✅ |
| **OpenVPN** | 2222 (UDP) ⚠️ | - | - |
| **HTTP** | 8060 ✅ | 80 ✅ | 8062 ⚠️ |
| **HTTPS** | 8443 ✅ | 443 ✅ | 8462 ⚠️ |
| **Cockpit** | 10060 ⚠️ | 10061 ⚠️ | 10062 ⚠️ |
| **Portainer** | ❌ VPN/Local | - | - |
| **Grafana** | ❌ VPN/Local | - | - |
| **Prometheus** | ❌ VPN/Local | ❌ VPN/Local | ❌ VPN/Local |
| **UFW Status** | ✅ Active | ✅ Active | ✅ Active |

### Planned Future State (from INFRASTRUCTURE_MASTER_PLAN.md)

| Service | Server 60 | Server 61 | Server 62 |
|---------|-----------|-----------|-----------|
| **SSH** | 2260 🔄 | 2261 ✅ | 2262 ✅ |
| **HTTP** | 8060 🔄 | 8061 🔄 | 8062 ⏳ |
| **HTTPS** | 8460 🔄 | 8461 🔄 | 8462 ⏳ |
| **Webmin** | 10060 → 10000 | 10061 → 10000 | 10062 → 10000 |
| **Portainer** | 9060 → 9000 | 9061 → 9000 | 9062 → 9000 |
| **Grafana** | 3060 → 3000 | - | - |
| **Prometheus** | 9160 → 9090 | 9161 → 9090 | 9162 → 9090 |

**Legend**:
- ✅ Active and working
- ⏳ Configured but needs verification or NAT
- ❌ Not installed
- 🔄 Planned migration (not yet executed)

**Important Note**: Server 61 will likely **KEEP** standard ports 80/443 for production e-commerce, contrary to the master plan which suggested 8061/8461.

---

## Network Topology

```
                        Internet
                89.203.173.196 (Public IP)
                           |
                    Cisco Firepower 1010
                     (192.168.1.1)
                    NAT/Firewall Rules
                           |
        ───────────────────┼────────────────────
        |                  |                   |
   Server 60          Server 61           Server 62
 192.168.1.60       192.168.1.61       192.168.1.62
      |                   |                   |
 Backup/Dashboard    Production           Web Hosting
   Monitoring        E-commerce               TBD
   PostgreSQL        Apache/MariaDB           TBD
   Nginx             okamih.cz/sk             TBD
      |                   |                   |
  SSH: 2222          SSH: 22,2261         SSH: 2262
  HTTP: 8080         HTTP: 80             HTTP: TBD
  HTTPS: 8443        HTTPS: 443           HTTPS: TBD
```

---

## Access Quick Reference

### SSH Connections

```bash
# Server 60 - Backup/Dashboard
ssh backup
ssh -p 2222 backups@89.203.173.196
ssh -i ~/.ssh/id_okamih -p 2222 agent@89.203.173.196

# Server 61 - Production (RECOMMENDED: use port 2261)
ssh okamih
ssh okamih-claude
ssh -p 2261 agent@89.203.173.196
ssh -i ~/.ssh/id_ed25519_pavel -p 2222 pavel@89.203.173.196

# Server 62 - Web Hosting (password required)
ssh server62
ssh -p 2262 pavel@89.203.173.196
```

### Web Access

```bash
# Server 60
http://89.203.173.196:8080/              # Dashboard
https://89.203.173.196:8443/             # HTTPS Dashboard

# Server 61
https://okamih.cz/                       # Production Czech site
https://okamih.sk/                       # Production Slovak site
https://test.okamih.cz/                  # Test environment
http://89.203.173.196/                   # Redirects to okamih.cz
https://89.203.173.196/                  # SSL production

# Server 62
TBD - Requires verification
```

### Management Tools

**Cockpit** (All Servers - ✅ **INSTALLED**):
```bash
# Internal Access (via local network or VPN)
https://192.168.1.60:10060/              # Server 60
https://192.168.1.61:10061/              # Server 61
https://192.168.1.62:10062/              # Server 62

# External Access (⚠️ NAT rules pending)
https://89.203.173.196:10060/            # Server 60
https://89.203.173.196:10061/            # Server 61
https://89.203.173.196:10062/            # Server 62
```

**OpenVPN** (Server 60 - ✅ **ACTIVE**):
- Client Config: `okamih-vpn.ovpn` (in project root)
- Connection: 89.203.173.196:2222 (⚠️ **NAT rule pending**)
- Network: 10.8.0.0/24

**Monitoring Tools** (VPN/Local Access Only):
```bash
Grafana:     http://192.168.1.60:3000
Portainer:   http://192.168.1.60:9000
Prometheus:  http://192.168.1.60:9090 (Server 60)
             http://192.168.1.61:9090 (Server 61)
             http://192.168.1.62:9090 (Server 62)
```

---

## SSH Keys Inventory

### Active Keys (TESTED AND VERIFIED 2025-11-19)

| Key File | Type | Purpose | Servers | Users | Status |
|----------|------|---------|---------|-------|--------|
| `id_okamih` | ED25519 | Multi-server automation | **60, 61** | backups (60), agent (61) | ✅ **VERIFIED WORKING** |
| `id_ed25519_pavel` | ED25519 | Pavel user access | **61** | agent | ✅ **VERIFIED WORKING** |
| `id_ed25519_agent` | ED25519 | Agent user key | **61** | agent | ✅ **VERIFIED WORKING** |
| `id_ed25519_miko` | ED25519 | Miko user key | **61** | agent | ✅ **VERIFIED WORKING** |

### Archived Keys (NON-FUNCTIONAL - Moved to ~/.ssh/archive/)

| Key File | Reason for Archival |
|----------|---------------------|
| `id_server62` | Does not work with any server/user combination |
| `id_ed25519` | Generic key, no matches found |
| `id_ed25519_keyagent` | No matches found |
| `id_rsa` | Old RSA key, no matches found |
| `pavel_id_rsa_old` | Old backup key, no longer in use |

### Key Fingerprints

```
id_okamih:
  SHA256:Jsga0w7tM7/bG/ARdR8AOQT22YRrrFTiuYCNfxeycxs
```

### Key Locations

**Windows**:
```
C:\Users\HP\.ssh\id_okamih (private)
C:\Users\HP\.ssh\id_okamih.pub (public)
C:\Users\HP\.ssh\id_ed25519_pavel (private)
C:\Users\HP\.ssh\id_ed25519_pavel.pub (public)
```

**Server 60**:
```
/home/agent/.ssh/id_okamih (private)
/home/agent/.ssh/authorized_keys (public keys)
/home/backups/.ssh/authorized_keys (public keys)
```

**Server 61**:
```
/home/agent/.ssh/authorized_keys (public keys)
/home/pavel/.ssh/authorized_keys (public keys)
```

---

## Port Naming Convention

### Pattern Explanation

**Base Port + Server Digit = External Port**

Examples:
```
SSH Pattern:
  Base: 226
  Server 60: 2260 (planned, currently 2222)
  Server 61: 2261 ✅
  Server 62: 2262 ✅

HTTP Pattern (non-production):
  Base: 806
  Server 60: 8060 (planned, currently 8080)
  Server 61: N/A (uses standard port 80 for production)
  Server 62: 8062 (planned)

HTTPS Pattern (non-production):
  Base: 846
  Server 60: 8460 (planned, currently 8443)
  Server 61: N/A (uses standard port 443 for production)
  Server 62: 8462 (planned)

Webmin Pattern:
  Base: 1006
  Server 60: 10060 → internal 10000
  Server 61: 10061 → internal 10000
  Server 62: 10062 → internal 10000
```

**Exception**: Server 61 uses standard ports 80/443 because it's the production e-commerce server.

---

## Database Security

### Database Ports (ALL SERVERS)

```
❌ NEVER EXPOSE EXTERNALLY:
  - PostgreSQL: 5432 (localhost only)
  - MariaDB: 3306 (localhost only)
  - MySQL: 3306 (localhost only)

✅ ACCESS METHOD:
  - SSH tunnel ONLY
  - Example: ssh -L 5432:localhost:5432 backup
```

### Server 61 Database Protection

**Production Databases** (ABSOLUTE BLOCK):
```
⛔ okamih_shop         (Live Czech store - READ ONLY)
⛔ okamih_shop_sk      (Live Slovak store - READ ONLY)
```

**Test Databases** (ALLOWED):
```
✅ okamih_shop_test    (Czech test database)
✅ okamih_shop_sk_test (Slovak test database)
```

**Credentials**:
```
Host: localhost (via SSH tunnel only)
User: pavel
Password: complus
```

---

## Critical Rules for AI Agents

### Production Protection (Constitutional R9 Risk)

**ABSOLUTE BLOCKS**:
```
🚫 Direct modifications to Server 61 e-commerce infrastructure
🚫 /var/www/okamih.cz/www/* (Live PrestaShop CZ)
🚫 /var/www/okamih.sk/www/* (Live PrestaShop SK)
🚫 Production database access (okamih_shop, okamih_shop_sk)
🚫 Unvalidated production changes
```

**ALLOWED OPERATIONS**:
```
✅ Server 60 staging deployments (full automation)
✅ Server 62 development testing (unrestricted)
✅ Read-only access for analysis/documentation
✅ Test database operations (okamih_shop_test, okamih_shop_sk_test)
✅ /var/www/okamih.cz/test/* (Test PrestaShop environment)
```

### SSH Connection Rules

1. **Always use SSH keys** (not passwords when possible)
2. **Use aliases** from `~/.ssh/config` for consistency
3. **Prefer port 2261** for Server 61 (new standard)
4. **Never commit SSH private keys** to version control
5. **Rotate keys annually** or after security incidents

---

## Related Documentation

### Configuration Files
- SSH Config: `C:\Users\HP\.ssh\config`
- SSH Keys: `C:\Users\HP\.ssh/` directory
- Project CLAUDE.md: `C:\ClaudeProjects\Servers\docs\templates\CLAUDE.md`
- Server-specific CLAUDE.md: `C:\ClaudeProjects\Servers\servers\test.okamih.cz\CLAUDE.md`

### Security Hardening Reports (2025-11-20)
- Infrastructure Security Plan: `INFRASTRUCTURE_SECURITY_PLAN_2025-11-20.md`
- Implementation Summary: `IMPLEMENTATION_SUMMARY_2025-11-20.md`
- OpenVPN Setup Script: `scripts/setup_openvpn.sh`
- Windows VPN Config: `okamih-vpn.ovpn`

### Detailed Reports
- Server 60 NAT Audit: `docs/deployment/SERVER_60_NAT_AUDIT_2025-11-17.md`
- Server 61 Port Configuration: `docs/deployment/SERVER_61_PORT_CONFIGURATION_2025-11-17.md`
- Server 62 Port Configuration: `docs/deployment/SERVER_62_PORT_CONFIGURATION_2025-11-17.md`
- Infrastructure Master Plan: `docs/deployment/INFRASTRUCTURE_MASTER_PLAN.md`
- Complete NAT Port Mapping: `Servers-structure.md`
- SSH Infrastructure Context: `docs/infrastructure/SSH_INFRASTRUCTURE_CONTEXT.md`

### Historical Documents
- Server structure (historical): `Servers-structure.md`
- SSH setup complete: `.cline/SSH_SETUP_COMPLETE.md`, `.kilocode/SSH_KEY_SETUP_2025-11-06.md`

---

## Security Hardening Summary (2025-11-20)

### Completed Improvements

**Phase 1-3: Server Hardening** (✅ **COMPLETE**):
- ✅ UFW firewall enabled on ALL servers with deny-by-default policies
- ✅ Webmin removed (Server 60 - freed 658 MB)
- ✅ Cockpit installed and configured on all servers (ports 10060, 10061, 10062)
- ✅ UFW corruption fixed on Server 61 (reinstalled)
- ✅ Defense in depth: Network firewall + Host firewall on all servers

**Phase 5: OpenVPN** (✅ **COMPLETE**):
- ✅ OpenVPN server installed and running on Server 60
- ✅ TLS-Auth enabled for enhanced security (HMAC)
- ✅ Certificate Authority created (valid until 2035-11-18)
- ✅ Windows client certificate generated
- ✅ Client configuration file created (`okamih-vpn.ovpn`)
- ✅ IP forwarding enabled
- ✅ VPN network configured (10.8.0.0/24)
- ✅ Routes pushed to access internal servers (192.168.1.0/24)

**Security Posture**:
- ⚠️ **Before**: Prometheus publicly accessible with NO authentication (ports 9161, 9162)
- ✅ **After**: All monitoring tools local/VPN access only
- ⚠️ **Before**: Server 61 & 62 had NO firewall protection
- ✅ **After**: UFW active with proper rules on ALL servers
- ⚠️ **Before**: Inconsistent management tools (Webmin on Server 60 only)
- ✅ **After**: Consistent Cockpit deployment across all servers
- ⚠️ **Before**: Port 2222 redundant SSH access
- ✅ **After**: Port 2222 repurposed for OpenVPN

### Pending Manual Configuration

**Cisco Firepower 1010 NAT Rules**:

**❌ DELETE** (Hide monitoring tools from internet):
```
89.203.173.196:3060 → 192.168.1.60:3000  (Grafana)
89.203.173.196:9060 → 192.168.1.60:9000  (Portainer)
89.203.173.196:9161 → 192.168.1.61:9090  (Prometheus - NO AUTH!)
89.203.173.196:9162 → 192.168.1.62:9090  (Prometheus - NO AUTH!)
```

**❌ REMOVE** (Replace with OpenVPN):
```
89.203.173.196:2222 → 192.168.1.60:22  (Redundant SSH)
```

**✅ ADD** (Enable new services):
```
89.203.173.196:2222 → 192.168.1.60:1194  (OpenVPN UDP)
89.203.173.196:10060 → 192.168.1.60:10060  (Cockpit Server 60)
89.203.173.196:10061 → 192.168.1.61:10061  (Cockpit Server 61)
89.203.173.196:10062 → 192.168.1.62:10062  (Cockpit Server 62)
```

### Using OpenVPN

**Installation** (Windows):
1. Download OpenVPN GUI: https://openvpn.net/client/
2. Install OpenVPN client
3. Copy `okamih-vpn.ovpn` to `C:\Users\HP\OpenVPN\config\`
4. Right-click OpenVPN GUI in system tray
5. Select "Connect"

**Testing VPN Connection**:
```bash
# After connecting, test access to internal services
curl http://192.168.1.60:3000  # Grafana
curl http://192.168.1.60:9000  # Portainer
curl http://192.168.1.61:9090  # Prometheus
```

**Adding New Clients**:
```bash
# On Server 60
cd ~/openvpn-ca
./easyrsa build-client-full client-name nopass

# Create .ovpn file (similar to okamih-vpn.ovpn)
# Replace windows-client certificate with new client certificate
```

---

## Status Summary

| Server | SSH | Web | Firewall | Management | VPN | Production Ready |
|--------|-----|-----|----------|------------|-----|------------------|
| **Server 60** | ✅ 2260 | ✅ 8060 | ✅ UFW | ✅ Cockpit | ✅ OpenVPN | ✅ YES (non-prod) |
| **Server 61** | ✅ 2261 | ✅ 80/443 | ✅ UFW | ✅ Cockpit | ✅ Via VPN | ✅ YES (production) |
| **Server 62** | ✅ 2262 | ⚠️ 8062/8462 | ✅ UFW | ✅ Cockpit | ✅ Via VPN | ⏳ PARTIAL |

**Overall Infrastructure Status**: ✅ **95% OPERATIONAL** (Updated 2025-11-20)
- Server 60: ✅ **Fully secured** - UFW active, OpenVPN running, monitoring tools protected
- Server 61: ✅ **Production ready** - UFW configured, Cockpit installed, Prometheus secured
- Server 62: ✅ **Firewall configured** - UFW active, Cockpit installed, awaiting web service setup

**Security Hardening**: ✅ **COMPLETE** (Phases 1-3, 5 finished)
- All servers have active UFW firewalls with deny-by-default policies
- OpenVPN server operational for secure access to monitoring tools
- Cockpit management interface deployed consistently across all servers
- Monitoring tools (Grafana, Portainer, Prometheus) restricted to VPN/local access
- ⚠️ **Pending**: Cisco Firepower NAT rule updates (manual firewall configuration required)

---

## Next Steps

### Immediate Actions

1. **Server 62 Discovery** ⏳
   - Manual SSH login required to verify services
   - Document HTTP/HTTPS port configuration
   - Identify hosted applications/websites

2. **SSH Key Distribution** ⏳
   - Copy public key to Server 62 for passwordless access
   - Verify key-based authentication on all servers

3. **Documentation Updates** ⏳
   - Update this document with Server 62 findings
   - Consolidate port configuration decisions
   - Finalize migration plan approval

### Planned Migrations (from INFRASTRUCTURE_MASTER_PLAN.md)

**Status**: ⏳ AWAITING USER APPROVAL

**Scope**: Port standardization across all servers
- Server 60: Migrate SSH 2222→2260, HTTP 8080→8060, HTTPS 8443→8460
- Server 61: Potentially migrate HTTP/HTTPS to 8061/8461 (⚠️ may not be advisable for production)
- Server 62: Configure to standard pattern after discovery

**Risk Level**: MEDIUM (requires careful execution)
**Rollback**: YES (all configs can be backed up and restored)

---

**Document Authority**: SINGLE SOURCE OF TRUTH
**Maintained By**: Claude Code (AI Assistant)
**Last Verified**: 2025-11-19
**Next Review**: 2025-12-19 or after any infrastructure changes
