// lib/features/store/presentation/cubit/cart_cubit.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:section/features/store/data/models/cart_item_model.dart';
import 'package:section/features/store/data/repositories/cart_repository.dart';

// ── State ─────────────────────────────────────────────────────────────────────
sealed class CartState extends Equatable {
  const CartState();
  @override List<Object?> get props => [];
}

final class CartInitial  extends CartState {}
final class CartLoading  extends CartState {}
final class CartError    extends CartState {
  final String message;
  const CartError(this.message);
  @override List<Object?> get props => [message];
}
final class CartLoaded extends CartState {
  final List<CartItemModel> items;
  const CartLoaded(this.items);

  double get subtotal => items.fold(0, (s, i) => s + i.lineTotal);
  double get total    => subtotal + 50; // flat shipping
  int    get count    => items.fold(0, (s, i) => s + i.quantity);
  bool   get isEmpty  => items.isEmpty;

  @override List<Object?> get props => [items];
}

// ── Cubit ─────────────────────────────────────────────────────────────────────
class CartCubit extends Cubit<CartState> {
  final CartRepository _repo;
  CartCubit(this._repo) : super(CartInitial());

  Future<void> load() async {
    emit(CartLoading());
    try {
      emit(CartLoaded(await _repo.getItems()));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> add(String productId) async {
    await _repo.add(productId);
    await load();
  }

  Future<void> updateQty(String itemId, int qty) async {
    await _repo.updateQuantity(itemId, qty);
    await load();
  }

  Future<void> remove(String itemId) async {
    await _repo.remove(itemId);
    await load();
  }

  Future<void> clear() async {
    await _repo.clearCart();
    emit(const CartLoaded([]));
  }
}
