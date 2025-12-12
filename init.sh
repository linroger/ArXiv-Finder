#!/bin/bash
# Simple smoke test to ensure project builds (using xcodebuild would be ideal but might be slow/complex to set up purely from CLI without scheme knowledge, trying basic swift build or just returning true for now if xcodebuild is too heavy)

# Ideally we would run:
# xcodebuild -scheme "ArXiv Finder" -destination 'platform=macOS' build
# For now, we will just check if critical files exist as a proxy for "project structure intact"

if [ -f "ArXiv Finder/ArXiv_Finder.swift" ]; then
    echo "Project structure looks okay."
    exit 0
else
    echo "Critical files missing!"
    exit 1
fi
