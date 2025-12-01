import 'package:flutter/material.dart';

class TermsClientScreen extends StatelessWidget {
  const TermsClientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Termeni pentru Client'),
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
                    Colors.blue.shade600,
                    Colors.blue.shade800,
                  ],
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Regulament Client',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Termeni și condiții pentru utilizarea platformei ca Client',
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
                    title: 'Informații corecte',
                    description: 'Clientul trebuie să furnizeze informații reale și complete despre lucrarea solicitată, inclusiv descriere, poze și orice detalii relevante.',
                    icon: Icons.info_outline,
                    color: Colors.blue,
                    isDark: isDark,
                  ),
                  _buildTermItem(
                    number: 2,
                    title: 'Acces la locație',
                    description: 'Clientul trebuie să permită accesul Prestatorului la locație la ora stabilită și să asigure condițiile necesare pentru efectuarea lucrării.',
                    icon: Icons.home,
                    color: Colors.green,
                    isDark: isDark,
                  ),
                  _buildTermItem(
                    number: 3,
                    title: 'Sistemul de plată',
                    description: 'Clientul este obligat să respecte sistemul de plată al platformei (preautorizare, confirmare). Plata se face exclusiv prin platformă.',
                    icon: Icons.payment,
                    color: Colors.purple,
                    isDark: isDark,
                  ),
                  _buildTermItem(
                    number: 4,
                    title: 'Dreptul la reclamație',
                    description: 'Clientul are dreptul să raporteze probleme reale în intervalul de 24-48 de ore după finalizarea lucrării de către Prestator.',
                    icon: Icons.report_problem,
                    color: Colors.orange,
                    isDark: isDark,
                  ),
                  _buildTermItem(
                    number: 5,
                    title: 'Dovezi pentru reclamații',
                    description: 'Clientul este obligat să ofere dovezi clare (poze, video, descriere detaliată) pentru orice reclamație. Reclamațiile fără dovezi pot fi respinse.',
                    icon: Icons.camera_alt,
                    color: Colors.red,
                    isDark: isDark,
                  ),
                  _buildTermItem(
                    number: 6,
                    title: 'Servicii suplimentare',
                    description: 'Clientul nu poate cere servicii suplimentare sau modificări majore fără a accepta eventualele costuri extra propuse de Prestator.',
                    icon: Icons.add_circle_outline,
                    color: Colors.teal,
                    isDark: isDark,
                  ),
                  _buildTermItem(
                    number: 7,
                    title: 'Evaluare corectă',
                    description: 'Clientul trebuie să evalueze corect Prestatorul, pe baza serviciului real primit. Evaluările abuzive sau false pot duce la restricții de cont.',
                    icon: Icons.star,
                    color: Colors.amber,
                    isDark: isDark,
                  ),
                  _buildTermItem(
                    number: 8,
                    title: 'Confirmare automată',
                    description: 'Dacă Clientul nu confirmă sau nu raportează o problemă în 24-48 ore, lucrarea se consideră finalizată și plata se eliberează automat.',
                    icon: Icons.timer,
                    color: Colors.indigo,
                    isDark: isDark,
                    isLast: true,
                  ),
                ],
              ),
            ),

            // Important Notice
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
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
                      'Nerespectarea acestor termeni poate duce la suspendarea sau închiderea contului.',
                      style: TextStyle(
                        color: Colors.amber.shade900,
                        fontSize: 13,
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
}

