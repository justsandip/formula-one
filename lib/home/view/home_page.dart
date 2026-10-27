import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formula_one/home/cubit/home_cubit.dart';
import 'package:formula_one/l10n/l10n.dart';
import 'package:formula_one/schedule/schedule.dart';
import 'package:formula_one/standings/standings.dart';
import 'package:formula_one/theme/theme.dart';
import 'package:material_ui/material_ui.dart';

part 'home_nav_bar.dart';

class HomePage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeCubit>(
      create: (_) => HomeCubit(),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Scaffold(
          body: IndexedStack(
            index: state.tab.index,
            children: [
              for (final tab in HomeTab.values)
                if (state.visited.contains(tab))
                  _pageFor(tab)
                else
                  const SizedBox.shrink(),
            ],
          ),
          bottomNavigationBar: HomeNavBar(
            selected: state.tab,
            onSelected: context.read<HomeCubit>().setTab,
          ),
        );
      },
    );
  }

  Widget _pageFor(HomeTab tab) {
    return switch (tab) {
      HomeTab.calendar => const SchedulePage(),
      HomeTab.results => const Placeholder(),
      HomeTab.standings => const StandingsPage(),
    };
  }
}
