import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zoomio_driverzoomio/views/styles/app_styles.dart';

class HelpSupportScreen extends StatelessWidget {
  HelpSupportScreen({Key? key}) : super(key: key);

  final List<FAQItem> faqList = [
    FAQItem(
        question: "What should I do if a passenger leaves an item in my car?",
        answer:
            "Report it immediately through the Lost & Found section. Store the item safely and coordinate with support for return."),
    FAQItem(
        question: "How is my driver rating calculated?",
        answer:
            "Ratings are based on your last 500 trips. Passengers rate from 1-5 stars based on service quality, safety, and cleanliness."),
    FAQItem(
        question: "What do I do in case of an accident?",
        answer:
            "1. Ensure everyone's safety\n2. Call emergency services if needed\n3. Contact support immediately\n4. Document the incident with photos\n5. File a report through the app"),
    FAQItem(
        question: "How do I dispute an unfair rating?",
        answer:
            "Contact support with trip details and your explanation. We review each case carefully and may remove unfair ratings."),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Help & Support',
          style: GoogleFonts.alikeAngular(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emergency Support Card
              Card(
                // color: ThemeColors.textColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🚨 Emergency Support',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ThemeColors.alertColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'For immediate assistance in emergencies',
                        style: TextStyle(color: ThemeColors.alertColor),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeColors.alertColor,
                          foregroundColor: ThemeColors.textColor,
                        ),
                        icon: const Icon(Icons.phone),
                        label: const Text('Emergency Helpline'),
                        onPressed: () => _makePhoneCall('911'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Support Options
              Text(
                'Contact Support',
                style: GoogleFonts.alikeAngular(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Support Options Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.5,
                children: [
                  _buildSupportCard(
                    context,
                    'Live Chat',
                    Icons.chat,
                    ThemeColors.baseColor,
                    () => _openLiveChat(context),
                  ),
                  _buildSupportCard(
                    context,
                    'Call Support',
                    Icons.phone,
                    ThemeColors.successColor,
                    () => _makePhoneCall('+1234567890'),
                  ),
                  _buildSupportCard(
                    context,
                    'Email Us',
                    Icons.email,
                    Colors.orange,
                    () => _sendEmail(''),
                  ),
                  _buildSupportCard(
                    context,
                    'WhatsApp',
                    Icons.message,
                    ThemeColors.successColor,
                    () => _openWhatsApp(''),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // FAQ Section
              Text(
                'Frequently Asked Questions',
                style: GoogleFonts.alikeAngular(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: faqList.length,
                itemBuilder: (context, index) {
                  return _buildFAQCard(faqList[index]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQCard(FAQItem faq) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          faq.question,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(faq.answer),
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Driver Support Request',
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    final url = "https://wa.me/$phoneNumber";
    final Uri launchUri = Uri.parse(url);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _openLiveChat(BuildContext context) {
    // Implement live chat functionality or show a modal
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Live Chat'),
        content: const Text('Support agent will connect with you shortly...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}
