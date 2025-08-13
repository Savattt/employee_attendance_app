# 🖥️ Laptop Setup Guide

## Quick Transfer to Your Laptop

### **Option 1: Using Git (Recommended)**

1. **On your laptop, open terminal/command prompt**
2. **Navigate to where you want the project**
   ```bash
   cd C:\Users\YourName\Documents\Flutter Projects
   ```

3. **Clone the project**
   ```bash
   git clone https://github.com/yourusername/employee_attendance_app.git
   cd employee_attendance_app
   ```

4. **Install dependencies**
   ```bash
   flutter pub get
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

### **Option 2: Copy Files (Simple)**

1. **Copy the entire folder** from your PC to laptop
2. **Open terminal in the project folder**
3. **Run:**
   ```bash
   flutter pub get
   flutter run
   ```

## 🔧 Required Software on Laptop

### **Must Have:**
- ✅ **Flutter SDK** (latest version)
- ✅ **Android Studio** or **VS Code**
- ✅ **Android Emulator** or **Physical Device**
- ✅ **Git** (for Option 1)

### **Optional:**
- 🔄 **Laravel** (if you want to test the API)
- 🔄 **PHP** (for Laravel backend)

## 📱 Firebase Setup

### **The app uses Firebase, so you need:**

1. **Firebase Project** (same as PC)
2. **google-services.json** (Android)
3. **GoogleService-Info.plist** (iOS)

### **If you don't have these:**
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project or use existing one
3. Add Android/iOS app
4. Download config files
5. Place them in the correct folders

## 🚀 Quick Test

1. **Run the app:**
   ```bash
   flutter run
   ```

2. **Test features:**
   - ✅ Login/Register
   - ✅ Leave requests
   - ✅ Dashboard navigation
   - ✅ QR scanner (if you have camera)

## 🔄 Current Status

- **Firebase**: ✅ Working (no setup needed)
- **Laravel**: 🔄 Optional (for future use)
- **App**: ✅ Ready to run

## 📋 Troubleshooting

### **If you get errors:**

1. **Flutter not found:**
   ```bash
   flutter doctor
   ```

2. **Dependencies missing:**
   ```bash
   flutter clean
   flutter pub get
   ```

3. **Firebase issues:**
   - Check if `google-services.json` is in `android/app/`
   - Verify Firebase project settings

## 🎯 You're Ready!

The app should work immediately on your laptop with Firebase backend. No server setup needed!
