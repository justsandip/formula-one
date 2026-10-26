// ignore_for_file: document_ignores, avoid_redundant_argument_values

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formula_one/home/home.dart';

void main() {
  group('HomeCubit', () {
    test('starts on the calendar with only it visited', () {
      final cubit = HomeCubit();
      addTearDown(cubit.close);

      expect(cubit.state.tab, HomeTab.calendar);
      expect(cubit.state.visited, {HomeTab.calendar});
    });

    blocTest<HomeCubit, HomeState>(
      'setTab selects the tab and marks it as visited',
      build: HomeCubit.new,
      act: (cubit) => cubit.setTab(HomeTab.results),
      expect: () => [
        const HomeState(
          tab: HomeTab.results,
          visited: {HomeTab.calendar, HomeTab.results},
        ),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'keeps every visited tab when switching back and forth',
      build: HomeCubit.new,
      act: (cubit) => cubit
        ..setTab(HomeTab.results)
        ..setTab(HomeTab.standings)
        ..setTab(HomeTab.calendar),
      expect: () => [
        const HomeState(
          tab: HomeTab.results,
          visited: {HomeTab.calendar, HomeTab.results},
        ),
        const HomeState(
          tab: HomeTab.standings,
          visited: {HomeTab.calendar, HomeTab.results, HomeTab.standings},
        ),
        const HomeState(
          tab: HomeTab.calendar,
          visited: {HomeTab.calendar, HomeTab.results, HomeTab.standings},
        ),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'does not emit when the selected tab is selected again',
      build: HomeCubit.new,
      act: (cubit) => cubit.setTab(HomeTab.calendar),
      expect: () => <HomeState>[],
    );
  });

  group('HomeState', () {
    test('supports value equality', () {
      expect(const HomeState(), const HomeState());
    });

    test('differs when the tab differs', () {
      expect(const HomeState(), isNot(const HomeState(tab: HomeTab.results)));
    });

    test('differs when the visited tabs differ', () {
      expect(
        const HomeState(),
        isNot(const HomeState(visited: {HomeTab.calendar, HomeTab.results})),
      );
    });
  });
}
