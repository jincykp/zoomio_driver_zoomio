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

class ProfileScreenTwo extends StatefulWidget {
  const ProfileScreenTwo({super.key, String? email, String? displayName});

  @override
  State<ProfileScreenTwo> createState() => _ProfileScreenTwoState();
}

class _ProfileScreenTwoState extends State<ProfileScreenTwo> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final contactController = TextEditingController();
  final genderController = TextEditingController();
  final vehiclePreferenceController = TextEditingController();
  final experienceController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? selectedGender;
  String? selectedVehiclePreference;
  String? profileImg;
  String? licenseImg;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final ProfileRepository profileServices = ProfileRepository();

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Create Your Profile",
            style: Textstyles.blackHead,
          ),
        ),
        backgroundColor: ThemeColors.primaryColor,
      ),
      body: SingleChildScrollView(
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
                        bottomLeft: Radius.circular(50))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          backgroundColor: ThemeColors.textColor,
                          maxRadius: 50,
                          minRadius: 50,
                          backgroundImage: profileImg != null
                              ? NetworkImage(profileImg!)
                              : null,
                          child: profileImg ==
                                  null // Show icon when there is no image
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
                            onTap: () {
                              profileImage(context); // Method to select image
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withOpacity(0.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.add_a_photo,
                                size: 25,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          SizedBox(
                            width: screenWidth * 0.6,
                            child: Profilefields(
                              controller: nameController,
                              //  textStyle: const TextStyle(color: Colors.black),
                              hintText: "Name",
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter your name";
                                }
                                if (value.length < 3) {
                                  return "Name must be at least 3 characters long";
                                }
                                final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
                                if (!nameRegex.hasMatch(value)) {
                                  return "Name can only contain letters and spaces";
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: screenWidth * 0.6,
                            child: Profilefields(
                              controller: ageController,
                              // textStyle: const TextStyle(color: Colors.black),
                              hintText: "Age",
                              keyBoardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter your age";
                                }
                                final age = int.tryParse(value);
                                if (age == null) {
                                  return "Age must be a number";
                                }
                                if (age > 65) {
                                  return "Age greater than 65 is not allowed";
                                }
                                if (age < 19) {
                                  return "Age must be at least 19";
                                }
                                return null;
                              },
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(2),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: screenWidth * 0.88,
                child: Profilefields(
                  controller: contactController,
                  hintText: "Contact Number",
                  //  textStyle: const TextStyle(color: Colors.black),
                  keyBoardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your mobile number";
                    }
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return "Please enter a valid mobile number";
                    }
                    if (value.length != 10) {
                      return "Mobile number must be 10 digits long";
                    }
                    return null;
                  },
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(10),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: screenWidth * 0.88,
                child: DropdownButtonFormField<String>(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your gender";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(19)),
                    ),
                  ),
                  value: selectedGender,
                  style: const TextStyle(
                    //  color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  hint: const Text(
                    "Select Gender",
                    // style: TextStyle(color: Colors.black),
                  ),
                  onChanged: (newValue) {
                    setState(() {
                      selectedGender = newValue;
                    });
                  },
                  items: ["Male", "Female", "Other"]
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: screenWidth * 0.88,
                child: DropdownButtonFormField<String>(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your vehicle preference";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(19)),
                    ),
                  ),
                  value: selectedVehiclePreference,
                  style: const TextStyle(
                    //  color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  hint: const Text(
                    "Select Vehicle Preference",
                    //  style: TextStyle(color: Colors.black),
                  ),
                  onChanged: (newValue) {
                    setState(() {
                      selectedVehiclePreference = newValue;
                    });
                  },
                  items: ["Bike", "Car", "Both"]
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: screenWidth * 0.88,
                child: Profilefields(
                  controller: experienceController,
                  hintText: "Experience (Years)",
                  //  textStyle: const TextStyle(color: Colors.black),
                  keyBoardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your experienced years";
                    }
                    return null;
                  },
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(2),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              SizedBox(
                width: screenWidth * 0.9,
                child: CustomButtons(
                    text: "Submit",
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final profile = ProfileModel(
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
                          await profileServices.saveProfileData(profile);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor: ThemeColors.successColor,
                              content: const Text(
                                  "Profile details added successfully")));

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BottomScreens()),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Error saving profile: $e")));
                        }
                      }
                    },
                    backgroundColor: ThemeColors.primaryColor,
                    textColor: ThemeColors.textColor,
                    screenWidth: screenWidth,
                    screenHeight: screenHeight),
              ),
              const SizedBox(
                height: 15,
              ),
              SizedBox(
                width: screenWidth * 0.9,
                child: TextButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(30)),
                      ),
                      builder: (context) {
                        return Container(
                          height: 400,
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(screenWidth * 0.09),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Container(
                                      width: screenWidth *
                                          0.8, // Use 0.8 for 80% width
                                      height: 250,
                                      decoration: BoxDecoration(
                                        // color: Colors
                                        // .amberAccent, // Set the color inside the decoration
                                        image: licenseImg != null
                                            ? DecorationImage(
                                                image: NetworkImage(
                                                    licenseImg!), // Use NetworkImage if licenseImg is not null
                                                fit: BoxFit
                                                    .cover, // Adjust the fit as needed
                                              )
                                            : null, // No decoration image if licenseImg is null
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        licenseImage(context);
                                      },
                                      icon: const Icon(
                                          Icons.add_a_photo_outlined,
                                          size: 30),
                                    ),
                                    ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Submit"))
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: const Text(
                    "Click to add your license",
                    style: Textstyles.addText,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> profileImage(BuildContext context) async {
    final imagePicker = ImagePicker();
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      String? res = await ImageStorageService()
          .uploadProfileImg(pickedImage.path, context);
      setState(() {
        profileImg = res;
      });
    }
  }

  Future<void> licenseImage(BuildContext context) async {
    final imagePicker = ImagePicker();
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      try {
        String? resf = await ImageStorageService()
            .uploadLicenseImg(pickedImage.path, context);

        if (resf != null) {
          // Force refresh by appending a random query parameter (timestamp)
          setState(() {
            licenseImg =
                "$resf?timestamp=${DateTime.now().millisecondsSinceEpoch}";
            print("SELECTED IMAGE  URL: $licenseImg");
          });
        }
      } catch (e) {
        print("Error uploading image: $e");
      }
    }
  }
}
