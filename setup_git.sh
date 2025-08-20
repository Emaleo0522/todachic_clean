#!/bin/bash

# Setup new git repository for TODAChic Clean with Photo Features
# Version: 1.4.0 (Photos in Sales & Stock)

echo "🚀 Setting up new git repository for TODAChic Clean v1.4.0..."

# Navigate to project directory
cd /home/ema/todachic_clean

# Initialize git repository
git init

# Configure git
git config user.name "emaleo0522"
git config user.email "emaleo0522@gmail.com"

# Rename master to main
git branch -M main

# Add all files
git add .

# Create detailed commit
git commit -m "Initial commit: TODAChic Clean v1.4.0 - Photo Features for Sales & Stock

🆕 NEW FEATURES (v1.4.0):
✅ Product photos in Stock section (create/edit/view products)
✅ Photo thumbnails in Sales product selector 
✅ Photo previews in Sales history
✅ Click-to-zoom image viewer in all sections
✅ Smart compression and Base64 storage
✅ 100% retrocompatible with existing data

📸 PHOTO FUNCTIONALITY:
- Upload photos when creating/editing products
- 64x64px thumbnails in product lists (Stock)
- 56x56px thumbnails in sales selector
- 48x48px circular avatars in sales history  
- Full-size image viewer with click-to-zoom
- Automatic compression and validation
- Support for JPG, PNG, WEBP up to 5MB

🎯 USER BENEFITS:
- Distinguish between similar products visually
- Faster product identification during sales
- Professional visual inventory management
- Complete visual sales history
- Enhanced customer experience

🔧 TECHNICAL IMPROVEMENTS:
- file_picker integration for Flutter Web 2025
- ImageUtils utility for compression and validation
- Enhanced ProductCard with image display
- Updated ProductSelectorDialog with photo support
- Modified SalesScreen with visual history
- Smart product lookup in sales records
- Error handling for corrupted images

📱 COMPATIBILITY:
- Works on desktop web browsers
- Mobile web browser support
- PWA offline functionality
- Cross-platform file picker access
- Native camera/gallery integration

🚀 Ready for production deployment!

Version: 1.4.0+5
Previous stable: 1.3.0+4 (without photos)
Build target: Web (HTML renderer)
Dependencies: file_picker ^8.1.2 added

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# Add remote (will be set manually)
echo "✅ Git repository initialized successfully!"
echo "📋 Next steps:"
echo "1. Create new repository 'todachic_clean_photos' on GitHub"
echo "2. Run: git remote add origin https://github.com/emaleo0522/todachic_clean_photos.git"  
echo "3. Run: git push -u origin main"
echo ""
echo "🎯 This version includes photo features in both Stock and Sales sections!"
echo "📸 Safe to develop alongside stable v1.3.0 version"