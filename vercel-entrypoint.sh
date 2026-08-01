#!/bin/sh

# Vercel-specific entrypoint script
# Handles ephemeral filesystem and environment setup

echo "Starting new-api on Vercel..."
echo "PORT: ${PORT:-not set}"
echo "SQL_DSN: ${SQL_DSN:+configured}"

# If no SQL_DSN is set, use SQLite in /tmp (only writable directory on Vercel)
if [ -z "$SQL_DSN" ]; then
    echo "WARNING: No SQL_DSN set, using SQLite in /tmp directory"
    echo "Note: Data will be lost on each deployment!"
    export SQL_DSN="/tmp/new-api.db"
fi

# Ensure data directory exists and is writable
mkdir -p /data /tmp
cd /data

# Start the application
echo "Launching application..."
exec /new-api
