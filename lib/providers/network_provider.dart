import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netverify/providers/storage_provider.dart';
import 'package:netverify/models/network.dart';

final networksProvider = StateNotifierProvider<NetworksNotifier, List<Network>>(
  (ref) {
    return NetworksNotifier(ref);
  },
);

class NetworksNotifier extends StateNotifier<List<Network>> {
  final Ref ref;

  NetworksNotifier(this.ref) : super([]) {
    loadNetworks();
  }

  Future<void> loadNetworks() async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      final jsonString = prefs.getString('networks');
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        state = jsonList.map((json) => Network.fromJson(json)).toList();
      } else {
        state = [];
      }
    } catch (e) {
      debugPrint('Error loading networks: $e');
      state = [];
    }
  }

  Future<void> _saveNetworks() async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      await prefs.setString(
        'networks',
        jsonEncode(state.map((n) => n.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('Error saving: $e');
    }
  }

  void addNetwork(Network network) {
    state = [...state, network];
    _saveNetworks();
  }

  void removeNetwork(Network network) {
    state = state.where((n) => n.id != network.id).toList();
    _saveNetworks();
  }

  void updateNetwork(Network network) {
    state = state.map((n) => n.id == network.id ? network : n).toList();
    _saveNetworks();
  }
}
