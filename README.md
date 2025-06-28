# 🚀 Uptime Monitoring Stack with Docker

A comprehensive website uptime monitoring solution using Docker, Prometheus, Grafana, Alertmanager, and Blackbox Exporter. This stack provides real-time monitoring, alerting, and visualization for website availability and performance.

## 📋 Table of Contents

- [Features](#-features)
- [Architecture](#-architecture)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [Configuration](#-configuration)
- [Services Overview](#-services-overview)
- [Monitoring Capabilities](#-monitoring-capabilities)
- [Alert Configuration](#-alert-configuration)
- [Email Notifications](#-email-notifications)
- [Grafana Dashboards](#-grafana-dashboards)
- [Testing](#-testing)
- [Troubleshooting](#-troubleshooting)
- [Security Considerations](#-security-considerations)
- [Contributing](#-contributing)

## ✨ Features

- **Real-time Website Monitoring**: HTTP/HTTPS endpoint monitoring with response time tracking
- **Visual Dashboards**: Pre-configured Grafana dashboards for monitoring metrics
- **Smart Alerting**: Configurable alerts for downtime, slow response times, and errors
- **Email Notifications**: Automated email alerts via SMTP (Gmail supported)
- **Multi-target Monitoring**: Monitor multiple websites and services simultaneously
- **Infrastructure Monitoring**: Monitor the monitoring stack itself
- **Easy Deployment**: One-command Docker Compose deployment
- **Scalable Architecture**: Easy to extend and customize

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     Website     │    │   Nginx Proxy   │    │  Blackbox       │
│   (Target)      │◄───┤   (Optional)    │◄───┤  Exporter       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                        │
┌─────────────────┐    ┌─────────────────┐             │
│   Prometheus    │◄───┤   Grafana       │             │
│   (Metrics)     │    │  (Visualization)│             │
└─────────────────┘    └─────────────────┘             │
         │                                              │
         └──────────────────────────────────────────────┘
         │
┌─────────────────┐
│  Alertmanager   │
│   (Alerts)      │
└─────────────────┘
```

## 📋 Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- Linux/macOS/Windows with Docker Desktop
- At least 2GB RAM available for containers
- Network access to target websites
- SMTP credentials for email alerts (optional)

## 🚀 Quick Start

1. **Clone the repository**:
   ```bash
   git clone https://github.com/sudo-hrmn/uptime-monitoring-terraform-docker.git
   cd uptime-monitoring-terraform-docker
   ```

2. **Start the monitoring stack**:
   ```bash
   docker-compose up -d
   ```

3. **Verify deployment**:
   ```bash
   ./test-monitoring.sh
   ```

4. **Access services**:
   - **Grafana**: http://localhost:3000 (admin/admin)
   - **Prometheus**: http://localhost:9090
   - **Alertmanager**: http://localhost:9093
   - **Website**: http://localhost (sample site)

## ⚙️ Configuration

### Environment Setup

Update the IP addresses in the configuration files to match your environment:

1. **Prometheus configuration** (`monitoring/prometheus/prometheus.yml`):
   ```yaml
   - targets:
     - http://nginx:80
     - http://YOUR_PUBLIC_IP  # Replace with your IP
   ```

2. **Alertmanager configuration** (`monitoring/alertmanager/alertmanager.yml`):
   ```yaml
   - '--web.external-url=http://YOUR_PUBLIC_IP:9093'  # Replace with your IP
   ```

### Target Websites

Add your websites to monitor in `monitoring/prometheus/prometheus.yml`:

```yaml
- job_name: 'blackbox-http'
  metrics_path: /probe
  params:
    module: [http_2xx]
  static_configs:
    - targets:
      - https://example.com
      - https://your-website.com
      - http://internal-service:8080
```

## 🔧 Services Overview

### 📊 Prometheus (Port 9090)
- **Purpose**: Metrics collection and storage
- **Configuration**: `monitoring/prometheus/prometheus.yml`
- **Data Retention**: 200 hours
- **Scrape Interval**: 15 seconds

### 📈 Grafana (Port 3000)
- **Purpose**: Visualization and dashboards
- **Default Login**: admin/admin
- **Dashboards**: Pre-configured website monitoring dashboard
- **Data Source**: Prometheus (auto-configured)

### 🔍 Blackbox Exporter (Port 9115)
- **Purpose**: HTTP/HTTPS probing and metrics
- **Configuration**: `monitoring/blackbox/blackbox.yml`
- **Modules**: HTTP 2xx, HTTPS, TCP, ICMP

### 🚨 Alertmanager (Port 9093)
- **Purpose**: Alert routing and notifications
- **Configuration**: `monitoring/alertmanager/alertmanager.yml`
- **Notifications**: Email, Slack, PagerDuty (configurable)

### 🌐 Nginx (Port 80/443)
- **Purpose**: Sample website for monitoring
- **Configuration**: `nginx/nginx.conf`
- **Content**: `website/index.html`

## 📊 Monitoring Capabilities

### Website Metrics
- **Availability**: Up/down status with probe_success metric
- **Response Time**: HTTP response duration
- **Status Codes**: HTTP response codes tracking
- **SSL Certificate**: Certificate expiry monitoring
- **DNS Resolution**: DNS lookup time

### Infrastructure Metrics
- **Container Health**: Docker container status
- **Resource Usage**: CPU, memory, disk usage
- **Service Discovery**: Automatic target discovery
- **Scrape Health**: Monitoring stack health

## 🚨 Alert Configuration

### Pre-configured Alerts

1. **WebsiteDown**: Triggers when probe_success == 0 for 1 minute
2. **WebsiteSlowResponse**: Triggers when response time > 5 seconds for 2 minutes
3. **HighErrorRate**: Triggers when error rate > 10% for 2 minutes
4. **PrometheusDown**: Infrastructure monitoring
5. **BlackboxExporterDown**: Exporter health monitoring
6. **AlertmanagerDown**: Alerting system health

### Custom Alert Rules

Add custom alerts in `monitoring/prometheus/rules.yml`:

```yaml
- alert: CustomAlert
  expr: your_metric > threshold
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Custom alert triggered"
    description: "Your custom alert description"
```

## 📧 Email Notifications

### Automated Configuration

Use the provided script to configure email alerts:

```bash
./configure-email-alerts.sh
```

The script will prompt for:
- SMTP server (default: Gmail)
- Email credentials
- Recipient addresses

### Manual Configuration

Edit `monitoring/alertmanager/alertmanager.yml`:

```yaml
global:
  smtp_smarthost: 'smtp.gmail.com:587'
  smtp_from: 'your-email@gmail.com'
  smtp_auth_username: 'your-email@gmail.com'
  smtp_auth_password: 'your-app-password'

receivers:
  - name: 'email-notifications'
    email_configs:
      - to: 'alerts@your-domain.com'
        subject: '🚨 Website Alert: {{ .GroupLabels.alertname }}'
```

### Gmail Setup

1. Enable 2-Factor Authentication
2. Generate App Password: https://myaccount.google.com/apppasswords
3. Use App Password instead of regular password

## 📈 Grafana Dashboards

### Pre-configured Dashboard: "Website Monitoring"

**Panels Include**:
- Website availability status
- Response time trends
- HTTP status code distribution
- Alert status overview
- Target health matrix

### Dashboard Features
- **Auto-refresh**: 30-second intervals
- **Time ranges**: Last 1h, 6h, 24h, 7d
- **Drill-down**: Click metrics for detailed views
- **Annotations**: Alert events marked on graphs

### Custom Dashboards

Import additional dashboards:
1. Go to Grafana → Dashboards → Import
2. Use dashboard ID or JSON file
3. Popular IDs: 7587 (Prometheus Stats), 9965 (Blackbox Exporter)

## 🧪 Testing

### Automated Testing

Run the comprehensive test script:

```bash
./test-monitoring.sh
```

**Test Coverage**:
- Service health checks
- Container status verification
- Prometheus targets validation
- Blackbox probe testing
- Dashboard accessibility

### Manual Testing

1. **Test Website Downtime Alert**:
   ```bash
   docker stop nginx-website
   # Wait 1-2 minutes for alert
   docker start nginx-website
   ```

2. **Test Slow Response Alert**:
   ```bash
   # Simulate network delay
   tc qdisc add dev eth0 root netem delay 6000ms
   # Remove delay
   tc qdisc del dev eth0 root
   ```

3. **Verify Metrics Collection**:
   ```bash
   curl http://localhost:9090/api/v1/query?query=probe_success
   ```

## 🔧 Troubleshooting

### Common Issues

1. **Services not starting**:
   ```bash
   docker-compose logs [service-name]
   docker-compose down && docker-compose up -d
   ```

2. **Prometheus targets down**:
   - Check network connectivity
   - Verify target URLs in configuration
   - Check firewall rules

3. **Grafana dashboard empty**:
   - Verify Prometheus data source
   - Check time range settings
   - Confirm metrics are being collected

4. **Email alerts not working**:
   - Verify SMTP credentials
   - Check Alertmanager logs
   - Test SMTP connection manually

### Debug Commands

```bash
# Check container logs
docker-compose logs -f prometheus
docker-compose logs -f alertmanager

# Verify Prometheus configuration
curl http://localhost:9090/api/v1/status/config

# Check alert rules
curl http://localhost:9090/api/v1/rules

# Test Blackbox probe
curl "http://localhost:9115/probe?target=http://example.com&module=http_2xx"
```

### Performance Tuning

1. **Reduce scrape intervals** for less frequent monitoring
2. **Adjust retention periods** to manage disk usage
3. **Optimize alert thresholds** to reduce noise
4. **Use recording rules** for complex queries

## 🔒 Security Considerations

### Production Deployment

1. **Change default passwords**:
   ```bash
   # Grafana admin password
   docker-compose exec grafana grafana-cli admin reset-admin-password newpassword
   ```

2. **Enable HTTPS**:
   - Configure SSL certificates
   - Update nginx configuration
   - Use secure SMTP connections

3. **Network security**:
   - Use Docker networks
   - Implement firewall rules
   - Restrict service ports

4. **Secrets management**:
   - Use Docker secrets
   - Environment variables
   - External secret stores

### Access Control

```yaml
# docker-compose.yml additions
environment:
  - GF_SECURITY_ADMIN_PASSWORD_FILE=/run/secrets/grafana_password
secrets:
  grafana_password:
    file: ./secrets/grafana_password.txt
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes
4. Add tests if applicable
5. Commit changes: `git commit -am 'Add feature'`
6. Push to branch: `git push origin feature-name`
7. Submit a Pull Request

### Development Setup

```bash
# Clone your fork
git clone https://github.com/your-username/uptime-monitoring-terraform-docker.git

# Create development environment
docker-compose -f docker-compose.dev.yml up -d

# Run tests
./test-monitoring.sh
```

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Prometheus](https://prometheus.io/) - Monitoring system
- [Grafana](https://grafana.com/) - Visualization platform
- [Blackbox Exporter](https://github.com/prometheus/blackbox_exporter) - HTTP probing
- [Alertmanager](https://prometheus.io/docs/alerting/latest/alertmanager/) - Alert routing

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/sudo-hrmn/uptime-monitoring-terraform-docker/issues)
- **Discussions**: [GitHub Discussions](https://github.com/sudo-hrmn/uptime-monitoring-terraform-docker/discussions)
- **Documentation**: [Wiki](https://github.com/sudo-hrmn/uptime-monitoring-terraform-docker/wiki)

---

**Made with ❤️ for reliable website monitoring**

*Last updated: June 2025*
