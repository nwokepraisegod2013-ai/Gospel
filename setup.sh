#!/bin/bash
# Gospel Backend + Flutter Integration Setup Script
# This script sets up both backend and frontend for local development

echo ""
echo "============================================="
echo "Gospel Platform - Local Development Setup"
echo "============================================="
echo ""

# Check if running from Gospel folder
if [ ! -f "pubspec.yaml" ]; then
    echo "Error: Run this script from the Gospel folder root"
    exit 1
fi

echo "Step 1: Installing Flutter dependencies..."
flutter pub get
if [ $? -ne 0 ]; then
    echo "Failed to get Flutter dependencies"
    exit 1
fi
echo "✓ Flutter dependencies installed"

echo ""
echo "Step 2: Checking GospelBackend location..."
if [ ! -f "../GospelBackend/package.json" ]; then
    echo "Error: GospelBackend not found at ../GospelBackend"
    echo "Please ensure GospelBackend folder exists on Desktop"
    exit 1
fi
echo "✓ GospelBackend found"

echo ""
echo "============================================="
echo "Setup Complete!"
echo "============================================="
echo ""
echo "Next steps:"
echo ""
echo "1. Start the backend (in another terminal):"
echo "   cd ../GospelBackend"
echo "   npm run dev"
echo ""
echo "2. Run the Flutter app:"
echo "   flutter run -d chrome        (for web)"
echo "   flutter run                  (for device/emulator)"
echo ""
echo "3. Backend will be available at:"
echo "   http://localhost:3000"
echo ""
echo "Documentation:"
echo "   See BACKEND_INTEGRATION.md for detailed setup"
echo ""
