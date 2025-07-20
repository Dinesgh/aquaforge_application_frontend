# AquaForge Frontend

This is the frontend-only package for the AquaForge application. It contains all the Flutter code needed to run the web and mobile interfaces.

## Connection to Backend API

This frontend is designed to connect to the AquaForge backend API. By default, it will try to connect to:

- Development: `http://localhost:8000`
- Production: `https://api.aquaforge.example.com` (Configure this in the app_config.dart file)

## Setup Instructions

1. **Install Flutter:**
   - Follow the instructions at [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
   - Run `flutter doctor` to verify your installation

2. **Get dependencies:**
   ```
   flutter pub get
   ```

3. **Configure the API endpoint:**
   - Open `lib/config/app_config.dart`
   - Update the `apiBaseUrl` for production to point to your backend API

4. **Configure Google Maps API Key:**
   - Open `lib/services/mock_location_service.dart`
   - Update the Google Maps API Key in the `getMapsApiKey()` method
   - For Android, update the key in `android/app/src/main/AndroidManifest.xml`
   - For iOS, update the key in `ios/Runner/AppDelegate.swift`

## Running the App

### For Web:
```
flutter run -d chrome
```

### For Mobile Emulator:
```
flutter run
```

### Build for Production Web:
```
flutter build web --release
```

## Project Structure

- `assets/` - Contains images and other static assets
- `lib/` - The main Flutter code
  - `config/` - Configuration files
  - `models/` - Data models
  - `screens/` - UI screens
  - `services/` - API and business logic services
  - `widgets/` - Reusable UI components
- `web/` - Web-specific files

## Features

- User authentication
- Device location tracking with Google Maps
- Sensor data visualization
- Dashboard for monitoring devices

## Important Notes

- This is a frontend-only package. The backend API needs to be running separately.
- The mock services will be used if the API connection fails.
- For full functionality, make sure the backend API is properly configured and accessible.
