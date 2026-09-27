import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paya_app/core/services/whatsapp_service.dart';
import 'package:paya_app/core/theme/app_theme.dart';

class WhatsAppTemplatesPage extends StatefulWidget {
  const WhatsAppTemplatesPage({super.key});

  @override
  State<WhatsAppTemplatesPage> createState() => _WhatsAppTemplatesPageState();
}

class _WhatsAppTemplatesPageState extends State<WhatsAppTemplatesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late WhatsAppService _whatsAppService;

  final Map<String, TextEditingController> _controllers = {};

  final List<String> _templateKeys = [
    WhatsAppService.keyConfirmation,
    WhatsAppService.keyPaid,
    WhatsAppService.keyProcessing,
    WhatsAppService.keyDelivered,
    WhatsAppService.keyUndelivered,
  ];

  @override
  void initState() {
    super.initState();
    _whatsAppService = Get.find<WhatsAppService>();
    _tabController = TabController(length: _templateKeys.length, vsync: this);

    for (final key in _templateKeys) {
      _controllers[key] = TextEditingController(
        text: _whatsAppService.getTemplate(key),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _insertVariable(String key, String tag) {
    final controller = _controllers[key]!;
    final text = controller.text;
    final selection = controller.selection;

    if (selection.start >= 0 && selection.end >= 0) {
      final newText = text.replaceRange(selection.start, selection.end, tag);
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start + tag.length),
      );
    } else {
      controller.text = '$text $tag';
    }
    setState(() {});
  }

  String _renderSamplePreview(String templateText) {
    var preview = templateText;
    final samples = {
      '{client_name}': 'Aïcha Traoré',
      '{order_id}': '84920',
      '{products}': '• Sac à main cuir x1 (25 000 F)\n• Écharpe soie x2 (10 000 F)',
      '{total_amount}': '35 000',
      '{amount_paid}': '20 000',
      '{remaining_balance}': '15 000',
      '{business_name}': 'Boutique Élégance',
      '{wave_name}': 'Campagne Décembre 2026',
      '{delivery_address}': 'Ouagadougou, Zone du Bois',
      '{date}': '27/09/2026',
    };

    samples.forEach((k, v) {
      preview = preview.replaceAll(k, v);
    });

    return preview;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.warmCream,
      appBar: AppBar(
        title: const Text(
          'Modèles WhatsApp',
          style: TextStyle(
            color: AppTheme.deepBlue,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppTheme.deepBlue),
          onPressed: () => Get.back(),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Get.defaultDialog(
                title: 'Restaurer les modèles',
                middleText: 'Voulez-vous réinitialiser tous les modèles par défaut ?',
                textConfirm: 'Restaurer',
                textCancel: 'Annuler',
                confirmTextColor: Colors.white,
                buttonColor: AppTheme.deepBlue,
                onConfirm: () async {
                  Get.back();
                  await _whatsAppService.resetToDefaults();
                  for (final key in _templateKeys) {
                    _controllers[key]!.text = _whatsAppService.getTemplate(key);
                  }
                  setState(() {});
                },
              );
            },
            icon: const Icon(Icons.restore_rounded, size: 16, color: AppTheme.slate600),
            label: const Text(
              'Par défaut',
              style: TextStyle(fontSize: 12, color: AppTheme.slate700, fontWeight: FontWeight.w600),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.slate200),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.slate600,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: AppTheme.deepBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
              dividerColor: Colors.transparent,
              padding: const EdgeInsets.all(3),
              tabs: const [
                Tab(text: '1. Confirmation'),
                Tab(text: '2. Paiement'),
                Tab(text: '3. Disponible'),
                Tab(text: '4. Livrée'),
                Tab(text: '5. Non livrée'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _templateKeys.map((key) => _buildTemplateEditor(key)).toList(),
      ),
    );
  }

  Widget _buildTemplateEditor(String key) {
    final controller = _controllers[key]!;
    final label = WhatsAppService.templateLabels[key] ?? key;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.slate200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF25D366).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.mark_chat_read_rounded,
                        color: Color(0xFF1EBE5D),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.slate900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Envoyé au client lors de cette étape de suivi',
                            style: TextStyle(fontSize: 12, color: AppTheme.slate500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Variable Chips
              const Text(
                'Variables disponibles (Touchez pour insérer) :',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.slate800,
                ),
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: WhatsAppService.availableVariables.map((v) {
                  final tag = v['tag']!;
                  return InkWell(
                    onTap: () => _insertVariable(key, tag),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.deepBlue.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.deepBlue.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add, size: 12, color: AppTheme.deepBlue),
                          const SizedBox(width: 4),
                          Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.deepBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 18),

              // Message Editor Box
              const Text(
                'Texte du modèle :',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.slate800,
                ),
              ),
              const SizedBox(height: 8),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.slate200),
                ),
                child: TextField(
                  controller: controller,
                  maxLines: 8,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(fontSize: 13, height: 1.4),
                  decoration: const InputDecoration(
                    hintText: 'Saisissez le texte du modèle...',
                    contentPadding: EdgeInsets.all(16),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Live Preview Card
              const Text(
                'Aperçu en situation réelle :',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.slate800,
                ),
              ),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEAE2), // WhatsApp chat background color
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFDDD4C8)),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 380),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7FFDB), // WhatsApp sent bubble
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      _renderSamplePreview(controller.text),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF111B21),
                        height: 1.35,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await _whatsAppService.saveTemplate(
                      key,
                      controller.text.trim(),
                    );
                  },
                  icon: const Icon(Icons.save_rounded, size: 20),
                  label: const Text(
                    'Enregistrer ce modèle',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.deepBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
