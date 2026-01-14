#!/bin/bash

# Start both API server and web server

echo "🚀 Starting RIAM Accordo AI Demo..."
echo ""

# Start API server in background
echo "Starting API server on port 3000..."
node api-server.js &
API_PID=$!

# Wait for API to start
sleep 2

# Start web server
echo "Starting web server on port 8000..."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Demo is ready!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🌐 Open in browser: http://localhost:8000/landing-page.html"
echo ""
echo "Press Ctrl+C to stop both servers"
echo ""

# Trap Ctrl+C to kill both processes
trap "kill $API_PID; exit" INT

python3 -m http.server 8000
