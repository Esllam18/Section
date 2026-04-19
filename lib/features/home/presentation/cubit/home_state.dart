// lib/features/home/presentation/cubit/home_state.dart
import 'package:equatable/equatable.dart';
import 'package:section/features/home/data/models/home_summary_model.dart';

sealed class HomeState extends Equatable {
  const HomeState();
  @override List<Object?> get props => [];
}

final class HomeInitial  extends HomeState {}
final class HomeLoading  extends HomeState {}
final class HomeError    extends HomeState {
  final String message;
  const HomeError(this.message);
  @override List<Object?> get props => [message];
}
final class HomeLoaded extends HomeState {
  final HomeSummaryModel data;
  const HomeLoaded(this.data);
  @override List<Object?> get props => [data];
}
