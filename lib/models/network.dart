import 'package:flutter/widgets.dart';

/// Represents a user's network
class Network {
  String? id;

  String name;

  /// First IP Address in the range
  String? ipStart;

  /// Last IP Address in the range
  String? ipEnd;

  /// In CIRD Notation
  int? subnetMask;

  /// Hexadecimal color representation for the network
  Color? color;

  /// Indicates if the network is valid or not
  bool? isValid;

  Network({
    String? id, // Keep this in the constructor
    this.name = "",
    this.ipStart,
    this.ipEnd,
    this.subnetMask,
    this.color,
    this.isValid = false,
  }) : id = id ?? UniqueKey().toString();

  /// Converts the network to a map for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ipStart': ipStart,
      'ipEnd': ipEnd,
      'subnetMask': subnetMask,
      'color': color?.toARGB32(), // Store color as int value
      'isValid': isValid,
    };
  }

  /// Creates a network from a map for JSON deserialization
  factory Network.fromJson(Map<String, dynamic> json) {
    return Network(
      id: json['id'],
      name: json['name'] ?? '',
      ipStart: json['ipStart'],
      ipEnd: json['ipEnd'],
      subnetMask: json['subnetMask'],
      color: json['color'] != null ? Color(json['color']) : null,
      isValid: json['isValid'] ?? false,
    );
  }

  /// Creates a copy of the network with updated values
  Network copyWith({
    String? id,
    String? name,
    String? ipStart,
    String? ipEnd,
    int? subnetMask,
    Color? color,
    bool? isValid,
  }) {
    return Network(
      id: id ?? this.id,
      name: name ?? this.name,
      ipStart: ipStart ?? this.ipStart,
      ipEnd: ipEnd ?? this.ipEnd,
      subnetMask: subnetMask ?? this.subnetMask,
      color: color ?? this.color,
      isValid: isValid ?? this.isValid,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Network &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          ipStart == other.ipStart &&
          ipEnd == other.ipEnd &&
          subnetMask == other.subnetMask &&
          color == other.color &&
          isValid == other.isValid;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      ipStart.hashCode ^
      ipEnd.hashCode ^
      subnetMask.hashCode ^
      color.hashCode ^
      isValid.hashCode;
}
