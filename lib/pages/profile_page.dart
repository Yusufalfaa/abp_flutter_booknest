import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  String avatar = '';
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  String selectedGender = 'Male';

  bool showAccountForm = false;
  bool showPasswordForm = false;

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final List<String> avatars = [
    'assets/25.png',
    'assets/26.png',
    'assets/27.png',
    'assets/28.png',
    'assets/29.png',
    'assets/30.png',
  ];

  @override
  void initState() {
    super.initState();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          avatar = data['avatar'] ?? 'assets/27.png';
          emailController.text = data['email'] ?? user.email ?? '';
          usernameController.text = data['username'] ?? 'User';
          mobileController.text = data['mobileNumber'] ?? '';
          selectedGender = data['gender'] ?? 'Male';
        });
      }
    }
  }

  void openAvatarSelector() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: backgroundColor,
        title: const Text('Choose Profile Picture'),
        content: SingleChildScrollView(
          child: Center(
            child: Wrap(
              alignment: WrapAlignment.center, // Penting untuk center
              spacing: 16,
              runSpacing: 16,
              children: avatars.map((path) {
                return GestureDetector(
                  onTap: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                        'avatar': path,
                      });
                      setState(() {
                        avatar = path;
                      });
                    }
                    Navigator.of(context).pop();
                  },
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage(path),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: primaryColor), // Ganti warna teks
            ),
          ),
        ],
      ),
    );
  }

  Future<void> saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
        'mobileNumber': mobileController.text.trim(),
        'gender': selectedGender,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      setState(() {
        showAccountForm = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
    }
  }

  Widget buildMenuItem({required IconData icon, required String title, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      leading: Icon(icon, color: blackColor),
      title: Text(title, style: const TextStyle(color: blackColor)),
      trailing: const Icon(Icons.arrow_forward_ios, color: blackColor, size: 16),
      onTap: onTap,
    );
  }

  Widget buildAccountForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () => setState(() => showAccountForm = false),
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          label: const Text("Back", style: TextStyle(color: primaryColor)),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: usernameController,
          decoration: const InputDecoration(labelText: 'Username'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: mobileController,
          decoration: const InputDecoration(labelText: 'Mobile Number'),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: selectedGender,
          decoration: const InputDecoration(labelText: 'Gender'),
          items: ['Male', 'Female', 'Other'].map((gender) {
            return DropdownMenuItem(value: gender, child: Text(gender));
          }).toList(),
          onChanged: (val) => setState(() => selectedGender = val!),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: saveProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRadius)),
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
          onPressed: () => setState(() => showPasswordForm = false),
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          label: const Text("Back", style: TextStyle(color: primaryColor)),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: currentPasswordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Current Password'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: newPasswordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'New Password'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: confirmPasswordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Confirm Password'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            setState(() {
              showPasswordForm = false;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRadius)),
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
          Container(height: size.height, color: lightColor),
          SafeArea(
            child: SingleChildScrollView(
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
                      backgroundImage: AssetImage(avatar),
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
                    child: const Text("Update Photo", style: TextStyle(color: Colors.white)),
                  ),
                  Text(usernameController.text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(emailController.text),
                  const SizedBox(height: 30),
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
                        const Divider(),
                        buildMenuItem(
                          icon: Icons.lock,
                          title: "Change Password",
                          onTap: () => setState(() => showPasswordForm = true),
                        ),
                        const Divider(),
                        ElevatedButton(
                          onPressed: saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(buttonRadius),
                            ),
                          ),
                          child: const Text('Save Profile', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
