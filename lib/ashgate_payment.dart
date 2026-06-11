// Généré automatiquement par ashgate init
import 'package:flutter/material.dart';
import 'package:feda_flutter/feda_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'ashgate_config.dart';
import 'ashgate_payment_provider.dart';
import 'providers/fedapay_provider.dart';
import 'providers/feexpay_provider.dart';
import 'providers/stripe_provider.dart';

export 'ashgate_config.dart';
export 'ashgate_payment_provider.dart';

/// Service instanciable facilitant la gestion des paiements dans vos blocs/providers.
class AshgatePaymentService {
  static final AshgatePaymentService instance = AshgatePaymentService._internal();

  AshgatePaymentService._internal();

  /// Résout l'adaptateur de paiement correspondant
  AshgatePaymentProvider getProvider(String providerName) {
    final name = providerName.toLowerCase();
    if (name == 'fedapay') return FedapayProvider();
    if (name == 'feexpay') return FeexpayProvider();
    if (name == 'stripe') return StripeProvider();
    throw Exception("Le fournisseur de paiement '$providerName' n'est pas supporté.");
  }

  /// Déclenche le paiement sur le provider de votre choix
  Future<AshgatePaymentResult> payWith({
    required String provider,
    required AshgatePaymentRequest request,
  }) async {
    return getProvider(provider).pay(request);
  }
}

/// Helper global d'initialisation et d'affichage des composants graphiques.
class AshgatePayment {
  /// Initialise la configuration globale d'Ashgate (FedaPay Cloud Proxy inclus)
  static void initialize() {
    FedaFlutter.applyCloudConfig(
      projectKey: AshgateConfig.projectKey,
      cloudUrl: AshgateConfig.cloudUrl,
      environment: AshgateConfig.environment,
    );
  }

  /// Widget de paiement unifié (FedaPay, FeexPay ou Stripe)
  static Widget payWidget({
    String? transactionToken,
    String? paymentUrl,
    required VoidCallback onPaymentSuccess,
    required VoidCallback onPaymentFailed,
  }) {
    if (transactionToken != null) {
      return PayWidget(
        transactionToken: transactionToken,
        onPaymentSuccess: onPaymentSuccess,
        onPaymentFailed: onPaymentFailed,
      );
    }
    if (paymentUrl != null) {
      return AshgateWebView(
        url: paymentUrl,
        onPaymentSuccess: onPaymentSuccess,
        onPaymentFailed: onPaymentFailed,
      );
    }
    return const SizedBox();
  }

  /// Affiche une boîte de dialogue bottom sheet avec un WebView pour n'importe quelle URL de paiement (ex: FeexPay)
  static Future<void> showPaymentSheet({
    required BuildContext context,
    required String paymentUrl,
    required VoidCallback onPaymentSuccess,
    required VoidCallback onPaymentFailed,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        height: MediaQuery.of(sheetContext).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Column(
            children: [
              AppBar(
                title: const Text('Paiement Sécurisé'),
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    if (sheetContext.mounted) Navigator.pop(sheetContext);
                    onPaymentFailed();
                  },
                ),
                backgroundColor: Colors.white,
                elevation: 0.5,
              ),
              Expanded(
                child: AshgateWebView(
                  url: paymentUrl,
                  onPaymentSuccess: () {
                    if (sheetContext.mounted) Navigator.pop(sheetContext);
                    onPaymentSuccess();
                  },
                  onPaymentFailed: () {
                    if (sheetContext.mounted) Navigator.pop(sheetContext);
                    onPaymentFailed();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Lance la procédure de paiement de manière unifiée pour tous les modes et fournisseurs.
  static Future<AshgatePaymentResult> startPayment({
    required BuildContext context,
    required String provider,
    required AshgatePaymentRequest request,
    required VoidCallback onPaymentSuccess,
    required VoidCallback onPaymentFailed,
  }) async {
    final result = await AshgatePaymentService.instance.payWith(
      provider: provider,
      request: request,
    );

    if (!result.success) {
      onPaymentFailed();
      return result;
    }

    if (!context.mounted) return result;

    final name = provider.toLowerCase();
    if (name == 'fedapay') {
      if (result.token == null) {
        onPaymentFailed();
        return result;
      }
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) => Container(
          height: MediaQuery.of(sheetContext).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: payWidget(
            transactionToken: result.token,
            onPaymentSuccess: () {
              if (sheetContext.mounted) Navigator.pop(sheetContext);
              onPaymentSuccess();
            },
            onPaymentFailed: () {
              if (sheetContext.mounted) Navigator.pop(sheetContext);
              onPaymentFailed();
            },
          ),
        ),
      );
    } else if (name == 'feexpay' || name == 'stripe') {
      if (result.paymentUrl != null) {
        await showPaymentSheet(
          context: context,
          paymentUrl: result.paymentUrl!,
          onPaymentSuccess: onPaymentSuccess,
          onPaymentFailed: onPaymentFailed,
        );
      }
    }

    return result;
  }
}

/// WebView personnalisé pour écouter la redirection de succès / échec d'Ash Gateway
class AshgateWebView extends StatefulWidget {
  final String url;
  final VoidCallback onPaymentSuccess;
  final VoidCallback onPaymentFailed;

  const AshgateWebView({
    super.key,
    required this.url,
    required this.onPaymentSuccess,
    required this.onPaymentFailed,
  });

  @override
  State<AshgateWebView> createState() => _AshgateWebViewState();
}

class _AshgateWebViewState extends State<AshgateWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _callbackCalled = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onUrlChange: (change) {
            if (_callbackCalled) return;
            if (change.url != null) {
              try {
                final uri = Uri.tryParse(change.url!);
                if (uri != null) {
                  final pathString = uri.path.toLowerCase();
                  bool isSuccess = pathString.contains('success');
                  bool isFailure = pathString.contains('failure') ||
                      pathString.contains('fail') ||
                      pathString.contains('cancel') ||
                      pathString.contains('error');

                  if (uri.hasQuery) {
                    final status = uri.queryParameters['status'];
                    final transaction = uri.queryParameters['transaction'];
                    if (status == 'success' || transaction == 'success') {
                      isSuccess = true;
                    }
                    if (status == 'failed') {
                      isFailure = true;
                    }
                  }

                  if (isSuccess) {
                    _callbackCalled = true;
                    widget.onPaymentSuccess();
                  } else if (isFailure) {
                    _callbackCalled = true;
                    widget.onPaymentFailed();
                  }
                }
              } catch (e) {
                // Avoid crashing on malformed query parameters
              }
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}

