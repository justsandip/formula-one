part of 'results_page.dart';

class RoundPickerSheet extends StatelessWidget {
  const new({required this.selectedRound, super.key});

  final int selectedRound;

  /// Opens the sheet and returns the chosen round, or null if dismissed.
  static Future<int?> show(BuildContext context, {required int selectedRound}) {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => BlocProvider<ScheduleBloc>(
        create: (_) => ScheduleBloc(
          formulaOneRepository: context.read<FormulaOneRepository>(),
        )..add(const ScheduleRequested()),
        child: RoundPickerSheet(selectedRound: selectedRound),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(
              l10n.resultsPickerTitle.toUpperCase(),
              style: textTheme.headlineLarge,
            ),
          ),
          Flexible(
            child: BlocBuilder<ScheduleBloc, ScheduleState>(
              builder: (context, state) {
                switch (state.status) {
                  case ScheduleStatus.initial:
                  case ScheduleStatus.loading:
                    if (state.races.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return _CompletedRaces(
                      races: state.races,
                      selectedRound: selectedRound,
                    );
                  case ScheduleStatus.success:
                    return _CompletedRaces(
                      races: state.races,
                      selectedRound: selectedRound,
                    );
                  case ScheduleStatus.failure:
                    return SizedBox(
                      height: 200,
                      child: FormulaOneFailureView(
                        failure: state.failure,
                        onRetry: () => context.read<ScheduleBloc>().add(
                          ScheduleRequested(season: state.season),
                        ),
                      ),
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletedRaces extends StatelessWidget {
  const new({required this.races, required this.selectedRound});

  final List<Race> races;
  final int selectedRound;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Newest first.
    final completed = races
        .where((race) => race.startsAt.isBefore(now))
        .toList()
        .reversed
        .toList();

    if (completed.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            context.l10n.resultsPickerEmpty,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      itemCount: completed.length,
      itemBuilder: (context, index) {
        final race = completed[index];
        final round = int.parse(race.round);
        return _PickerRow(
          race: race,
          selected: round == selectedRound,
          latest: index == 0,
          onTap: () => Navigator.of(context).pop(round),
        );
      },
    );
  }
}

class _PickerRow extends StatelessWidget {
  const new({
    required this.race,
    required this.selected,
    required this.latest,
    required this.onTap,
  });

  final Race race;
  final bool selected;
  final bool latest;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final muted = scheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? scheme.outlineVariant : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 40),
                    child: Text(
                      l10n.scheduleRoundShortLabel(race.round.padLeft(2, '0')),
                      style: textTheme.titleLarge?.copyWith(color: muted),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          race.name.toUpperCase(),
                          style: textTheme.titleMedium,
                        ),
                        Text(
                          l10n.scheduleRaceLocationAndDate(
                            race.circuit.location,
                            race.startsAt.toLocal(),
                          ),
                          style: textTheme.bodyMedium?.copyWith(color: muted),
                        ),
                      ],
                    ),
                  ),
                  if (latest) ...[
                    const SizedBox(width: 8),
                    FormulaOnePill(
                      label: l10n.resultsPickerLatestChip,
                      background: scheme.outlineVariant,
                      foreground: scheme.onSurface,
                    ),
                  ],
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 24,
                    child: selected
                        ? Icon(Icons.check, color: scheme.primary)
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
