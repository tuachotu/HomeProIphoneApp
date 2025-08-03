# HomePro App Icon Setup Guide

## 🎯 You Need These Icon Sizes:

| Size | Filename | Dimensions |
|------|----------|------------|
| 20pt @2x | `20.png` | 40×40 px |
| 20pt @3x | `20@3x.png` | 60×60 px |
| 29pt @2x | `29.png` | 58×58 px |
| 29pt @3x | `29@3x.png` | 87×87 px |
| 40pt @2x | `40.png` | 80×80 px |
| 40pt @3x | `40@3x.png` | 120×120 px |
| 60pt @2x | `60@2x.png` | 120×120 px |
| 60pt @3x | `60@3x.png` | 180×180 px |
| App Store | `1024.png` | 1024×1024 px |

## 🎨 Icon Design:
- **Background**: Black circle
- **Icon**: White house symbol (like in your app)
- **Style**: Clean, simple, matches your house icon in the app

## 📱 How to Add Icons to Xcode:

### Option 1: Quick Method (Use a Single 1024×1024 Image)
1. Create ONE icon: **1024×1024 pixels**
2. Open Xcode → Your Project
3. Navigate to: `Assets.xcassets` → `AppIcon`
4. Drag your 1024×1024 icon to the **App Store** slot
5. Xcode will auto-generate other sizes!

### Option 2: Manual Method (Add Each Size)
1. Create all the icon sizes listed above
2. Save them in a folder with exact filenames
3. Open Xcode → `Assets.xcassets` → `AppIcon`
4. Drag each file to its corresponding slot

## 🛠️ Tools to Create Icons:

### Online Tools (Easiest):
- **Canva**: Create 1024×1024 black circle with white house
- **Figma**: Vector-based design
- **Icon Generator**: Upload 1024×1024, get all sizes

### Desktop Apps:
- **Sketch**: Professional design tool
- **Photoshop**: Create all sizes manually
- **GIMP**: Free alternative to Photoshop

## 🎯 Icon Design Template:
```
Black Circle (1024×1024)
├── White House Icon (centered)
├── Padding: ~100px from edges
└── House size: ~400×400px
```

## ✅ After Adding Icons:
1. **Clean Build**: ⌘+Shift+K
2. **Build**: ⌘+B  
3. **Run on Simulator**: Check home screen
4. **Test on Device**: Deploy to see actual icon

## 🔍 Troubleshooting:
- **Icon not showing**: Clean build folder and rebuild
- **Blurry icon**: Ensure each size is pixel-perfect
- **Wrong colors**: Check transparency (should be opaque)