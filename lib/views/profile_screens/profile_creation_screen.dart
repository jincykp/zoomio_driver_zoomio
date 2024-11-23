// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:zoomio_driverapp/data/storage/img_storage.dart';
// import 'package:zoomio_driverapp/views/bottom_screens.dart';
// import 'package:zoomio_driverapp/views/custom_widgets/custom_button.dart';
// import 'package:zoomio_driverapp/views/custom_widgets/textformfields.dart';
// import 'package:zoomio_driverapp/views/profile_screens/secondprofile.dart';
// import 'package:zoomio_driverapp/views/styles/app_styles.dart';

// class ProfileCreationScreen extends StatefulWidget {
//   const ProfileCreationScreen({super.key});

//   @override
//   State<ProfileCreationScreen> createState() => _ProfileCreationScreenState();
// }

// class _ProfileCreationScreenState extends State<ProfileCreationScreen> {
//   final nameController = TextEditingController();
//   final ageController = TextEditingController();
//   final contactController = TextEditingController();
//   final genderController = TextEditingController();
//   final vehiclePreferenceController = TextEditingController();
//   final experienceController = TextEditingController();
//   final GlobalKey<FormState> formKey = GlobalKey<FormState>();
//   String? selectedGender;
//   String? selectedVehiclePreference;
//   String? profileImg;
//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(12.0),
//           child: SingleChildScrollView(
//             child: Form(
//               key: formKey,
//               child: Column(
//                 children: [
//                   const Text(
//                     "Create Your Profile",
//                     style: Textstyles.blackHead,
//                   ),
//                   const SizedBox(height: 20),
//                   Center(
//                     child: Stack(
//                       children: [
//                         Container(
//                           decoration: BoxDecoration(
//                             color: ThemeColors.primaryColor,
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                           width: 120,
//                           height: 120,
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(30),
//                             child: profileImg != null
//                                 ? Image.network(
//                                     profileImg!,
//                                     fit: BoxFit.cover,
//                                     errorBuilder: (context, error, stackTrace) {
//                                       return const Icon(
//                                         Icons.broken_image,
//                                         color: Colors.white,
//                                       );
//                                     },
//                                   )
//                                 : const Center(
//                                     child: Icon(
//                                       Icons.person,
//                                       size: 80,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                           ),
//                         ),
//                         Positioned(
//                           bottom: 0,
//                           right: 0,
//                           child: GestureDetector(
//                             onTap: () {
//                               profileImage(context);
//                             },
//                             child: Container(
//                               padding: const EdgeInsets.all(8),
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.1),
//                                     blurRadius: 8,
//                                     offset: const Offset(0, 3),
//                                   ),
//                                 ],
//                               ),
//                               child: const Icon(
//                                 Icons.add_a_photo,
//                                 size: 25,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   SingleChildScrollView(
//                     child: Container(
//                       padding: const EdgeInsets.only(top: 28),
//                       decoration: BoxDecoration(
//                         color: const Color.fromARGB(255, 236, 204, 96),
//                         borderRadius: BorderRadius.circular(50),
//                       ),
//                       child: Column(
//                         children: [
//                           SizedBox(
//                             width: screenWidth * 0.78,
//                             child: ProfileFields(
//                               controller: nameController,
//                               textStyle: const TextStyle(color: Colors.black),
//                               hintText: "Name",
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return "Please enter your name";
//                                 }
//                                 if (value.length <= 3) {
//                                   return "Name must be at least 3 characters long";
//                                 }
//                                 final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
//                                 if (!nameRegex.hasMatch(value)) {
//                                   return "Name can only contain letters and spaces";
//                                 }
//                                 return null;
//                               },
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           SizedBox(
//                             width: screenWidth * 0.88,
//                             child: Profilefields(
//                               controller: ageController,
//                               textStyle: const TextStyle(color: Colors.black),
//                               hintText: "Age",
//                               keyBoardType: TextInputType.number,
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return "Please enter your age";
//                                 }
//                                 final age = int.tryParse(value);
//                                 if (age == null) {
//                                   return "Age must be a number";
//                                 }
//                                 if (age > 65) {
//                                   return "Age greater than 65 is not allowed";
//                                 }
//                                 if (age < 19) {
//                                   return "Age must be at least 19";
//                                 }
//                                 return null;
//                               },
//                               inputFormatters: [
//                                 LengthLimitingTextInputFormatter(2),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           SizedBox(
//                             width: screenWidth * 0.88,
//                             child: Profilefields(
//                               controller: contactController,
//                               hintText: "Contact Number",
//                               textStyle: const TextStyle(color: Colors.black),
//                               keyBoardType: TextInputType.number,
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return "Please enter your mobile number";
//                                 }
//                                 if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
//                                   return "Please enter a valid mobile number";
//                                 }
//                                 if (value.length != 10) {
//                                   return "Mobile number must be 10 digits long";
//                                 }
//                                 return null;
//                               },
//                               inputFormatters: [
//                                 LengthLimitingTextInputFormatter(10),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           SizedBox(
//                             width: screenWidth * 0.88,
//                             child: DropdownButtonFormField<String>(
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return "Please enter your gender";
//                                 }
//                                 return null;
//                               },
//                               decoration: const InputDecoration(
//                                 border: OutlineInputBorder(
//                                   borderRadius:
//                                       BorderRadius.all(Radius.circular(19)),
//                                 ),
//                               ),
//                               value: selectedGender,
//                               style: const TextStyle(
//                                 color: Colors.black,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                               hint: const Text(
//                                 "Select Gender",
//                                 style: TextStyle(color: Colors.black),
//                               ),
//                               onChanged: (newValue) {
//                                 setState(() {
//                                   selectedGender = newValue;
//                                 });
//                               },
//                               items: [
//                                 "Male",
//                                 "Female",
//                                 "Other"
//                               ].map<DropdownMenuItem<String>>((String value) {
//                                 return DropdownMenuItem<String>(
//                                   value: value,
//                                   child: Text(value),
//                                 );
//                               }).toList(),
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           SizedBox(
//                             width: screenWidth * 0.88,
//                             child: DropdownButtonFormField<String>(
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return "Please enter your vehicle preference";
//                                 }
//                                 return null;
//                               },
//                               decoration: const InputDecoration(
//                                 border: OutlineInputBorder(
//                                   borderRadius:
//                                       BorderRadius.all(Radius.circular(19)),
//                                 ),
//                               ),
//                               value: selectedVehiclePreference,
//                               style: const TextStyle(
//                                 color: Colors.black,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                               hint: const Text(
//                                 "Select Vehicle Preference",
//                                 style: TextStyle(color: Colors.black),
//                               ),
//                               onChanged: (newValue) {
//                                 setState(() {
//                                   selectedVehiclePreference = newValue;
//                                 });
//                               },
//                               items: [
//                                 "Bike",
//                                 "Car",
//                                 "Both"
//                               ].map<DropdownMenuItem<String>>((String value) {
//                                 return DropdownMenuItem<String>(
//                                   value: value,
//                                   child: Text(value),
//                                 );
//                               }).toList(),
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           SizedBox(
//                             width: screenWidth * 0.88,
//                             child: Profilefields(
//                               controller: experienceController,
//                               hintText: "Experience (Years)",
//                               textStyle: const TextStyle(color: Colors.black),
//                               keyBoardType: TextInputType.number,
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return "Please enter your experienced years";
//                                 }
//                                 return null;
//                               },
//                               inputFormatters: [
//                                 LengthLimitingTextInputFormatter(2),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(height: 30),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20), // Spacing before the button
//                   CustomButtons(
//                     text: "Create Profile",
//                     onPressed: () {
//                       Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => ProfileScreenTwo()));
//                       // Submit profile creation logic
//                       print("Profile Created");
//                     },
//                     backgroundColor: ThemeColors.primaryColor,
//                     textColor: ThemeColors.textColor,
//                     screenWidth: screenWidth,
//                     screenHeight: screenHeight,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> profileImage(BuildContext context) async {
//     final imagePicker = ImagePicker();
//     final pickedImage =
//         await imagePicker.pickImage(source: ImageSource.gallery);
//     if (pickedImage != null) {
//       String? res = await ImageStorageService()
//           .uploadProfileImg(pickedImage.path, context);
//       setState(() {
//         profileImg = res;
//       });
//     }
//   }

//   // addProfileDetails() {
//   //   if (formKey.currentState!.validate()) {
//   //     ProfileModel profileModel = ProfileModel(
//   //         id: ,
//   //         name: nameController.text,
//   //         age: int.parse(ageController.text),
//   //         contactNumber: contactController.text,
//   //         gender: selectedGender!,
//   //         vehiclePreference: selectedVehiclePreference!,
//   //         experience: int.parse(experienceController.text),
//   //         profileImg: profileImg);
//   //   }
//   // }
// }
