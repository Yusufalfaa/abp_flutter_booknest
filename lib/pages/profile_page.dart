import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

const Color lightColor = Color(0xFFF1EFE3);
const Color backgroundColor = Color(0xFFF8F8F8);
const Color primaryColor = Color(0xFFC76E6F);
const Color blackColor = Color(0xFF272727);
const Color greyColor = Color(0xFFE8E8E8);
const double buttonRadius = 12.0;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int selectedAvatar = 0;
  final List<String> avatars = [
    'assets/25.png',
    'assets/26.png',
    'assets/27.png',
    'assets/28.png',
    'assets/29.png',
    'assets/30.png',
  ];

  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  String selectedGender = 'Male';

  bool showAccountForm = false;
  bool showPasswordForm = false;

  // Password controllers
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      emailController.text = user.email ?? '';
      usernameController.text = user.displayName ?? 'User';
      mobileController.text = '08xxxxxxxxxx'; // dummy default
    }
  }

  void openAvatarSelector() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Choose Profile Picture'),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(avatars.length, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedAvatar = index;
                  });
                  Navigator.of(context).pop();
                },
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(avatars[index]),
                ),
              );
            }),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget buildMenuItem({required IconData icon, required String title, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      leading: Icon(icon, color: blackColor),
      title: Text(title, style: const TextStyle(color: blackColor)),
      trailing: const Icon(Icons.arrow_forward_ios, color: blackColor, size: 16),
      onTap: onTap ?? () {},
    );
  }


  Widget buildAccountForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () {
            setState(() {
              showAccountForm = false;
            });
          },
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          label: const Text("Back", style: TextStyle(color: primaryColor)),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: usernameController,
          style: const TextStyle(color: blackColor),
          decoration: const InputDecoration(
            labelText: 'Username',
            labelStyle: TextStyle(color: blackColor),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: blackColor),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: blackColor),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: emailController,
          style: const TextStyle(color: blackColor),
          decoration: const InputDecoration(
            labelText: 'Email',
            labelStyle: TextStyle(color: blackColor),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: blackColor),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: blackColor),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: mobileController,
          style: const TextStyle(color: blackColor),
          decoration: const InputDecoration(
            labelText: 'Mobile Number',
            labelStyle: TextStyle(color: blackColor),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: blackColor),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: blackColor),
            ),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: selectedGender,
          decoration: const InputDecoration(
            labelText: 'Gender',
            labelStyle: TextStyle(color: blackColor),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: blackColor),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: blackColor),
            ),
          ),
          dropdownColor: primaryColor,
          iconEnabledColor: blackColor,
          style: const TextStyle(color: blackColor),
          items: ['Male', 'Female', 'Other'].map((String gender) {
            return DropdownMenuItem<String>(
              value: gender,
              child: Text(gender, style: const TextStyle(color: blackColor)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedGender = value!;
            });
          },
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // TODO: Save logic
            setState(() {
              showAccountForm = false;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: lightColor, // Warna teks
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(buttonRadius),
            ),
          ),
          child: const Text('Save Changes'),
        ),
      ],
    );
  }

  Widget buildPasswordForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () {
            setState(() {
              showPasswordForm = false;
            });
          },
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          label: const Text("Back", style: TextStyle(color: primaryColor)),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: currentPasswordController,
          obscureText: true,
          style: const TextStyle(color: blackColor),
          decoration: const InputDecoration(
            labelText: 'Current Password',
            labelStyle: TextStyle(color: blackColor),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: blackColor),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: blackColor),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: newPasswordController,
          obscureText: true,
          style: const TextStyle(color: blackColor),
          decoration: const InputDecoration(
            labelText: 'New Password',
            labelStyle: TextStyle(color: blackColor),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: blackColor),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: blackColor),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: confirmPasswordController,
          obscureText: true,
          style: const TextStyle(color: blackColor),
          decoration: const InputDecoration(
            labelText: 'Confirm Password',
            labelStyle: TextStyle(color: blackColor),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: blackColor),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: blackColor),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // TODO: Password update logic
            setState(() {
              showPasswordForm = false;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: lightColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(buttonRadius),
            ),
          ),
          child: const Text('Save Password'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            height: size.height,
            color: lightColor,
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: openAvatarSelector,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: AssetImage(avatars[selectedAvatar]),
                        backgroundColor: Colors.pinkAccent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: openAvatarSelector,
                      style: TextButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(buttonRadius),
                        ),
                      ),
                      child: const Text(
                        "Update Photo",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    Text(usernameController.text,
                        style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(emailController.text, style: const TextStyle(color: Colors.black)),
                    const SizedBox(height: 30),

                    // Menu / Form
                    Container(
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: showAccountForm
                          ? buildAccountForm()
                          : showPasswordForm
                          ? buildPasswordForm()
                          : Column(
                        children: [
                          buildMenuItem(
                            icon: Icons.person,
                            title: "Account",
                            onTap: () => setState(() => showAccountForm = true),
                          ),
                          const Divider(color: Colors.white),
                          buildMenuItem(
                            icon: Icons.lock,
                            title: "Change Password",
                            onTap: () => setState(() => showPasswordForm = true),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
