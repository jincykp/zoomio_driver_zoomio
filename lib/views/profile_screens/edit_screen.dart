import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zoomio_driverzoomio/data/model/profile_model.dart';
import 'package:zoomio_driverzoomio/data/services/profile_services.dart';
import 'package:zoomio_driverzoomio/data/storage/img_storage.dart';
import 'package:zoomio_driverzoomio/views/bottom_screens.dart';
import 'package:zoomio_driverzoomio/views/custom_widgets/custom_button.dart';
import 'package:zoomio_driverzoomio/views/custom_widgets/textformfields.dart';
import 'package:zoomio_driverzoomio/views/styles/app_styles.dart';

class EditProfileScreen extends StatefulWidget {
  final String driverId;

  const EditProfileScreen({super.key, required this.driverId});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController = TextEditingController();
  late TextEditingController ageController = TextEditingController();
  late TextEditingController contactController = TextEditingController();
  late TextEditingController experienceController = TextEditingController();

  String? selectedGender;
  String? selectedVehiclePreference;
  String? profileImg;
  String? licenseImg;
  ProfileModel? profile;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ProfileRepository profileServices = ProfileRepository();

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  bool _isLoading = true;
  Future<void> _fetchProfileData() async {
    try {
      ProfileModel fetchedProfile = await profileServices.getProfileData();

      if (mounted) {
        // Check if widget is still mounted
        setState(() {
          _isLoading = false; // Set loading to false when data is fetched
          profile = fetchedProfile;

          nameController = TextEditingController(text: profile?.name ?? '');
          ageController =
              TextEditingController(text: profile?.age.toString() ?? '');
          contactController =
              TextEditingController(text: profile?.contactNumber ?? '');
          experienceController = TextEditingController(
              text: profile?.experienceYears.toString() ?? '');

          selectedGender = profile?.gender;
          selectedVehiclePreference = profile?.vehiclePreference;
          profileImg = profile?.profileImageUrl;
          licenseImg = profile?.licenseImageUrl;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false; // Set loading to false even if there's an error
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching profile: $e')));
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    contactController.dispose();
    experienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Edit Your Profile",
            style: Textstyles.blackHead,
          ),
        ),
        backgroundColor: ThemeColors.primaryColor,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: ThemeColors.primaryColor,
            ))
          : SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: const BoxDecoration(
                        color: ThemeColors.primaryColor,
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(50),
                          bottomLeft: Radius.circular(50),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                backgroundColor: ThemeColors.textColor,
                                maxRadius: 70,
                                backgroundImage: profileImg != null
                                    ? NetworkImage(profileImg!)
                                    : null,
                                child: profileImg == null
                                    ? const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: ThemeColors.titleColor,
                                      )
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () => selectProfileImage(),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      size: 25,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: screenWidth * 0.88,
                      child: Profilefields(
                        controller: nameController,
                        hintText: "Name",
                        validator: (value) => validateName(value),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: screenWidth * 0.88,
                      child: Profilefields(
                        controller: ageController,
                        hintText: "Age",
                        keyBoardType: TextInputType.number,
                        validator: (value) => validateAge(value),
                        inputFormatters: [LengthLimitingTextInputFormatter(2)],
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: screenWidth * 0.88,
                      child: Profilefields(
                        controller: contactController,
                        hintText: "Contact Number",
                        keyBoardType: TextInputType.number,
                        validator: (value) => validateContact(value),
                        inputFormatters: [LengthLimitingTextInputFormatter(10)],
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownField(
                      value: selectedGender,
                      hint: "Select Gender",
                      items: ["Male", "Female", "Other"],
                      onChanged: (newValue) {
                        setState(() {
                          selectedGender = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownField(
                      value: selectedVehiclePreference,
                      hint: "Select Vehicle Preference",
                      items: ["Bike", "Car", "Both"],
                      onChanged: (newValue) {
                        setState(() {
                          selectedVehiclePreference = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: screenWidth * 0.88,
                      child: Profilefields(
                        controller: experienceController,
                        hintText: "Experience (Years)",
                        keyBoardType: TextInputType.number,
                        validator: (value) => validateExperience(value),
                        inputFormatters: [LengthLimitingTextInputFormatter(2)],
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: screenWidth * 0.9,
                      child: CustomButtons(
                        text: "Save Changes",
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            final updatedProfile = ProfileModel(
                              name: nameController.text,
                              age: int.tryParse(ageController.text) ?? 0,
                              contactNumber: contactController.text,
                              gender: selectedGender,
                              vehiclePreference: selectedVehiclePreference,
                              experienceYears:
                                  int.tryParse(experienceController.text) ?? 0,
                              profileImageUrl: profileImg,
                              licenseImageUrl: licenseImg,
                            );

                            try {
                              await profileServices
                                  .updateProfile(updatedProfile);
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                backgroundColor: ThemeColors.successColor,
                                content:
                                    const Text("Profile updated successfully!"),
                              ));
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BottomScreens(),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text("Error updating profile: $e"),
                              ));
                            }
                          }
                        },
                        backgroundColor: ThemeColors.primaryColor,
                        textColor: ThemeColors.textColor,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> selectProfileImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final url = await ImageStorageService().uploadProfileImg(
        pickedImage.path,
        context,
      );
      setState(() {
        profileImg = url;
      });
    }
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) return "Please enter your name";
    if (value.length < 3) return "Name must be at least 3 characters long";
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return "Name can only contain letters and spaces";
    }
    return null;
  }

  String? validateAge(String? value) {
    final age = int.tryParse(value ?? '');
    if (age == null) return "Age must be a number";
    if (age < 19 || age > 65) return "Age must be between 19 and 65";
    return null;
  }

  String? validateContact(String? value) {
    if (value == null || value.isEmpty) return "Please enter your contact";
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
      return "Contact must be 10 digits long";
    }
    return null;
  }

  String? validateExperience(String? value) {
    final exp = int.tryParse(value ?? '');
    if (exp == null || exp < 0) return "Experience must be a positive number";
    return null;
  }
}

class DropdownField extends StatelessWidget {
  final String? value;
  final String hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const DropdownField({
    super.key,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.88,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) =>
            value == null || value.isEmpty ? "Please select an option" : null,
      ),
    );
  }
}
