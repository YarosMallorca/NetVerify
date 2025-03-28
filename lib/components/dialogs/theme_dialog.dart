import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netverify/providers/theme_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ThemeDialog extends ConsumerWidget {
  const ThemeDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.selectTheme),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<ThemeMode>(
            title: Text(AppLocalizations.of(context)!.systemDefault),
            value: ThemeMode.system,
            groupValue: themeMode,
            onChanged: (value) {
              ref.read(themeProvider.notifier).setTheme(value!);
            },
          ),
          RadioListTile<ThemeMode>(
            title: Text(AppLocalizations.of(context)!.lightTheme),
            value: ThemeMode.light,
            groupValue: themeMode,
            onChanged: (value) {
              ref.read(themeProvider.notifier).setTheme(value!);
            },
          ),
          RadioListTile<ThemeMode>(
            title: Text(AppLocalizations.of(context)!.darkTheme),
            value: ThemeMode.dark,
            groupValue: themeMode,
            onChanged: (value) {
              ref.read(themeProvider.notifier).setTheme(value!);
            },
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(AppLocalizations.of(context)!.done),
        ),
      ],
    );
  }
}
