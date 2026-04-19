part of 'cart_cubit.dart';

enum CartStatus { initial, loading, loaded, error }

class CartState extends Equatable {
  final CartStatus status;
  final List<CartItemModel> items;
  final String? error;

  const CartState({
    this.status = CartStatus.initial,
    this.items = const [],
    this.error,
  });

  double get total => items.fold(0, (s, i) => s + i.subtotal);
  int get itemCount => items.fold(0, (s, i) => s + i.quantity);

  CartState copyWith({CartStatus? status, List<CartItemModel>? items, String? error}) =>
    CartState(status: status ?? this.status, items: items ?? this.items, error: error);

  @override List<Object?> get props => [status, items, error];
}
