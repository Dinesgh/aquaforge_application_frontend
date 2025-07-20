# Frontend Deployment Guide

This guide provides instructions for deploying the AquaForge frontend to various hosting platforms.

## Prerequisites

- Flutter SDK installed
- Configured API endpoint (using `configure_api.py` or manually updating `lib/config/app_config.dart`)
- Google Maps API key (update in `lib/services/mock_location_service.dart`)

## Build for Production

```bash
flutter build web --release
```

This will create a build in the `build/web` directory with all the necessary files for deployment.

## Option 1: Deploy to GitHub Pages

1. Create a new repository on GitHub
2. Initialize Git in your local frontend directory:
   ```
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
   git push -u origin main
   ```

3. Set up GitHub Pages:
   - Go to repository Settings
   - Navigate to Pages
   - Select the branch to deploy from (usually 'main' or 'gh-pages')
   - Choose the folder '/docs' or '/root'
   - Save

4. If using the 'gh-pages' branch approach:
   ```
   # Install gh-pages package
   npm install -g gh-pages

   # Deploy
   gh-pages -d build/web
   ```

## Option 2: Deploy to Firebase Hosting

1. Install Firebase CLI:
   ```
   npm install -g firebase-tools
   ```

2. Login to Firebase:
   ```
   firebase login
   ```

3. Initialize Firebase in your project:
   ```
   firebase init
   ```
   - Select Hosting
   - Select your Firebase project
   - Specify "build/web" as your public directory
   - Configure as a single-page app: Yes
   - Set up automatic builds and deploys with GitHub: No (for now)

4. Deploy to Firebase:
   ```
   firebase deploy
   ```

## Option 3: Deploy to AWS Amplify

1. Set up an AWS account if you don't have one

2. Install the Amplify CLI:
   ```
   npm install -g @aws-amplify/cli
   ```

3. Configure Amplify:
   ```
   amplify configure
   ```

4. Initialize Amplify in your project:
   ```
   amplify init
   ```

5. Add hosting:
   ```
   amplify add hosting
   ```
   - Select "Manual deployment"

6. Publish:
   ```
   amplify publish
   ```

## Option 4: Deploy to Netlify

1. Create a `netlify.toml` file in your project root:
   ```
   [build]
     publish = "build/web"
     command = "flutter build web --release"
   ```

2. Install Netlify CLI:
   ```
   npm install -g netlify-cli
   ```

3. Login to Netlify:
   ```
   netlify login
   ```

4. Deploy:
   ```
   netlify deploy --prod
   ```

## Connecting to Your Backend API

Remember to update the API endpoint in your production build:

1. Use the included script:
   ```
   python configure_api.py https://your-api-endpoint.com
   ```

2. Or manually update in `lib/config/app_config.dart`:
   ```dart
   static const String apiBaseUrl = kDebugMode
      ? 'http://localhost:8000'
      : 'https://your-api-endpoint.com';
   ```

## Post-Deployment Verification

1. Visit your deployed site
2. Verify that the login functionality works
3. Check that the dashboard and maps display correctly
4. Confirm that API calls are reaching your backend server
