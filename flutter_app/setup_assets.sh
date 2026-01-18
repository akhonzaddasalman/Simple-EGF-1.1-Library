#!/bin/bash

# Setup script for EGF Reader Flutter app
# This script copies the web application files to the Flutter assets folder

echo "Setting up EGF Reader Flutter assets..."

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$( cd "$SCRIPT_DIR/.." && pwd )"

# Create assets/web directory
mkdir -p "$SCRIPT_DIR/assets/web"

# Copy web files
echo "Copying web files from parent directory..."

cp "$PARENT_DIR/index.html" "$SCRIPT_DIR/assets/web/"
cp "$PARENT_DIR/app.js" "$SCRIPT_DIR/assets/web/"
cp "$PARENT_DIR/style.css" "$SCRIPT_DIR/assets/web/"
cp "$PARENT_DIR/i18n.js" "$SCRIPT_DIR/assets/web/"
cp "$PARENT_DIR/jszip.min.js" "$SCRIPT_DIR/assets/web/"

echo "Files copied successfully!"
echo ""
echo "Asset files:"
ls -la "$SCRIPT_DIR/assets/web/"

echo ""
echo "Setup complete! You can now run:"
echo "  flutter pub get"
echo "  flutter run"
