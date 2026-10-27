part of 'schedule_page.dart';

class ScheduleSuccess extends StatelessWidget {
  const new({required this.races, super.key});

  final List<Race> races;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final l10n = context.l10n;

    if (races.isEmpty) {
      return Center(
        child: Text(
          l10n.scheduleEmpty.toUpperCase(),
          style: textTheme.titleMedium,
        ),
      );
    }

    final now = DateTime.now();
    final nextIndex = races.indexWhere((race) => race.startsAt.isAfter(now));
    // The card needs room, so hide it on short screens (e.g. landscape).
    final showNextRace =
        nextIndex != -1 && MediaQuery.sizeOf(context).height >= 600;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.scheduleSeasonLabel(races.first.startsAt.year).toUpperCase(),
            style: textTheme.labelMedium?.copyWith(color: muted),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.scheduleTitle.toUpperCase(),
            style: textTheme.displayMedium,
          ),
          const SizedBox(height: 20),
          if (showNextRace) ...[
            NextRaceCard(race: races[nextIndex]),
            const SizedBox(height: 16),
          ],
          Expanded(
            child: _RaceList(races: races, now: now, nextIndex: nextIndex),
          ),
        ],
      ),
    );
  }
}

enum _RaceStatus { done, next, upcoming }

class _RaceList extends StatefulWidget {
  const new({required this.races, required this.now, required this.nextIndex});

  final List<Race> races;
  final DateTime now;
  final int nextIndex;

  @override
  State<_RaceList> createState() => _RaceListState();
}

class _RaceListState extends State<_RaceList> {
  final GlobalKey<State<StatefulWidget>> _anchorKey = GlobalKey();
  var _positioned = false;

  /// The row placed at the top: the last two completed races stay visible
  /// above the next one. When the season is over, the final races show.
  int get _anchorIndex {
    final next = widget.nextIndex == -1
        ? widget.races.length
        : widget.nextIndex;
    return math.max(next - 2, 0);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final anchorContext = _anchorKey.currentContext;
      if (anchorContext != null) Scrollable.ensureVisible(anchorContext);
      setState(() => _positioned = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _positioned ? 1 : 0,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          child: Column(
            children: [
              for (final (index, race) in widget.races.indexed) ...[
                if (index > 0) const Divider(),
                KeyedSubtree(
                  key: index == _anchorIndex ? _anchorKey : null,
                  child: _RaceRow(
                    race: race,
                    status: race.startsAt.isBefore(widget.now)
                        ? _RaceStatus.done
                        : index == widget.nextIndex
                        ? _RaceStatus.next
                        : _RaceStatus.upcoming,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RaceRow extends StatelessWidget {
  const new({required this.race, required this.status});

  final Race race;
  final _RaceStatus status;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                Text(race.name.toUpperCase(), style: textTheme.titleMedium),
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
          const SizedBox(width: 12),
          _StatusChip(status: status),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const new({required this.status});

  final _RaceStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return switch (status) {
      _RaceStatus.done => FormulaOnePill(
        label: l10n.scheduleStatusDone,
        background: scheme.outlineVariant,
        foreground: scheme.onSurface,
      ),
      _RaceStatus.next => FormulaOnePill(
        label: l10n.scheduleStatusNext,
        background: scheme.primary,
        foreground: scheme.onPrimary,
      ),
      _RaceStatus.upcoming => FormulaOnePill(
        label: l10n.scheduleStatusUpcoming,
        background: scheme.outlineVariant,
        foreground: scheme.onSurface,
      ),
    };
  }
}
