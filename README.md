# 🏠 HomePro iOS App

> The trusted friend your home always needed

HomePro is a private beta iOS application designed to be the ultimate home management companion. Built with SwiftUI and powered by Firebase, it provides homeowners with a seamless way to manage their property and connect with trusted professionals.

## ✨ Features

### 🔐 Authentication
- **Firebase Integration**: Secure email/password authentication
- **Backend API**: Custom backend integration with role-based access
- **Login Persistence**: Seamless session management across app launches
- **Invite-Only System**: Private beta with invite management

### 🎨 Design System
- **Modern UI**: Clean, professional interface with SwiftUI
- **Light Neutrals**: Off-white and pale gray color palette
- **Soft Blue Accents**: Primary brand colors throughout
- **Responsive Design**: Optimized for iPhone 12+ screen sizes
- **Collapsible Sections**: Expandable UI elements for better UX

### 🏡 User Experience
- **Role-Based Interface**: Customized experience for Home Owners
- **Profile Management**: User information and preferences
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
│   └── WelcomeView.swift                 # Post-login dashboard
├── 🎨 Design System/
│   ├── DesignSystem.swift                # Colors, typography, spacing
│   └── HouseIconView.swift               # Reusable icon component
├── 🌐 API/
│   ├── APIService.swift                  # Backend API client
│   └── UserModel.swift                   # Data models
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

## 🔧 Configuration

### Firebase Setup
1. Create Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add iOS app with bundle identifier: `com.homeownerstech.homepro`
3. Download `GoogleService-Info.plist` and add to project
4. Enable Authentication → Email/Password in Firebase Console

### Backend API
- **Endpoint**: `https://home-owners.tech/api/users/login`
- **Method**: GET
- **Headers**: `Authorization: Bearer <firebase-token>`
- **Response**: User profile with role information

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

### Authentication Flow
1. **Login Screen**: Email/password with Firebase
2. **Backend Verification**: Token validation with role detection
3. **Welcome Dashboard**: Personalized user experience
4. **Invite System**: Private beta access control

### User Experience
- **Login Persistence**: Automatic sign-in on app launch
- **Role Recognition**: "Home Owner" status display
- **Profile Management**: Expandable user information
- **Feature Preview**: Collapsible upcoming features section

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

## 🧪 Testing

### Manual Testing
1. **Authentication**: Test login, logout, and persistence
2. **API Integration**: Verify backend communication
3. **UI Responsiveness**: Test on different screen sizes
4. **Error Handling**: Validate error states and messages

### Test Accounts
- Use Firebase Authentication console to create test users
- Ensure test users exist in backend system
- Verify role assignments (Home Owner status)

## 🚀 Deployment

### Development
- **Simulator**: Use Xcode simulator for development
- **Device**: Install via Xcode for device testing
- **TestFlight**: Coming soon for beta testing

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