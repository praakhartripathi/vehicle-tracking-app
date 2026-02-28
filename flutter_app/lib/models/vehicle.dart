class Vehicle {
  final String id;
  final String name;
  final String status;

  const Vehicle({
    required this.id,
    required this.name,
    required this.status,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String,
      name: json['name'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
    };
  }

  Vehicle copyWith({String? status}) {
    return Vehicle(id: id, name: name, status: status ?? this.status);
  }
}
