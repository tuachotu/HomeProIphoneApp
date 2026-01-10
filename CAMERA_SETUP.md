# Camera Capture Setup Instructions

## Required Configuration

To enable camera capture functionality in the app, you need to add camera permission descriptions to your project.

### Step 1: Add Privacy Descriptions to Info.plist

In Xcode, add the following keys to your `Info.plist`:

#### Method 1: Using Xcode UI
1. Open your project in Xcode
2. Select the **HomeProIphoneApp** target
3. Go to the **Info** tab
4. Click the **+** button to add new keys
5. Add the following:

```
Key: Privacy - Camera Usage Description
Type: String
Value: This app needs access to your camera to take photos of your home items for documentation and reference.
```

#### Method 2: Edit Info.plist as Source Code
1. Right-click on `Info.plist` in Xcode
2. Select **Open As** → **Source Code**
3. Add the following inside the `<dict>` tag:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs access to your camera to take photos of your home items for documentation and reference.</string>
```

### Step 2: Verify Permissions

After adding the permission keys:
1. Clean build folder: `⌘+Shift+K`
2. Build the project: `⌘+B`
3. Run on a device or simulator
4. When you tap "Take Photo", the app should request camera permission

### Important Notes

- **Simulator**: The iOS Simulator does not have a real camera. Camera capture will only work on a physical device.
- **First Launch**: Users will see a permission dialog the first time they try to use the camera
- **Denied Permission**: If users deny permission, they can enable it later in Settings → HomeProIphoneApp → Camera
- **Required Permission**: Camera access is required to use the "Take Photo" feature, but users can still select photos from their library

## Features Added

### 1. Camera Capture (PhotoUploadView)
- **Take Photo** button to capture images directly
- **Choose from Library** button for selecting existing photos
- **Add More** button to capture additional photos after initial selection
- Automatic camera permission handling
- Permission denial redirects to settings

### 2. Permission Management (CameraPermissionView)
- Clear explanation of why camera access is needed
- "Allow Camera Access" button for initial permission request
- "Open Settings" button if permission was denied
- User-friendly error messages for different permission states

### 3. Camera Interface (CameraView)
- Full-screen camera interface
- Automatic image capture
- Seamless integration with existing upload flow

## Testing

### On Physical Device:
1. Build and run on iPhone
2. Navigate to a home item
3. Tap the camera button
4. Grant camera permission when prompted
5. Take a photo
6. Photo should appear in the selected photos grid
7. Upload works the same as library photos

### Permission States to Test:
- **Not Determined**: First time user, should show system dialog
- **Authorized**: Camera opens immediately
- **Denied**: Shows permission explanation with "Open Settings" button
- **Restricted**: Shows explanation that camera is restricted (parental controls)

## Troubleshooting

### "Camera permission denied"
- User must go to Settings → HomeProIphoneApp → Enable Camera
- App provides "Open Settings" button for convenience

### "Camera not available"
- Check that you're running on a physical device, not simulator
- Verify Info.plist has NSCameraUsageDescription key

### Build errors about AVFoundation
- Ensure you're building for iOS 16.0+
- Check that `import AVFoundation` is present in CameraView.swift

## Files Modified/Created

1. **CameraView.swift** (NEW) - Camera capture wrapper for SwiftUI
2. **PhotoUploadView.swift** (MODIFIED) - Added camera capture options
3. **HomeProIphoneApp/Info.plist** (NEEDS UPDATE) - Add camera permission

## Next Steps

After adding camera permissions, you may want to:
1. Test on multiple devices
2. Add photo editing capabilities (crop, rotate)
3. Add flash control for low-light conditions
4. Add front/rear camera switching
5. Add grid overlay for better composition
