// *** IMPORTANT CONFIGURATION INSTRUCTIONS ***
// Since your app client has a client secret, you have two options:
//
// OPTION 1 (RECOMMENDED): Create a new app client without a client secret
// 1. Go to AWS Cognito Console
// 2. Navigate to User Pools > "User pool - stjqez" > App integration > App clients
// 3. Click "Create app client"
// 4. Name it "AquaForgeFlutterNoSecret" 
// 5. IMPORTANT: Uncheck "Generate client secret"
// 6. Complete the setup and replace the AppClientId below with your new client ID
//
// OPTION 2: Keep using client with secret and ensure SECRET_HASH is calculated correctly
// - This is already implemented in auth_service.dart

const amplifyconfig = '''
{
  "UserAgent": "aws-amplify/cli",
  "Version": "0.1.0",
  "auth": {
    "plugins": {
      "awsCognitoAuthPlugin": {
        "UserAgent": "aws-amplify/cli",
        "Version": "0.1.0",
        "IdentityManager": {
          "Default": {}
        },
        "CognitoUserPool": {
          "Default": {
            "PoolId": "us-east-1_VBU5vSzoh", 
            "AppClientId": "7iqtgp2u4esgc5ts56pqmjft4b",
            "Region": "us-east-1"
          }
        },
        "Auth": {
          "Default": {
            "authenticationFlowType": "USER_PASSWORD_AUTH"
          }
        }
      }
    }
  }
}
''';
