part of 'standings_page.dart';

enum _StandingsTab { drivers, constructors }

/// One championship row, whichever table it comes from.
class _Entry {
  const new({
    required this.position,
    required this.title,
    required this.detail,
    required this.points,
    required this.wins,
    this.number,
  });

  final int position;
  final String title;
  final String detail;
  final double points;
  final int wins;
  final String? number;
}

String _formatPoints(double points) => NumberFormat('0.#').format(points);

class StandingsSuccess extends StatefulWidget {
  const new({required this.drivers, required this.constructors, super.key});

  final List<DriverStanding> drivers;
  final List<ConstructorStanding> constructors;

  @override
  State<StandingsSuccess> createState() => _StandingsSuccessState();
}

class _StandingsSuccessState extends State<StandingsSuccess> {
  _StandingsTab _tab = _StandingsTab.drivers;

  List<_Entry> get _entries => switch (_tab) {
    _StandingsTab.drivers => [
      for (final s in widget.drivers)
        _Entry(
          position: s.position,
          title: '${s.driver.givenName} ${s.driver.familyName}',
          detail: s.constructors.map((c) => c.name).join(' / '),
          points: s.points,
          wins: s.wins,
          number: s.driver.permanentNumber,
        ),
    ],
    _StandingsTab.constructors => [
      for (final s in widget.constructors)
        _Entry(
          position: s.position,
          title: s.constructor.name,
          detail: s.constructor.nationality,
          points: s.points,
          wins: s.wins,
        ),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final entries = _entries;
    // The leader card needs room, so hide it on short screens. The list then
    // includes the leader.
    final showLeader =
        entries.isNotEmpty && MediaQuery.sizeOf(context).height >= 600;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.standingsKicker.toUpperCase(),
            style: textTheme.labelMedium?.copyWith(color: muted),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.standingsTitle.toUpperCase(),
            style: textTheme.displayMedium,
          ),
          const SizedBox(height: 14),
          _TabPills(
            selected: _tab,
            onSelected: (tab) => setState(() => _tab = tab),
          ),
          const SizedBox(height: 14),
          if (entries.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  l10n.standingsEmpty.toUpperCase(),
                  style: textTheme.titleMedium,
                ),
              ),
            )
          else ...[
            if (showLeader) ...[
              _LeaderCard(
                leader: entries.first,
                second: entries.length > 1 ? entries[1] : null,
              ),
              const SizedBox(height: 14),
            ],
            _ColumnHeader(tab: _tab),
            const SizedBox(height: 8),
            Expanded(
              child: _StandingsList(
                entries: showLeader ? entries.sublist(1) : entries,
                leaderPoints: entries.first.points,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TabPills extends StatelessWidget {
  const new({required this.selected, required this.onSelected});

  final _StandingsTab selected;
  final ValueChanged<_StandingsTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      children: [
        for (final tab in _StandingsTab.values)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _TabPill(
              label: switch (tab) {
                _StandingsTab.drivers => l10n.standingsTabDrivers,
                _StandingsTab.constructors => l10n.standingsTabConstructors,
              },
              selected: tab == selected,
              onTap: () => onSelected(tab),
            ),
          ),
      ],
    );
  }
}

class _TabPill extends StatelessWidget {
  const new({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Semantics(
      button: true,
      selected: selected,
      excludeSemantics: true,
      label: label,
      child: Material(
        color: selected ? scheme.onSurface : Colors.transparent,
        shape: StadiumBorder(
          side: BorderSide(color: selected ? scheme.onSurface : scheme.outline),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: selected ? scheme.surface : scheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LeaderCard extends StatelessWidget {
  const new({required this.leader, required this.second});

  final _Entry leader;
  final _Entry? second;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final muted = scheme.onSurfaceVariant;
    final number = leader.number;
    final runnerUp = second;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      FormulaOnePill(
                        label: l10n.standingsLeaderChip,
                        background: scheme.primary,
                        foreground: scheme.onPrimary,
                      ),
                      if (number != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          l10n.standingsDriverNumber(number),
                          style: textTheme.bodyMedium?.copyWith(color: muted),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    leader.title.toUpperCase(),
                    style: textTheme.displaySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.standingsSubtitle(leader.detail, leader.wins),
                    style: textTheme.bodyMedium?.copyWith(color: muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatPoints(leader.points),
                  style: textTheme.displayLarge,
                ),
                Text(
                  runnerUp == null
                      ? l10n.standingsPointsUnit
                      : l10n.standingsLeaderMargin(
                          _formatPoints(leader.points - runnerUp.points),
                        ),
                  style: textTheme.bodyMedium?.copyWith(color: muted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ColumnHeader extends StatelessWidget {
  const new({required this.tab});

  final _StandingsTab tab;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final style = Theme.of(context).textTheme.labelMedium
        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            switch (tab) {
              _StandingsTab.drivers => l10n.standingsColumnDriver,
              _StandingsTab.constructors => l10n.standingsColumnTeam,
            }.toUpperCase(),
            style: style,
          ),
          Text(l10n.standingsColumnGapPoints.toUpperCase(), style: style),
        ],
      ),
    );
  }
}

class _StandingsList extends StatelessWidget {
  const new({required this.entries, required this.leaderPoints});

  final List<_Entry> entries;
  final double leaderPoints;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: entries.length,
        separatorBuilder: (_, _) => const Divider(),
        itemBuilder: (context, index) =>
            _StandingRow(entry: entries[index], leaderPoints: leaderPoints),
      ),
    );
  }
}

class _StandingRow extends StatelessWidget {
  const new({required this.entry, required this.leaderPoints});

  final _Entry entry;
  final double leaderPoints;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final muted = scheme.onSurfaceVariant;
    final gap = leaderPoints - entry.points;
    final fraction = leaderPoints == 0
        ? 0.0
        : (entry.points / leaderPoints).clamp(0.0, 1.0);

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 30),
                child: Text(
                  '${entry.position}',
                  style: textTheme.titleLarge?.copyWith(
                    color: entry.position <= 3 ? scheme.onSurface : muted,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium,
                    ),
                    Text(
                      l10n.standingsSubtitle(entry.detail, entry.wins),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatPoints(entry.points),
                    style: textTheme.headlineMedium,
                  ),
                  Text(
                    l10n.standingsGapBehind(_formatPoints(gap)),
                    style: textTheme.bodyMedium?.copyWith(color: muted),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Points relative to the leader: the row's bottom edge doubles as a
        // progress bar.
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomLeft,
            child: FractionallySizedBox(
              widthFactor: fraction,
              child: SizedBox(
                height: 2,
                child: ColoredBox(color: scheme.primary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
