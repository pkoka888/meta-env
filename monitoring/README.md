# Meta-Env Monitoring Stack

Comprehensive monitoring configuration for the meta-env multi-server infrastructure.

## Overview

This monitoring stack provides unified observability across three Debian servers:

- **Server 60** (192.168.1.60): Monitoring Hub - Grafana, Prometheus, Wazuh Manager
- **Server 61** (192.168.1.61): Production E-commerce - Critical monitoring
- **Server 62** (192.168.1.62): Web Hosting - Standard monitoring

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Server 60 - Monitoring Hub                │
│                      (192.168.1.60)                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────────┐ │
│  │ Grafana  │  │Prometheus│  │  Wazuh   │  │ Portainer  │ │
│  │  :3000   │  │  :9090   │  │ Manager  │  │   :9000    │ │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────────────┘ │
│       │             │              │                         │
└───────┼─────────────┼──────────────┼─────────────────────────┘
        │             │              │
        │        ┌────┴────┐    ┌────┴────┐
        │        │         │    │         │
        ▼        ▼         ▼    ▼         ▼
┌────────────────────┐  ┌────────────────────┐
│  Server 61 (okamih)│  │  Server 62 (cpall) │
│  192.168.1.61      │  │  192.168.1.62      │
├────────────────────┤  ├────────────────────┤
│ Prometheus :9090   │  │ Prometheus :9090   │
│ Node Exporter      │  │ Node Exporter      │
│ Apache Exporter    │  │ Nginx Exporter     │
│ MySQL Exporter     │  │ Wazuh Agent        │
│ Wazuh Agent        │  │                    │
└────────────────────┘  └────────────────────┘
```

## Components

### 1. Prometheus (`/monitoring/prometheus/`)

**File**: `prometheus.yml`

Multi-server metrics collection with federation architecture:

- **Federation**: Central Prometheus on Server 60 aggregates metrics from Servers 61 and 62
- **Structured Labels**: Consistent labeling (server, environment, project, role)
- **Scrape Configs**:
  - System metrics (Node Exporter)
  - Database metrics (PostgreSQL, MariaDB)
  - Web server metrics (Nginx, Apache)
  - Application metrics (PrestaShop, Node.js)
  - Container metrics (Docker, Portainer)
  - Security metrics (Wazuh)
  - Network metrics (OpenVPN, Blackbox)

**Key Features**:
- 15-second scrape interval for real-time monitoring
- External labels for multi-cluster identification
- Blackbox monitoring for external endpoint health checks
- Support for custom AI/ML project exporters

**Access**:
- Server 60: http://192.168.1.60:9090 (VPN/Local only)
- Server 61: http://192.168.1.61:9090 (VPN/Local only)
- Server 62: http://192.168.1.62:9090 (VPN/Local only)

### 2. Grafana (`/monitoring/grafana/`)

**File**: `grafana.ini`

Centralized visualization and dashboarding on Server 60.

**Configuration Highlights**:
- **Port**: 3000 (VPN/Local access only)
- **Database**: SQLite (default, can upgrade to PostgreSQL)
- **Security**: Admin user/pass (change on first login!)
- **Authentication**: Basic auth enabled, no anonymous access
- **Unified Alerting**: Enabled for modern alert management
- **Default Theme**: Dark mode

**Dashboard Files** (`/monitoring/grafana/dashboards/`):
1. **node-exporter-full.json**: System metrics for all servers
   - Import Dashboard ID: 1860
   - Multi-server filtering
   - CPU, memory, disk, network metrics

2. **wazuh-security.json**: Security monitoring and SIEM
   - Import Dashboard ID: 22448, 21565
   - Security events by severity
   - Multi-server security overview

3. **database-monitoring.json**: PostgreSQL & MariaDB metrics
   - Import Dashboard ID: 9628 (PostgreSQL), 7362 (MySQL)
   - Database performance and health
   - Connection pooling, query performance

4. **infrastructure-overview.json**: High-level infrastructure view
   - Custom dashboard for entire meta-env
   - Service status map
   - Multi-project filtering

5. **webserver-monitoring.json**: Nginx & Apache metrics
   - Import Dashboard ID: 12708 (Nginx), 3894 (Apache)
   - Request rates, response times
   - Connection statistics

**Access**: http://192.168.1.60:3000 (VPN/Local only)

### 3. Wazuh (`/monitoring/wazuh/`)

**File**: `ossec.conf`

Security Information and Event Management (SIEM) system.

**Architecture**:
- **Manager**: Server 60 (192.168.1.60)
- **Agents**: Server 61 and Server 62
- **Communication**: Secure TCP on port 1514
- **Registration**: Port 1515 with SSL certificates

**Monitoring Coverage**:

**Server 60 (Monitoring Hub)**:
- System logs (auth, syslog, dpkg)
- Nginx logs (access, error)
- PostgreSQL logs
- OpenVPN logs
- Grafana logs

**Server 61 (Production E-commerce - CRITICAL)**:
- System logs with high criticality labels
- Apache logs (access, error)
- PrestaShop application logs
- MariaDB logs (error, slow queries)
- PHP-FPM logs

**Server 62 (Web Hosting)**:
- System logs
- Nginx logs (access, error)

**Security Features**:
- **File Integrity Monitoring (FIM)**: Real-time monitoring of critical files
  - System configs (/etc)
  - Web roots (/var/www)
  - SSH keys (~/.ssh)
  - Database configs
  - Web server configs

- **Rootkit Detection**: Comprehensive rootkit and malware detection
- **Vulnerability Detection**: Debian and NVD vulnerability databases
- **Active Response**: Automatic firewall blocking for:
  - SSH brute force attempts
  - Failed authentication attempts
  - 10-minute timeout for blocked IPs

**Prometheus Integration**:
- Wazuh Prometheus Exporter on port 9999
- Metrics exposed for Grafana visualization
- GitHub: https://github.com/pyToshka/wazuh-prometheus-exporter

**Access**:
- Manager API: http://192.168.1.60:55000 (VPN/Local only)
- Metrics: http://192.168.1.60:9999 (VPN/Local only)

## Network Access

All monitoring tools are restricted to VPN/Local network access only:

**VPN Access** (OpenVPN on Server 60):
- Network: 10.8.0.0/24
- Connection: 89.203.173.196:2260 (via sslh multiplexer)
- Client Config: `okamih-vpn.ovpn`

**Local Network**:
- Network: 192.168.1.0/24
- Direct access from within the network

**UFW Firewall Rules** (All Servers):
```bash
# Monitoring tools blocked from public internet
Grafana (3000): Local/VPN only
Prometheus (9090): Local/VPN only
Portainer (9000): Local/VPN only
Wazuh Exporter (9999): Local/VPN only
```

## Installation Guide

### Prerequisites

1. **OpenVPN Connection** (for remote access):
   ```bash
   # Use okamih-vpn.ovpn configuration
   # Located in project root
   ```

2. **SSH Access** to all servers:
   ```bash
   ssh backup      # Server 60
   ssh okamih      # Server 61
   ssh server62    # Server 62
   ```

### Step 1: Install Prometheus on All Servers

```bash
# On each server (60, 61, 62)
sudo apt-get update
sudo apt-get install prometheus

# Copy prometheus.yml to Server 60
sudo cp /home/user/meta-env/monitoring/prometheus/prometheus.yml \
        /etc/prometheus/prometheus.yml

# On Servers 61 and 62, configure minimal local Prometheus
# Federation will be handled by Server 60

# Restart Prometheus
sudo systemctl restart prometheus
sudo systemctl enable prometheus
```

### Step 2: Install Node Exporter on All Servers

```bash
# On each server (60, 61, 62)
sudo apt-get install prometheus-node-exporter
sudo systemctl enable prometheus-node-exporter
sudo systemctl start prometheus-node-exporter

# Verify
curl http://localhost:9100/metrics
```

### Step 3: Install Grafana on Server 60

```bash
# On Server 60
sudo apt-get install -y software-properties-common
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
sudo apt-get update
sudo apt-get install grafana

# Copy configuration
sudo cp /home/user/meta-env/monitoring/grafana/grafana.ini \
        /etc/grafana/grafana.ini

# Create dashboards directory
sudo mkdir -p /etc/grafana/provisioning/dashboards
sudo cp /home/user/meta-env/monitoring/grafana/dashboards/*.json \
        /etc/grafana/provisioning/dashboards/

# Start Grafana
sudo systemctl enable grafana-server
sudo systemctl start grafana-server

# Access: http://192.168.1.60:3000
# Default credentials: admin/admin (CHANGE IMMEDIATELY!)
```

### Step 4: Install Database Exporters

**PostgreSQL Exporter (Server 60)**:
```bash
# On Server 60
sudo apt-get install prometheus-postgres-exporter
sudo systemctl enable prometheus-postgres-exporter
sudo systemctl start prometheus-postgres-exporter
```

**MySQL Exporter (Server 61)**:
```bash
# On Server 61
sudo apt-get install prometheus-mysqld-exporter

# Create MySQL user for exporter
mysql -u root -p
CREATE USER 'exporter'@'localhost' IDENTIFIED BY 'password';
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'localhost';
FLUSH PRIVILEGES;

# Configure exporter
echo "DATA_SOURCE_NAME='exporter:password@(localhost:3306)/'" | \
  sudo tee /etc/default/prometheus-mysqld-exporter

sudo systemctl enable prometheus-mysqld-exporter
sudo systemctl start prometheus-mysqld-exporter
```

### Step 5: Install Web Server Exporters

**Nginx Exporter (Servers 60, 62)**:
```bash
# On Servers 60 and 62
sudo apt-get install prometheus-nginx-exporter

# Configure Nginx stub_status
sudo tee -a /etc/nginx/sites-available/default <<EOF
location /nginx_status {
  stub_status on;
  access_log off;
  allow 127.0.0.1;
  deny all;
}
EOF

sudo nginx -t
sudo systemctl reload nginx
sudo systemctl enable prometheus-nginx-exporter
sudo systemctl start prometheus-nginx-exporter
```

**Apache Exporter (Server 61)**:
```bash
# On Server 61
sudo apt-get install prometheus-apache-exporter

# Enable mod_status
sudo a2enmod status

# Configure Apache
sudo tee -a /etc/apache2/conf-available/server-status.conf <<EOF
<Location "/server-status">
  SetHandler server-status
  Require ip 127.0.0.1
</Location>
EOF

sudo a2enconf server-status
sudo systemctl reload apache2
sudo systemctl enable prometheus-apache-exporter
sudo systemctl start prometheus-apache-exporter
```

### Step 6: Install Wazuh

**Wazuh Manager (Server 60)**:
```bash
# On Server 60
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | sudo apt-key add -
echo "deb https://packages.wazuh.com/4.x/apt/ stable main" | \
  sudo tee /etc/apt/sources.list.d/wazuh.list
sudo apt-get update
sudo apt-get install wazuh-manager

# Copy configuration
sudo cp /home/user/meta-env/monitoring/wazuh/ossec.conf \
        /var/ossec/etc/ossec.conf

# Start Wazuh
sudo systemctl enable wazuh-manager
sudo systemctl restart wazuh-manager

# Allow agents to connect
sudo ufw allow from 192.168.1.0/24 to any port 1514 proto tcp
sudo ufw allow from 192.168.1.0/24 to any port 1515 proto tcp
```

**Wazuh Agents (Servers 61, 62)**:
```bash
# On Servers 61 and 62
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | sudo apt-key add -
echo "deb https://packages.wazuh.com/4.x/apt/ stable main" | \
  sudo tee /etc/apt/sources.list.d/wazuh.list
sudo apt-get update
sudo apt-get install wazuh-agent

# Configure manager IP
echo "WAZUH_MANAGER='192.168.1.60'" | sudo tee -a /var/ossec/etc/ossec.conf

# Register with manager
sudo /var/ossec/bin/agent-auth -m 192.168.1.60

# Start agent
sudo systemctl enable wazuh-agent
sudo systemctl restart wazuh-agent
```

**Wazuh Prometheus Exporter (Server 60)**:
```bash
# On Server 60
git clone https://github.com/pyToshka/wazuh-prometheus-exporter
cd wazuh-prometheus-exporter
pip3 install -r requirements.txt

# Configure and run as systemd service
sudo tee /etc/systemd/system/wazuh-exporter.service <<EOF
[Unit]
Description=Wazuh Prometheus Exporter
After=network.target wazuh-manager.service

[Service]
Type=simple
User=wazuh
ExecStart=/usr/bin/python3 /opt/wazuh-prometheus-exporter/exporter.py
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable wazuh-exporter
sudo systemctl start wazuh-exporter

# Allow Prometheus to scrape
sudo ufw allow from 192.168.1.0/24 to any port 9999 proto tcp
```

## Verification

### Check Prometheus Targets

```bash
# On Server 60
curl http://localhost:9090/api/v1/targets | jq

# Or visit in browser (via VPN):
# http://192.168.1.60:9090/targets
```

### Check Grafana Data Sources

```bash
# Access Grafana (via VPN):
# http://192.168.1.60:3000

# 1. Login with admin/admin
# 2. Go to Configuration > Data Sources
# 3. Add Prometheus data source: http://localhost:9090
# 4. Click "Save & Test"
```

### Check Wazuh Agents

```bash
# On Server 60
sudo /var/ossec/bin/agent_control -l

# Should show:
# - server-61 (Active)
# - server-62 (Active)
```

### Import Grafana Dashboards

```bash
# In Grafana UI:
# 1. Go to Dashboards > Import
# 2. Import each dashboard by ID:
#    - 1860: Node Exporter Full
#    - 22448: Wazuh Summary
#    - 9628: PostgreSQL Database
#    - 7362: MySQL Overview
#    - 12708: Nginx Metrics
#    - 3894: Apache Metrics
# 3. Select Prometheus data source
# 4. Click Import
```

## Security Considerations

### Firewall Rules (UFW)

**Server 60 (Monitoring Hub)**:
```bash
# Allow VPN and local network access
sudo ufw allow from 192.168.1.0/24 to any port 3000 proto tcp  # Grafana
sudo ufw allow from 192.168.1.0/24 to any port 9090 proto tcp  # Prometheus
sudo ufw allow from 192.168.1.0/24 to any port 9000 proto tcp  # Portainer
sudo ufw allow from 192.168.1.0/24 to any port 1514 proto tcp  # Wazuh
sudo ufw allow from 192.168.1.0/24 to any port 1515 proto tcp  # Wazuh Auth
sudo ufw allow from 192.168.1.0/24 to any port 9999 proto tcp  # Wazuh Exporter

sudo ufw allow from 10.8.0.0/24 to any port 3000 proto tcp     # Grafana via VPN
sudo ufw allow from 10.8.0.0/24 to any port 9090 proto tcp     # Prometheus via VPN
sudo ufw allow from 10.8.0.0/24 to any port 9000 proto tcp     # Portainer via VPN
```

**Server 61 (Production)**:
```bash
# Local network access only for monitoring
sudo ufw allow from 192.168.1.0/24 to any port 9090 proto tcp  # Prometheus
sudo ufw allow from 10.8.0.0/24 to any port 9090 proto tcp     # Prometheus via VPN
```

**Server 62 (Web Hosting)**:
```bash
# Local network access only for monitoring
sudo ufw allow from 192.168.1.0/24 to any port 9090 proto tcp  # Prometheus
sudo ufw allow from 10.8.0.0/24 to any port 9090 proto tcp     # Prometheus via VPN
```

### Critical Security Notes

1. **Change Default Credentials**: Grafana admin password MUST be changed immediately
2. **VPN Access Only**: All monitoring tools accessible only via VPN or local network
3. **Database Protection**: Database ports (3306, 5432) NEVER exposed externally
4. **Production Isolation**: Server 61 (e-commerce) has stricter monitoring
5. **SSL/TLS**: Consider enabling HTTPS for Grafana with proper certificates
6. **Authentication**: Enable OAuth or LDAP for Grafana in production
7. **Alert Notifications**: Configure email/Slack for critical alerts

## Maintenance

### Log Rotation

```bash
# Prometheus logs
sudo tee /etc/logrotate.d/prometheus <<EOF
/var/log/prometheus/*.log {
  daily
  rotate 7
  compress
  delaycompress
  missingok
  notifempty
}
EOF

# Grafana logs
sudo tee /etc/logrotate.d/grafana <<EOF
/var/log/grafana/*.log {
  daily
  rotate 7
  compress
  delaycompress
  missingok
  notifempty
}
EOF

# Wazuh logs
# Already configured in Wazuh
```

### Backup

```bash
# Grafana dashboards and settings
sudo tar -czf /backups/grafana-$(date +%Y%m%d).tar.gz \
  /var/lib/grafana \
  /etc/grafana

# Prometheus data
sudo tar -czf /backups/prometheus-$(date +%Y%m%d).tar.gz \
  /var/lib/prometheus

# Wazuh configuration
sudo tar -czf /backups/wazuh-$(date +%Y%m%d).tar.gz \
  /var/ossec/etc
```

### Updates

```bash
# Update all monitoring components
sudo apt-get update
sudo apt-get upgrade prometheus grafana wazuh-manager wazuh-agent

# Restart services
sudo systemctl restart prometheus
sudo systemctl restart grafana-server
sudo systemctl restart wazuh-manager
```

## Troubleshooting

### Prometheus Issues

```bash
# Check Prometheus status
sudo systemctl status prometheus

# View logs
sudo journalctl -u prometheus -f

# Test configuration
promtool check config /etc/prometheus/prometheus.yml

# Check targets
curl http://localhost:9090/api/v1/targets
```

### Grafana Issues

```bash
# Check Grafana status
sudo systemctl status grafana-server

# View logs
sudo tail -f /var/log/grafana/grafana.log

# Test data source connection
# Go to Configuration > Data Sources > Test
```

### Wazuh Issues

```bash
# Check Wazuh manager status
sudo /var/ossec/bin/wazuh-control status

# View logs
sudo tail -f /var/ossec/logs/ossec.log

# Check agents
sudo /var/ossec/bin/agent_control -l

# Restart agent (on agent server)
sudo systemctl restart wazuh-agent
```

## References

### Documentation
- **SERVERS.md**: `/home/user/meta-env/SERVERS.md`
- **Prometheus**: https://prometheus.io/docs/
- **Grafana**: https://grafana.com/docs/
- **Wazuh**: https://documentation.wazuh.com/

### GitHub Repositories
- **Prometheus Monitoring**: https://github.com/systelab/prometheus-monitoring
- **Workshop Prometheus + Grafana**: https://github.com/samber/workshop-prometheus-grafana
- **Wazuh Prometheus Exporter**: https://github.com/pyToshka/wazuh-prometheus-exporter

### Community Dashboards
- **Grafana Labs**: https://grafana.com/grafana/dashboards/
- **Wazuh Dashboards**:
  - 22448: Wazuh Summary
  - 21565: SIEM XDR Wazuh
- **System Dashboards**:
  - 1860: Node Exporter Full
  - 9628: PostgreSQL Database
  - 7362: MySQL Overview
  - 12708: Nginx Metrics
  - 3894: Apache Metrics

## Support

For issues or questions:
1. Check troubleshooting section above
2. Review SERVERS.md for infrastructure details
3. Consult official documentation for each tool
4. Check GitHub repositories for known issues

---

**Last Updated**: 2025-11-20
**Maintained By**: Meta-Env Infrastructure Team
**Version**: 1.0.0
