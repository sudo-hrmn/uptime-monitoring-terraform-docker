#!/bin/bash

echo "📧 Email Configuration Script for Alertmanager"
echo "=============================================="
echo ""

# Function to prompt for input
prompt_input() {
    local prompt="$1"
    local var_name="$2"
    local default="$3"
    
    if [ -n "$default" ]; then
        read -p "$prompt [$default]: " input
        if [ -z "$input" ]; then
            input="$default"
        fi
    else
        read -p "$prompt: " input
    fi
    
    eval "$var_name='$input'"
}

echo "This script will help you configure email notifications for Alertmanager."
echo "You'll need SMTP credentials (Gmail App Password recommended)."
echo ""

# Collect email configuration
prompt_input "SMTP Server" SMTP_SERVER "smtp.gmail.com:587"
prompt_input "From Email Address" FROM_EMAIL
prompt_input "SMTP Username" SMTP_USER "$FROM_EMAIL"
echo "For Gmail, use an App Password instead of your regular password."
echo "Generate one at: https://myaccount.google.com/apppasswords"
read -s -p "SMTP Password/App Password: " SMTP_PASS
echo ""
prompt_input "Recipient Email Address" TO_EMAIL

# Backup original file
cp monitoring/alertmanager/alertmanager.yml monitoring/alertmanager/alertmanager.yml.backup

# Update alertmanager configuration
cat > monitoring/alertmanager/alertmanager.yml << ALERTCONFIG
global:
  smtp_smarthost: '$SMTP_SERVER'
  smtp_from: '$FROM_EMAIL'
  smtp_auth_username: '$SMTP_USER'
  smtp_auth_password: '$SMTP_PASS'

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'email-notifications'

receivers:
  - name: 'email-notifications'
    email_configs:
      - to: '$TO_EMAIL'
        subject: '🚨 ALERT: {{ .GroupLabels.alertname }} - {{ .Status | toUpper }}'
        body: |
          {{ range .Alerts }}
          🔴 Alert: {{ .Annotations.summary }}
          📝 Description: {{ .Annotations.description }}
          🏷️  Labels: {{ range .Labels.SortedPairs }}{{ .Name }}={{ .Value }} {{ end }}
          ⏰ Started: {{ .StartsAt }}
          {{ end }}
        headers:
          Subject: '🚨 Website Monitoring Alert'

inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'dev', 'instance']
ALERTCONFIG

echo ""
echo "✅ Email configuration updated!"
echo "🔄 Restarting Alertmanager..."

# Restart alertmanager to apply new configuration
docker-compose restart alertmanager

echo "✅ Alertmanager restarted with new email configuration."
echo ""
echo "🧪 To test email notifications:"
echo "   1. Stop the nginx container: docker stop nginx-website"
echo "   2. Wait 1-2 minutes for the alert to trigger"
echo "   3. Check your email for the alert notification"
echo "   4. Restart nginx: docker start nginx-website"
echo ""
