import 'dart:convert';

class UserProfile {
  String firstName;
  String lastName;
  double height; // en cm
  double weight; // en kg
  int age;
  String nationality;

  UserProfile({
    this.firstName = '',
    this.lastName = '',
    this.height = 0,
    this.weight = 0,
    this.age = 0,
    this.nationality = '',
  });

  // Calcul de l'IMC (Indice de Masse Corporelle)
  double get bmi {
    if (height <= 0 || weight <= 0) return 0;
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  String get bmiCategory {
    if (bmi <= 0) return 'Non calculé';
    if (bmi < 18.5) return 'Insuffisance pondérale';
    if (bmi < 25) return 'Poids normal';
    if (bmi < 30) return 'Surpoids';
    return 'Obésité';
  }

  // Conversion en JSON pour la sauvegarde
  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'height': height,
        'weight': weight,
        'age': age,
        'nationality': nationality,
      };

  // Création depuis JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        firstName: json['firstName'] ?? '',
        lastName: json['lastName'] ?? '',
        height: (json['height'] ?? 0).toDouble(),
        weight: (json['weight'] ?? 0).toDouble(),
        age: json['age'] ?? 0,
        nationality: json['nationality'] ?? '',
      );

  // Conversion en String JSON
  String toJsonString() => jsonEncode(toJson());

  // Création depuis String JSON
  factory UserProfile.fromJsonString(String jsonString) {
    try {
      return UserProfile.fromJson(jsonDecode(jsonString));
    } catch (e) {
      return UserProfile();
    }
  }

  bool get isComplete =>
      firstName.isNotEmpty &&
      lastName.isNotEmpty &&
      height > 0 &&
      weight > 0 &&
      age > 0 &&
      nationality.isNotEmpty;
}

