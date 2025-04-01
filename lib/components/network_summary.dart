import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netverify/models/network.dart';
import 'package:netverify/providers/network_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NetworkSummary extends ConsumerWidget {
  const NetworkSummary({super.key});

  // Convert IP address to integer representation
  int _ipToInt(String ip) {
    return ip
        .split('.')
        .fold(0, (prev, octet) => (prev << 8) + int.parse(octet));
  }

  // Compute network base address using subnet mask
  int _networkBase(String ip, int subnetMask) {
    return _ipToInt(ip) & ((0xFFFFFFFF) << (32 - subnetMask));
  }

  // Compute broadcast address from network base and subnet mask
  int _broadcastAddress(int networkBase, int subnetMask) {
    return networkBase | ((1 << (32 - subnetMask)) - 1);
  }

  // Function to check for overlapping networks
  List<String> _findOverlappingNetworks(
    List<Network> networks,
    BuildContext context,
  ) {
    final overlaps = <String>[];

    final validNetworks =
        networks
            .where(
              (n) =>
                  n.ipStart != null &&
                  n.subnetMask != null &&
                  n.isValid == true,
            )
            .toList();

    for (int i = 0; i < validNetworks.length; i++) {
      for (int j = i + 1; j < validNetworks.length; j++) {
        final netA = validNetworks[i];
        final netB = validNetworks[j];

        final baseA = _networkBase(netA.ipStart!, netA.subnetMask!);
        final broadcastA = _broadcastAddress(baseA, netA.subnetMask!);

        final baseB = _networkBase(netB.ipStart!, netB.subnetMask!);
        final broadcastB = _broadcastAddress(baseB, netB.subnetMask!);

        // Networks overlap if one network's range intersects with the other's
        if (baseA <= broadcastB && broadcastA >= baseB) {
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
