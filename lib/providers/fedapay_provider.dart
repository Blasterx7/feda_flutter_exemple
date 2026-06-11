// Généré automatiquement par ashgate init
import 'package:feda_flutter/feda_flutter.dart';
import '../ashgate_payment_provider.dart';

class FedapayProvider implements AshgatePaymentProvider {
  @override
  Future<AshgatePaymentResult> pay(AshgatePaymentRequest request) async {
    try {
      // 1. Adapter la requête plate vers le modèle FedaPay
      final customer = CustomerCreate(
        email: request.email,
        firstname: request.firstname,
        lastname: request.lastname,
        phoneNumber: PhoneNumber(number: request.phoneNumber, country: request.country),
      );

      final transactionCreate = TransactionCreate(
        amount: request.amount.toInt(),
        description: request.description,
        currency: CurrencyIso(iso: request.currency),
        customer: customer,
      );

      // 2. Créer la transaction via le SDK feda_flutter
      final response = await FedaFlutter.instance.transactions.createTransaction(transactionCreate);
      final transactionId = response.data?.id;

      if (transactionId == null) {
        return AshgatePaymentResult(success: false, errorMessage: "Erreur lors de la création de la transaction FedaPay.");
      }

      // 3. Récupérer le token de paiement
      final tokenResponse = await FedaFlutter.instance.transactions.getTransactionToken(transactionId);
      final token = tokenResponse.data?.token;
      final url = tokenResponse.data?.url;

      return AshgatePaymentResult(
        success: token != null,
        transactionId: transactionId.toString(),
        paymentUrl: url,
        token: token,
      );
    } catch (e) {
      return AshgatePaymentResult(success: false, errorMessage: e.toString());
    }
  }
}
