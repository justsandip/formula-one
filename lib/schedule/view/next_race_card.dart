part of 'schedule_page.dart';

class NextRaceCard extends StatefulWidget {
  const new({required this.race, super.key});

  final Race race;

  @override
  State<NextRaceCard> createState() => _NextRaceCardState();
}

class _NextRaceCardState extends State<NextRaceCard> {
  late final Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = _computeRemaining();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      setState(() => _remaining = _computeRemaining());
    });
  }

  @override
  void didUpdateWidget(NextRaceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.race != widget.race) _remaining = _computeRemaining();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Duration _computeRemaining() {
    final remaining = widget.race.startsAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  String keepLastWordsTogether(String text) =>
      text.replaceFirstMapped(RegExp(r' (\S+)$'), (m) => '\u00A0${m[1]}');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final scheme = theme.colorScheme;
    final muted = scheme.onSurfaceVariant;
    final race = widget.race;
    final l10n = context.l10n;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FormulaOnePill(
                  label: 'Next race',
                  background: scheme.primary,
                  foreground: scheme.onPrimary,
                ),
                Text(
                  'Round ${race.round}',
                  style: textTheme.bodyMedium?.copyWith(color: muted),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              keepLastWordsTogether(race.name.toUpperCase()),
              style: textTheme.displaySmall,
            ),
            const SizedBox(height: 6),
            Text(
              race.circuit.name,
              style: textTheme.bodyMedium?.copyWith(color: muted),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _CountdownTile(
                    value: _remaining.inDays,
                    unit: l10n.scheduleCountdownDaysUnit(_remaining.inDays),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _CountdownTile(
                    value: _remaining.inHours % 24,
                    unit: l10n.scheduleCountdownHoursUnit(
                      _remaining.inHours % 24,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _CountdownTile(
                    value: _remaining.inMinutes % 60,
                    unit: l10n.scheduleCountdownMinUnit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CountdownTile extends StatelessWidget {
  const new({required this.value, required this.unit});

  final int value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value.toString().padLeft(2, '0'),
              style: theme.textTheme.headlineMedium,
            ),
            Text(
              unit,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
