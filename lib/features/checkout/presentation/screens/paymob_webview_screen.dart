// lib/features/checkout/presentation/screens/paymob_webview_screen.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:section/core/constants/app_colors.dart';
import 'package:section/core/services/navigation/navigation.dart';

enum PaymobStatus { pending, success, failed }

class PaymobWebViewScreen extends StatefulWidget {
  final String iframeUrl;
  final void Function(PaymobStatus) onResult;
  const PaymobWebViewScreen({super.key, required this.iframeUrl, required this.onResult});
  @override State<PaymobWebViewScreen> createState() => _PaymobWebViewScreenState();
}

class _PaymobWebViewScreenState extends State<PaymobWebViewScreen> {
  late final WebViewController _ctrl;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _ctrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _loading = true),
        onPageFinished: (url) { setState(() => _loading = false); _checkUrl(url); },
        onNavigationRequest: (r) { _checkUrl(r.url); return NavigationDecision.navigate; },
      ))
      ..loadRequest(Uri.parse(widget.iframeUrl));
  }

  void _checkUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final success = uri.queryParameters['success'];
    if (success == 'true') { widget.onResult(PaymobStatus.success); if (mounted) Navigation.back(); }
    else if (success == 'false') { widget.onResult(PaymobStatus.failed); if (mounted) Navigation.back(); }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () { widget.onResult(PaymobStatus.failed); Navigation.back(); }),
        title: Text(isAr ? 'الدفع الآمن' : 'Secure Payment', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
        actions: [Padding(padding: const EdgeInsets.only(right: 16), child: Row(children: [
          const Icon(Icons.lock_rounded, color: AppColors.success, size: 15),
          const SizedBox(width: 4),
          const Text('SSL', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w700)),
        ]))],
      ),
      body: Stack(children: [
        WebViewWidget(controller: _ctrl),
        if (_loading) Container(color: Theme.of(context).scaffoldBackgroundColor,
          child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            Text(isAr ? 'تحميل بوابة الدفع...' : 'Loading payment gateway...',
              style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondaryLight)),
          ]))),
      ]),
    );
  }
}
