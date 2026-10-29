part of 'results_page.dart';

class _ResultsTopBar extends StatelessWidget {
  const new({required this.state});

  final ResultsState state;

  Future<void> _pickRound(BuildContext context, int current) async {
    final picked = await RoundPickerSheet.show(context, selectedRound: current);
    if (picked == null || picked == current || !context.mounted) return;
    context.read<ResultsBloc>().add(ResultsRequested(round: picked));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final raceResults = state.raceResults;

    // A pushed page gets a back button; the tab shows a chip while it is on
    // the latest race.
    final leading = Navigator.of(context).canPop()
        ? const _BackButton()
        : state.round == null && raceResults != null
        ? FormulaOnePill(
            label: l10n.resultsLatestChip,
            background: scheme.primary,
            foreground: scheme.onPrimary,
          )
        : const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            leading,
            if (raceResults != null)
              _RoundPill(
                label: l10n.resultsRoundPill(raceResults.race.round),
                onTap: () =>
                    _pickRound(context, int.parse(raceResults.race.round)),
              ),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return IconButton(
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: () => Navigator.of(context).maybePop(),
      icon: const Icon(Icons.chevron_left),
      style: IconButton.styleFrom(
        minimumSize: const Size.square(44),
        backgroundColor: scheme.surfaceContainer,
        side: BorderSide(color: scheme.outline),
      ),
    );
  }
}

class _RoundPill extends StatelessWidget {
  const new({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: scheme.surfaceContainer,
        shape: StadiumBorder(side: BorderSide(color: scheme.outline)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Center(
                widthFactor: 1,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label, style: theme.textTheme.labelLarge),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.expand_more,
                      size: 20,
                      color: scheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
