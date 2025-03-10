// import 'package:googleapis_auth/auth_io.dart';

// class GetServerKey {
//   Future<String> getServerKey() async {
//     final scopes = [
//       'https://www.googleapis.com/auth/userinfo.email',
//       'http://www.googleapis.com/auth/firebase.database',
//       'https://www.googleapis.com/auth/firebase.messaging',
//     ];
//     final client = await clientViaServiceAccount(
//       ServiceAccountCredentials.fromJson({
//         "type": "service_account",
//         "project_id": "zoomer-af32a",
//         "private_key_id": "d76c685a4eaa989416559cd01a84432f4fc42f3a",
//         "private_key":
//             "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC2HZdj7LoRddJk\nGC+lamf+8KDljHY4pPOB+YAWRAXuiAlqcmdviyTIkemF8ZJgX0rOWeYUYeOwjNfO\nZvRd943RNU3Ed2H1YNRTtV/5y10vSBzpCc0nUBFor4v+Lb/T2xHtOr36g4DTzsz9\nwqmXyqP0Rba0KljIM+TpGGQqdF7R7xOMUaz+03zy7rhx2HWYLA3lSfYCDSLO8QwH\n4fZcMiQZI2SjhT2y+vI1okgVi4rkaoqfp0H5amaMeBR79xYhJQw3kNmnGnp2MME6\ne912rdl8BIkvbobbV2p4VTR1G80QB/YjB5aBmOw/F7AQV8W4pYtiTABhMFoBsfUj\n9xlrrYKpAgMBAAECggEAUBahXjNb/JO5C4XLZk5uH6KIz4o+71gzMmSb3K7bgPPY\nWDSpolcpvP7WGK6M9c7SYf8M/Mezzw+RVFbYfn6AopFzesQZk0Sa+5kW9Q5nE4T+\nGcnSq8g9b7FLumM6Khv8PTyJEaNFQ2B9q9cwp+1YvvLtjzvUQW746z1rx3PXwzBG\n+lzfaXb2O55QKT152kbz2F98HRoVwlLlWlM6TvwznFikYqRUIaKbyFudi+UOi0Sy\nBhvKPF/5u3iUm2lNmHWJBBSDo20eqm6ypM75buu/6Z5rC5sXMaRHyAad0cAbFyNu\nEBslBnLweb3LakaOGS/ZldDvxhGpFFg7bFcyCnzPFQKBgQDqJAXHyWdYaX/vratH\nkPtIwGV8tD18uYwXj3khPYWYzgOz/3r8vObmGSyAGEtziO8YArq51Gx82oNpLk/E\nKvR9Ti9hKtVSRtymEI38jvLM0DVY5I4oitaz52uvxyiypdarNWjQYwxvDgW/aluI\nHxuUIRlWkQGGIwdwmfcfxhSpIwKBgQDHHipJSu6sJfr8d0aZtjYW7jNWIh3lKa9S\nRonaB6e3Nk0ZakoFyXST4Q9SzI98urwuHRJ5c5cmuyn9VR2ZKkrxlLV5X8uXahdi\noI6l5ne9dFp+lzp7dcTols57SZsNoX+rV48T2BN3goBrB5Xk5vwyGEEVSA5cb9Qd\nupucAuPvwwKBgQDQnwwveXsFwermih2lBL+BkTxcItTufv0eOQ462fBhuJ6AEVFq\nRH6P4zpNYFhKN2aiRDxQO7/2d1TDsSoNpiB2TeXVdC7iwpTzuqhoso4QhCwkanFo\nGl03qym+U3wlwbJGlq4vjzGS+jGQ3plz7hPKprtG8Kkk9a05XVZeD0Z1dQKBgE6J\n7W//aGjqijcu7OAQaQFeb01YI6aSbJ7tR86CGns/peWScSQbNCpoKV0lZqtyFGuz\n9+eD2mjihktwWT5i2jCz0WjQikNtC1BRuDJj13MZA+DO0biE2WhMo6EphUk5HFx/\nKuZO4k7PYMvWsB8bpPo1auZ0B4YabfZT9rDwyut1AoGBANj89sr2I5pZkEeiyvvN\n0IGUhxKZz2NhEDYYrMUIar1RpAcPHpLESFGmCsspgXBrOr8hT7UNX3I6k2ITPtig\n1KUNUFxjf+uW5qXU1jUWoGo8R3rcoPZqOFi7wMSEFrAvtEtwU37jlMtL0VhiuDcA\nwVCJNyulnfhAtFdwh1POTXmJ\n-----END PRIVATE KEY-----\n",
//         "client_email":
//             "firebase-adminsdk-oaxq3@zoomer-af32a.iam.gserviceaccount.com",
//         "client_id": "104402101846096095283",
//         "auth_uri": "https://accounts.google.com/o/oauth2/auth",
//         "token_uri": "https://oauth2.googleapis.com/token",
//         "auth_provider_x509_cert_url":
//             "https://www.googleapis.com/oauth2/v1/certs",
//         "client_x509_cert_url":
//             "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-oaxq3%40zoomer-af32a.iam.gserviceaccount.com",
//         "universe_domain": "googleapis.com"
//       }),
//       scopes,
//     );
//     final accessServerKey = client.credentials.accessToken.data;
//     return accessServerKey;
//   }
// }
