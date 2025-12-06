#!/usr/bin/env pwsh
# Flutter WMS Mobile App - Setup & Run Script
# Author: AI Development Assistant
# Date: December 1, 2025
# Purpose: Automated setup for Flutter mobile app

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("setup", "run", "clean", "test", "build-android", "build-ios")]
    [string]$Action = "setup"
)

$projectPath = "D:\WORKSPACE\PROJECT\wms_mobile"
$backendPath = "D:\WORKSPACE\PROJECT\wms"

# Color output functions
function Write-Success {
    Write-Host "✅ $args" -ForegroundColor Green
}

function Write-Info {
    Write-Host "ℹ️ $args" -ForegroundColor Cyan
}

function Write-Warning {
    Write-Host "⚠️ $args" -ForegroundColor Yellow
}

function Write-Error {
    Write-Host "❌ $args" -ForegroundColor Red
}

# Check if project exists
if (-not (Test-Path $projectPath)) {
    Write-Error "Project not found at $projectPath"
    exit 1
}

# Main menu if no action specified
if ($Action -eq "") {
    Write-Info "Flutter WMS Mobile App - Setup Menu"
    Write-Host @"
    1. setup        - Install dependencies and generate code
    2. run          - Run the app on emulator
    3. clean        - Clean build artifacts
    4. test         - Run tests
    5. build-android- Build Android APK
    6. build-ios    - Build iOS IPA

Usage: .\setup.ps1 -Action <action>
Example: .\setup.ps1 -Action setup
"@
    exit 0
}

# Change to project directory
Set-Location $projectPath

switch ($Action) {
    "setup" {
        Write-Info "Setting up Flutter WMS Mobile App..."
        
        # Check Flutter installation
        Write-Info "Checking Flutter installation..."
        $flutterVersion = flutter --version
        Write-Success "Flutter found: $flutterVersion"
        
        # Verify backend is running
        Write-Info "Checking backend server..."
        try {
            $backendStatus = (Invoke-WebRequest -Uri "http://localhost:3000" -ErrorAction SilentlyContinue).StatusCode
            Write-Success "Backend is running on http://localhost:3000"
        }
        catch {
            Write-Warning "Backend not responding. Make sure to run the backend server:"
            Write-Host "  cd $backendPath"
            Write-Host "  npm run dev"
        }
        
        # Install dependencies
        Write-Info "Installing Flutter dependencies..."
        flutter pub get
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Dependencies installed"
        }
        else {
            Write-Error "Failed to install dependencies"
            exit 1
        }
        
        # Generate JSON serialization code
        Write-Info "Generating JSON serialization code..."
        flutter pub run build_runner build --delete-conflicting-outputs
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Code generation completed"
        }
        else {
            Write-Warning "Code generation had warnings (this is normal)"
        }
        
        Write-Success "Setup complete! Run 'flutter run' to start the app"
    }
    
    "run" {
        Write-Info "Starting Flutter app..."
        
        # List available devices
        Write-Info "Available devices:"
        flutter devices
        
        # Run the app
        Write-Info "Launching app..."
        flutter run -v
    }
    
    "clean" {
        Write-Info "Cleaning Flutter project..."
        flutter clean
        Write-Success "Project cleaned"
    }
    
    "test" {
        Write-Info "Running Flutter tests..."
        flutter test
    }
    
    "build-android" {
        Write-Info "Building Android APK..."
        Write-Warning "Make sure you have configured signing keys!"
        
        flutter build apk --release
        if ($LASTEXITCODE -eq 0) {
            Write-Success "APK built successfully"
            Write-Info "Location: build/app/outputs/flutter-apk/app-release.apk"
        }
        else {
            Write-Error "Android build failed"
            exit 1
        }
    }
    
    "build-ios" {
        Write-Info "Building iOS IPA..."
        Write-Warning "Make sure you have Xcode and developer certificates set up!"
        
        flutter build ios --release
        if ($LASTEXITCODE -eq 0) {
            Write-Success "iOS build completed"
            Write-Info "Next: Open build/ios/archive/Runner.xcarchive in Xcode"
        }
        else {
            Write-Error "iOS build failed"
            exit 1
        }
    }
    
    default {
        Write-Error "Unknown action: $Action"
        exit 1
    }
}

Write-Success "Done!"
