import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:section/features/cart/data/models/cart_item_model.dart';
import 'package:section/features/cart/data/repositories/cart_repository.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRepository _r;
  CartCubit(this._r) : super(const CartState());

  Future<void> load() async {
    emit(state.copyWith(status: CartStatus.loading));
    try {
      final items = await _r.getCartItems();
      emit(state.copyWith(status: CartStatus.loaded, items: items));
    } catch (e) {
      emit(state.copyWith(status: CartStatus.error, error: e.toString()));
    }
  }

  Future<void> updateQty(String id, int qty) async {
    try {
      await _r.updateQuantity(id, qty);
      await load();
    } catch (_) {}
  }

  Future<void> remove(String id) async {
    try {
      await _r.removeItem(id);
      await load();
    } catch (_) {}
  }

  Future<void> clear() async {
    try {
      await _r.clearCart();
      emit(state.copyWith(status: CartStatus.loaded, items: []));
    } catch (_) {}
  }
}
