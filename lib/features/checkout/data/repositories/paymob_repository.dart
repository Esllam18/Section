// lib/features/checkout/data/repositories/paymob_repository.dart
import 'package:dio/dio.dart';
import 'package:section/core/config/app_config.dart';

class PaymobItem {
  final String name, description;
  final int amountCents, quantity;
  const PaymobItem({required this.name, required this.description, required this.amountCents, required this.quantity});
  Map<String,dynamic> toJson() => {'name':name,'description':description,'amount_cents':amountCents.toString(),'quantity':quantity.toString()};
}

class PaymobResult {
  final bool success;
  final String? paymentKey, iframeUrl, error;
  const PaymobResult({required this.success, this.paymentKey, this.iframeUrl, this.error});
}

class PaymobRepository {
  final _dio = Dio(BaseOptions(baseUrl: AppConfig.paymobBaseUrl, contentType: 'application/json',
    connectTimeout: const Duration(seconds: 30), receiveTimeout: const Duration(seconds: 30)));

  Future<String> _authToken() async {
    final r = await _dio.post('/auth/tokens', data: {'api_key': AppConfig.paymobApiKey});
    return r.data['token'] as String;
  }

  Future<int> _createOrder({required String token, required int amountCents, required List<PaymobItem> items, required String refNum}) async {
    final r = await _dio.post('/ecommerce/orders', data: {'auth_token':token,'delivery_needed':false,'amount_cents':amountCents,'currency':'EGP','merchant_order_id':refNum,'items':items.map((i)=>i.toJson()).toList()});
    return r.data['id'] as int;
  }

  Future<String> _paymentKey({required String token, required int orderId, required int amountCents, required int integrationId, required String email, required String phone, required String firstName, required String lastName, required String city}) async {
    final r = await _dio.post('/acceptance/payment_keys', data: {
      'auth_token':token,'amount_cents':amountCents,'expiration':3600,'order_id':orderId,
      'billing_data':{'apartment':'NA','email':email,'floor':'NA','first_name':firstName,'street':'NA','building':'NA','phone_number':phone,'shipping_method':'NA','postal_code':'NA','city':city,'country':'EGY','last_name':lastName,'state':'NA'},
      'currency':'EGP','integration_id':integrationId,'lock_order_when_paid':false,
    });
    return r.data['token'] as String;
  }

  Future<PaymobResult> initiateCardPayment({required int amountCents, required List<PaymobItem> items, required String orderRef, required String email, required String phone, required String firstName, required String lastName, required String city}) async {
    try {
      final token = await _authToken();
      final orderId = await _createOrder(token:token, amountCents:amountCents, items:items, refNum:orderRef);
      final payKey = await _paymentKey(token:token, orderId:orderId, amountCents:amountCents, integrationId:AppConfig.paymobCardIntegrationId, email:email, phone:phone, firstName:firstName, lastName:lastName, city:city);
      final url = 'https://accept.paymob.com/api/acceptance/iframes/${AppConfig.paymobIframeId}?payment_token=$payKey';
      return PaymobResult(success:true, paymentKey:payKey, iframeUrl:url);
    } on DioException catch(e) { return PaymobResult(success:false, error:e.response?.data?.toString() ?? e.message); }
    catch(e) { return PaymobResult(success:false, error:e.toString()); }
  }

  Future<PaymobResult> initiateWalletPayment({required int amountCents, required List<PaymobItem> items, required String orderRef, required String walletPhone, required String email, required String firstName, required String lastName, required String city}) async {
    try {
      final token = await _authToken();
      final orderId = await _createOrder(token:token, amountCents:amountCents, items:items, refNum:orderRef);
      final payKey = await _paymentKey(token:token, orderId:orderId, amountCents:amountCents, integrationId:AppConfig.paymobWalletIntegrationId, email:email, phone:walletPhone, firstName:firstName, lastName:lastName, city:city);
      final r = await _dio.post('/acceptance/payments/pay', data: {'source':{'identifier':walletPhone,'subtype':'WALLET'},'payment_token':payKey});
      return PaymobResult(success:true, paymentKey:payKey, iframeUrl:r.data['redirect_url'] as String?);
    } on DioException catch(e) { return PaymobResult(success:false, error:e.response?.data?.toString() ?? e.message); }
    catch(e) { return PaymobResult(success:false, error:e.toString()); }
  }
}
