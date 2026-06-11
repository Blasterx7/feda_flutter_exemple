import 'ashgate_payment.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AshgatePayment.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ashgate Payment Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF6C63FF),
        scaffoldBackgroundColor: const Color(0xFF0F0F1E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          secondary: Color(0xFF3F3D56),
          surface: Color(0xFF1E1E2E),
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '🚀 Ashgate Checkout'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstnameController = TextEditingController(text: 'Alexis');
  final _lastnameController = TextEditingController(text: 'Ashborn');
  final _emailController = TextEditingController(text: 'contact@ashborn.com');
  final _phoneController = TextEditingController(text: '90000000');

  String _selectedProvider = 'fedapay'; // 'fedapay', 'feexpay', 'stripe'
  String _selectedOperator = 'mtn'; // 'mtn', 'moov', 'celtiis'
  bool _isProcessing = false;

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _startCheckout() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
    });

    // Définir le montant et la devise selon le fournisseur
    double amount = _selectedProvider == 'stripe' ? 9.99 : 6500.0;
    // Si Stripe, le montant transmis doit être en centimes (subunit) : 999
    if (_selectedProvider == 'stripe') {
      amount = 999.0;
    }
    final currency = _selectedProvider == 'stripe' ? 'EUR' : 'XOF';

    final request = AshgatePaymentRequest(
      amount: amount,
      currency: currency,
      description: 'Abonnement Premium Ashgate',
      phoneNumber: _phoneController.text,
      country: 'bj',
      email: _emailController.text,
      firstname: _firstnameController.text,
      lastname: _lastnameController.text,
      paymentMethod: _selectedOperator,
      context: context,
    );

    try {
      final result = await AshgatePayment.startPayment(
        context: context,
        provider: _selectedProvider,
        request: request,
        onPaymentSuccess: () {
          _showStatusDialog(
            title: 'Paiement Réussi !',
            message: 'Votre abonnement Premium est maintenant activé.',
            isSuccess: true,
          );
        },
        onPaymentFailed: () {
          _showStatusDialog(
            title: 'Annulé ou Échoué',
            message: 'La transaction a été annulée ou a échoué.',
            isSuccess: false,
          );
        },
      );

      // Notification pour le mode direct USSD prompt de FedaPay (qui n'utilise pas de redirect automatique)
      if (result.success && _selectedProvider == 'fedapay') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez confirmer le prompt de paiement sur votre téléphone...'),
            backgroundColor: Colors.blueAccent,
          ),
        );
      }
    } catch (e) {
      _showStatusDialog(
        title: 'Erreur',
        message: e.toString(),
        isSuccess: false,
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showStatusDialog({
    required String title,
    required String message,
    required bool isSuccess,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: isSuccess ? Colors.green : Colors.red,
              size: 28,
            ),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message, style: const TextStyle(color: Color(0xFFC0C0D0), fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isStripe = _selectedProvider == 'stripe';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E1E2E),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Récapitulatif d'Achat Premium
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF3F3D56)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PRODUIT SELECTIONNÉ',
                      style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Abonnement Premium (1 mois)',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Divider(color: Colors.white.withOpacity(0.2)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total à payer :', style: TextStyle(color: Colors.white70, fontSize: 16)),
                        Text(
                          isStripe ? '9.99 EUR' : '6 500 XOF',
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Titre Sélection du Fournisseur
              const Text(
                'Moyen de paiement',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
              ),
              const SizedBox(height: 12),

              // Boutons Fournisseurs (FedaPay, FeexPay, Stripe)
              Row(
                children: [
                  _buildProviderCard('fedapay', 'FedaPay', Icons.phone_android),
                  const SizedBox(width: 12),
                  _buildProviderCard('feexpay', 'FeexPay', Icons.payment),
                  const SizedBox(width: 12),
                  _buildProviderCard('stripe', 'Stripe', Icons.credit_card),
                ],
              ),
              const SizedBox(height: 24),

              // Champs Utilisateur
              _buildInputLabel('Prénom'),
              _buildTextField(_firstnameController, 'Prénom', Icons.person_outline),
              const SizedBox(height: 16),

              _buildInputLabel('Nom'),
              _buildTextField(_lastnameController, 'Nom', Icons.person),
              const SizedBox(height: 16),

              _buildInputLabel('Email'),
              _buildTextField(_emailController, 'Email', Icons.mail_outline, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),

              // Champ Téléphone + Opérateur (Affichés uniquement pour FedaPay/FeexPay)
              if (!isStripe) ...[
                _buildInputLabel('Numéro de Téléphone'),
                _buildTextField(_phoneController, 'Téléphone', Icons.phone, keyboardType: TextInputType.phone),
                const SizedBox(height: 16),

                _buildInputLabel('Opérateur mobile'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildOperatorCard('mtn', 'MTN'),
                    const SizedBox(width: 12),
                    _buildOperatorCard('moov', 'Moov'),
                    const SizedBox(width: 12),
                    _buildOperatorCard('celtiis', 'Celtiis'),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // Message d'information pour Stripe
              if (isStripe) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E2E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFF6C63FF)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Vous allez être redirigé vers l'interface sécurisée de Stripe Checkout pour finaliser le paiement par carte bancaire.",
                          style: const TextStyle(color: Color(0xFFA0A0B0), fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Bouton d'action de paiement
              ElevatedButton(
                onPressed: _isProcessing ? null : _startCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 5,
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                    : Text(
                        isStripe ? 'Payer 9.99 EUR avec Stripe' : 'Lancer le paiement Mobile Money',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white70)),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        filled: true,
        fillColor: const Color(0xFF1E1E2E),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
        ),
      ),
      validator: (value) => value == null || value.trim().isEmpty ? 'Ce champ est requis' : null,
    );
  }

  Widget _buildProviderCard(String provider, String title, IconData icon) {
    final isSelected = _selectedProvider == provider;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedProvider = provider;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6C63FF).withOpacity(0.15) : const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? const Color(0xFF6C63FF) : Colors.white10,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? const Color(0xFF6C63FF) : Colors.white60, size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOperatorCard(String operator, String label) {
    final isSelected = _selectedOperator == operator;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedOperator = operator;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6C63FF).withOpacity(0.1) : const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF6C63FF) : Colors.white12,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
