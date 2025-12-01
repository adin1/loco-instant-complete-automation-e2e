import 'package:flutter/material.dart';

class PaymentPolicyScreen extends StatelessWidget {
  const PaymentPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cum funcționează plățile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade600,
                    Colors.teal.shade500,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.security,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Protecție pentru ambele părți',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sistemul nostru de escrow asigură că atât clientul cât și prestatorul sunt protejați',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Steps
            _buildStep(
              number: 1,
              title: 'Fondurile sunt blocate înainte de lucrare',
              description:
                  'Când plasezi o comandă, suma este blocată pe cardul tău (pre-autorizare) sau plătești un avans. Banii nu ajung imediat la prestator.',
              icon: Icons.lock,
              color: Colors.blue,
              isDark: isDark,
            ),
            _buildStep(
              number: 2,
              title: 'Prestatorul documentează lucrarea',
              description:
                  'Prestatorul face fotografii ÎNAINTE și DUPĂ lucrare. Acestea servesc ca dovadă în caz de dispute.',
              icon: Icons.camera_alt,
              color: Colors.orange,
              isDark: isDark,
            ),
            _buildStep(
              number: 3,
              title: 'Lucrarea se testează la final',
              description:
                  'Prestatorul testează funcționalitatea (ex: se aprinde lumina, siguranța nu sare) și poate înregistra un scurt video.',
              icon: Icons.check_circle,
              color: Colors.green,
              isDark: isDark,
            ),
            _buildStep(
              number: 4,
              title: 'Ai 24-48 ore să confirmi sau să reclami',
              description:
                  'După ce prestatorul marchează lucrarea ca finalizată, ai timp să verifici și să confirmi că totul este în regulă.',
              icon: Icons.timer,
              color: Colors.purple,
              isDark: isDark,
            ),
            _buildStep(
              number: 5,
              title: 'Dacă nu răspunzi, plata e automată',
              description:
                  'Dacă nu confirmi și nu raportezi nicio problemă în 48 ore, plata se eliberează automat către prestator.',
              icon: Icons.auto_mode,
              color: Colors.teal,
              isDark: isDark,
            ),
            _buildStep(
              number: 6,
              title: 'Reclamațiile necesită dovezi',
              description:
                  'Dacă raportezi o problemă, trebuie să explici ce nu funcționează și să adaugi fotografii/video. Reclamațiile nefondate sunt respinse.',
              icon: Icons.gavel,
              color: Colors.red,
              isDark: isDark,
            ),
            _buildStep(
              number: 7,
              title: 'Reintervenție gratuită sau cu cost',
              description:
                  'Dacă problema e din cauza lucrării, prestatorul revine gratis. Dacă e altă defecțiune, poate exista un cost suplimentar.',
              icon: Icons.refresh,
              color: Colors.indigo,
              isDark: isDark,
              isLast: true,
            ),

            const SizedBox(height: 32),

            // FAQ Section
            Text(
              'Întrebări frecvente',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildFaqItem(
              question: 'Ce se întâmplă dacă nu sunt mulțumit?',
              answer:
                  'Poți raporta o problemă în cele 48 ore după finalizare. Trebuie să descrii problema și să adaugi dovezi. Echipa noastră va analiza cazul.',
              isDark: isDark,
            ),
            _buildFaqItem(
              question: 'Când primesc banii dacă sunt prestator?',
              answer:
                  'Banii sunt eliberați imediat ce clientul confirmă lucrarea, sau automat după 48 ore dacă nu există reclamații.',
              isDark: isDark,
            ),
            _buildFaqItem(
              question: 'Pot primi ramburs?',
              answer:
                  'Da, dacă reclamația este fondată și nu se poate rezolva prin reintervenție, vei primi ramburs total sau parțial.',
              isDark: isDark,
            ),
            _buildFaqItem(
              question: 'Ce înseamnă pre-autorizare pe card?',
              answer:
                  'Suma este "blocată" pe card dar nu este încasată. E ca atunci când dai garanție la hotel. Suma se încasează doar la finalizarea lucrării.',
              isDark: isDark,
            ),
            _buildFaqItem(
              question: 'De ce trebuie să fac poze înainte și după?',
              answer:
                  'Pozele sunt esențiale în caz de dispută. Fără ele, este foarte greu să demonstrezi calitatea lucrării sau problemele apărute.',
              isDark: isDark,
            ),

            const SizedBox(height: 32),

            // Contact support
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.support_agent,
                    size: 40,
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Ai nevoie de ajutor?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Echipa noastră de suport este disponibilă 24/7',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to support chat
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Deschide chat cu suportul...'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text('Contactează suportul'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStep({
    required int number,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool isDark,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: color.withOpacity(0.3),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.grey.shade800
                      : color.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: color.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, color: color, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem({
    required String question,
    required String answer,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        childrenPadding: const EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 16,
        ),
        children: [
          Text(
            answer,
            style: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

