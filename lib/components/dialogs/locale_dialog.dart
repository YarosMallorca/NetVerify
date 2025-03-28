import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locale_names/locale_names.dart';
import 'package:netverify/providers/locale_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LocaleDialog extends ConsumerWidget {
  const LocaleDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.selectLanguage),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(AppLocalizations.supportedLocales.length + 1, (
            index,
          ) {
            if (index == 0) {
              final systemLocaleName =
                  PlatformDispatcher.instance.locale.toString();
              return RadioListTile<Locale?>(
                title: Text(
                  "${AppLocalizations.of(context)!.systemDefault} ($systemLocaleName)",
                ),
                value: null,
                groupValue: locale,
                onChanged: (value) {
                  ref.read(localeProvider.notifier).setLocale(value);
                },
              );
            }
            final l = AppLocalizations.supportedLocales[index - 1];
            return RadioListTile<Locale?>(
              title: Text(
                Locale.fromSubtags(
                  languageCode: l.languageCode,
                ).nativeDisplayLanguage.capitalize(),
              ),

              value: Locale(l.languageCode),
              groupValue: locale,
              onChanged: (value) {
                ref.read(localeProvider.notifier).setLocale(value!);
              },
            );
          }),
        ),
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

extension StringExtension on String {
  /// Capitalizes the first letter of the string and converts the rest of the string to lowercase.
  ///
  /// Returns the capitalized string.
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
