part of 'home_page.dart';

class HomeNavBar extends StatelessWidget {
  const new({required this.selected, required this.onSelected, super.key});

  final HomeTab selected;
  final ValueChanged<HomeTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    String labelFor(HomeTab tab) => switch (tab) {
      HomeTab.calendar => l10n.homeTabCalendar,
      HomeTab.results => l10n.homeTabResults,
      HomeTab.standings => l10n.homeTabStandings,
    };

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: FormulaOneColors.asphalt,
        border: Border(top: BorderSide(color: FormulaOneColors.steel)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (final tab in HomeTab.values)
              Expanded(
                child: _HomeNavItem(
                  label: labelFor(tab),
                  selected: tab == selected,
                  onTap: () => onSelected(tab),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HomeNavItem extends StatelessWidget {
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
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 64,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: selected ? scheme.primary : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Center(
              child: Text(
                label.toUpperCase(),
                style: theme.textTheme.labelLarge?.copyWith(
                  letterSpacing: 1.3,
                  color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
