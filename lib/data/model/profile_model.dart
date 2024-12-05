class ProfileModel {
  final String? id; // Unique identifier for Firestore and app logic.
  final String name;
  final int age;
  final String contactNumber;
  final String? gender;
  final String? vehiclePreference;
  final int experienceYears;
  final String? profileImageUrl;
  final String? licenseImageUrl;

  ProfileModel({
    this.id,
    required this.name,
    required this.age,
    required this.contactNumber,
    this.gender,
    this.vehiclePreference,
    required this.experienceYears,
    this.profileImageUrl,
    this.licenseImageUrl,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map,
      {required String docId}) {
    return ProfileModel(
      id: docId, // Always use Firestore's document ID
      name: map['name'] as String,
      age: map['age'] as int,
      contactNumber: map['contactNumber'] as String,
      gender: map['gender'] as String?,
      vehiclePreference: map['vehiclePreference'] as String?,
      experienceYears: map['experienceYears'] as int,
      profileImageUrl: map['profileImageUrl'] as String?,
      licenseImageUrl: map['licenseImageUrl'] as String?,
    );
  }

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

  ProfileModel copyWith({
    String? id,
    String? name,
    int? age,
    String? contactNumber,
    String? gender,
    String? vehiclePreference,
    int? experienceYears,
    String? profileImageUrl,
    String? licenseImageUrl,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      contactNumber: contactNumber ?? this.contactNumber,
      gender: gender ?? this.gender,
      vehiclePreference: vehiclePreference ?? this.vehiclePreference,
      experienceYears: experienceYears ?? this.experienceYears,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      licenseImageUrl: licenseImageUrl ?? this.licenseImageUrl,
    );
  }
}
