import 'package:flutter/material.dart';

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cum funcționează'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2DD4BF),
                    const Color(0xFF0EA5E9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.verified_user,
                    color: Colors.white,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Cum funcționează platforma',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Platforma noastră oferă un sistem de lucru sigur, eficient și protejat atât pentru Client, cât și pentru Prestator.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Steps
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildStep(
                    number: 1,
                    title: 'Crearea comenzii',
                    description: 'Clientul descrie lucrarea, alege data/ora și selectează un Prestator potrivit din lista disponibilă.',
                    icon: Icons.edit_note,
                    color: const Color(0xFF6366F1),
                    details: [
                      'Descriere detaliată a lucrării',
                      'Poze pentru clarificare (opțional)',
                      'Adresa și detalii locație',
                      'Data și ora dorită',
                    ],
                    isDark: isDark,
                  ),
                  _buildStep(
                    number: 2,
                    title: 'Blocarea fondurilor',
                    description: 'Înainte ca Prestatorul să vină la locație, suma pentru lucrare este securizată.',
                    icon: Icons.lock,
                    color: const Color(0xFF8B5CF6),
                    details: [
                      'Preautorizare pe card (suma blocată, neîncasată)',
                      'Sau avans parțial (30-50%)',
                      'Protecție pentru Prestator împotriva refuzului de plată',
                    ],
                    isDark: isDark,
                  ),
                  _buildStep(
                    number: 3,
                    title: 'Execuția lucrării',
                    description: 'Prestatorul ajunge la locație, efectuează lucrarea și documentează procesul.',
                    icon: Icons.construction,
                    color: const Color(0xFFF59E0B),
                    details: [
                      'Prestatorul merge la adresă (status: În drum)',
                      'Începe lucrarea (status: În lucru)',
                      'Încarcă poze ÎNAINTE de intervenție',
                      'Execută serviciul profesionist',
                    ],
                    isDark: isDark,
                  ),
                  _buildStep(
                    number: 4,
                    title: 'Finalizarea lucrării',
                    description: 'Prestatorul marchează lucrarea ca finalizată și documentează rezultatul.',
                    icon: Icons.check_circle,
                    color: const Color(0xFF10B981),
                    details: [
                      'Încarcă poze DUPĂ finalizare',
                      'Poate adăuga video cu testarea',
                      'Apasă butonul "Lucrare finalizată"',
                      'Clientul primește notificare',
                    ],
                    isDark: isDark,
                  ),
                  _buildStep(
                    number: 5,
                    title: 'Confirmarea Clientului',
                    description: 'Clientul are 24-48 ore pentru a verifica și confirma lucrarea.',
                    icon: Icons.timer,
                    color: const Color(0xFF3B82F6),
                    details: [
                      '✓ Confirmă lucrarea → plata se eliberează',
                      '❗ Raportează problemă → se deschide dispută',
                      '⏰ Fără răspuns → confirmare automată',
                    ],
                    isDark: isDark,
                    isImportant: true,
                  ),
                  _buildStep(
                    number: 6,
                    title: 'Rezolvarea problemelor',
                    description: 'Dacă Clientul raportează o problemă, platforma intermediază rezolvarea.',
                    icon: Icons.support_agent,
                    color: const Color(0xFFEF4444),
                    details: [
                      'Clientul trimite poze/video + descriere exactă',
                      'Prestatorul poate accepta revizia',
                      'Problema din lucrarea inițială → rezolvare gratuită',
                      'Defecțiune nouă → poate exista cost suplimentar',
                    ],
                    isDark: isDark,
                  ),
                  _buildStep(
                    number: 7,
                    title: 'Plata Prestatorului',
                    description: 'După confirmare sau expirarea timpului, plata este eliberată.',
                    icon: Icons.payments,
                    color: const Color(0xFF22C55E),
                    details: [
                      'Suma ajunge în portofelul Prestatorului',
                      'Prestator poate solicita retragere',
                      'Transfer bancar în 1-3 zile',
                    ],
                    isDark: isDark,
                  ),
                  _buildStep(
                    number: 8,
                    title: 'Recenzii',
                    description: 'Clientul poate evalua Prestatorul pe baza experienței.',
                    icon: Icons.star,
                    color: const Color(0xFFF97316),
                    details: [
                      'Rating 1-5 stele',
                      'Comentariu detaliat',
                      'Prestatorii cu comportament slab pot fi blocați',
                    ],
                    isDark: isDark,
                    isLast: true,
                  ),
                ],
              ),
            ),

            // Benefits Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
              child: Column(
                children: [
                  Text(
                    'De ce să folosești platforma?',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildBenefitCard(
                          icon: Icons.security,
                          title: 'Siguranță',
                          description: 'Plata securizată în escrow',
                          color: Colors.blue,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildBenefitCard(
                          icon: Icons.verified,
                          title: 'Verificat',
                          description: 'Prestatori verificați',
                          color: Colors.green,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildBenefitCard(
                          icon: Icons.support_agent,
                          title: 'Suport',
                          description: 'Mediere în dispute',
                          color: Colors.purple,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildBenefitCard(
                          icon: Icons.photo_camera,
                          title: 'Dovezi',
                          description: 'Documentare foto/video',
                          color: Colors.orange,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // CTA
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    'Ai întrebări?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Echipa noastră de suport este disponibilă 24/7',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to support
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text('Contactează Suportul'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                    ),
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
    required List<String> details,
    required bool isDark,
    bool isImportant = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline
          Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withOpacity(0.5), Colors.grey.withOpacity(0.2)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: isImportant
                    ? Border.all(color: color.withOpacity(0.5), width: 2)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, color: color, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      if (isImportant)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Important',
                            style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: TextStyle(
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...details.map((detail) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          detail.startsWith('✓') || detail.startsWith('❗') || detail.startsWith('⏰')
                              ? null
                              : Icons.arrow_right,
                          size: 18,
                          color: color.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            detail,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required bool isDark,
  }) {
    return Container(
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
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

