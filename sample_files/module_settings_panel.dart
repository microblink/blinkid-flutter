import 'package:flutter/material.dart';
import 'package:blinkid_flutter/blinkid_flutter.dart';
import 'scanning_modules_config.dart';

class ModuleSettingsPanel extends StatelessWidget {
  final ScanningModulesConfig config;
  final VoidCallback onChanged;

  const ModuleSettingsPanel({
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
          'Scanning modules',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Disabled modules are sent as null (not supported). '
          'Settings apply to all scan actions below.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: DropdownButtonFormField<ScanningMode>(
            key: ValueKey('scanning-mode-${config.scanningMode}'),
            initialValue: config.scanningMode,
            decoration: InputDecoration(
              labelText: 'Scanning Mode',
              isDense: true,
              border: const OutlineInputBorder(),
            ),
            items: ScanningMode.values
                .map(
                  (mode) => DropdownMenuItem(
                    value: mode,
                    child: Text(mode.name),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                config.scanningMode = value;
                onChanged();
              }
            },
          ),
        ),
        const SizedBox(height: 12),
        _SessionSettingsCard(config: config, onChanged: onChanged),
        const SizedBox(height: 12),
        _UxSettingsCard(config: config, onChanged: onChanged),
        const SizedBox(height: 12),
        _BarcodeModuleCard(config: config, onChanged: onChanged),
        const SizedBox(height: 8),
        _DocumentCaptureModuleCard(config: config, onChanged: onChanged),
        const SizedBox(height: 8),
        _MrzModuleCard(config: config, onChanged: onChanged),
        const SizedBox(height: 8),
        _VizModuleCard(config: config, onChanged: onChanged),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              config.resetToDefaults();
              onChanged();
            },
            child: const Text('Reset to defaults'),
          ),
        ),
        const Divider(height: 24),
      ],
    );
  }
}

class SampleModuleCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool enabled;
  final ValueChanged<bool> onEnabledChanged;
  final List<Widget> children;

  const SampleModuleCard({
    required this.title,
    this.subtitle,
    required this.enabled,
    required this.onEnabledChanged,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: enabled
          ? theme.colorScheme.surfaceContainerLow
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          enabled: enabled,
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: enabled
                            ? null
                            : theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              Switch(
                value: enabled,
                onChanged: onEnabledChanged,
              ),
            ],
          ),
          children: enabled
              ? [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                    child: Column(children: children),
                  ),
                ]
              : const [],
        ),
      ),
    );
  }
}

class _BarcodeModuleCard extends StatelessWidget {
  final ScanningModulesConfig config;
  final VoidCallback onChanged;

  const _BarcodeModuleCard({required this.config, required this.onChanged});

  void _updateBarcode(BarcodeModuleSettings Function(BarcodeModuleSettings s) update) {
    config.barcode = update(config.barcode);
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final b = config.barcode;
    return SampleModuleCard(
      title: 'Barcode',
      subtitle: config.barcodeEnabled ? 'Enabled' : 'Disabled (null)',
      enabled: config.barcodeEnabled,
      onEnabledChanged: (v) {
        config.barcodeEnabled = v;
        onChanged();
      },
      children: [
        SampleSectionLabel('Presence & image'),
        SampleBoolSettingTile(
          title: 'Presence mandatory',
          subtitle: 'Barcode must be present on scanned side(s)',
          value: b.presenceMandatory,
          onChanged: (v) => _updateBarcode((s) => s.copyWith(presenceMandatory: v)),
        ),
        SampleBoolSettingTile(
          title: 'Barcode image return',
          value: b.barcodeImageReturnEnabled,
          onChanged: (v) =>
              _updateBarcode((s) => s.copyWith(barcodeImageReturnEnabled: v)),
        ),
        SampleSectionLabel('Document barcodes'),
        SampleBoolSettingTile(
          title: 'PDF417 scanning',
          value: b.pdf417ScanningEnabled,
          onChanged: (v) =>
              _updateBarcode((s) => s.copyWith(pdf417ScanningEnabled: v)),
        ),
        SampleBoolSettingTile(
          title: 'QR scanning',
          value: b.qrScanningEnabled,
          onChanged: (v) => _updateBarcode((s) => s.copyWith(qrScanningEnabled: v)),
        ),
        SampleSectionLabel('Retail formats'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            'Retail formats apply when document capture is disabled.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        SampleBoolSettingTile(
          title: 'UPC-E',
          value: b.upceScanningEnabled,
          onChanged: (v) => _updateBarcode((s) => s.copyWith(upceScanningEnabled: v)),
        ),
        SampleBoolSettingTile(
          title: 'UPC-A',
          value: b.upcaScanningEnabled,
          onChanged: (v) => _updateBarcode((s) => s.copyWith(upcaScanningEnabled: v)),
        ),
        SampleBoolSettingTile(
          title: 'Code 128',
          value: b.code128ScanningEnabled,
          onChanged: (v) =>
              _updateBarcode((s) => s.copyWith(code128ScanningEnabled: v)),
        ),
        SampleBoolSettingTile(
          title: 'Code 39',
          value: b.code39ScanningEnabled,
          onChanged: (v) => _updateBarcode((s) => s.copyWith(code39ScanningEnabled: v)),
        ),
        SampleBoolSettingTile(
          title: 'EAN-8',
          value: b.ean8ScanningEnabled,
          onChanged: (v) => _updateBarcode((s) => s.copyWith(ean8ScanningEnabled: v)),
        ),
        SampleBoolSettingTile(
          title: 'EAN-13',
          value: b.ean13ScanningEnabled,
          onChanged: (v) => _updateBarcode((s) => s.copyWith(ean13ScanningEnabled: v)),
        ),
        SampleBoolSettingTile(
          title: 'ITF',
          value: b.itfScanningEnabled,
          onChanged: (v) => _updateBarcode((s) => s.copyWith(itfScanningEnabled: v)),
        ),
        SampleBoolSettingTile(
          title: 'DataMatrix',
          value: b.dataMatrixScanningEnabled,
          onChanged: (v) =>
              _updateBarcode((s) => s.copyWith(dataMatrixScanningEnabled: v)),
        ),
      ],
    );
  }
}

class _DocumentCaptureModuleCard extends StatelessWidget {
  final ScanningModulesConfig config;
  final VoidCallback onChanged;

  const _DocumentCaptureModuleCard({
    required this.config,
    required this.onChanged,
  });

  void _update(DocumentCaptureModuleSettings Function(DocumentCaptureModuleSettings s) update) {
    config.documentCapture = update(config.documentCapture);
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final d = config.documentCapture;
    return SampleModuleCard(
      title: 'Document capture',
      subtitle: config.documentCaptureEnabled ? 'Enabled' : 'Disabled (null)',
      enabled: config.documentCaptureEnabled,
      onEnabledChanged: (v) {
        config.documentCaptureEnabled = v;
        onChanged();
      },
      children: [
        SampleSectionLabel('Images & return'),
        SampleBoolSettingTile(
          title: 'Document image return',
          value: d.documentImageReturnEnabled,
          onChanged: (v) =>
              _update((s) => s.copyWith(documentImageReturnEnabled: v)),
        ),
        SampleBoolSettingTile(
          title: 'Input image return',
          subtitle: 'Increases memory usage',
          value: d.inputImageReturnEnabled,
          onChanged: (v) => _update((s) => s.copyWith(inputImageReturnEnabled: v)),
        ),
        SampleBoolSettingTile(
          title: 'Unsupported documents allowed',
          value: d.unsupportedDocumentsAllowed,
          onChanged: (v) =>
              _update((s) => s.copyWith(unsupportedDocumentsAllowed: v)),
        ),
        SampleBoolSettingTile(
          title: 'Skip second side with no extractable data',
          value: d.secondSideWithNoExtractableDataSkipped,
          onChanged: (v) =>
              _update((s) => s.copyWith(secondSideWithNoExtractableDataSkipped: v)),
        ),
        SampleSectionLabel('Face & passport'),
        SampleBoolSettingTile(
          title: 'Face image extraction',
          value: d.faceImageExtractionEnabled,
          onChanged: (v) =>
              _update((s) => s.copyWith(faceImageExtractionEnabled: v)),
        ),
        SampleBoolSettingTile(
          title: 'Face image presence mandatory',
          value: d.faceImagePresenceMandatory,
          onChanged: (v) =>
              _update((s) => s.copyWith(faceImagePresenceMandatory: v)),
        ),
        SampleBoolSettingTile(
          title: 'Passport data page scan only',
          value: d.passportDataPageScanOnly,
          onChanged: (v) => _update((s) => s.copyWith(passportDataPageScanOnly: v)),
        ),
        SampleSectionLabel('Image quality'),
        _SensitivityDropdown(
          label: 'Blur sensitivity',
          value: d.blurSensitivityLevel,
          onChanged: (v) => _update((s) => s.copyWith(blurSensitivityLevel: v)),
        ),
        SampleBoolSettingTile(
          title: 'Reject image with blur',
          value: d.imageWithBlurRejected,
          onChanged: (v) => _update((s) => s.copyWith(imageWithBlurRejected: v)),
        ),
        _SensitivityDropdown(
          label: 'Glare sensitivity',
          value: d.glareSensitivityLevel,
          onChanged: (v) => _update((s) => s.copyWith(glareSensitivityLevel: v)),
        ),
        SampleBoolSettingTile(
          title: 'Reject image with glare',
          value: d.imageWithGlareRejected,
          onChanged: (v) => _update((s) => s.copyWith(imageWithGlareRejected: v)),
        ),
        _SensitivityDropdown(
          label: 'Tilt sensitivity',
          value: d.tiltSensitivityLevel,
          onChanged: (v) => _update((s) => s.copyWith(tiltSensitivityLevel: v)),
        ),
        SampleBoolSettingTile(
          title: 'Reject poor lighting',
          value: d.imageWithPoorLightingRejected,
          onChanged: (v) =>
              _update((s) => s.copyWith(imageWithPoorLightingRejected: v)),
        ),
        SampleBoolSettingTile(
          title: 'Reject hand occlusion',
          value: d.imageWithHandOcclusionRejected,
          onChanged: (v) =>
              _update((s) => s.copyWith(imageWithHandOcclusionRejected: v)),
        ),
        SampleIntSettingField(
          label: 'Dots per inch',
          value: d.dotsPerInch,
          min: 100,
          max: 400,
          onChanged: (v) => _update((s) => s.copyWith(dotsPerInch: v)),
        ),
        _DoubleSettingField(
          label: 'Extension factor',
          value: d.extensionFactor,
          min: 0,
          max: 1,
          onChanged: (v) => _update((s) => s.copyWith(extensionFactor: v)),
        ),
        SampleSectionLabel('Direct API'),
        SampleBoolSettingTile(
          title: 'Input image cropped',
          subtitle: 'For pre-cropped Direct API images only',
          value: d.inputImageCropped,
          onChanged: (v) => _update((s) => s.copyWith(inputImageCropped: v)),
        ),
        _DoubleSettingField(
          label: 'Input image margin',
          value: d.inputImageMargin ?? 0.02,
          min: 0,
          max: 1,
          onChanged: (v) => _update((s) => s.copyWith(inputImageMargin: v)),
        ),
      ],
    );
  }
}

class _MrzModuleCard extends StatelessWidget {
  final ScanningModulesConfig config;
  final VoidCallback onChanged;

  const _MrzModuleCard({required this.config, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SampleModuleCard(
      title: 'MRZ',
      subtitle: config.mrzEnabled ? 'Enabled' : 'Disabled (null)',
      enabled: config.mrzEnabled,
      onEnabledChanged: (v) {
        config.mrzEnabled = v;
        onChanged();
      },
      children: [
        SampleBoolSettingTile(
          title: 'Presence mandatory',
          subtitle: 'MRZ must be present on scanned side(s)',
          value: config.mrz.presenceMandatory,
          onChanged: (v) {
            config.mrz = config.mrz.copyWith(presenceMandatory: v);
            onChanged();
          },
        ),
      ],
    );
  }
}

class _VizModuleCard extends StatelessWidget {
  final ScanningModulesConfig config;
  final VoidCallback onChanged;

  const _VizModuleCard({required this.config, required this.onChanged});

  void _update(VizModuleSettings Function(VizModuleSettings s) update) {
    config.viz = update(config.viz);
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final v = config.viz;
    return SampleModuleCard(
      title: 'VIZ',
      subtitle: config.vizEnabled ? 'Enabled' : 'Disabled (null)',
      enabled: config.vizEnabled,
      onEnabledChanged: (v) {
        config.vizEnabled = v;
        onChanged();
      },
      children: [
        SampleBoolSettingTile(
          title: 'Presence mandatory',
          value: v.presenceMandatory,
          onChanged: (val) => _update((s) => s.copyWith(presenceMandatory: val)),
        ),
        SampleBoolSettingTile(
          title: 'Signature image extraction',
          value: v.signatureImageExtractionEnabled,
          onChanged: (val) =>
              _update((s) => s.copyWith(signatureImageExtractionEnabled: val)),
        ),
        SampleBoolSettingTile(
          title: 'Character validation',
          value: v.characterValidationEnabled,
          onChanged: (val) =>
              _update((s) => s.copyWith(characterValidationEnabled: val)),
        ),
        SampleBoolSettingTile(
          title: 'Result aggregation',
          subtitle: 'Aggregate data from multiple frames (video only)',
          value: v.resultAggregationEnabled,
          onChanged: (val) => _update((s) => s.copyWith(resultAggregationEnabled: val)),
        ),
      ],
    );
  }
}

class _SessionSettingsCard extends StatelessWidget {
  final ScanningModulesConfig config;
  final VoidCallback onChanged;

  const _SessionSettingsCard({required this.config, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Session timeouts',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Duration in milliseconds. Set to 0 to disable timeout.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SampleIntSettingField(
              label: 'Step timeout duration',
              value: config.stepTimeoutDuration,
              min: 0,
              max: 600000,
              onChanged: (v) {
                config.stepTimeoutDuration = v;
                onChanged();
              },
            ),
            SampleIntSettingField(
              label: 'Inactivity timeout duration',
              value: config.inactivityTimeoutDuration,
              min: 0,
              max: 600000,
              onChanged: (v) {
                config.inactivityTimeoutDuration = v;
                onChanged();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _UxSettingsCard extends StatelessWidget {
  final ScanningModulesConfig config;
  final VoidCallback onChanged;

  const _UxSettingsCard({required this.config, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Text(
                'UX settings',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              'Apply to Scan with camera.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SampleBoolSettingTile(
              title: 'Show onboarding dialog',
              subtitle: 'Introduction dialog at the start of scanning',
              value: config.showOnboardingDialog,
              onChanged: (v) {
                config.showOnboardingDialog = v;
                onChanged();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SampleSectionLabel extends StatelessWidget {
  final String text;

  const SampleSectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class SampleBoolSettingTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SampleBoolSettingTile({
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      value: value,
      onChanged: onChanged,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

class _SensitivityDropdown extends StatelessWidget {
  final String label;
  final SensitivityLevel value;
  final ValueChanged<SensitivityLevel> onChanged;

  const _SensitivityDropdown({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonFormField<SensitivityLevel>(
        key: ValueKey('$label-$value'),
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: const OutlineInputBorder(),
        ),
        items: SensitivityLevel.values
            .map(
              (level) => DropdownMenuItem(
                value: level,
                child: Text(level.name),
              ),
            )
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

class SampleIntSettingField extends StatefulWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const SampleIntSettingField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  State<SampleIntSettingField> createState() => _SampleIntSettingFieldState();
}

class _SampleIntSettingFieldState extends State<SampleIntSettingField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.value}');
  }

  @override
  void didUpdateWidget(SampleIntSettingField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value &&
        _controller.text != '${widget.value}') {
      _controller.text = '${widget.value}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _commit() {
    final parsed = int.tryParse(_controller.text);
    if (parsed != null && parsed >= widget.min && parsed <= widget.max) {
      widget.onChanged(parsed);
    } else {
      _controller.text = '${widget.value}';
    }
  }

  void _commitAndDismiss() {
    _commit();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextFormField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: widget.label,
          helperText: '${widget.min}–${widget.max}',
          isDense: true,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        onTapOutside: (_) => _commitAndDismiss(),
        onFieldSubmitted: (_) => _commitAndDismiss(),
        onEditingComplete: _commitAndDismiss,
      ),
    );
  }
}

class _DoubleSettingField extends StatefulWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _DoubleSettingField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  State<_DoubleSettingField> createState() => _DoubleSettingFieldState();
}

class _DoubleSettingFieldState extends State<_DoubleSettingField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(_DoubleSettingField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value &&
        _controller.text != widget.value.toString()) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _commit() {
    final parsed = double.tryParse(_controller.text);
    if (parsed != null && parsed >= widget.min && parsed <= widget.max) {
      widget.onChanged(parsed);
    } else {
      _controller.text = widget.value.toString();
    }
  }

  void _commitAndDismiss() {
    _commit();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextFormField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: widget.label,
          helperText: '${widget.min}–${widget.max}',
          isDense: true,
          border: const OutlineInputBorder(),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: TextInputAction.done,
        onTapOutside: (_) => _commitAndDismiss(),
        onFieldSubmitted: (_) => _commitAndDismiss(),
        onEditingComplete: _commitAndDismiss,
      ),
    );
  }
}

class SampleEnumDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> options;
  final ValueChanged<T> onChanged;

  const SampleEnumDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  String _labelFor(T option) {
    if (option is Enum) {
      return option.name;
    }
    return option.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonFormField<T>(
        key: ValueKey('$label-$value'),
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: const OutlineInputBorder(),
        ),
        items: options
            .map(
              (option) => DropdownMenuItem(
                value: option,
                child: Text(_labelFor(option)),
              ),
            )
            .toList(),
        onChanged: (selected) {
          if (selected != null) {
            onChanged(selected);
          }
        },
      ),
    );
  }
}

class SampleOptionalEnumDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> options;
  final ValueChanged<T?> onChanged;

  const SampleOptionalEnumDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  String _labelFor(T option) {
    if (option is Enum) {
      return option.name;
    }
    return option.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonFormField<T?>(
        key: ValueKey('$label-${value ?? 'none'}'),
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: const OutlineInputBorder(),
        ),
        items: [
          DropdownMenuItem<T?>(
            value: null,
            child: Text('None'),
          ),
          ...options.map(
            (option) => DropdownMenuItem<T?>(
              value: option,
              child: Text(_labelFor(option)),
            ),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}
