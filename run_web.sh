#!/bin/bash
# Run Organoid Analysis as a production-style web application (Gunicorn).
# Use this for deployment or when you want multiple workers and no debug mode.

PORT="${PORT:-5174}"
WORKERS="${WORKERS:-2}"

echo "Starting Organoid Analysis (Gunicorn)..."
echo "  Port: $PORT"
echo "  Workers: $WORKERS"
echo "  URL: http://0.0.0.0:$PORT"
echo "  Press Ctrl+C to stop"
echo ""

cd "$(dirname "$0")"
exec gunicorn -w "$WORKERS" -b "0.0.0.0:$PORT" --timeout 300 "app:app"
