import 'package:flutter/material.dart';
import 'package:netverify/components/dialogs/locale_dialog.dart';
import 'package:netverify/components/dialogs/theme_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';

class NAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NAppBar({super.key});

  static const double _height = 70;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 5,
      centerTitle: true,
      toolbarHeight: _height,
      title: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          return Tooltip(
            message: snapshot.hasData ? 'V${snapshot.data!.version}' : "",
            child: Column(
              spacing: 4,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'NetVerify',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  AppLocalizations.of(context)!.appDescription,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        },
      ),
      actions: [
        IconButton(
          icon: Icon(
            Theme.of(context).brightness == Brightness.dark
                ? Icons.dark_mode
                : Icons.light_mode,
          ),
          onPressed: () {
            showDialog(context: context, builder: (context) => ThemeDialog());
          },
        ),
        SizedBox(width: 8),
        IconButton(
          icon: Icon(Icons.language),
          onPressed: () {
            showDialog(context: context, builder: (context) => LocaleDialog());
          },
        ),
        SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(_height);
}
