# 🏠 HomePro iOS App

> The trusted friend your home always needed

HomePro is a private beta iOS application designed to be the ultimate home management companion. Built with SwiftUI and powered by Firebase, it provides homeowners with a seamless way to manage their property and connect with trusted professionals.

## ✨ Features

### 🔐 Authentication
- **Firebase Integration**: Secure email/password authentication
- **Backend API**: Custom backend integration with role-based access
- **Login Persistence**: Seamless session management across app launches
- **Invite-Only System**: Private beta with invite management
- **API Configuration**: Dynamic base URL switching via hidden developer mode

### 🎨 Design System
- **Modern UI**: Clean, professional interface with SwiftUI
- **Light Neutrals**: Off-white and pale gray color palette
- **Soft Blue Accents**: Primary brand colors throughout
- **Responsive Design**: Optimized for iPhone 12+ screen sizes
- **Collapsible Sections**: Expandable UI elements for better UX

### 🏠 Home Management
- **Home Display**: View all user homes with statistics
- **Photo Integration**: Home photos with pre-signed S3 URLs
- **Statistics Dashboard**: Track items, photos, and emergency alerts per home
- **Role-Based Access**: Owner/Guest/Manager role display

### 🏡 User Experience
- **Role-Based Interface**: Customized experience for Home Owners
- **Profile Management**: User information and preferences
- **Home Cards**: Visual home display with photos and statistics
- **Image Caching**: Smart image caching for instant photo loading
- **Comprehensive Logging**: Detailed activity logging for debugging
- **Future Features Preview**: Expandable sections showing upcoming functionality

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 16.0+
- Swift 5.9+
- Firebase account

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd HomeProIphoneApp
   ```

2. **Install Firebase SDK**
   - Open project in Xcode
   - File → Add Package Dependencies
   - Add: `https://github.com/firebase/firebase-ios-sdk`
   - Select: `FirebaseAuth` and `FirebaseCore`

3. **Configure Firebase**
   - Ensure `GoogleService-Info.plist` is in the project
   - Verify bundle identifier matches Firebase configuration

4. **Build and Run**
   ```bash
   # Clean build
   ⌘+Shift+K
   
   # Build and run
   ⌘+R
   ```

## 🏗️ Architecture

### Project Structure
```
HomeProIphoneApp/
├── 📱 App/
│   ├── HomeProIphoneAppApp.swift          # App entry point
│   └── ContentView.swift                  # Legacy content view
├── 🔐 Authentication/
│   ├── AuthenticationManager.swift        # Firebase auth manager
│   ├── AuthenticationView.swift          # Main auth flow
│   ├── LoginView.swift                   # Login screen
│   ├── SignUpView.swift                  # Sign up screen (unused)
│   ├── PasswordResetView.swift           # Password reset
│   └── InviteOnlyView.swift             # Invite-only popup
├── 🏠 Dashboard/
│   ├── WelcomeView.swift                 # Post-login dashboard
│   └── HomeCardView.swift                # Individual home display component
├── 🎨 Design System/
│   ├── DesignSystem.swift                # Colors, typography, spacing
│   └── HouseIconView.swift               # Reusable icon component
├── 🖼️ Image Management/
│   ├── ImageCacheManager.swift           # Smart image caching system
│   └── CachedAsyncImage.swift            # Cached AsyncImage component
├── 🌐 API/
│   ├── APIService.swift                  # Backend API client
│   └── UserModel.swift                   # Data models
├── 🛠️ Developer Tools/
│   ├── DeveloperSettingsView.swift       # Developer settings panel
│   ├── DeveloperModeGesture.swift        # Tap-based gesture detection
│   └── ThreeFingerGesture.swift          # Multi-touch gesture detection
└── 📱 Assets/
    └── Assets.xcassets/                  # App icons and images
```

### Key Components

#### AuthenticationManager
- Manages Firebase authentication state
- Handles backend API integration
- Provides login persistence
- Publishes user state changes

#### Design System
- Centralized color palette and typography
- Reusable UI components and modifiers
- Consistent spacing and corner radius values
- Brand-aligned visual elements

#### API Integration
- Firebase token-based backend authentication
- User role management (Home Owner detection)
- Error handling and loading states
- Structured API response models
- Comprehensive request/response logging

#### Image Management
- Smart caching system with memory and disk storage
- Automatic cache size management (50MB memory limit)
- Pre-signed S3 URL handling with 1-hour expiry
- Instant loading for previously cached images
- Developer tools for cache monitoring and clearing

## 🔧 Configuration

### Firebase Setup
1. Create Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add iOS app with bundle identifier: `com.homeownerstech.homepro`
3. Download `GoogleService-Info.plist` and add to project
4. Enable Authentication → Email/Password in Firebase Console

### Backend API
- **Base URL**: `https://home-owners.tech/api` (configurable)
- **Authentication**: Firebase JWT tokens required for all endpoints

#### Available Endpoints:
- **Login**: `GET /api/users/login`
  - Returns user profile with id, name, and roles
- **Get Homes**: `GET /api/homes?userId={userId}`
  - Returns array of user homes with statistics
- **Get Photos**: `GET /api/photos?homeId={homeId}`
  - Returns home photos with pre-signed S3 URLs (1-hour expiry)

### App Icon
- Located in `Assets.xcassets/AppIcon.appiconset/`
- Includes all required iOS icon sizes
- Features HomePro brand design

## 🎨 Design Guidelines

### Color Palette
- **Background**: Light neutrals (#F8F9FA, #F5F5F7)
- **Cards**: Pure white (#FFFFFF)
- **Primary**: Soft blue (#5691E3)
- **Secondary**: Light blue (#DDE7F6)
- **Text**: Hierarchical grays

### Typography
- **System Font**: SF Pro with custom weights
- **Hierarchy**: Large title → Title → Headline → Body → Caption
- **Weights**: Light for elegance, Medium for emphasis

### UI Patterns
- **Cards**: Subtle shadows with rounded corners
- **Buttons**: Primary (filled) and Secondary (outline) styles
- **Forms**: Clean input fields with proper spacing
- **Icons**: Simple line icons (SF Symbols)

## 📱 Current Features

### Authentication & Home Loading Flow
1. **Login Screen**: Email/password with Firebase authentication
2. **Backend Verification**: Token validation with role detection
3. **Home Loading**: Automatic fetching of user's homes after login
4. **Photo Loading**: Asynchronous loading of home photos with S3 URLs
5. **Welcome Dashboard**: Personalized experience with home display
6. **Invite System**: Private beta access control

### User Experience
- **Login Persistence**: Automatic sign-in on app launch
- **Role Recognition**: "Home Owner" status display
- **Profile Management**: Expandable user information
- **Home Management**: Visual home cards with photos and statistics
- **Photo Display**: AsyncImage loading with fallback placeholders
- **Statistics Tracking**: Items, photos, and emergency alerts per home
- **Feature Preview**: Collapsible upcoming features section
- **Developer Mode**: Hidden settings panel for API configuration
- **Smart Image Caching**: Intelligent caching with memory and disk storage
- **Debug Logging**: Comprehensive activity logging throughout the app
- **Cache Management**: Developer tools for monitoring and clearing image cache

## 🔮 Upcoming Features

### Service Management
- **Service Requests**: Book home maintenance services
- **Project Tracking**: Manage home improvement projects
- **Maintenance Calendar**: Schedule recurring tasks
- **Professional Network**: Connect with verified contractors

### Enhanced UX
- **Dark Mode**: Full dark theme support
- **Notifications**: Smart reminders and updates
- **Offline Mode**: Core functionality without internet
- **Advanced Search**: Find services and professionals
- **Photo Management**: Upload and manage home photos
- **Home Items**: Detailed home inventory management
- **Support Requests**: Service request lifecycle management

## 🧪 Testing

### Manual Testing
1. **Authentication**: Test login, logout, and persistence
2. **API Integration**: Verify backend communication and all endpoints
3. **Home Loading**: Test home fetching and photo display
4. **Image Caching**: Verify images load instantly on subsequent views
5. **UI Responsiveness**: Test on different screen sizes
6. **Error Handling**: Validate error states and messages
7. **Developer Mode**: Test gesture activation and URL switching
8. **Debug Logging**: Check Xcode console for detailed activity logs
9. **Cache Management**: Test cache size monitoring and clearing functionality

### Test Accounts
- Use Firebase Authentication console to create test users
- Ensure test users exist in backend system
- Verify role assignments (Home Owner status)

## 🚀 Deployment

### Development
- **Simulator**: Use Xcode simulator for development
- **Device**: Install via Xcode for device testing
- **TestFlight**: Coming soon for beta testing
- **API Environments**: Use developer mode to switch between environments

### Developer Features
- **Hidden Developer Mode**: 7 rapid taps or 3-finger simultaneous tap to access settings
- **API URL Configuration**: Switch between production, staging, and local environments
- **Environment Presets**: Quick selection of common API endpoints
- **Image Cache Management**: Monitor cache size and clear cached images
- **Debug Console**: Comprehensive logging with emoji prefixes for easy identification
- **Real-time Monitoring**: Live cache size updates and activity tracking

### Production
- **App Store**: Ready for App Store submission
- **Bundle ID**: `com.homeownerstech.homepro`
- **Requirements**: iOS 16.0+, iPhone only

## 📞 Contact & Support

### Invite Requests
- **Twitter**: [@vikkrraant](https://twitter.com/vikkrraant)
- **Method**: Follow and send DM for beta access

### Development
- **Lead Developer**: Vikrant Singh
- **Platform**: iOS (SwiftUI)
- **Backend**: Node.js with Firebase

## 📄 License

Private beta software. All rights reserved.

---

**HomePro** - The trusted friend your home always needed. 🏠✨