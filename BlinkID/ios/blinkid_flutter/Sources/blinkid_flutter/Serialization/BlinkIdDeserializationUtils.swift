//
//  BlinkIdDeserializationUtils.swift
//  blinkid_flutter
//
//  Created by Milan Parađina on 08.04.2025..
//

import BlinkID
import BlinkIDUX
import Foundation
import UIKit

struct BlinkIdDeserializationUtils {
  static func deserializeBlinkIdSdkSettings(_ sdkSettingsDict: [String: Any]?)
    -> BlinkIDSdkSettings?
  {
    var blinkidSdkSettings: BlinkIDSdkSettings?

    if let licenseKey = sdkSettingsDict?["licenseKey"] as? String {
      blinkidSdkSettings = BlinkIDSdkSettings(licenseKey: licenseKey)
    }

    if let licensee = sdkSettingsDict?["licensee"] as? String {
      blinkidSdkSettings?.licensee = licensee
    }

    if let downloadResources = sdkSettingsDict?["downloadResources"] as? Bool {
      blinkidSdkSettings?.downloadResources = downloadResources
    }

    if let resourceDownloadUrl = sdkSettingsDict?["resourceDownloadUrl"] as? String {
      blinkidSdkSettings?.resourceDownloadUrl = resourceDownloadUrl
    }

    if let resourceLocalFolder = sdkSettingsDict?["resourceLocalFolder"] as? String {
      blinkidSdkSettings?.resourceLocalFolder = resourceLocalFolder
    }

    if let bundleURL = sdkSettingsDict?["bundleIdentifier"] as? String,
      let bundle: Bundle = Bundle.init(identifier: bundleURL)
    {
      blinkidSdkSettings?.bundleURL = bundle.bundleURL
    }

    if let resourceRequestTimeout = sdkSettingsDict?["resourceRequestTimeout"] as? Int {
      // TODO Bug in iOS native SDK
      blinkidSdkSettings?.resourceRequestTimeout = BlinkID.RequestTimeout.default
    }

    if let microblinkProxyUrl = sdkSettingsDict?["microblinkProxyUrl"] as? String {
      blinkidSdkSettings?.microblinkProxyURL = microblinkProxyUrl
    }

    return blinkidSdkSettings
  }

  static func deserializeBlinkIdSessionSettings(
    _ sessionSettingsDict: [String: Any]?, source: String = "performScan", isDirectApi: Bool = false
  ) -> BlinkIDSessionSettings {
    var blinkidSessionSettings = BlinkIDSessionSettings()

    if let scanningSettings = sessionSettingsDict?["scanningSettings"] as? [String: Any] {
      blinkidSessionSettings.scanningSettings = deserializeBlinkIdScanningSettings(scanningSettings)
      #if DEBUG
      logSessionSettings(
        source: source,
        sessionSettingsDict: sessionSettingsDict,
        scanningSettingsDict: scanningSettings,
        scanningSettings: blinkidSessionSettings.scanningSettings
      )
      #endif
    }

    if let scanningMode = sessionSettingsDict?["scanningMode"] as? String {
      blinkidSessionSettings.scanningMode = deserializeScanningMode(scanningMode)
    }

    if let stepTimeoutDuration = sessionSettingsDict?["stepTimeoutDuration"] as? Int {
      blinkidSessionSettings.stepTimeoutDuration = Double(stepTimeoutDuration) / 1000.0
    }

    if let inactivityTimeoutDuration = sessionSettingsDict?["inactivityTimeoutDuration"] as? Int {
      blinkidSessionSettings.inactivityTimeoutDuration = Double(inactivityTimeoutDuration) / 1000.0
    }

    if isDirectApi {
      blinkidSessionSettings.inputImageSource = .photo
    }

    return blinkidSessionSettings
  }

  static func deserializeBlinkIdScanningSettings(_ scanningSettingsDict: [String: Any]?)
    -> ScanningSettings
  {
    var scanningSettings = ScanningSettings()
    guard let scanningSettingsDict else {
      return scanningSettings
    }

    // NSNull means the caller explicitly disabled the module; absent key keeps the .init() default.
    let barcodeValue = scanningSettingsDict["barcodeModule"]
    if barcodeValue is NSNull {
      scanningSettings.barcodeModule = nil
    } else if let dict = barcodeValue as? [String: Any] {
      scanningSettings.barcodeModule = deserializeBarcodeModule(dict)
    }

    let documentCaptureValue = scanningSettingsDict["documentCaptureModule"]
    if documentCaptureValue is NSNull {
      scanningSettings.documentCaptureModule = nil
    } else if let dict = documentCaptureValue as? [String: Any] {
      scanningSettings.documentCaptureModule = deserializeDocumentCaptureModule(dict)
    }

    let mrzValue = scanningSettingsDict["mrzModule"]
    if mrzValue is NSNull {
      scanningSettings.mrzModule = nil
    } else if let dict = mrzValue as? [String: Any] {
      scanningSettings.mrzModule = deserializeMrzModule(dict)
    }

    let vizValue = scanningSettingsDict["vizModule"]
    if vizValue is NSNull {
      scanningSettings.vizModule = nil
    } else if let dict = vizValue as? [String: Any] {
      scanningSettings.vizModule = deserializeVizModule(dict)
    }

    if let maxAllowedMismatchesPerField = scanningSettingsDict["maxAllowedMismatchesPerField"]
      as? Int
    {
      scanningSettings.maxAllowedMismatchesPerField = maxAllowedMismatchesPerField
    }

    return scanningSettings
  }

  private static func logSessionSettings(
    source: String,
    sessionSettingsDict: [String: Any]?,
    scanningSettingsDict: [String: Any],
    scanningSettings: ScanningSettings
  ) {
    print(
      "[BlinkIdFlutter][\(source)] scanningMode=\(String(describing: sessionSettingsDict?["scanningMode"]))"
    )
    print(
      "[BlinkIdFlutter][\(source)] raw modules: documentCapture=\(String(describing: scanningSettingsDict["documentCaptureModule"])), "
        + "barcode=\(String(describing: scanningSettingsDict["barcodeModule"])), "
        + "mrz=\(String(describing: scanningSettingsDict["mrzModule"])), "
        + "viz=\(String(describing: scanningSettingsDict["vizModule"]))"
    )
    print(
      "[BlinkIdFlutter][\(source)] deserialized modules: documentCapture=\(String(describing: scanningSettings.documentCaptureModule)), "
        + "barcode=\(String(describing: scanningSettings.barcodeModule)), "
        + "mrz=\(String(describing: scanningSettings.mrzModule)), "
        + "viz=\(String(describing: scanningSettings.vizModule))"
    )
    if let barcode = scanningSettings.barcodeModule {
      print("[BlinkIdFlutter][\(source)] barcode.presenceMandatory=\(barcode.presenceMandatory)")
    }
    if let mrz = scanningSettings.mrzModule {
      print("[BlinkIdFlutter][\(source)] mrz.presenceMandatory=\(mrz.presenceMandatory)")
    }
    if let viz = scanningSettings.vizModule {
      print("[BlinkIdFlutter][\(source)] viz.presenceMandatory=\(viz.presenceMandatory)")
    }
  }

  static func deserializeBarcodeModule(_ barcodeModuleDict: [String: Any]) -> BarcodeModuleSettings
  {
    var barodeModuleSettings = BarcodeModuleSettings()

    if let barcodeImageReturnEnabled = barcodeModuleDict["barcodeImageReturnEnabled"] as? Bool {
      barodeModuleSettings.barcodeImageReturnEnabled = barcodeImageReturnEnabled
    }

    if let code128ScanningEnabled = barcodeModuleDict["code128ScanningEnabled"] as? Bool {
      barodeModuleSettings.code128ScanningEnabled = code128ScanningEnabled
    }

    if let code39ScanningEnabled = barcodeModuleDict["code39ScanningEnabled"] as? Bool {
      barodeModuleSettings.code39ScanningEnabled = code39ScanningEnabled
    }

    if let dataMatrixScanningEnabled = barcodeModuleDict["dataMatrixScanningEnabled"] as? Bool {
      barodeModuleSettings.dataMatrixScanningEnabled = dataMatrixScanningEnabled
    }

    if let ean13ScanningEnabled = barcodeModuleDict["ean13ScanningEnabled"] as? Bool {
      barodeModuleSettings.ean13ScanningEnabled = ean13ScanningEnabled
    }

    if let ean8ScanningEnabled = barcodeModuleDict["ean8ScanningEnabled"] as? Bool {
      barodeModuleSettings.ean8ScanningEnabled = ean8ScanningEnabled
    }

    if let itfScanningEnabled = barcodeModuleDict["itfScanningEnabled"] as? Bool {
      barodeModuleSettings.itfScanningEnabled = itfScanningEnabled
    }

    if let pdf417ScanningEnabled = barcodeModuleDict["pdf417ScanningEnabled"] as? Bool {
      barodeModuleSettings.pdf417ScanningEnabled = pdf417ScanningEnabled
    }

    if let presenceMandatory = barcodeModuleDict["presenceMandatory"] as? Bool {
      barodeModuleSettings.presenceMandatory = presenceMandatory
    }

    if let qrScanningEnabled = barcodeModuleDict["qrScanningEnabled"] as? Bool {
      barodeModuleSettings.qrScanningEnabled = qrScanningEnabled
    }

    if let upcaScanningEnabled = barcodeModuleDict["upcaScanningEnabled"] as? Bool {
      barodeModuleSettings.upcaScanningEnabled = upcaScanningEnabled
    }

    if let upceScanningEnabled = barcodeModuleDict["upceScanningEnabled"] as? Bool {
      barodeModuleSettings.upceScanningEnabled = upceScanningEnabled
    }

    return barodeModuleSettings
  }

  static func deserializeDocumentCaptureModule(_ documentCaptureModuleDict: [String: Any])
    -> DocumentCaptureModuleSettings
  {
    var documentCaptureSettings = DocumentCaptureModuleSettings()

    if let blurSensitivityLevel = documentCaptureModuleDict["blurSensitivityLevel"] as? String {
      documentCaptureSettings.blurSensitivityLevel = deserializeSensitivityLevel(
        blurSensitivityLevel)
    }

    if let glareSensitivityLevel = documentCaptureModuleDict["glareSensitivityLevel"] as? String {
      documentCaptureSettings.glareSensitivityLevel = deserializeSensitivityLevel(
        glareSensitivityLevel)
    }

    if let tiltSensitivityLevel = documentCaptureModuleDict["tiltSensitivityLevel"] as? String {
      documentCaptureSettings.tiltSensitivityLevel = deserializeSensitivityLevel(
        tiltSensitivityLevel)
    }

    if let documentImageReturnEnabled = documentCaptureModuleDict["documentImageReturnEnabled"]
      as? Bool
    {
      documentCaptureSettings.documentImageReturnEnabled = documentImageReturnEnabled
    }

    if let dotsPerInch = documentCaptureModuleDict["dotsPerInch"] as? Int {
      documentCaptureSettings.dotsPerInch = DPI(dotsPerInch)
    }

    if let extensionFactor = documentCaptureModuleDict["extensionFactor"] as? Double {
      documentCaptureSettings.extensionFactor = Float(extensionFactor)
    }

    if let faceImageExtractionEnabled = documentCaptureModuleDict["faceImageExtractionEnabled"]
      as? Bool
    {
      documentCaptureSettings.faceImageExtractionEnabled = faceImageExtractionEnabled
    }

    if let faceImagePresenceMandatory = documentCaptureModuleDict["faceImagePresenceMandatory"]
      as? Bool
    {
      documentCaptureSettings.faceImagePresenceMandatory = faceImagePresenceMandatory
    }

    if let imageWithBlurRejected = documentCaptureModuleDict["imageWithBlurRejected"] as? Bool {
      documentCaptureSettings.imageWithBlurRejected = imageWithBlurRejected
    }

    if let imageWithGlareRejected = documentCaptureModuleDict["imageWithGlareRejected"] as? Bool {
      documentCaptureSettings.imageWithGlareRejected = imageWithGlareRejected
    }

    if let imageWithHandOcclusionRejected = documentCaptureModuleDict[
      "imageWithHandOcclusionRejected"] as? Bool
    {
      documentCaptureSettings.imageWithHandOcclusionRejected = imageWithHandOcclusionRejected
    }

    if let imageWithPoorLightingRejected = documentCaptureModuleDict[
      "imageWithPoorLightingRejected"] as? Bool
    {
      documentCaptureSettings.imageWithPoorLightingRejected = imageWithPoorLightingRejected
    }

    if let inputImageCropped = documentCaptureModuleDict["inputImageCropped"] as? Bool {
      documentCaptureSettings.inputImageCropped = inputImageCropped
    }

    if let inputImageReturnEnabled = documentCaptureModuleDict["inputImageReturnEnabled"] as? Bool {
      documentCaptureSettings.inputImageReturnEnabled = inputImageReturnEnabled
    }

    if let passportDataPageScanOnly = documentCaptureModuleDict["passportDataPageScanOnly"] as? Bool
    {
      documentCaptureSettings.passportDataPageScanOnly = passportDataPageScanOnly
    }

    if let secondSideWithNoExtractableDataSkipped = documentCaptureModuleDict[
      "secondSideWithNoExtractableDataSkipped"] as? Bool
    {
      documentCaptureSettings.secondSideWithNoExtractableDataSkipped =
        secondSideWithNoExtractableDataSkipped
    }

    if let unsupportedDocumentsAllowed = documentCaptureModuleDict["unsupportedDocumentsAllowed"]
      as? Bool
    {
      documentCaptureSettings.unsupportedDocumentsAllowed = unsupportedDocumentsAllowed
    }

    if let inputImageMargin = documentCaptureModuleDict["inputImageMargin"] as? Double {
      documentCaptureSettings.inputImageMargin = Float(inputImageMargin)
    }

    if let tiltSensitivityLevel = documentCaptureModuleDict["tiltSensitivityLevel"] as? String {
      documentCaptureSettings.tiltSensitivityLevel = deserializeSensitivityLevel(
        tiltSensitivityLevel)
    }
    return documentCaptureSettings
  }

  static func deserializeSensitivityLevel(_ sensitivityLevelRawValue: String) -> SensitivityLevel {
    switch sensitivityLevelRawValue {
    case "off": return .off
    case "low": return .low
    case "mid": return .mid
    case "high": return .high
    default: return .mid
    }
  }

  static func deserializeMrzModule(_ mrzModuleDict: [String: Any]) -> MrzModuleSettings {

    var mrzModuleSettings = MrzModuleSettings()

    if let presenceMandatory = mrzModuleDict["presenceMandatory"] as? Bool {
      mrzModuleSettings.presenceMandatory = presenceMandatory
    }

    return mrzModuleSettings
  }

  static func deserializeVizModule(_ vizModuleDict: [String: Any]) -> VizModuleSettings {
    var vizModuleSettings = VizModuleSettings()

    if let characterValidationEnabled = vizModuleDict["characterValidationEnabled"] as? Bool {
      vizModuleSettings.characterValidationEnabled = characterValidationEnabled
    }

    if let presenceMandatory = vizModuleDict["presenceMandatory"] as? Bool {
      vizModuleSettings.presenceMandatory = presenceMandatory
    }

    if let signatureImageExtractionEnabled = vizModuleDict["signatureImageExtractionEnabled"]
      as? Bool
    {
      vizModuleSettings.signatureImageExtractionEnabled = signatureImageExtractionEnabled
    }

    if let resultAggregationEnabled = vizModuleDict["resultAggregationEnabled"] as? Bool {
      vizModuleSettings.resultAggregationEnabled = resultAggregationEnabled
    }

    return vizModuleSettings
  }

  static func deserializeRedactionSettings(_ redactionDict: [String: Any]) -> RedactionSettings? {
    guard let fieldsRaw = toStringList(redactionDict["fields"]), !fieldsRaw.isEmpty else {
      print(
        "[BlinkIdFlutter] deserializeRedactionSettings: no fields deserialized from \(String(describing: redactionDict["fields"]))"
      )
      return nil
    }
    let fieldTypes: [FieldType] = fieldsRaw.compactMap { FieldType(rawValue: $0) }
    if fieldTypes.isEmpty {
      print(
        "[BlinkIdFlutter] deserializeRedactionSettings: no valid FieldType values in \(fieldsRaw)")
      return nil
    }

    let mode: RedactionMode
    if let modeRaw = redactionDict["mode"] as? String,
      let parsedMode = RedactionMode(rawValue: modeRaw)
    {
      mode = parsedMode
    } else {
      mode = .fullResult
    }

    let redactBarcode = redactionDict["redactBarcodeResult"] as? Bool ?? false
    let redactMrz = redactionDict["redactMrzResult"] as? Bool ?? false

    let documentNumberRedaction: DocumentNumberRedactionSettings?
    if let documentNumberRedactionDict = toStringKeyedMap(
      redactionDict["documentNumberRedactionSettings"])
    {
      documentNumberRedaction = deserializeDocumentNumberRedactionSettings(
        documentNumberRedactionDict)
    } else {
      documentNumberRedaction = nil
    }

    return RedactionSettings(
      mode: mode,
      fields: fieldTypes,
      documentNumberRedactionSettings: documentNumberRedaction,
      redactMrz: redactMrz,
      redactBarcode: redactBarcode
    )
  }

  static func deserializeDocumentNumberRedactionSettings(
    _ documentNumberRedactionSettingsDict: [String: Any]
  ) -> DocumentNumberRedactionSettings {
    var documentNumberRedactionSettings = DocumentNumberRedactionSettings()

    if let prefixDigitsVisible = toInt(documentNumberRedactionSettingsDict["prefixDigitsVisible"]) {
      documentNumberRedactionSettings.prefixDigitsVisible = UInt8(prefixDigitsVisible)
    }

    if let suffixDigitsVisible = toInt(documentNumberRedactionSettingsDict["suffixDigitsVisible"]) {
      documentNumberRedactionSettings.suffixDigitsVisible = UInt8(suffixDigitsVisible)
    }

    return documentNumberRedactionSettings
  }

  static func deserializeBlinkIdUxScanningSettings(_ scanningUxSettingsDict: [String: Any]?)
    -> ScanningUXSettings
  {
    if let scanningUxSettingsDict = scanningUxSettingsDict,
      let allowHapticFeedback = scanningUxSettingsDict["allowHapticFeedback"] as? Bool,
      let preferredCameraPosition = scanningUxSettingsDict["preferredCamera"] as? String,
      let showHelpButton = scanningUxSettingsDict["showHelpButton"] as? Bool,
      let showIntroductionAlert = scanningUxSettingsDict["showOnboardingDialog"] as? Bool
    {
      return ScanningUXSettings(
        showIntroductionAlert: showIntroductionAlert,
        showHelpButton: showHelpButton,
        preferredCameraPosition: deserializePreferredCameraPosition(preferredCameraPosition),
        allowHapticFeedback: allowHapticFeedback)
    }
    return ScanningUXSettings()
  }

  static func deserializePreferredCameraPosition(_ value: String) -> Camera.CameraPosition {
    switch value {
    case "front":
      return Camera.CameraPosition.front
    case "back":
      return Camera.CameraPosition.back
    default:
      return Camera.CameraPosition.back
    }
  }

  static func deserializeScanningMode(_ value: String) -> ScanningMode {
    switch value {
    case "single":
      return ScanningMode.single
    case "automatic":
      return ScanningMode.automatic
    default:
      return ScanningMode.automatic
    }
  }

  static func deserializeDetailedFieldType(_ detailedFieldTypeDict: [String: Any]?)
    -> DetailedFieldType?
  {
    if let fieldType = detailedFieldTypeDict?["fieldType"] as? String,
      let alphabetType = detailedFieldTypeDict?["alphabetType"] as? String,
      let fieldTypeValue = FieldType.init(rawValue: fieldType),
      let alphabetTypeValue = AlphabetType(rawValue: alphabetType)
    {
      return DetailedFieldType(
        fieldType: fieldTypeValue,
        alphabetType: alphabetTypeValue)
    }
    return nil
  }

  static func deserializeRedactionSettingsResolver(
    _ redactionResolverDict: [String: Any]?,
    _ classInfo: BlinkID.BlinkIDSDK.DocumentClassInfo
  ) -> RedactionSettings? {

    guard let redactionResolverDict,
      let documentRedactionList = toStringKeyedMapList(
        redactionResolverDict["documentRedactionList"]),
      !documentRedactionList.isEmpty
    else { return nil }

    for redactionDict in documentRedactionList {
      if shouldUseRedactionSettings(redactionDict, classInfo: classInfo) {
        let settings = deserializeRedactionSettings(redactionDict)
        print(
          "[BlinkIdFlutter] resolveRedactionSettings matched class=\(classInfo.country)/\(classInfo.region)/\(classInfo.documentType), mode=\(String(describing: settings?.mode)), fields=\(settings?.fields.count ?? 0)"
        )
        return settings
      }
    }

    print(
      "[BlinkIdFlutter] resolveRedactionSettings no matching entry for class=\(classInfo.country)/\(classInfo.region)/\(classInfo.documentType)"
    )
    return nil
  }

  private static func shouldUseRedactionSettings(
    _ redactionDict: [String: Any],
    classInfo: BlinkID.BlinkIDSDK.DocumentClassInfo
  ) -> Bool {
    guard let documentFilters = toStringKeyedMapList(redactionDict["documentFilter"]) else {
      return true
    }

    if documentFilters.isEmpty {
      return true
    }

    return documentFilters.contains { filterDict in
      matchClassFilter(filterDict, classInfo: classInfo)
    }
  }

  static func deserializeClassFilter(
    _ classFilterDictArr: [String: Any]?, _ classInfo: BlinkID.BlinkIDSDK.DocumentClassInfo
  ) -> Bool {
    guard let sanitizedDict = sanitizeDictionary(classFilterDictArr) else { return true }
    var includeClass = false
    var excludeClass = true

    if let includedClasses = sanitizedDict["includeDocuments"] as? [[String: Any]] {
      for includedClass in includedClasses {
        includeClass = includeClass || matchClassFilter(includedClass, classInfo: classInfo)
      }
    } else {
      includeClass = true
    }

    if let excludedClasses = sanitizedDict["excludeDocuments"] as? [[String: Any]] {
      for excludedClass in excludedClasses {
        excludeClass = excludeClass && !matchClassFilter(excludedClass, classInfo: classInfo)
      }
    }

    return includeClass && excludeClass
  }

  static func matchClassFilter(
    _ filteredClass: [String: Any], classInfo: BlinkID.BlinkIDSDK.DocumentClassInfo
  ) -> Bool {
    let country = filteredClass["country"] as? String
    let type = filteredClass["documentType"] as? String
    let region = filteredClass["region"] as? String

    let countryMatches = country == nil || classInfo.country == Country(rawValue: country!)
    let typeMatches = type == nil || classInfo.documentType == DocumentType(rawValue: type!)
    let regionMatches = region == nil || classInfo.region == Region(rawValue: region!)

    return countryMatches && typeMatches && regionMatches
  }

  static func toStringKeyedMap(_ value: Any?) -> [String: Any]? {
    guard let dictionary = value as? [String: Any] else { return nil }
    return sanitizeDictionary(dictionary)
  }

  private static func toStringList(_ value: Any?) -> [String]? {
    guard let rawList = value as? [Any] else { return nil }
    return rawList.compactMap { $0 as? String }
  }

  private static func toStringKeyedMapList(_ value: Any?) -> [[String: Any]]? {
    guard let rawList = value as? [Any] else { return nil }
    return rawList.compactMap { item in
      guard let dictionary = item as? [String: Any] else { return nil }
      return sanitizeDictionary(dictionary)
    }
  }

  private static func toInt(_ value: Any?) -> Int? {
    if let intValue = value as? Int {
      return intValue
    }
    if let int32Value = value as? Int32 {
      return Int(int32Value)
    }
    if let int64Value = value as? Int64 {
      return Int(int64Value)
    }
    if let number = value as? NSNumber {
      return number.intValue
    }
    return nil
  }

  static func sanitizeDictionary(_ dictionary: [String: Any]?) -> [String: Any]? {
    if let dictionary = dictionary {
      var sanitized = dictionary
      for (key, value) in dictionary {
        if value is NSNull {
          sanitized[key] = nil
        }
      }
      return sanitized
    }
    return dictionary
  }

  static func deserializeBase64Image(_ base64Image: String?) -> UIImage? {
    if let base64Image = base64Image,
      let data = Data(base64Encoded: base64Image, options: .ignoreUnknownCharacters)
    {
      return UIImage(data: data)
    }
    return nil
  }
}
