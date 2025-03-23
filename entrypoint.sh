#!/bin/bash
set -e

echo "Starting Jekyll setup..."

# Install dependencies from the Gemfile in the mounted directory
echo "Installing Ruby dependencies..."
bundle install

# Check if package.json exists and build JavaScript assets
if [ -f "package.json" ]; then
    echo "Installing Node.js dependencies..."
    npm install
    
    echo "Building JavaScript assets..."
    npm run build
fi

# Start Jekyll server
echo "Starting Jekyll server..."
exec bundle exec jekyll serve --host 0.0.0.0
