part of 'results_page.dart';

class ResultsSuccess extends StatelessWidget {
  const new({required this.raceResults, super.key});

  final RaceResults raceResults;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final race = raceResults.race;
    final results = raceResults.results;
    final hasPodium = results.length >= 3;
    final rest = hasPodium ? results.sublist(3) : results;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      children: [
        Text(
          l10n.resultsKicker(race.round, race.circuit.location).toUpperCase(),
          style: textTheme.labelMedium?.copyWith(color: muted),
        ),
        const SizedBox(height: 6),
        Text(race.name.toUpperCase(), style: textTheme.displaySmall),
        const SizedBox(height: 16),
        if (hasPodium) ...[
          _Podium(results: results.take(3).toList()),
          const SizedBox(height: 14),
        ],
        if (rest.isNotEmpty)
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final (index, result) in rest.indexed) ...[
                  if (index > 0) const Divider(),
                  _ResultRow(result: result),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _Podium extends StatelessWidget {
  const new({required this.results});

  /// The first three results, winner first.
  final List<RaceResult> results;

  @override
  Widget build(BuildContext context) {
    // Displayed as P2, P1, P3.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _PodiumStep(result: results[1], place: 2, minHeight: 100),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _PodiumStep(result: results[0], place: 1, minHeight: 138),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _PodiumStep(result: results[2], place: 3, minHeight: 76),
        ),
      ],
    );
  }
}

class _PodiumStep extends StatelessWidget {
  const new({
    required this.result,
    required this.place,
    required this.minHeight,
  });

  final RaceResult result;
  final int place;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final winner = place == 1;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (winner)
              SizedBox(
                height: 3,
                width: double.infinity,
                child: ColoredBox(color: scheme.primary),
              ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.resultsPodiumPosition(place),
                    style: textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    result.driver.code,
                    style: winner
                        ? textTheme.headlineLarge
                        : textTheme.headlineMedium,
                  ),
                  Text(
                    result.time ?? result.status,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const new({required this.result});

  final RaceResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final muted = scheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 34),
            child: Text(
              result.positionText,
              style: textTheme.titleLarge?.copyWith(color: muted),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.driver.code, style: textTheme.titleMedium),
                Text(
                  result.constructor.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(color: muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FormulaOnePill(
            label: result.time ?? result.status,
            background: scheme.outlineVariant,
            foreground: scheme.onSurface,
          ),
        ],
      ),
    );
  }
}
