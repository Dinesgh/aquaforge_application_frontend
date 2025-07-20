#!/usr/bin/env python
"""
API Configuration Script for AquaForge Frontend

This script updates the API endpoint configuration in the AquaForge frontend code.
"""

import os
import sys
import re

CONFIG_FILE_PATH = os.path.join('lib', 'config', 'app_config.dart')

def update_api_endpoint(api_url):
    """Update the API endpoint in the app_config.dart file"""
    if not os.path.exists(CONFIG_FILE_PATH):
        print(f"Error: Could not find configuration file at {CONFIG_FILE_PATH}")
        return False
        
    try:
        # Read the current config file
        with open(CONFIG_FILE_PATH, 'r') as file:
            content = file.read()
            
        # Replace the API URL using regex to handle both http and https
        updated_content = re.sub(
            r"apiBaseUrl = kDebugMode\s*\?\s*'http://localhost:\d+'\s*:\s*'[^']*'",
            f"apiBaseUrl = kDebugMode\n      ? 'http://localhost:8000'\n      : '{api_url}'",
            content
        )
        
        # Write the updated content back
        with open(CONFIG_FILE_PATH, 'w') as file:
            file.write(updated_content)
            
        print(f"Successfully updated API endpoint to: {api_url}")
        return True
    except Exception as e:
        print(f"Error updating API endpoint: {e}")
        return False

def main():
    """Main function"""
    print("AquaForge Frontend - API Configuration Script")
    print("=============================================")
    
    if len(sys.argv) > 1:
        api_url = sys.argv[1]
    else:
        print("Enter the production API URL (e.g., https://api.aquaforge.example.com):")
        api_url = input("> ").strip()
    
    if not api_url:
        print("Error: API URL cannot be empty")
        return
        
    # Validate URL format
    if not (api_url.startswith('http://') or api_url.startswith('https://')):
        print("Warning: API URL should start with 'http://' or 'https://'")
        print("Do you want to add 'https://' prefix? (y/n)")
        add_prefix = input("> ").strip().lower()
        if add_prefix == 'y':
            api_url = 'https://' + api_url
    
    success = update_api_endpoint(api_url)
    
    if success:
        print("\nConfiguration complete!")
        print("\nNext steps:")
        print("1. Run 'flutter pub get' to update dependencies")
        print("2. Test the application with 'flutter run -d chrome'")
    else:
        print("\nConfiguration failed. Please check the error messages above.")

if __name__ == "__main__":
    main()
