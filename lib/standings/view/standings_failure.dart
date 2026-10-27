part of 'standings_page.dart';

class StandingsFailure extends StatelessWidget {
  const new({required this.failure, required this.onRetry, super.key});

  final FormulaOneApiFailure? failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final message = switch (failure) {
      FormulaOneNetworkFailure() => l10n.commonFailureOffline,
      _ => l10n.commonFailureGeneric,
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: Text(l10n.commonRetryButton),
            ),
          ],
        ),
      ),
    );
  }
}
