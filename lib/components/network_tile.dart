import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netverify/models/network.dart';
import 'package:netverify/providers/network_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NetworkTile extends ConsumerStatefulWidget {
  const NetworkTile({
    super.key,
    required this.network,
    required this.onDelete,
    required this.onNetworkChanged,
  });

  final Network network;
  final VoidCallback onDelete;
  final ValueChanged<Network> onNetworkChanged;

  @override
  ConsumerState<NetworkTile> createState() => _NetworkTileState();
}

class _NetworkTileState extends ConsumerState<NetworkTile> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _ipStartController = TextEditingController();
  TextEditingController _ipEndController = TextEditingController();
  TextEditingController _subnetMaskController = TextEditingController();

  String? _validationError;
  bool _isNetworkValid = false;

  bool isValidIp(String ip) {
    final ipRegex = RegExp(
      r'^((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$',
    );
    return ipRegex.hasMatch(ip);
  }

  bool isValidSubnetMask(String mask) {
    final maskRegex = RegExp(r'^/?([0-9]|[12][0-9]|3[0-2])$');
    return maskRegex.hasMatch(mask);
  }

  bool isValidRange(String ipStart, String ipEnd, String subnetMask) {
    if (!isValidIp(ipStart) ||
        !isValidIp(ipEnd) ||
        !isValidSubnetMask(subnetMask)) {
      return false;
    }

    int ipStartInt = ipToInt(ipStart);
    int ipEndInt = ipToInt(ipEnd);
    int mask = int.parse(subnetMask.replaceAll('/', ''));
    int networkBase = ipStartInt & ((0xFFFFFFFF) << (32 - mask));
    int broadcast = networkBase | ((1 << (32 - mask)) - 1);

    return ipEndInt >= ipStartInt && ipEndInt <= broadcast;
  }

  int ipToInt(String ip) {
    List<String> parts = ip.split('.');
    return (int.parse(parts[0]) << 24) |
        (int.parse(parts[1]) << 16) |
        (int.parse(parts[2]) << 8) |
        int.parse(parts[3]);
  }

  void validateFields() {
    setState(() {
      _validationError = null;
      if (_ipStartController.text.isEmpty ||
          _ipEndController.text.isEmpty ||
          _subnetMaskController.text.isEmpty) {
        _validationError = AppLocalizations.of(context)!.allFieldsRequired;
      } else if (!isValidIp(_ipStartController.text)) {
        _validationError = AppLocalizations.of(context)!.invalidStartIP;
      } else if (!isValidIp(_ipEndController.text)) {
        _validationError = AppLocalizations.of(context)!.invalidEndIP;
      } else if (!isValidSubnetMask(_subnetMaskController.text)) {
        _validationError = AppLocalizations.of(context)!.invalidSubnetMask;
      } else if (!isValidRange(
        _ipStartController.text,
        _ipEndController.text,
        _subnetMaskController.text,
      )) {
        _validationError = AppLocalizations.of(context)!.notInRange;
      }
      _isNetworkValid = _validationError == null;
      widget.network.isValid = _isNetworkValid;
      // Notify the parent widget about the change
      widget.onNetworkChanged(
        widget.network.copyWith(
          // Create a copy
          name: _nameController.text,
          ipStart: _ipStartController.text,
          ipEnd: _ipEndController.text,
          subnetMask: int.tryParse(
            _subnetMaskController.text.replaceAll('/', ''),
          ),
          isValid: _isNetworkValid,
          color: widget.network.color, // Keep the current color
        ),
      );
    });
  }

  // Add this method to check for overlaps with other networks
  List<String> _checkForOverlaps(
    Network currentNetwork,
    List<Network> allNetworks,
  ) {
    final overlaps = <String>[];
    final currentIpStart = currentNetwork.ipStart;
    final currentIpEnd = currentNetwork.ipEnd;

    if (currentIpStart == null ||
        currentIpEnd == null ||
        !currentNetwork.isValid!) {
      return overlaps;
    }

    final currentStart = ipToInt(currentIpStart);
    final currentEnd = ipToInt(currentIpEnd);

    for (final otherNetwork in allNetworks) {
      if (otherNetwork.id == currentNetwork.id ||
          otherNetwork.ipStart == null ||
          otherNetwork.ipEnd == null ||
          !otherNetwork.isValid!) {
        continue;
      }

      final otherStart = ipToInt(otherNetwork.ipStart!);
      final otherEnd = ipToInt(otherNetwork.ipEnd!);

      if ((currentStart <= otherEnd && currentEnd >= otherStart)) {
        overlaps.add(
          AppLocalizations.of(context)!.overlapsWith(otherNetwork.name),
        );
      }
    }

    return overlaps;
  }

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current network values
    _nameController = TextEditingController(text: widget.network.name);
    _ipStartController = TextEditingController(text: widget.network.ipStart);
    _ipEndController = TextEditingController(text: widget.network.ipEnd);
    _subnetMaskController = TextEditingController(
      text: widget.network.subnetMask?.toString() ?? '24',
    );

    // Validate initial state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      validateFields();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ipStartController.dispose();
    _ipEndController.dispose();
    _subnetMaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allNetworks = ref.watch(networksProvider);
    final overlaps = _checkForOverlaps(widget.network, allNetworks);
    final hasOverlaps = overlaps.isNotEmpty;

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: widget.network.color ?? Colors.blue,
          brightness: Theme.of(context).brightness,
        ),
      ),
      child: Builder(
        builder: (context) {
          return Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText:
                                AppLocalizations.of(context)!.networkName,
                            border: OutlineInputBorder(),
                          ),
                          textInputAction: TextInputAction.next,
                          onChanged: (value) {
                            widget.network.name = value;
                            widget.onNetworkChanged(
                              widget.network.copyWith(name: value),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _ipStartController,
                          decoration: InputDecoration(
                            labelText:
                                AppLocalizations.of(context)!.ipStartHint,
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          onChanged: (value) {
                            widget.network.ipStart = value;
                            validateFields();
                          },
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _ipEndController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.ipEndHint,
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          onChanged: (value) {
                            widget.network.ipEnd = value;
                            validateFields();
                          },
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _subnetMaskController,
                          decoration: InputDecoration(
                            labelText:
                                AppLocalizations.of(context)!.subnetMaskHint,
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          onChanged: (value) {
                            final sanitized = value.replaceAll('/', '');
                            widget.network.subnetMask =
                                int.tryParse(sanitized) ?? 24;
                            validateFields();
                          },
                        ),
                        const SizedBox(height: 8),
                        Row(
                          spacing: 12,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child:
                                  _isNetworkValid
                                      ? hasOverlaps
                                          ? const Icon(
                                            Icons.warning_amber,
                                            color: Colors.orange,
                                            size: 24,
                                            key: ValueKey('overlap'),
                                          )
                                          : const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                            size: 24,
                                            key: ValueKey('valid'),
                                          )
                                      : const Icon(
                                        Icons.cancel,
                                        color: Colors.red,
                                        size: 24,
                                        key: ValueKey('invalid'),
                                      ),
                            ),
                            if (_validationError != null)
                              Text(
                                _validationError!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            if (hasOverlaps && _isNetworkValid)
                              Text(
                                overlaps.join(', '),
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ExcludeFocus(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 24,
                      children: [
                        IconButton(
                          tooltip: AppLocalizations.of(context)!.changeColor,
                          onPressed: () => _showColorPicker(context),
                          icon: const Icon(Icons.palette_outlined),
                        ),
                        IconButton(
                          tooltip: AppLocalizations.of(context)!.deleteNetwork,
                          onPressed: widget.onDelete,
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    Color tempColor = widget.network.color ?? Colors.blue;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: tempColor,
                  brightness: Theme.of(context).brightness,
                ),
              ),
              child: AlertDialog(
                title: Text(AppLocalizations.of(context)!.pickAColor),
                content: SingleChildScrollView(
                  child: ColorPicker(
                    enableAlpha: false,
                    pickerColor: tempColor,
                    hexInputBar: true,
                    onColorChanged: (pickerColor) {
                      setState(() {
                        tempColor = pickerColor;
                      });
                    },
                  ),
                ),
                actions: <Widget>[
                  OutlinedButton(
                    child: Text(AppLocalizations.of(context)!.cancel),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  ElevatedButton(
                    child: Text(AppLocalizations.of(context)!.done),
                    onPressed: () {
                      setState(() => widget.network.color = tempColor);
                      widget.onNetworkChanged(
                        widget.network.copyWith(color: tempColor),
                      );
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
