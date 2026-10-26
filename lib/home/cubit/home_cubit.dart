import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  new() : super(const HomeState());

  /// Selects [tab] and marks it as visited, so it gets built.
  void setTab(HomeTab tab) {
    if (tab == state.tab) return;
    emit(HomeState(tab: tab, visited: {...state.visited, tab}));
  }
}
