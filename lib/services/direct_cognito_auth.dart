import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

// A direct implementation to test AWS Cognito authentication with SECRET_HASH
class DirectCognitoAuth {
  final String userPoolId = 'us-east-1_VBU5vSzoh';
  final String clientId = '7iqtgp2u4esgc5ts56pqmjft4b';
  final String clientSecret = 'nja1jtili5jc2101u2s8gok0bbhmii809a848io0lc2hrb2qb8d';
  final String region = 'us-east-1';
  
  String _calculateSecretHash(String username) {
    final String message = username + clientId;
    final key = utf8.encode(clientSecret);
    final bytes = utf8.encode(message);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);
    return base64.encode(digest.bytes);
  }
  
  Future<Map<String, dynamic>> signUp(String username, String password, String email) async {
    final secretHash = _calculateSecretHash(username);
    
    final url = Uri.parse(
      'https://cognito-idp.$region.amazonaws.com/',
    );
    
    final body = {
      'ClientId': clientId,
      'Username': username,
      'Password': password,
      'SecretHash': secretHash,
      'UserAttributes': [
        {
          'Name': 'email',
          'Value': email,
        },
      ],
    };
    
    final response = await http.post(
      url,
      headers: {
        'X-Amz-Target': 'AWSCognitoIdentityProviderService.SignUp',
        'Content-Type': 'application/x-amz-json-1.1',
      },
      body: json.encode(body),
    );
    
    return json.decode(response.body);
  }
}
