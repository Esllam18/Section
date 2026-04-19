// lib/features/checkout/presentation/cubit/checkout_cubit.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:section/features/checkout/data/repositories/paymob_repository.dart';
import 'package:section/features/store/data/models/cart_item_model.dart';
import 'package:section/features/store/data/models/order_model.dart';
import 'package:section/features/store/data/repositories/order_repository.dart';

// ── State ─────────────────────────────────────────────────────────────────────
sealed class CheckoutState extends Equatable {
  const CheckoutState();
  @override List<Object?> get props => [];
}

final class CheckoutInitial    extends CheckoutState {}
final class CheckoutLoading    extends CheckoutState {}
final class CheckoutError      extends CheckoutState {
  final String message;
  const CheckoutError(this.message);
  @override List<Object?> get props => [message];
}
final class CheckoutAwaitPayment extends CheckoutState {
  final String iframeUrl;
  final String orderId;
  const CheckoutAwaitPayment({required this.iframeUrl, required this.orderId});
  @override List<Object?> get props => [iframeUrl, orderId];
}
final class CheckoutSuccess extends CheckoutState {
  final OrderModel order;
  const CheckoutSuccess(this.order);
  @override List<Object?> get props => [order];
}

// ── Cubit ─────────────────────────────────────────────────────────────────────
class CheckoutCubit extends Cubit<CheckoutState> {
  final OrderRepository  _orderRepo;
  final PaymobRepository _paymobRepo;

  CheckoutCubit(this._orderRepo, this._paymobRepo) : super(CheckoutInitial());

  /// Cash on delivery — place order directly.
  Future<void> placeOrderCod({
    required List<CartItemModel> items,
    required Map<String, dynamic> address,
  }) async {
    emit(CheckoutLoading());
    try {
      final order = await _orderRepo.placeOrder(
        items: items,
        paymentMethod: 'cash_on_delivery',
        shippingAddress: address,
      );
      emit(CheckoutSuccess(order));
    } catch (e) {
      emit(CheckoutError(e.toString()));
    }
  }

  /// Card payment — place order then open Paymob iframe.
  Future<void> placeOrderCard({
    required List<CartItemModel> items,
    required Map<String, dynamic> address,
    required String email,
    required String phone,
    required String firstName,
    required String lastName,
  }) async {
    emit(CheckoutLoading());
    try {
      final order = await _orderRepo.placeOrder(
        items: items,
        paymentMethod: 'paymob_card',
        shippingAddress: address,
      );
      final amountCents = (order.total * 100).round();
      final paymobItems = items
          .map((i) => PaymobItem(
                name: i.product.nameEn,
                description: i.product.nameEn,
                amountCents: (i.product.effectivePrice * 100).round(),
                quantity: i.quantity,
              ))
          .toList();

      final result = await _paymobRepo.initiateCardPayment(
        amountCents: amountCents,
        items: paymobItems,
        orderRef: order.orderNumber,
        email: email,
        phone: phone,
        firstName: firstName,
        lastName: lastName,
        city: address['city'] as String? ?? 'Cairo',
      );

      if (!result.success || result.iframeUrl == null) {
        throw Exception(result.error ?? 'Payment initiation failed');
      }
      emit(CheckoutAwaitPayment(
          iframeUrl: result.iframeUrl!, orderId: order.id));
    } catch (e) {
      emit(CheckoutError(e.toString()));
    }
  }

  /// Called after Paymob WebView resolves.
  Future<void> onPaymobResult({
    required String orderId,
    required bool success,
  }) async {
    try {
      await _orderRepo.updatePaymentStatus(
        orderId,
        status: success ? 'paid' : 'failed',
      );
      if (success) {
        final order = await _orderRepo.getById(orderId);
        emit(CheckoutSuccess(order));
      } else {
        emit(const CheckoutError('Payment was not completed.'));
      }
    } catch (e) {
      emit(CheckoutError(e.toString()));
    }
  }
}
