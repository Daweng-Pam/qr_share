import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn(
  clientId: '1098265368760-t863oof5daid523f5tflcm1fm09kufcu.apps.googleusercontent.com',
  scopes: [
    'email',
    'profile',
    'openid',
    'https://www.googleapis.com/auth/contacts.readonly',
    "https://www.googleapis.com/auth/userinfo.profile"
  ],
);

