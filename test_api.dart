import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  // 1. Login to get token for Mahbub Gas Shop
  final loginResponse = await http.post(
    Uri.parse('https://gasapp.atwebpages.com/api/v1/auth/login.php'),
    body: {
      'phone': '01700000000', // Assuming a test vendor phone number, needs to be replaced if unknown
      'password': 'password', // Assuming test password
    },
  );
  
  print('Login Response: ${loginResponse.body}');
  
  if (loginResponse.statusCode == 200) {
    final data = jsonDecode(loginResponse.body);
    final token = data['data']['token'];
    
    // 2. Fetch products
    final productsResponse = await http.get(
      Uri.parse('https://gasapp.atwebpages.com/api/v1/vendor/products.php'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    
    print('Products Response: ${productsResponse.body}');
  }
}
