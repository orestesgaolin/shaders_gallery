#!/bin/bash

# Flutter Web Build Script for GitHub Pages
# This script builds the Flutter web app and sets up the necessary files for SPA routing on GitHub Pages

echo "Building Flutter web app for GitHub Pages..."

# Build the Flutter web app with the correct base href
flutter build web --base-href="/shaders_gallery/"

# Copy the 404.html file to the build directory
echo "Copying 404.html to build directory..."
cp web/404.html build/web/404.html

# Create .nojekyll file to disable Jekyll processing on GitHub Pages
echo "Creating .nojekyll file..."
touch build/web/.nojekyll

echo "Build complete! The files in build/web/ are ready for deployment to GitHub Pages."
echo ""
echo "To deploy:"
echo "1. Copy all files from build/web/ to your GitHub Pages repository"
echo "2. Make sure your repository settings point to the correct branch/folder"
echo "3. Your site will be available at: https://roszkowski.dev/shaders_gallery/"
