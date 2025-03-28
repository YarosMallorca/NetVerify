import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netverify/models/network.dart';
import 'package:netverify/providers/network_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NetworkSummary extends ConsumerWidget {
  const NetworkSummary({super.key});

  // Helper function to convert IP address to numerical representation
  int _ipToInt(String ip) {
    return ip
        .split('.')
        .fold(0, (prev, octet) => (prev << 8) + int.parse(octet));
  }

  // Function to check for overlapping networks
  List<String> _findOverlappingNetworks(
    List<Network> networks,
    BuildContext context,
  ) {
    final overlaps = <String>[];

    // Filter out networks without valid IP ranges
    final validNetworks =
        networks
            .where(
              (n) => n.ipStart != null && n.ipEnd != null && n.isValid == true,
            )
            .toList();

    for (int i = 0; i < validNetworks.length; i++) {
      for (int j = i + 1; j < validNetworks.length; j++) {
        final netA = validNetworks[i];
        final netB = validNetworks[j];

        final aStart = _ipToInt(netA.ipStart!);
        final aEnd = _ipToInt(netA.ipEnd!);
        final bStart = _ipToInt(netB.ipStart!);
        final bEnd = _ipToInt(netB.ipEnd!);

        // Check if ranges overlap
        if ((aStart <= bEnd && aEnd >= bStart)) {
          final overlapText = AppLocalizations.of(
            context,
          )!.overlapDetails(netA.name, netB.name);

          if (!overlaps.contains(overlapText)) {
            overlaps.add(overlapText);
          }
        }
      }
    }

    return overlaps;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networks = ref.watch(networksProvider);
    final hasErrors = networks.any((network) => network.isValid == false);
    final overlaps = _findOverlappingNetworks(networks, context);
    final hasOverlaps = overlaps.isNotEmpty;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: SizedBox(
        width: double.infinity,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    AppLocalizations.of(context)!.networkSummary,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Divider(),
                if (hasErrors)
                  Text(
                    AppLocalizations.of(context)!.someNetworkErrors,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (!hasErrors && !hasOverlaps)
                  Text(
                    AppLocalizations.of(context)!.allFunctional,
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (hasOverlaps) ...[
                  Text(
                    AppLocalizations.of(context)!.overlapsDetected,
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...overlaps.map(
                    (overlap) => Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
                      child: Text(
                        '• $overlap',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
