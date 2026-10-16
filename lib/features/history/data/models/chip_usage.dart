class ChipUsage {
  final String name;
  final String time;
  final int event;

  ChipUsage({required this.name, required this.time, required this.event});

  factory ChipUsage.fromJson(Map<String, dynamic> json) {
    return ChipUsage(
      name: json['name'],
      time: json['time'],
      event: json['event'],
    );
  }

  String get displayName {
    switch (name) {
      case 'wildcard':  return 'Wildcard 🃏';
      case 'freehit':   return 'Free Hit ⚡';
      case 'bboost':    return 'Bench Boost 💺';
      case '3xc':       return 'Triple Captain ©©©';
      default:          return name;
    }
  }
}
