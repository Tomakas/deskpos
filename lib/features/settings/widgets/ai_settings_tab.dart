import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/enums/ai_provider_type.dart';
import '../../../core/data/models/company_settings_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../l10n/app_localizations.dart';

const _modelsByProvider = <AiProviderType, List<String>>{
  AiProviderType.anthropic: [
    'claude-sonnet-4-20250514',
    'claude-haiku-4-5-20251001',
  ],
  AiProviderType.google: [
    'gemini-2.0-flash',
    'gemini-1.5-pro',
    'gemini-1.5-flash',
  ],
  AiProviderType.openai: [
    'gpt-4o',
    'gpt-4o-mini',
  ],
};

const _defaultModels = <AiProviderType, String>{
  AiProviderType.anthropic: 'claude-sonnet-4-20250514',
  AiProviderType.openai: 'gpt-4o',
  AiProviderType.google: 'gemini-2.0-flash',
};

class AiSettingsTab extends ConsumerStatefulWidget {
  const AiSettingsTab({super.key});

  @override
  ConsumerState<AiSettingsTab> createState() => _AiSettingsTabState();
}

class _AiSettingsTabState extends ConsumerState<AiSettingsTab> {
  StreamSubscription<CompanySettingsModel?>? _settingsSub;
  CompanySettingsModel? _settings;
  bool _settingsInitialized = false;

  final _modelController = TextEditingController();
  final _rateLimitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initSettings();
  }

  Future<void> _initSettings() async {
    final company = ref.read(currentCompanyProvider);
    if (company == null) return;

    final repo = ref.read(companySettingsRepositoryProvider);
    final settings = await repo.getOrCreate(company.id);
    if (!mounted) return;
    _applyToControllers(settings);
    setState(() {
      _settings = settings;
      _settingsInitialized = true;
    });

    _settingsSub = repo.watchByCompany(company.id).listen((s) {
      if (mounted && s != null) {
        setState(() => _settings = s);
      }
    });
  }

  void _applyToControllers(CompanySettingsModel s) {
    _modelController.text = s.aiModel ?? '';
    _rateLimitController.text = s.aiRateLimitPerHour.toString();
  }

  @override
  void dispose() {
    _settingsSub?.cancel();
    _modelController.dispose();
    _rateLimitController.dispose();
    super.dispose();
  }

  Future<void> _updateSettings(CompanySettingsModel updated) async {
    final repo = ref.read(companySettingsRepositoryProvider);
    await repo.update(updated);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    if (!_settingsInitialized || _settings == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final s = _settings!;
    final providerEnabled = s.aiProviderType != AiProviderType.none;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              l.aiAssistant,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SwitchListTile(
            title: Text(l.settingsAiEnabled),
            value: s.aiEnabled,
            onChanged: (value) {
              _updateSettings(s.copyWith(aiEnabled: value));
            },
          ),
          ListTile(
            title: Text(l.settingsAiProvider),
            trailing: SizedBox(
              width: 200,
              child: DropdownButtonFormField<AiProviderType>(
                initialValue: s.aiProviderType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  for (final provider in AiProviderType.values)
                    DropdownMenuItem<AiProviderType>(
                      value: provider,
                      child: Text(_providerLabel(l, provider)),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    final defaultModel = _defaultModels[value];
                    _modelController.text = defaultModel ?? '';
                    _updateSettings(s.copyWith(
                      aiProviderType: value,
                      aiModel: defaultModel,
                    ));
                  }
                },
              ),
            ),
          ),
          if (providerEnabled) ...[
            ListTile(
              title: Text(l.settingsAiModel),
              trailing: SizedBox(
                width: 280,
                child: _buildModelSelector(s, l),
              ),
            ),
            ListTile(
              title: Text(l.settingsAiRateLimit),
              trailing: SizedBox(
                width: 200,
                child: TextField(
                  controller: _rateLimitController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    final parsed = int.tryParse(value);
                    if (parsed != null && parsed > 0) {
                      _updateSettings(
                          s.copyWith(aiRateLimitPerHour: parsed));
                    }
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModelSelector(CompanySettingsModel s, AppLocalizations l) {
    final models = _modelsByProvider[s.aiProviderType];
    if (models != null) {
      // Ensure current value is in the list, fall back to default
      final currentModel = s.aiModel;
      final effectiveValue = (currentModel != null && models.contains(currentModel))
          ? currentModel
          : _defaultModels[s.aiProviderType];
      return DropdownButtonFormField<String>(
        initialValue: effectiveValue,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        items: [
          for (final model in models)
            DropdownMenuItem<String>(
              value: model,
              child: Text(model),
            ),
        ],
        onChanged: (value) {
          if (value != null) {
            _updateSettings(s.copyWith(aiModel: value));
          }
        },
      );
    }
    return TextField(
      controller: _modelController,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        hintText: l.settingsAiModelHint,
      ),
      onChanged: (value) {
        _updateSettings(s.copyWith(aiModel: value.isEmpty ? null : value));
      },
    );
  }

  String _providerLabel(AppLocalizations l, AiProviderType provider) {
    return switch (provider) {
      AiProviderType.none => l.settingsAiProviderNone,
      AiProviderType.openai => l.settingsAiProviderOpenai,
      AiProviderType.google => l.settingsAiProviderGoogle,
      AiProviderType.anthropic => l.settingsAiProviderAnthropic,
    };
  }
}
