class ProfileModel {
  String? id; // Unique identifier for the profile
  String name;
  int age;
  String contactNumber;
  String? gender;
  String? vehiclePreference;
  int experienceYears;
  String? profileImageUrl;
  String? licenseImageUrl;

  ProfileModel({
    this.id,
    required this.name,
    required this.age,
    required this.contactNumber,
    required this.gender,
    required this.vehiclePreference,
    required this.experienceYears,
    this.profileImageUrl,
    this.licenseImageUrl,
  });

  // Factory method to create a Profile instance from a map
  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'],
      name: map['name'],
      age: map['age'],
      contactNumber: map['contactNumber'],
      gender: map['gender'],
      vehiclePreference: map['vehiclePreference'],
      experienceYears: map['experienceYears'],
      profileImageUrl: map['profileImageUrl'],
      licenseImageUrl: map['licenseImageUrl'],
    );
  }

  // Method to convert Profile instance to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'contactNumber': contactNumber,
      'gender': gender,
      'vehiclePreference': vehiclePreference,
      'experienceYears': experienceYears,
      'profileImageUrl': profileImageUrl,
      'licenseImageUrl': licenseImageUrl,
    };
  }
}
