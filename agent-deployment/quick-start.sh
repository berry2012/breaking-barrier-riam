#!/bin/bash

# Quick Start Script for RIAM Accordo AI Agent Demo

echo "🎵 RIAM Accordo AI Coach - Quick Start"
echo "======================================"
echo ""

# Check if deployment info exists
if [ -f "deployment-info.json" ]; then
    echo "✅ Agent already deployed!"
    AGENT_ID=$(jq -r '.agentId' deployment-info.json)
    ALIAS_ID=$(jq -r '.agentAliasId' deployment-info.json)
    echo "Agent ID: $AGENT_ID"
    echo "Alias ID: $ALIAS_ID"
    echo ""
else
    echo "⚠️  Agent not yet deployed. Run ./deploy-agent.sh first"
    echo ""
    exit 1
fi

# Start local web server
echo "🚀 Starting local web server..."
echo ""
echo "Landing page will be available at:"
echo "👉 http://localhost:8000/landing-page.html"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

python3 -m http.server 8000
