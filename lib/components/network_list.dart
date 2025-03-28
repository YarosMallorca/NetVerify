import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netverify/components/network_tile.dart';
import 'package:netverify/models/network.dart';
import 'package:netverify/providers/network_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NetworkList extends ConsumerStatefulWidget {
  const NetworkList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NetworkListState();
}

class _NetworkListState extends ConsumerState<NetworkList> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final Duration _animationDuration = const Duration(milliseconds: 300);
  final Curve _curve = Curves.easeInOut;
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    // Wait for initial load to complete
    ref.read(networksProvider.notifier).loadNetworks().then((_) {
      if (mounted) {
        setState(() => _isInitialLoad = false);
      }
    });
  }

  void _addNetwork() {
    final notifier = ref.read(networksProvider.notifier);
    final newNetwork = Network();

    // First add to state
    notifier.addNetwork(newNetwork);

    // Then trigger animation after state is updated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listKey.currentState?.insertItem(
        ref.read(networksProvider).length - 1,
        duration: _animationDuration,
      );
    });
  }

  void _removeNetwork(int index) {
    final notifier = ref.read(networksProvider.notifier);
    final networks = ref.read(networksProvider);
    final removedNetwork = networks[index];

    notifier.removeNetwork(removedNetwork);
    _listKey.currentState?.removeItem(index, (context, animation) {
      final curvedAnimation = CurvedAnimation(parent: animation, curve: _curve);
      return SizeTransition(
        sizeFactor: curvedAnimation,
        axisAlignment: 0.0,
        child: NetworkTile(
          network: removedNetwork,
          onDelete: () {},
          onNetworkChanged: (updatedNetwork) {},
        ),
      );
    }, duration: _animationDuration);
  }

  void _updateNetwork(Network updatedNetwork) {
    ref.read(networksProvider.notifier).updateNetwork(updatedNetwork);
  }

  @override
  Widget build(BuildContext context) {
    final networks = ref.watch(networksProvider);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Card(
        child:
            _isInitialLoad
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  children: [
                    Expanded(
                      child: AnimatedList(
                        key: _listKey,
                        padding: const EdgeInsets.all(8),
                        initialItemCount: networks.length,
                        itemBuilder: (context, index, animation) {
                          return SizeTransition(
                            sizeFactor: CurvedAnimation(
                              parent: animation,
                              curve: _curve,
                            ),
                            child: NetworkTile(
                              network: networks[index],
                              onDelete: () => _removeNetwork(index),
                              onNetworkChanged: _updateNetwork,
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.add),
                        label: Text(AppLocalizations.of(context)!.addNetwork),
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.primary,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                        ),
                        onPressed: _addNetwork,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
