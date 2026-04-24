import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const String _portalUrl =
      'https://afrotierre.zohodesk.com/portal/en/home';
  static const String _submitTicketUrl =
      'https://afrotierre.zohodesk.com/portal/en/newticket';
  static const String _supportEmail = 'support@afrotierre.com';

  // Policy URLs
  static const String _shippingPolicyUrl =
      'https://app.termly.io/policy-viewer/policy.html?policyUUID=8aa565e7-1502-4c3c-affc-1a5ef1085914';
  static const String _termsUrl =
      'https://app.termly.io/policy-viewer/policy.html?policyUUID=1c207878-1a91-4f28-b5a8-1c979b8af6dc';
  static const String _returnPolicyUrl =
      'https://app.termly.io/policy-viewer/policy.html?policyUUID=12d8a63f-7541-4fc1-a26f-aa9b9ae272da';

  void _openWebView(BuildContext context, String url, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WebViewScreen(url: url, title: title),
      ),
    );
  }

  void _openEmail(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: _supportEmail));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email copied: $_supportEmail')),
      );
    }
  }

  void _showQuestionDetail(BuildContext context, _PopularQuestion question) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _QuestionDetailSheet(question: question),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Help Center',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroCard(context),
            const SizedBox(height: 24),
            _buildSectionTitle('Quick Actions'),
            const SizedBox(height: 12),
            _buildQuickActions(context),
            const SizedBox(height: 28),
            _buildSectionTitle('Popular Topics'),
            const SizedBox(height: 12),
            _buildTopics(context),
            const SizedBox(height: 28),
            _buildSectionTitle('Popular Questions'),
            const SizedBox(height: 12),
            _buildPopularQuestions(context),
            const SizedBox(height: 28),
            _buildOpenHelpCenterButton(context),
            const SizedBox(height: 24),
            _buildContactInfo(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Get help and support',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Find answers to common questions or\ncontact our support team.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 17,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    // "Browse Help Articles" card is hidden (preserved below for future use).
    // Only "Contact Support" is shown.
    return Row(
      children: [
        // Hidden: Browse Help Articles card
        // Expanded(
        //   child: _buildActionCard(
        //     context,
        //     icon: Icons.menu_book_rounded,
        //     iconBg: Colors.blue.withOpacity(0.1),
        //     iconColor: Colors.blue[700]!,
        //     title: 'Browse Help Articles',
        //     subtitle: 'Find answers about orders, shipping, payments and more',
        //     onTap: () => _openWebView(context, _portalUrl, 'Help Center'),
        //   ),
        // ),
        // const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            context,
            icon: Icons.headset_mic_rounded,
            iconBg: Colors.green.withOpacity(0.1),
            iconColor: Colors.green[700]!,
            title: 'Contact Support',
            subtitle: 'Submit a request and our team will assist you',
            onTap: () => _openWebView(context, _submitTicketUrl, 'Submit Ticket'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
      BuildContext context, {
        required IconData icon,
        required Color iconBg,
        required Color iconColor,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopics(BuildContext context) {
    // Each topic has either a 'url' (opens WebView) or 'question' (opens inline sheet).
    final topics = [
      _TopicItem(icon: '📦', label: 'Orders & Shipping',        url: _shippingPolicyUrl, webTitle: 'Shipping Policy'),
      _TopicItem(icon: '💳', label: 'Payments & Refunds',       url: _returnPolicyUrl,   webTitle: 'Return Policy'),
      _TopicItem(icon: '🚚', label: 'Shipping & Tracking',      url: _shippingPolicyUrl, webTitle: 'Shipping Policy'),
      _TopicItem(icon: '🧑‍💼', label: 'Seller Support',          url: _termsUrl,          webTitle: 'Terms & Conditions'),
      _TopicItem(icon: '⚙️', label: 'Account & Settings',       url: _termsUrl,          webTitle: 'Terms & Conditions'),
      _TopicItem(icon: '📋', label: 'Vendor Agreement & Subscription', question: _vendorAgreementTopic),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: topics.map((topic) {
        return GestureDetector(
          onTap: () {
            if (topic.question != null) {
              _showQuestionDetail(context, topic.question!);
            } else {
              _openWebView(context, topic.url!, topic.webTitle!);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(topic.icon, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  topic.label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPopularQuestions(BuildContext context) {
    final questions = _popularQuestions;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: List.generate(questions.length, (index) {
          final isLast = index == questions.length - 1;
          final question = questions[index];
          return Column(
            children: [
              ListTile(
                onTap: () => _showQuestionDetail(context, question),
                leading: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ),
                title: Text(
                  question.title,
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey,
                ),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: Colors.grey[100],
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildOpenHelpCenterButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _openWebView(context, _portalUrl, 'Help Center'),
        icon: const Icon(Icons.open_in_new_rounded, size: 18),
        label: const Text(
          'Open Help Center',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context) {
    return GestureDetector(
      onTap: () => _openEmail(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.mail_outline_rounded,
                color: Colors.blue,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Need immediate help?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _supportEmail,
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.copy, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Popular Questions Data Model
// ─────────────────────────────────────────────────────────────

class _PopularQuestion {
  final String title;
  final List<_QuestionSection> sections;

  const _PopularQuestion({required this.title, required this.sections});
}

class _QuestionSection {
  final String? heading;
  final String body;

  const _QuestionSection({this.heading, required this.body});
}

final List<_PopularQuestion> _popularQuestions = [
  // ── Question 1 ──────────────────────────────────────────────
  _PopularQuestion(
    title: 'Why is my order split into multiple shipments?',
    sections: [
      const _QuestionSection(
        heading: 'Nature of the Marketplace',
        body:
        'Afrotierre is a global, multi-vendor marketplace enabling independent sellers to offer culturally unique goods. Each seller operates independently and is responsible for storing, processing, and shipping their own products. Items purchased in a single order may originate from different sellers and locations.',
      ),
      const _QuestionSection(
        heading: 'What is a Split Shipment?',
        body:
        'An order may be divided into multiple shipments when items cannot be fulfilled and delivered together in a single package. By placing an order on Afrotierre, you acknowledge that Split Shipments are a standard part of marketplace fulfillment.',
      ),
      const _QuestionSection(
        heading: 'Common Reasons',
        body:
        '• Multiple Sellers – each ships their items separately.\n'
            '• Different Locations – products stored in different warehouses or countries.\n'
            '• Availability – some items ship immediately, others require preparation time.\n'
            '• Logistics Efficiency – to speed delivery and reduce risk of damage.\n'
            '• Size / Weight / Regulations – oversized, fragile, or regulated items may require separate packaging.',
      ),
      const _QuestionSection(
        heading: 'Shipping Fees',
        body:
        'Shipping fees are calculated and displayed at checkout. You will not be charged additional fees solely due to Split Shipments unless explicitly disclosed prior to purchase.',
      ),
      const _QuestionSection(
        heading: 'Tracking',
        body:
        'Where available, Afrotierre provides separate tracking numbers for each shipment, individual shipping notifications, and order status updates per item. Each shipment may have a different estimated delivery date.',
      ),
    ],
  ),

  // ── Question 2 ──────────────────────────────────────────────
  _PopularQuestion(
    title: 'What is the Afrotierre Shipping Policy?',
    sections: [
      const _QuestionSection(
        heading: 'Overview',
        body:
        'Afrotierre facilitates shipping between independent sellers and buyers worldwide. Each seller is responsible for dispatching orders from their location. Delivery times vary based on the seller\'s location, chosen carrier, and your destination.',
      ),
      const _QuestionSection(
        heading: 'Tracking Your Order',
        body:
        'Once your order ships, you will receive a tracking number via email or through the app. Use this number on the carrier\'s website to check delivery status in real time.',
      ),
      const _QuestionSection(
        heading: 'Delays & Issues',
        body:
        'If your shipment is delayed beyond the estimated delivery window, please contact Afrotierre Support. We will coordinate with the seller and carrier on your behalf.',
      ),
      const _QuestionSection(
        heading: 'Full Policy',
        body:
        'For the complete Shipping Policy, tap "View Full Policy" below.',
      ),
    ],
  ),

  // ── Question 3 ──────────────────────────────────────────────
  _PopularQuestion(
    title: 'When will I receive my vendor payout?',
    sections: [
      const _QuestionSection(
        heading: 'Payout Schedule',
        body:
        'Vendors are eligible for payout 7 calendar days after the confirmed Shipping Date — the date the carrier scans the package as "In Transit" or "Shipped." Funds are released during the next scheduled banking run (typically every Tuesday and Friday).',
      ),
      const _QuestionSection(
        heading: 'Conditions for Payout',
        body:
        '1. Valid Tracking – a verifiable tracking number must be uploaded at shipment.\n'
            '2. Good Account Standing – no active flags for fraud or high return rates.\n'
            '3. Documentation – a digital invoice matching the Order ID must be generated.',
      ),
      const _QuestionSection(
        heading: 'Withholding of Funds',
        body:
        'Payouts may be delayed if a customer dispute is opened, the tracking number is invalid, or the item is subject to an active return window.',
      ),
      const _QuestionSection(
        heading: 'Fees & Deductions',
        body:
        'Final payout = Gross Sales Price minus Afrotierre commission, transaction/processing fees, applicable taxes (VAT/GST), and any refund adjustments.',
      ),
      const _QuestionSection(
        heading: 'Payout Methods',
        body:
        'Funds are disbursed via your selected method in the Vendor Payment Profile: Direct Bank Transfer (ACH/EFT/Swift) or an approved Digital Wallet.',
      ),
    ],
  ),
];

// ─────────────────────────────────────────────────────────────
// Topic Item Model (supports WebView OR inline sheet)
// ─────────────────────────────────────────────────────────────

class _TopicItem {
  final String icon;
  final String label;
  final String? url;
  final String? webTitle;
  final _PopularQuestion? question;

  const _TopicItem({
    required this.icon,
    required this.label,
    this.url,
    this.webTitle,
    this.question,
  });
}

// ─────────────────────────────────────────────────────────────
// Vendor Agreement & Subscription inline content
// ─────────────────────────────────────────────────────────────

final _PopularQuestion _vendorAgreementTopic = _PopularQuestion(
  title: 'Vendor Agreement & Subscription',
  sections: [
    const _QuestionSection(
      heading: 'Subscription Fee',
      body:
      'All vendors pay a flat rate of \$10/month (or \$120/year). There are no tiers — every vendor receives the full suite of Afrotierre global tools. Billing begins immediately upon account approval and origin-verification.',
    ),
    const _QuestionSection(
      heading: 'Automatic Renewal & Grace Period',
      body:
      'Subscriptions renew automatically each billing cycle. If a payment fails, you have a 7-day grace period to update your payment method. After 7 days, listings may be hidden and dashboard access restricted until the balance is cleared.',
    ),
    const _QuestionSection(
      heading: 'Cancellation & Refunds',
      body:
      'You may cancel at any time and retain full access until the current billing period expires. Subscription fees are generally non-refundable. Prorated refunds on annual plans are only considered for documented platform outages exceeding 48 hours.',
    ),
    const _QuestionSection(
      heading: 'Commission Rate',
      body:
      'Afrotierre charges a flat 7% commission on every successful sale, applied to the Total Gross Sale (product price + service fees, excluding shipping and duties). This rate is equal for all vendors.',
    ),
    const _QuestionSection(
      heading: 'Payouts & Deductions',
      body:
      'Commissions are automatically deducted at the point of sale. Your Net Payout (Gross Sale minus commission and payment processing fees) is credited to your Afrotierre Wallet. Note: third-party processing fees (Stripe, PayPal, etc.) are separate and are the vendor\'s responsibility.',
    ),
    const _QuestionSection(
      heading: 'Refunds & Chargebacks',
      body:
      'If a buyer is granted a full refund, the platform commission for that transaction is credited back to your account. In the event of a fraudulent chargeback, Afrotierre will assist in the dispute process, though the commission may be held until resolved.',
    ),
    const _QuestionSection(
      heading: 'Tax Responsibility',
      body:
      'Vendors are solely responsible for calculating, collecting, and remitting any local sales tax, VAT, or GST applicable to their region or the buyer\'s destination.',
    ),
    const _QuestionSection(
      heading: 'Anti-Circumvention',
      body:
      'Vendors agree not to bypass Afrotierre\'s payment system to avoid commission fees. Moving a transaction initiated on Afrotierre to an off-platform payment method will result in immediate permanent account termination.',
    ),
    const _QuestionSection(
      heading: 'Changes to Fees',
      body:
      'Afrotierre reserves the right to modify the subscription fee or commission rate. All vendors will be notified via email at least 30 days prior to any changes. Continued use of the platform after the notice period constitutes acceptance of the new rates.\n\nEffective Date: April 23, 2026 · Governing Jurisdiction: Texas, USA',
    ),
  ],
);

// ─────────────────────────────────────────────────────────────
// Question Detail Bottom Sheet
// ─────────────────────────────────────────────────────────────

class _QuestionDetailSheet extends StatelessWidget {
  final _PopularQuestion question;

  const _QuestionDetailSheet({required this.question});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title bar
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        question.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            size: 18, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Scrollable content
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  itemCount: question.sections.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 20),
                  itemBuilder: (_, i) {
                    final section = question.sections[i];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (section.heading != null) ...[
                          Text(
                            section.heading!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],
                        Text(
                          section.body,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            height: 1.6,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// WebView Screen Component
// ─────────────────────────────────────────────────────────────
class WebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const WebViewScreen({super.key, required this.url, required this.title});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            debugPrint('WebView error: $error');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}