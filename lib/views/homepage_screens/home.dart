import 'package:flutter/material.dart';
import 'package:zoomio_driverzoomio/data/services/auth_services.dart';
import 'package:zoomio_driverzoomio/views/auth_screens/signin_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthServices auth = AuthServices();
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text(
                      "Logout Confirmation",
                      //   style: Textstyles.buttonText,
                    ),
                    content: const Text("Are you sure you want to logout?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await auth.signout();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignInScreen()),
                          );
                        },
                        child: const Text("Logout"),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              width: double.infinity,
              // child: Container(
              //   decoration: BoxDecoration(
              //     color:
              //         const Color.fromARGB(255, 66, 60, 60), // Outer box color
              //     borderRadius: BorderRadius.circular(19),
              //   ),
              //   child: Padding(
              //     padding: const EdgeInsets.all(
              //         15.0), // Padding inside the outer box
              //     child: Container(
              //       decoration: BoxDecoration(
              //         // color: const Color.fromARGB(
              //         //     255, 228, 226, 226), // Inner box color
              //         borderRadius: BorderRadius.circular(
              //             15), // Slightly smaller radius for inner box
              //         boxShadow: const [
              //           BoxShadow(
              //             //color: Colors.grey.withOpacity(0.5),
              //             spreadRadius: 1,
              //             blurRadius: 5,
              //             offset: Offset(0, 3), // Shadow position
              //           ),
              //         ],
              //       ),
              //       child: TextFormField(
              //         decoration: const InputDecoration(
              //           hintText: "Where would you go?",
              //           hintStyle: TextStyle(
              //             color: Colors.grey,
              //             fontSize: 14,
              //           ),
              //           prefixIcon: Icon(
              //             Icons.search,
              //             size: 25,
              //           ),
              //           border: OutlineInputBorder(
              //               borderRadius: BorderRadius.all(
              //                 Radius.circular(15),
              //               ),
              //               borderSide:
              //                   BorderSide(color: ThemeColors.primaryColor)

              //               // Removes border line from TextFormField
              //               ),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            ),
          ],
        ),
      ),
    );
  }
}
