class ProfileModel {
  final String? id; // Nullable ID for Firestore documents
  final String? userId; // Add userId to link with Firebase Authentication
  final String name; // Non-nullable, required field
  final int age; // Non-nullable, required field
  final String contactNumber; // Non-nullable, required field
  final String? gender; // Optional, can be null
  final String? vehiclePreference; // Optional, can be null
  final int experienceYears; // Non-nullable, required field
  final String? profileImageUrl; // Optional, can be null
  final String? licenseImageUrl; // Optional, can be null

  // Constructor with required and optional fields
  ProfileModel({
    this.id, // ID is optional; Firestore assigns it if not provided
    this.userId, // Add userId to constructor
    required this.name,
    required this.age,
    required this.contactNumber,
    this.gender,
    this.vehiclePreference,
    required this.experienceYears,
    this.profileImageUrl,
    this.licenseImageUrl,
  });

  /// Factory method to create a `ProfileModel` from a Firestore map
  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    try {
      return ProfileModel(
        id: map['id'] as String?, // Ensure proper casting
        userId: map['userId'] as String?, // Add userId parsing
        name: map['name'] as String,
        age: map['age'] as int,
        contactNumber: map['contactNumber'] as String,
        gender: map['gender'] as String?,
        vehiclePreference: map['vehiclePreference'] as String?,
        experienceYears: map['experienceYears'] as int,
        profileImageUrl: map['profileImageUrl'] as String?,
        licenseImageUrl: map['licenseImageUrl'] as String?,
      );
    } catch (e) {
      throw Exception("Error parsing profile data: $e");
    }
  }

  /// Method to convert a `ProfileModel` instance into a Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId, // Add userId to the map
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

  // CopyWith method to allow creating a modified copy of the model
  ProfileModel copyWith({
    String? id,
    String? userId, // Add userId to copyWith
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
      userId: userId ?? this.userId, // Add userId handling
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
