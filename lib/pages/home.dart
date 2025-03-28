import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netverify/components/app_bar.dart';
import 'package:netverify/components/network_list.dart';
import 'package:netverify/components/network_summary.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: NAppBar(),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Expanded(child: NetworkList()), NetworkSummary()],
          ),
        ),
      ),
    );
  }
}
