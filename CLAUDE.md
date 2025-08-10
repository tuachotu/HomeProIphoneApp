# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

### Build and Run
- **Build in Xcode**: `⌘+B` (or Product → Build)
- **Run in Simulator**: `⌘+R` (or Product → Run)  
- **Clean Build**: `⌘+Shift+K` (or Product → Clean Build Folder)
- **Archive for Release**: Product → Archive (for App Store/TestFlight builds)

### Testing
- **Run Unit Tests**: `⌘+U` (or Product → Test)
- **Run Specific Test**: Use Xcode Test Navigator
- Test targets: `HomeProIphoneAppTests` and `HomeProIphoneAppUITests`

### Dependencies
- **Add Swift Package**: File → Add Package Dependencies
- Firebase SDK is managed via Swift Package Manager
- **Current dependencies**: 
  - Firebase iOS SDK (v12.0.0) - includes FirebaseAuth and FirebaseCore
  - All transitive dependencies are automatically resolved via Package.resolved
- **Package Manager**: Uses Xcode's integrated Swift Package Manager (no CocoaPods or Carthage)

## Architecture Overview

This is a SwiftUI iOS app with Firebase authentication and custom backend integration. The app follows MVVM architecture patterns with ObservableObject managers.

### Key Components

#### Authentication Flow
- **AuthenticationManager**: Centralized Firebase auth state management with backend token validation
- **Entry Point**: `AuthenticationView` handles the main auth flow logic
- **Persistence**: Firebase automatically handles login persistence across app launches
- **Backend Integration**: Custom API validates Firebase tokens and returns user roles

#### Design System
- **Centralized Styling**: `DesignSystem.swift` contains all colors, typography, spacing, and reusable modifiers
- **Color Palette**: Light neutrals (off-white, pale gray) with soft blue accents
- **UI Patterns**: Card-based layouts with subtle shadows and rounded corners
- **Modifiers**: `.cardStyle()`, `.inputFieldStyle()`, `.primaryButtonStyle()`, `.secondaryButtonStyle()`

#### API Layer
- **APIService**: Singleton pattern for backend communication
- **Backend URL**: `https://home-owners.tech/api`
- **Authentication**: Bearer token-based with Firebase ID tokens
- **Error Handling**: Comprehensive error enum with localized descriptions

#### Data Models
- **BackendUser**: User profile data from custom backend (id, name, roles)
- **Home**: Home data with address, role, timestamps, and stats
- **HomeStats**: Statistics (total items, photos, emergency items)
- **Photo**: Photo data with pre-signed S3 URLs and metadata
- **Role System**: "homeowner" role detection and display
- **APIError**: Structured error handling for network operations

### Project Structure
```
HomeProIphoneApp/
├── HomeProIphoneAppApp.swift       # App entry point with Firebase initialization
├── AuthenticationManager.swift     # Firebase + backend auth state + homes management
├── APIService.swift                # Backend API client (login, homes, photos)
├── UserModel.swift                 # Data models (BackendUser, Home, HomeStats, Photo) and errors
├── DesignSystem.swift             # UI system (colors, fonts, modifiers)
├── AuthenticationView.swift       # Main auth flow controller
├── LoginView.swift                # Login form UI
├── WelcomeView.swift             # Post-login dashboard with homes display
├── HomeCardView.swift            # Individual home card component with photos
├── PasswordResetView.swift       # Password reset flow
├── InviteOnlyView.swift          # Beta access messaging
├── HouseIconView.swift           # Reusable icon component
├── ImageCacheManager.swift       # Smart image caching system
├── CachedAsyncImage.swift        # Cached AsyncImage component
├── DeveloperModeGesture.swift    # Hidden developer mode activation
├── DeveloperSettingsView.swift   # Developer settings panel with cache management
├── ThreeFingerGesture.swift      # Alternative developer mode trigger
├── SignUpView.swift              # Unused signup form
└── ContentView.swift             # Legacy view (not used)
```

### Firebase Configuration
- **Bundle ID**: `info.vikrant.HomeProIphoneApp`
- **GoogleService-Info.plist**: Must be present in project root
- **Required Services**: Authentication (Email/Password)
- **Initialization**: Handled in `HomeProIphoneAppApp.swift`

### Backend API Details
- **Base URL**: `https://home-owners.tech/api`
- **Authentication**: All endpoints require `Authorization: Bearer <firebase-id-token>` header

#### Endpoints:
- **Login**: GET `/api/users/login`
  - Response: User object with id, name, and roles
- **Get Homes**: GET `/api/homes?userId={userId}`
  - Response: Array of homes with stats (total items, photos, emergency items)
- **Get Photos**: GET `/api/photos?homeId={homeId}`
  - Response: Array of photos with pre-signed S3 URLs (valid for 1 hour)

## Development Notes

### Authentication State Management
The app uses Firebase Auth for primary authentication, then validates tokens with a custom backend. The `AuthenticationManager` publishes both Firebase and backend user states, allowing views to react to authentication changes.

### Design Principles
- Clean, professional interface optimized for iPhone
- Consistent spacing and typography via design system
- Card-based layouts with subtle visual hierarchy
- Soft blue color scheme with light neutral backgrounds

### Error Handling
Comprehensive error handling across authentication and API layers with user-friendly error messages. Network errors, decoding failures, and authentication issues are all handled gracefully.

### Bundle Identifier
- **Current**: `info.vikrant.HomeProIphoneApp` (development)
- **Production**: `com.homeownerstech.homepro` (as noted in README.md)
- Update this when switching between development and production builds

## Developer Features

### Hidden Developer Mode
The app includes a hidden developer settings panel accessible via secret gestures:

- **Primary Activation**: Tap anywhere on the screen 7 times rapidly (within 1 second intervals)
- **Alternative**: Three-finger simultaneous tap (implemented via `ThreeFingerGesture.swift`)
- **Features**: 
  - Change API base URL dynamically
  - Quick presets for Production, Home Owners Tech, and Local Development
  - Custom URL input with validation
  - Persistent storage of URL changes
  - Image cache size monitoring and clearing
  - Real-time cache statistics display
- **Location**: Available on both login screen and main app
- **Haptic Feedback**: Triple vibration when successfully activated
- **Security**: Hidden from production users, no UI indicators

### API URL Configuration
- **Default URL**: `https://home-owners.tech/api`
- **Storage**: Settings persist across app launches via UserDefaults
- **Validation**: URLs are validated before being applied
- **Reset**: Can reset to default URL from developer panel

## Key Implementation Details

### ObservableObject State Management
- **AuthenticationManager**: Uses `@Published` properties for reactive UI updates
- **APIService**: Singleton pattern with dynamic base URL configuration
- **State Flow**: Firebase Auth → Backend validation → Home data loading

### Design System Architecture
- **Centralized Constants**: Colors, typography, and spacing defined in `DesignSystem.swift`
- **Reusable Modifiers**: `.cardStyle()`, `.primaryButtonStyle()`, etc.
- **Color Scheme**: Light neutrals with soft blue accents for professional appearance

### Error Handling Patterns
- **Comprehensive APIError enum**: Covers network, decoding, and authentication failures
- **User-friendly messages**: Localized error descriptions for better UX
- **Graceful degradation**: Fallbacks for network failures and missing data

### Image Caching Architecture
- **Dual-layer Caching**: Memory cache (NSCache) + disk storage for optimal performance
- **Smart Cache Management**: 50MB memory limit, 100 image count limit with automatic cleanup
- **MD5-based Keys**: URL hashing for consistent cache key generation
- **Background Downloads**: Async image downloading with proper error handling
- **Developer Tools**: Integrated cache monitoring and management in developer settings

### Debug Logging System
- **Comprehensive Coverage**: All major app flows include detailed logging
- **Emoji Prefixes**: Easy visual identification of log categories (🔐 auth, 🏠 homes, 📸 photos, etc.)
- **Request/Response Logging**: Complete API interaction visibility
- **Performance Monitoring**: Cache hit/miss tracking and image loading times
- **Error Diagnostics**: Detailed error information with raw data for troubleshooting

## System Requirements

### Development Environment
- **Xcode**: 15.0+ (required for iOS 17+ deployment targets)
- **iOS Deployment Target**: 16.0+ 
- **Swift Version**: 5.9+
- **macOS**: Required for Xcode and iOS development

### Runtime Requirements
- **iOS**: 16.0+
- **Device Support**: iPhone only (optimized for iPhone 12+ screen sizes)
- **Orientation**: Portrait only
- **Network**: Internet connection required for Firebase auth and API calls