#!/bin/bash

echo "🧪 Comprehensive Monitoring Stack Test"
echo "====================================="
echo ""

# Get public IP
PUBLIC_IP="51.20.80.133"

echo "🔍 Testing service health..."
echo ""

# Function to check service
check_service() {
    local service_name="$1"
    local url="$2"
    local expected_code="$3"
    
    echo -n "Checking $service_name... "
    
    if response=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null); then
        if [ "$response" = "$expected_code" ] || [ "$response" = "302" ] || [ "$response" = "200" ]; then
            echo "✅ OK ($response)"
        else
            echo "⚠️  Unexpected response ($response)"
        fi
    else
        echo "❌ Failed to connect"
    fi
}

# Check all services
check_service "Website" "http://$PUBLIC_IP" "200"
check_service "Grafana" "http://$PUBLIC_IP:3000" "302"
check_service "Prometheus" "http://$PUBLIC_IP:9090" "302"
check_service "Alertmanager" "http://$PUBLIC_IP:9093" "200"
check_service "Blackbox Exporter" "http://$PUBLIC_IP:9115" "200"

echo ""
echo "🐳 Docker container status:"
docker-compose ps

echo ""
echo "📊 Prometheus targets status:"
curl -s "http://$PUBLIC_IP:9090/api/v1/targets" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    for target in data['data']['activeTargets']:
        job = target['labels'].get('job', 'unknown')
        health = target['health']
        print(f'{job}: {health}')
except:
    print('Could not parse targets - check manually at http://$PUBLIC_IP:9090/targets')
" 2>/dev/null || echo "Check targets manually at http://$PUBLIC_IP:9090/targets"

echo ""
echo "🎯 Testing website probe:"
probe_result=$(curl -s "http://$PUBLIC_IP:9115/probe?target=http://$PUBLIC_IP&module=http_2xx" | grep "probe_success 1")
if [ -n "$probe_result" ]; then
    echo "✅ Website probe successful"
else
    echo "⚠️  Website probe failed or not ready yet"
fi

echo ""
echo "📈 Grafana Dashboard:"
echo "   URL: http://$PUBLIC_IP:3000"
echo "   Login: admin / admin"
echo "   Dashboard: Website Monitoring Dashboard"

echo ""
echo "🚨 Testing alert simulation:"
echo "To test email alerts:"
echo "1. Stop website: docker stop nginx-website"
echo "2. Wait 1-2 minutes"
echo "3. Check email for alert"
echo "4. Restart: docker start nginx-website"
echo ""
echo "📱 Quick test command:"
echo "docker stop nginx-website && sleep 70 && docker start nginx-website"
echo ""

echo "✅ Monitoring stack test completed!"
echo ""
echo "🌐 Access your services:"
echo "   Website:      http://$PUBLIC_IP"
echo "   Grafana:      http://$PUBLIC_IP:3000 (admin/admin)"
echo "   Prometheus:   http://$PUBLIC_IP:9090"
echo "   Alertmanager: http://$PUBLIC_IP:9093"
echo ""
