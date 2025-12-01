import 'package:flutter/material.dart';

class TermsPrestatorScreen extends StatelessWidget {
  const TermsPrestatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Termeni pentru Prestator'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2DD4BF),
                    const Color(0xFF0D9488),
                  ],
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.handyman,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Regulament Prestator',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Termeni și condiții pentru prestarea serviciilor pe platformă',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Terms List
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildTermItem(
                    number: 1,
                    title: 'Servicii profesioniste',
                    description: 'Prestatorul trebuie să ofere servicii profesioniste, de calitate, conform descrierii din profilul său și specificațiilor clientului.',
                    icon: Icons.workspace_premium,
                    color: const Color(0xFF2DD4BF),
                    isDark: isDark,
                  ),
                  _buildTermItem(
                    number: 2,
                    title: 'Punctualitate',
                    description: 'Prestatorul trebuie să ajungă la timp la locația clientului sau să anunțe din timp dacă întârzie sau nu poate onora programarea.',
                    icon: Icons.access_time,
                    color: Colors.blue,
                    isDark: isDark,
                  ),
                  _buildTermItem(
                    number: 3,
                    title: 'Documentare foto/video',
                    description: 'Prestatorul trebuie să documenteze lucrarea cu poze ÎNAINTE și DUPĂ. Aceste dovezi sunt esențiale în caz de dispută.',
                    icon: Icons.camera_alt,
                    color: Colors.purple,
                    isDark: isDark,
                  ),
                  _buildTermItem(
                    number: 4,
                    title: 'Finalizare corectă',
                    description: 'Prestatorul marchează lucrarea ca finalizată doar după verificarea la fața locului că totul funcționează corect.',
                    icon: Icons.check_circle,
                    color: Colors.green,
                    isDark: isDark,
                  ),
                  _buildTermItem(
                    number: 5,
                    title: 'Răspuns la reclamații',
                    description: 'Prestatorul trebuie să răspundă la reclamații în mod responsabil, profesionist și în timp util prin platforma.',
                    icon: Icons.support_agent,
                    color: Colors.orange,
                    isDark: isDark,
                  ),
                  _buildTermItem(
                    number: 6,
                    title: 'Revizie gratuită',
                    description: 'Prestatorul revine gratuit dacă problema raportată este din lucrarea inițială executată de el.',
                    icon: Icons.refresh,
                    color: Colors.red,
                    isDark: isDark,
                  ),
                  _buildTermItem(
                    number: 7,
                    title: 'Cost suplimentar',
                    description: 'Prestatorul poate cere cost suplimentar pentru defecțiuni noi, servicii extra sau situații care nu fac parte din comanda inițială.',
                    icon: Icons.add_shopping_cart,
                    color: Colors.indigo,
                    isDark: isDark,
                  ),
                  _buildTermItem(
                    number: 8,
                    title: 'Politici și siguranță',
                    description: 'Prestatorul trebuie să respecte politicile platformei, regulile de siguranță și să aibă un comportament profesionist cu clienții.',
                    icon: Icons.security,
                    color: Colors.teal,
                    isDark: isDark,
                    isLast: true,
                  ),
                ],
              ),
            ),

            // Benefits Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.emoji_events, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Beneficii Prestator',
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildBenefitRow(Icons.lock, 'Plată garantată prin escrow'),
                  _buildBenefitRow(Icons.verified, 'Protecție împotriva clienților abuzivi'),
                  _buildBenefitRow(Icons.star, 'Sistem de rating pentru credibilitate'),
                  _buildBenefitRow(Icons.account_balance, 'Retrageri rapide în cont bancar'),
                ],
              ),
            ),

            // Warning
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.amber.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Nerespectarea acestor termeni poate duce la suspendarea sau închiderea contului de prestator.',
                      style: TextStyle(
                        color: Colors.amber.shade900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTermItem({
    required int number,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool isDark,
    bool isLast = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(icon, color: color, size: 22),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$number. $title',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.green.shade600),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: Colors.green.shade800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

