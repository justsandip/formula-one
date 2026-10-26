part of 'home_cubit.dart';

/// Tabs of the bottom navigation bar, in display order.
enum HomeTab { calendar, results, standings }

final class HomeState extends Equatable {
  const new({
    this.tab = HomeTab.calendar,
    this.visited = const {HomeTab.calendar},
  });

  /// The selected tab.
  final HomeTab tab;

  /// Tabs opened at least once. Tabs not in this set are not built yet.
  final Set<HomeTab> visited;

  @override
  List<Object> get props => [tab, visited];
}
