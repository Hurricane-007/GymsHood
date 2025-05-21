class Location {
  final String address;
  final List<double> coordinates;

  Location({
    required this.address,
    required this.coordinates,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    final rawCoords = json['coordinates'];

    final List<double> coords = (rawCoords is List)
        ? rawCoords.map((e) {
            if (e is num) return e.toDouble();
            return 0.0;
          }).toList()
        : [0.0, 0.0];

    return Location(
      address: json['address'] ?? '',
      coordinates: coords,
    );
  }

  Map<String, dynamic> toJson() => {
        'address': address,
        'coordinates': coordinates,
      };
}