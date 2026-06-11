// Généré automatiquement par ashgate init
import 'dart:convert';
import 'dart:io';
import '../ashgate_config.dart';
import '../ashgate_payment_provider.dart';

class StripeProvider implements AshgatePaymentProvider {
  @override
  Future<AshgatePaymentResult> pay(AshgatePaymentRequest request) async {
    final client = HttpClient();
    try {
      final url = Uri.parse('${AshgateConfig.cloudUrl}/fedapay/direct-payment');

      final req = await client.postUrl(url);
      req.headers.set('content-type', 'application/json');
      req.headers.set('x-feda-project-key', AshgateConfig.projectKey);
      req.headers.set('x-feda-env', AshgateConfig.environment.toString().split('.').last);

      final body = {
        'provider': 'stripe',
        'amount': request.amount.toInt(),
        'email': request.email,
        'description': request.description,
        'firstname': request.firstname,
        'lastname': request.lastname,
        'currency': request.currency == 'XOF' ? 'EUR' : request.currency,
      };

      req.add(utf8.encode(jsonEncode(body)));
      final response = await req.close();
      
      final responseBody = await response.transform(utf8.decoder).join();
      final json = jsonDecode(responseBody) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AshgatePaymentResult(
          success: true,
          transactionId: json['id']?.toString(),
          paymentUrl: json['payment_url'] ?? json['url'],
          token: json['id']?.toString(),
        );
      } else {
        return AshgatePaymentResult(
          success: false, 
          errorMessage: json['message'] ?? "Erreur HTTP ${response.statusCode}"
        );
      }
    } catch (e) {
      return AshgatePaymentResult(success: false, errorMessage: e.toString());
    } finally {
      client.close();
    }
  }
}
