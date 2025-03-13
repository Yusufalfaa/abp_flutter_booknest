import 'package:booknest/main.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({Key? key}) : super(key: key);

  @override
  State<FaqPage> createState() => _FaqPage();
}

class _FaqPage extends State<FaqPage> {
  // Track which panel is expanded
  int? expandedIndex = 0;

  // FAQ data
  final List<Map<String, String>> faqItems = [
    {
      'question': 'How do I change my password?',
      'answer': 'To change your password, proceed to menu and select a profile. Then retype your current password and click confirm.'
    },
    {
      'question': 'How do I update my profile information?',
      'answer': 'Go to your profile page by tapping on your avatar. Then tap the "Edit" button to update your information.'
    },
    {
      'question': 'Can I delete my account?',
      'answer': 'Yes, you can delete your account from the Settings menu. Please note that this action is permanent and cannot be undone.'
    },
    {
      'question': 'How do I report a problem?',
      'answer': 'You can report problems through the "Help & Support" section in the app settings or by contacting us directly via WhatsApp.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Pink header section
          Container(
            color: const Color(0xFFC76E6F), // Pink/salmon color
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title section
                  const SizedBox(height: 24),
                  const Text(
                    'FAQ and Support',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Dind\'t find the answer you were looking for?\ncontact our support center!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Contact Us
                  InkWell(
                    onTap: () async {
                      final Uri emailUri = Uri(
                        scheme: 'mailto',
                        path: 'adminbooknest@gmail.com',
                        queryParameters: {
                          'subject': 'Support Inquiry',
                        },
                      );
                      if (await canLaunchUrl(emailUri)) {
                        await launchUrl(emailUri);
                      } else {
                        debugPrint('Could not launch $emailUri');
                      }
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.email,
                              color: primaryColor,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Contact Us',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                ],
              ),
            ),
          ),

          // FAQ accordion list
          Expanded(
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: faqItems.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1EFE3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent,
                        ),
                        child: ExpansionTile(
                          initiallyExpanded: index == expandedIndex,
                          onExpansionChanged: (isExpanded) {
                            setState(() {
                              expandedIndex = isExpanded ? index : null;
                            });
                          },
                          title: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              faqItems[index]['question']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          trailing: Icon(
                            expandedIndex == index
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.black54,
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Text(
                                faqItems[index]['answer']!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}