import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'About Us',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Logo / Brand Icon
            Center(child: Image.asset('assets/logo.png', width: 120, height: 120)),

            // const SizedBox(height: 18),

            /// Title
            const Center(
              child: Text(
                'Afrotierre',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A3A),
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 16),

            /// Subtitle / Tagline
            const Center(
              child: Text(
                'A bridge between cultures',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF5D6D6D),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 32),

            /// Opening paragraph
            _buildSection(
              title: 'Our Belief',
              content:
              'At our core, we believe the world is richer when cultures are shared, stories are told, and traditions are celebrated. Our marketplace was created to bring people closer together—no matter where they are—by connecting buyers and sellers through unique, meaningful products from across the globe.',
            ),

            const SizedBox(height: 24),

            /// Mission
            _buildSection(
              title: 'Our Mission',
              content:
              'At Afrotierre, we are more than just an e-commerce platform. We are a bridge between cultures. From handcrafted goods and traditional textiles to rare artisanal creations and locally inspired designs, every item on our platform carries a story—of heritage, craftsmanship, and identity.\n\nOur mission is simple: to empower independent creators and small businesses while giving customers access to authentic products they won\'t find anywhere else. By supporting our sellers, you\'re not just making a purchase—you\'re helping preserve traditions, sustain livelihoods, and celebrate diversity.',
            ),

            const SizedBox(height: 24),

            /// Curation & Invitation
            _buildSection(
              title: 'Quality & Authenticity',
              content:
              'We carefully curate our marketplace to ensure quality, authenticity, and cultural respect. Whether you\'re searching for something meaningful, one-of-a-kind, or simply curious to explore the world through its creations, we invite you to discover something extraordinary.',
            ),

            const SizedBox(height: 32),

            /// Call to Action
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A3A).withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF1E3A3A).withOpacity(0.2),
                ),
              ),
              child: const Center(
                child: Text(
                  'Join us in building a global community where creativity thrives, cultures connect, and every purchase tells a story.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E3A3A),
                    height: 1.4,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              color: const Color(0xFFD4A373),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A3A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: const TextStyle(
            fontSize: 15,
            height: 1.5,
            color: Color(0xFF3A4A4A),
          ),
        ),
      ],
    );
  }
}