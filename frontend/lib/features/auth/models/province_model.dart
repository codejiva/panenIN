// lib/features/signup/models/province.dart
class Province {
  final String name;

  Province({required this.name});

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      name: json['name'] ?? '',
    );
  }
}
