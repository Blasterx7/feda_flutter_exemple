import 'ashgate_payment.dart';
import 'package:feda_flutter/feda_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/catalog_page.dart';
import 'providers/cart_provider.dart';

const String _fedaCloudUrl = String.fromEnvironment(
  'FEDA_CLOUD_URL',
  defaultValue: 'http://192.168.100.9:3000',
);
const String _fedaProjectKey = String.fromEnvironment(
  'FEDA_PROJECT_KEY',
  defaultValue: 'pk_1a49352729494d7390172f94789ea566',
);
const String _fedaEnvironment = String.fromEnvironment(
  'FEDA_ENV',
  defaultValue: 'sandbox',
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AshgatePayment.initialize();
  final environment = _fedaEnvironment.toLowerCase() == 'live'
      ? ApiEnvironment.live
      : ApiEnvironment.sandbox;

  FedaFlutter.applyCloudConfig(
    environment: environment,
    cloudUrl: _fedaCloudUrl,
    projectKey: _fedaProjectKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: MaterialApp(
        title: 'ShoesHub',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1A1A2E),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const CatalogPage(),
      ),
    );
  }
}
