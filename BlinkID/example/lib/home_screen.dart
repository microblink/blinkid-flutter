import 'dart:convert';
import 'dart:typed_data';

import 'package:blinkid_flutter/blinkid_flutter.dart';
import 'package:flutter/material.dart';

import 'custom_scanner_screen.dart';

const _licenseKeyAndroid = String.fromEnvironment('BLINKID_LICENSE_KEY_ANDROID');
const _licenseKeyIos = String.fromEnvironment('BLINKID_LICENSE_KEY_IOS');

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _blinkId = BlinkIdFlutter();
  BlinkIdScanningResult? _result;
  String? _error;
  bool _scanning = false;

  BlinkIdSdkSettings get _sdkSettings => BlinkIdSdkSettings(
    licenseKey: switch (Theme.of(context).platform) {
      .iOS => _licenseKeyIos,
      .android => _licenseKeyAndroid,
      .fuchsia || .linux || .macOS || .windows => throw UnsupportedError('BlinkID not supported on this platform'),
    },
  );

  BlinkIdSessionSettings get _sessionSettings => .new(
    scanningSettings: BlinkIdScanningSettings(
      documentCaptureModule: DocumentCaptureModuleSettings(
        documentImageReturnEnabled: true,
        inputImageReturnEnabled: true,
      ),
    ),
  );

  Future<void> _performScan() async {
    setState(() {
      _scanning = true;
      _result = null;
      _error = null;
    });
    try {
      final result = await _blinkId.performScan(
        blinkIdSdkSettings: _sdkSettings,
        blinkIdSessionSettings: _sessionSettings,
      );
      setState(() => _result = result);
    } catch (e, st) {
      debugPrint('BlinkID scan error: $e\n$st');
      setState(() => _error = 'Error: $e');
    } finally {
      setState(() => _scanning = false);
    }
  }

  Future<void> _openCustomScanner() async {
    setState(() { _result = null; _error = null; });
    final result = await Navigator.push<BlinkIdScanningResult>(
      context,
      MaterialPageRoute(
        builder: (_) => CustomScannerScreen(sdkSettings: _sdkSettings, sessionSettings: _sessionSettings),
      ),
    );
    if (result != null) setState(() => _result = result);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('BlinkID Example')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton(onPressed: _scanning ? null : _performScan, child: const Text('Scan (Native UI)')),
          const SizedBox(height: 12),
          FilledButton.tonal(onPressed: _scanning ? null : _openCustomScanner, child: const Text('Scan (Custom UI)')),
          const SizedBox(height: 24),
          if (_scanning) const Center(child: CircularProgressIndicator()),
          if (_error != null)
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
              ),
            ),
          if (_result != null) _ResultCard(result: _result!),
        ],
      ),
    ),
  );
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final BlinkIdScanningResult result;

  @override
  Widget build(BuildContext context) {
    final faceBytes = result.faceImage?.image != null ? base64Decode(result.faceImage!.image!) : null;
    final docInfo = result.documentClassInfo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (faceBytes != null) ...[
          Center(child: CircleAvatar(radius: 56, backgroundImage: MemoryImage(faceBytes))),
          const SizedBox(height: 16),
        ],
        _Section(
          title: 'Personal Info',
          rows: [
            _row('Full name', result.fullName?.value ?? _joinName(result)),
            _row('Date of birth', _formatDate(result.dateOfBirth?.date)),
            _row('Sex', result.sex?.value),
            _row('Nationality', result.nationality?.value),
            _row('Place of birth', result.placeOfBirth?.value),
            _row('Address', result.address?.value),
          ],
        ),
        const SizedBox(height: 12),
        _Section(
          title: 'Document',
          rows: [
            _row('Country', docInfo?.countryName),
            _row('Type', docInfo?.documentType?.name),
            _row('Document no.', result.documentNumber?.value),
            _row('Personal ID', result.personalIdNumber?.value),
            _row('Date of issue', _formatDate(result.dateOfIssue?.date)),
            _row('Date of expiry', _formatDate(result.dateOfExpiry?.date)),
            _row('Issuing authority', result.issuingAuthority?.value),
          ],
        ),
        const SizedBox(height: 12),
        _ImagesSection(result: result),
      ],
    );
  }

  String? _formatDate(Date? date) {
    if (date == null || date.year == null) return null;
    final d = (date.day ?? 1).toString().padLeft(2, '0');
    final m = (date.month ?? 1).toString().padLeft(2, '0');
    final y = date.year!.toString().padLeft(4, '0');
    return '$d/$m/$y';
  }

  String? _joinName(BlinkIdScanningResult r) {
    final first = r.firstName?.value;
    final last = r.lastName?.value;
    if (first == null && last == null) return null;
    return [first, last].where((s) => s != null && s.isNotEmpty).join(' ');
  }

  (String, String)? _row(String label, String? value) {
    if (value == null || value.isEmpty) return null;
    return (label, value);
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.rows});

  final String title;
  final List<(String, String)?> rows;

  @override
  Widget build(BuildContext context) {
    final visible = rows.whereType<(String, String)>().toList();
    if (visible.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            ...visible.map((row) => _FieldRow(label: row.$1, value: row.$2)),
          ],
        ),
      ),
    );
  }
}

class _ImagesSection extends StatelessWidget {
  const _ImagesSection({required this.result});

  final BlinkIdScanningResult result;

  @override
  Widget build(BuildContext context) {
    final images = <(String, Uint8List)>[
      if (result.firstDocumentImage != null) ('Front', base64Decode(result.firstDocumentImage!)),
      if (result.secondDocumentImage != null) ('Back', base64Decode(result.secondDocumentImage!)),
      if (result.signatureImage?.image != null) ('Signature', base64Decode(result.signatureImage!.image!)),
    ];

    if (images.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Images',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 12),
            ...images.map(
              (img) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    img.$1,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(img.$2, fit: BoxFit.contain, width: double.infinity),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
        Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyMedium)),
      ],
    ),
  );
}
