import 'package:flutter/material.dart';
import 'package:blinkid_flutter/blinkid_flutter.dart';
import 'module_settings_panel.dart';
import 'sample_filter_options.dart';
import 'scanning_modules_config.dart';

class OptionalScanSettingsPanel extends StatelessWidget {
  final ScanningModulesConfig config;
  final VoidCallback onChanged;

  const OptionalScanSettingsPanel({
    super.key,
    required this.config,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Optional scan settings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Class filter and redaction apply per scan type. '
          'Disabled options are not sent to the SDK.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        _ClassFilterCard(config: config, onChanged: onChanged),
        const SizedBox(height: 8),
        _RedactionResolverCard(config: config, onChanged: onChanged),
        const SizedBox(height: 8),
        _OtaResourcesCard(config: config, onChanged: onChanged),
      ],
    );
  }
}

class _OtaResourcesCard extends StatelessWidget {
  final ScanningModulesConfig config;
  final VoidCallback onChanged;

  const _OtaResourcesCard({required this.config, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SampleModuleCard(
      title: 'OTA resources download',
      subtitle: config.otaResourcesDownload
          ? 'Enabled — SDK initialization'
          : 'Disabled (null)',
      enabled: config.otaResourcesDownload,
      onEnabledChanged: (enabled) {
        config.otaResourcesDownload = enabled;
        onChanged();
      },
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Enables over-the-air document resource download during SDK '
            'initialization. When disabled, OTA settings are not sent to the SDK.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        SampleStringSettingField(
          label: 'Service URL',
          value: config.otaResourcesServiceUrl,
          placeholder: defaultOtaServiceUrl,
          onChanged: (serviceUrl) {
            config.otaResourcesServiceUrl = serviceUrl;
            onChanged();
          },
        ),
        SampleBoolSettingTile(
          title: 'Strict',
          value: config.otaResourcesStrict,
          onChanged: (otaResourcesStrict) {
            config.otaResourcesStrict = otaResourcesStrict;
            onChanged();
          },
        ),
      ],
    );
  }
}

class _ClassFilterCard extends StatelessWidget {
  final ScanningModulesConfig config;
  final VoidCallback onChanged;

  const _ClassFilterCard({required this.config, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SampleModuleCard(
      title: 'Class filter',
      subtitle: config.classFilterEnabled
          ? 'Enabled — Scan with camera'
          : 'Disabled (null)',
      enabled: config.classFilterEnabled,
      onEnabledChanged: (enabled) {
        config.classFilterEnabled = enabled;
        onChanged();
      },
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Controls which documents are accepted or rejected during camera '
            'scanning. Include rules restrict to listed classes; exclude rules '
            'reject listed classes.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        _DocumentFilterListEditor(
          title: 'Include documents',
          rules: config.classFilterInclude,
          onRulesChanged: (rules) {
            config.classFilterInclude = rules;
            onChanged();
          },
        ),
        _DocumentFilterListEditor(
          title: 'Exclude documents',
          rules: config.classFilterExclude,
          onRulesChanged: (rules) {
            config.classFilterExclude = rules;
            onChanged();
          },
        ),
      ],
    );
  }
}

class _RedactionResolverCard extends StatelessWidget {
  final ScanningModulesConfig config;
  final VoidCallback onChanged;

  const _RedactionResolverCard({required this.config, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SampleModuleCard(
      title: 'Redaction resolver',
      subtitle: config.redactionResolverEnabled
          ? 'Enabled — Scan with camera'
          : 'Disabled (null)',
      enabled: config.redactionResolverEnabled,
      onEnabledChanged: (enabled) {
        config.redactionResolverEnabled = enabled;
        onChanged();
      },
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Per-document redaction rules evaluated before the camera scan '
            'result is finalized. The first matching entry is applied.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        _RedactionSettingsListEditor(
          entries: config.redactionResolverEntries,
          onEntriesChanged: (entries) {
            config.redactionResolverEntries = entries;
            onChanged();
          },
        ),
      ],
    );
  }
}

class _DocumentFilterListEditor extends StatelessWidget {
  final String title;
  final List<UiDocumentFilter> rules;
  final ValueChanged<List<UiDocumentFilter>> onRulesChanged;

  const _DocumentFilterListEditor({
    required this.title,
    required this.rules,
    required this.onRulesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (rules.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'No rules configured.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          ...List.generate(rules.length, (index) {
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Rule ${index + 1}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    _DocumentFilterRuleEditor(
                      rule: rules[index],
                      onChanged: (updated) {
                        final next = [...rules];
                        next[index] = updated;
                        onRulesChanged(next);
                      },
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {
                          onRulesChanged([
                            for (var i = 0; i < rules.length; i++)
                              if (i != index) rules[i],
                          ]);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFC62828),
                        ),
                        child: const Text('Remove rule'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: FilledButton(
              onPressed: () {
                onRulesChanged([...rules, emptyUiDocumentFilter()]);
              },
              child: const Text('Add rule'),
            ),
          ),
        ),
      ],
    );
  }
}

class _DocumentFilterRuleEditor extends StatelessWidget {
  final UiDocumentFilter rule;
  final ValueChanged<UiDocumentFilter> onChanged;

  const _DocumentFilterRuleEditor({
    required this.rule,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final regionOptions =
        rule.country == CountryID.usa ? sampleUsaRegions : const <RegionID>[];

    return Column(
      children: [
        SampleOptionalEnumDropdown<CountryID>(
          label: 'Country',
          value: rule.country,
          options: sampleCountries,
          onChanged: (country) {
            onChanged(
              UiDocumentFilter(
                country: country,
                region: country == rule.country ? rule.region : null,
                documentType: rule.documentType,
              ),
            );
          },
        ),
        if (regionOptions.isNotEmpty)
          SampleOptionalEnumDropdown<RegionID>(
            label: 'Region',
            value: rule.region,
            options: regionOptions,
            onChanged: (region) {
              onChanged(
                UiDocumentFilter(
                  country: rule.country,
                  region: region,
                  documentType: rule.documentType,
                ),
              );
            },
          ),
        SampleOptionalEnumDropdown<DocumentTypeID>(
          label: 'Document type',
          value: rule.documentType,
          options: sampleDocumentTypes,
          onChanged: (documentType) {
            onChanged(
              UiDocumentFilter(
                country: rule.country,
                region: rule.region,
                documentType: documentType,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _RedactionSettingsListEditor extends StatelessWidget {
  final List<RedactionSettings> entries;
  final ValueChanged<List<RedactionSettings>> onEntriesChanged;

  const _RedactionSettingsListEditor({
    required this.entries,
    required this.onEntriesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...List.generate(entries.length, (index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Entry ${index + 1}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  _RedactionSettingsEditor(
                    settings: entries[index],
                    onSettingsChanged: (updated) {
                      final next = [...entries];
                      next[index] = updated;
                      onEntriesChanged(next);
                    },
                  ),
                  if (entries.length > 1)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {
                          onEntriesChanged([
                            for (var i = 0; i < entries.length; i++)
                              if (i != index) entries[i],
                          ]);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFC62828),
                        ),
                        child: const Text('Remove entry'),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: FilledButton(
              onPressed: () {
                onEntriesChanged([
                  ...entries,
                  ScanningModulesConfig.defaultRedactionSettings(),
                ]);
              },
              child: const Text('Add entry'),
            ),
          ),
        ),
      ],
    );
  }
}

class _RedactionSettingsEditor extends StatelessWidget {
  final RedactionSettings settings;
  final ValueChanged<RedactionSettings> onSettingsChanged;

  const _RedactionSettingsEditor({
    required this.settings,
    required this.onSettingsChanged,
  });

  void _update(RedactionSettings updated) {
    onSettingsChanged(updated);
  }

  void _updatePartial({
    RedactionMode? mode,
    List<FieldType>? fields,
    DocumentNumberRedactionSettings? documentNumberRedactionSettings,
    bool? redactMrzResult,
    bool? redactBarcodeResult,
    List<DocumentFilter>? documentFilter,
  }) {
    _update(
      RedactionSettings(
        fields: fields ?? settings.fields,
        mode: mode ?? settings.mode,
        documentNumberRedactionSettings:
            documentNumberRedactionSettings ??
            settings.documentNumberRedactionSettings,
        redactMrzResult: redactMrzResult ?? settings.redactMrzResult,
        redactBarcodeResult:
            redactBarcodeResult ?? settings.redactBarcodeResult,
        documentFilter: documentFilter ?? settings.documentFilter,
      ),
    );
  }

  void _updateDocumentFilter(UiDocumentFilter filter) {
    _updatePartial(
      documentFilter: hasDocumentFilterCriteria(filter)
          ? [uiToDocumentFilter(filter)]
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefixDigits =
        settings.documentNumberRedactionSettings?.prefixDigitsVisible ?? 0;
    final suffixDigits =
        settings.documentNumberRedactionSettings?.suffixDigitsVisible ?? 0;
    final filter = settings.documentFilter?.isNotEmpty == true
        ? settings.documentFilter!.first
        : null;

    return Column(
      children: [
        SampleEnumDropdown<RedactionMode>(
          label: 'Redaction mode',
          value: settings.mode,
          options: redactionModes,
          onChanged: (mode) => _updatePartial(mode: mode),
        ),
        const SampleSectionLabel('Fields to anonymize'),
        ...sampleRedactionFields.map(
          (field) => SampleBoolSettingTile(
            title: field.name,
            value: settings.fields.contains(field),
            onChanged: (enabled) {
              final fields = {...settings.fields};
              if (enabled) {
                fields.add(field);
              } else {
                fields.remove(field);
              }
              _updatePartial(fields: fields.toList());
            },
          ),
        ),
        const SampleSectionLabel('Document number redaction'),
        SampleIntSettingField(
          label: 'Prefix digits visible',
          value: prefixDigits,
          min: 0,
          max: 20,
          onChanged: (prefixDigitsVisible) {
            _updatePartial(
              documentNumberRedactionSettings: DocumentNumberRedactionSettings(
                prefixDigitsVisible: prefixDigitsVisible,
                suffixDigitsVisible: suffixDigits,
              ),
            );
          },
        ),
        SampleIntSettingField(
          label: 'Suffix digits visible',
          value: suffixDigits,
          min: 0,
          max: 20,
          onChanged: (suffixDigitsVisible) {
            _updatePartial(
              documentNumberRedactionSettings: DocumentNumberRedactionSettings(
                prefixDigitsVisible: prefixDigits,
                suffixDigitsVisible: suffixDigitsVisible,
              ),
            );
          },
        ),
        SampleBoolSettingTile(
          title: 'Redact MRZ result',
          value: settings.redactMrzResult,
          onChanged: (value) => _updatePartial(redactMrzResult: value),
        ),
        SampleBoolSettingTile(
          title: 'Redact barcode result',
          value: settings.redactBarcodeResult,
          onChanged: (value) => _updatePartial(redactBarcodeResult: value),
        ),
        const SampleSectionLabel('Document filter (match target)'),
        _DocumentFilterRuleEditor(
          rule: UiDocumentFilter(
            country: filter?.country,
            region: filter?.region,
            documentType: filter?.documentType,
          ),
          onChanged: _updateDocumentFilter,
        ),
      ],
    );
  }
}
