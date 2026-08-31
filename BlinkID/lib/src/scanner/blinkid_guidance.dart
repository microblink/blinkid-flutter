import 'package:flutter/foundation.dart';

/// Guidance states emitted by [BlinkIdScannerController.guidanceStream].
///
/// Both platforms emit a guidance string per frame.  Mapping:
///
///   wrongSide          — ProcessingStatus.ScanningWrongSide
///   blur               — blurDetectionStatus == Detected
///   glare              — glareDetectionStatus == Detected
///   tooFar             — DetectionStatus.CameraTooFar
///   tooClose           — DetectionStatus.CameraTooClose
///   tooCloseToEdge     — DetectionStatus.DocumentTooCloseToCameraEdge
///   tilted             — DetectionStatus.CameraAngleTooSteep
///   notFullyVisible    — DetectionStatus.DocumentPartiallyVisible
///   searching          — DetectionStatus.Success / Failed (fallback)
///
/// [flipDocument] is NOT a DetectionStatus — it is emitted by the controller
/// when ScanningStatus.SideScanned fires (front side complete). The guidance
/// stream goes silent during the flip phase; use [BlinkIdScanPhase] instead.
///
/// holdStill / lowLight / tooMuchLight are reserved for forward-compat.
sealed class BlinkIdGuidance {
  const BlinkIdGuidance._();

  // --- Android + iOS ---
  const factory BlinkIdGuidance.searching() = BlinkIdGuidanceSearching;
  const factory BlinkIdGuidance.tooFar() = BlinkIdGuidanceTooFar;
  const factory BlinkIdGuidance.tooClose() = BlinkIdGuidanceTooClose;
  const factory BlinkIdGuidance.tooCloseToEdge() = BlinkIdGuidanceTooCloseToEdge;
  const factory BlinkIdGuidance.tilted() = BlinkIdGuidanceTilted;
  const factory BlinkIdGuidance.notFullyVisible() = BlinkIdGuidanceNotFullyVisible;

  // --- Phase-driven (not emitted via stream; use BlinkIdScanPhase.flip) ---
  const factory BlinkIdGuidance.flipDocument() = BlinkIdGuidanceFlipDocument;

  // --- Wrong side (emitted to stream; no phase change) ---
  const factory BlinkIdGuidance.wrongSide() = BlinkIdGuidanceWrongSide;

  // --- Quality hints (emitted by both platforms when detected) ---
  const factory BlinkIdGuidance.blur() = BlinkIdGuidanceBlur;
  const factory BlinkIdGuidance.glare() = BlinkIdGuidanceGlare;

  // --- Reserved (not emitted by either platform SDK; kept for forward-compat) ---
  const factory BlinkIdGuidance.holdStill() = BlinkIdGuidanceHoldStill;
  const factory BlinkIdGuidance.lowLight() = BlinkIdGuidanceLowLight;
  const factory BlinkIdGuidance.tooMuchLight() = BlinkIdGuidanceTooMuchLight;

  static BlinkIdGuidance fromString(String value) => switch (value) {
    'searching' => const BlinkIdGuidance.searching(),
    'tooFar' => const BlinkIdGuidance.tooFar(),
    'tooClose' => const BlinkIdGuidance.tooClose(),
    'tooCloseToEdge' => const BlinkIdGuidance.tooCloseToEdge(),
    'tilted' => const BlinkIdGuidance.tilted(),
    'notFullyVisible' => const BlinkIdGuidance.notFullyVisible(),
    'flipDocument' => const BlinkIdGuidance.flipDocument(),
    'wrongSide' => const BlinkIdGuidance.wrongSide(),
    'holdStill' => const BlinkIdGuidance.holdStill(),
    'blur' => const BlinkIdGuidance.blur(),
    'glare' => const BlinkIdGuidance.glare(),
    'lowLight' => const BlinkIdGuidance.lowLight(),
    'tooMuchLight' => const BlinkIdGuidance.tooMuchLight(),
    _ => _unknown(value),
  };

  static BlinkIdGuidance _unknown(String value) {
    assert(() {
      debugPrint('[BlinkID] Unknown guidance value: "$value"');
      return true;
    }());
    return const BlinkIdGuidance.searching();
  }
}

final class BlinkIdGuidanceSearching extends BlinkIdGuidance {
  const BlinkIdGuidanceSearching() : super._();
}

final class BlinkIdGuidanceTooFar extends BlinkIdGuidance {
  const BlinkIdGuidanceTooFar() : super._();
}

final class BlinkIdGuidanceTooClose extends BlinkIdGuidance {
  const BlinkIdGuidanceTooClose() : super._();
}

final class BlinkIdGuidanceTooCloseToEdge extends BlinkIdGuidance {
  const BlinkIdGuidanceTooCloseToEdge() : super._();
}

final class BlinkIdGuidanceTilted extends BlinkIdGuidance {
  const BlinkIdGuidanceTilted() : super._();
}

final class BlinkIdGuidanceNotFullyVisible extends BlinkIdGuidance {
  const BlinkIdGuidanceNotFullyVisible() : super._();
}

final class BlinkIdGuidanceFlipDocument extends BlinkIdGuidance {
  const BlinkIdGuidanceFlipDocument() : super._();
}

final class BlinkIdGuidanceWrongSide extends BlinkIdGuidance {
  const BlinkIdGuidanceWrongSide() : super._();
}

final class BlinkIdGuidanceHoldStill extends BlinkIdGuidance {
  const BlinkIdGuidanceHoldStill() : super._();
}

final class BlinkIdGuidanceBlur extends BlinkIdGuidance {
  const BlinkIdGuidanceBlur() : super._();
}

final class BlinkIdGuidanceGlare extends BlinkIdGuidance {
  const BlinkIdGuidanceGlare() : super._();
}

final class BlinkIdGuidanceLowLight extends BlinkIdGuidance {
  const BlinkIdGuidanceLowLight() : super._();
}

final class BlinkIdGuidanceTooMuchLight extends BlinkIdGuidance {
  const BlinkIdGuidanceTooMuchLight() : super._();
}
