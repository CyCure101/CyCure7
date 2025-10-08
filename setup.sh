#!/bin/bash

# CyCure Setup Script
echo "🚀 Setting up CyCure..."

# Check if .env exists
if [ ! -f "server/.env" ]; then
    echo "📝 Creating .env file..."
    cp server/.env.example server/.env
    echo "✅ .env file created"
else
    echo "✅ .env file already exists"
fi

# Start database
echo "🗄️ Starting database..."
docker-compose up -d

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
sleep 10

# Install dependencies
echo "📦 Installing server dependencies..."
cd server && npm install

echo "📦 Installing client dependencies..."
cd ../client && npm install

echo "🎉 Setup complete!"
echo ""
echo "To start the application:"
echo "1. Server: cd server && npm start"
echo "2. Client: cd client && npm run dev"
echo ""
echo "Server will run on http://localhost:3000"
echo "Client will run on http://localhost:5173"
