package com.microblink.blinkid.flutter

import android.graphics.BitmapFactory
import android.os.Parcelable
import com.microblink.blinkid.core.BlinkIdSdkSettings
import com.microblink.blinkid.core.result.AlphabetType
import com.microblink.blinkid.core.result.FieldType
import com.microblink.blinkid.core.result.classinfo.Country
import com.microblink.blinkid.core.result.classinfo.DocumentClassInfo
import com.microblink.blinkid.core.result.classinfo.Region
import com.microblink.blinkid.core.result.classinfo.Type
import com.microblink.blinkid.core.session.BlinkIdSessionSettings
import com.microblink.blinkid.core.session.ScanningMode
import com.microblink.blinkid.core.settings.CroppedImageSettings
import com.microblink.blinkid.core.settings.DetailedFieldType
import com.microblink.blinkid.core.settings.DocumentFilter
import com.microblink.blinkid.core.settings.DocumentRules
import com.microblink.blinkid.core.settings.RecognitionModeFilter
import com.microblink.blinkid.core.settings.ScanningSettings
import com.microblink.blinkid.ux.settings.BlinkIdUxSettings
import com.microblink.blinkid.core.settings.DocumentAnonymizationSettings
import com.microblink.blinkid.ux.settings.ClassFilter
import com.microblink.core.utils.defaultResourceDownloadUrl
import com.microblink.core.utils.defaultResourcesLocalFolder
import kotlin.time.Duration.Companion.milliseconds
import kotlinx.parcelize.Parcelize
import kotlinx.parcelize.RawValue
import android.graphics.Bitmap
import android.util.Base64
import com.microblink.blinkid.core.settings.DocumentNumberAnonymizationSettings
import com.microblink.core.network.RequestTimeout
import com.microblink.core.session.InputImageSource
import com.microblink.core.settings.AnonymizationMode
import com.microblink.core.settings.DetectionLevel
import com.microblink.ux.camera.CameraLensFacing
import com.microblink.ux.camera.CameraSettings

object BlinkIdDeserializationUtils {

    fun deserializeBlinkIdSdkSettings(blinkIdSdkSettingsMap: Map<String, Any>?): BlinkIdSdkSettings? {
        val licenseKey = blinkIdSdkSettingsMap?.get("licenseKey") as? String ?: return null

        val sdkSettings = BlinkIdSdkSettings(
            licenseKey = licenseKey,
            licensee = blinkIdSdkSettingsMap["licensee"] as? String,
            downloadResources = blinkIdSdkSettingsMap["downloadResources"] as? Boolean ?: true,
            resourceDownloadUrl = blinkIdSdkSettingsMap["resourceDownloadUrl"] as? String
                ?: defaultResourceDownloadUrl,
            resourceLocalFolder = blinkIdSdkSettingsMap["resourceLocalFolder"] as? String
                ?: defaultResourcesLocalFolder,
            resourceRequestTimeout = deserializeResourceRequestTimeout(blinkIdSdkSettingsMap["resourceRequestTimeout"] as? Map<String, Any>),
            microblinkProxyUrl = blinkIdSdkSettingsMap["microblinkProxyURL"] as? String,
            )

        return sdkSettings
    }

    fun deserializeBlinkIdSessionSettings(
        blinkIdSdkSessionSettingsMap: Map<String, Any>?,
        isDirectApi: Boolean
    ): BlinkIdSessionSettings {
        if (blinkIdSdkSessionSettingsMap == null) return BlinkIdSessionSettings()

        return BlinkIdSessionSettings(
            inputImageSource = if (isDirectApi) InputImageSource.Photo else InputImageSource.Video,
            scanningMode = ScanningMode.entries[blinkIdSdkSessionSettingsMap["scanningMode"] as? Int
                ?: ScanningMode.Automatic.ordinal],
            scanningSettings = deserializeScanningSettings(blinkIdSdkSessionSettingsMap["scanningSettings"] as? Map<String, Any>),
        )
    }

    private fun deserializeScanningSettings(scanningSettingsMap: Map<String, Any>?): ScanningSettings {
        if (scanningSettingsMap == null) return ScanningSettings()
        return ScanningSettings(
            blurDetectionLevel = DetectionLevel.entries[scanningSettingsMap["blurDetectionLevel"] as? Int
                ?: DetectionLevel.Mid.ordinal],
            skipImagesWithBlur = scanningSettingsMap["skipImagesWithBlur"] as? Boolean ?: true,
            glareDetectionLevel = DetectionLevel.entries[scanningSettingsMap["glareDetectionLevel"] as? Int
                ?: DetectionLevel.Mid.ordinal],
            skipImagesWithGlare = scanningSettingsMap["skipImagesWithGlare"] as? Boolean ?: true,
            tiltDetectionLevel = DetectionLevel.entries[scanningSettingsMap["tiltDetectionLevel"] as? Int
                ?: DetectionLevel.Off.ordinal],
            skipImagesWithInadequateLightingConditions = scanningSettingsMap["skipImagesWithInadequateLightingConditions"] as? Boolean
                ?: true,
            skipImagesOccludedByHand = scanningSettingsMap["skipImagesOccludedByHand"] as? Boolean
                ?: true,
            combineResultsFromMultipleInputImages = scanningSettingsMap["combineResultsFromMultipleInputImages"] as? Boolean
                ?: true,
            enableBarcodeScanOnly = scanningSettingsMap["enableBarcodeScanOnly"] as? Boolean
                ?: false,
            customDocumentRules = deserializeDocumentRules(scanningSettingsMap["customDocumentRules"] as? List<Map<String, Any>>),
            anonymizationMode = AnonymizationMode.entries[scanningSettingsMap["anonymizationMode"] as? Int
                ?: AnonymizationMode.FullResult.ordinal],
            customDocumentAnonymizationSettings = deserializeCustomAnonymizationSetings(
                scanningSettingsMap["customDocumentAnonymizationSettings"] as? List<Map<String, Any>>
            ),
            returnInputImages = scanningSettingsMap["returnInputImages"] as? Boolean ?: false,
            scanCroppedDocumentImage = scanningSettingsMap["scanCroppedDocumentImage"] as? Boolean
                ?: false,
            recognitionModeFilter = deserializeRecognitionModeFilter(scanningSettingsMap["recognitionModeFilter"] as? Map<String, Any>),
            enableCharacterValidation = scanningSettingsMap["enableCharacterValidation"] as? Boolean
                ?: true,
            inputImageMargin = (scanningSettingsMap["inputImageMargin"] as? Number)?.toFloat()
                ?: 0.02f,
            scanUnsupportedBack = scanningSettingsMap["scanUnsupportedBack"] as? Boolean ?: false,
            allowUncertainFrontSideScan = scanningSettingsMap["allowUncertainFrontSideScan"] as? Boolean
                ?: false,
            maxAllowedMismatchesPerField = (scanningSettingsMap["maxAllowedMismatchesPerField"] as? Int)?.toUInt()
                ?: 0u,
            scanPassportDataPageOnly = scanningSettingsMap["scanPassportDataPageOnly"] as? Boolean
                ?: true,
            croppedImageSettings = deserializeCroppedImageSettings(scanningSettingsMap["croppedImageSettings"] as? Map<String, Any>),
        )
    }

    private fun deserializeCroppedImageSettings(croppedImageSettingsMap: Map<String, Any>?): CroppedImageSettings {
        if (croppedImageSettingsMap == null) return CroppedImageSettings()
        return CroppedImageSettings(
            dotsPerInch = (croppedImageSettingsMap["dotsPerInch"] as? Int)?.toUShort() ?: 250u,
            extensionFactor = croppedImageSettingsMap["extensionFactor"] as? Float ?: 0.0f,
            returnDocumentImage = croppedImageSettingsMap["returnDocumentImage"] as? Boolean
                ?: false,
            returnFaceImage = croppedImageSettingsMap["returnFaceImage"] as? Boolean ?: false,
            returnSignatureImage = croppedImageSettingsMap["returnSignatureImage"] as? Boolean
                ?: false,
        )
    }

    private fun deserializeResourceRequestTimeout(resourceRequestTimeoutMap: Map<String, Any>?): RequestTimeout {
        if (resourceRequestTimeoutMap == null) return RequestTimeout.DEFAULT
        return RequestTimeout(
            connectionTimeoutMillis = (resourceRequestTimeoutMap["connectionTimeoutMilliseconds"] as? Number)?.toInt() ?: 10000,
            writeTimeoutMillis = (resourceRequestTimeoutMap["writeTimeoutMilliseconds"] as? Number)?.toInt() ?: 10000,
            readTimeoutMillis = (resourceRequestTimeoutMap["readTimeoutMilliseconds"] as? Number)?.toInt() ?: 10000
        )
    }

    private fun deserializeDocumentRules(documentRulesMapArray: List<Map<String, Any>>?): List<DocumentRules> {
        if (documentRulesMapArray == null) return emptyList()
        val documentRulesList = mutableListOf<DocumentRules>()

        for (documentRulesMap in documentRulesMapArray) {
            (documentRulesMap["fields"] as? List<Map<String, Any>>)?.let { fields ->
                val deserializedFields = fields.mapNotNull { deserializeDetailedFieldType(it) }
                documentRulesList.add(
                    DocumentRules(
                        deserializeDocumentFilter(documentRulesMap["documentFilter"] as? Map<String, Any>),
                        deserializedFields
                    )
                )
            } ?: continue
        }
        return documentRulesList
    }

    private fun deserializeDetailedFieldType(detailedFieldTypeMap: Map<String, Any>?): DetailedFieldType? {
        val fieldTypeName = detailedFieldTypeMap?.get("fieldType") as? String
        val alphabetTypeName = detailedFieldTypeMap?.get("alphabetType") as? String

        return if (fieldTypeName != null && alphabetTypeName != null) {
            DetailedFieldType(
                enumValueOf<FieldType>(fieldTypeName.replaceFirstChar { char -> char.uppercase() }),
                enumValueOf<AlphabetType>(alphabetTypeName.replaceFirstChar { char -> char.uppercase() })
            )
        } else {
            null
        }
    }

    private fun deserializeDocumentFilter(documentFilterMap: Map<String, Any>?): DocumentFilter {
        return if (documentFilterMap != null) {
            val filter = DocumentFilter()

            (documentFilterMap["country"] as? String)?.let {
                filter.country = enumValueOf<Country>(it.replaceFirstChar { char -> char.uppercase() })
            }
            (documentFilterMap["region"] as? String)?.let {
                filter.region = enumValueOf<Region>(it.replaceFirstChar { char -> char.uppercase() })
            }
            (documentFilterMap["documentType"] as? String)?.let {
                filter.type = enumValueOf<Type>(it.replaceFirstChar { char -> char.uppercase() })
            }
            filter
        } else {
            DocumentFilter()
        }
    }

    private fun deserializeCustomAnonymizationSetings(customAnonymizationSettingsMapArray: List<Map<String, Any>>?): List<DocumentAnonymizationSettings> {
        if (customAnonymizationSettingsMapArray == null) return emptyList()

        val customAnonymizationList = mutableListOf<DocumentAnonymizationSettings>()
        for (customAnonymizationSettingsMap in customAnonymizationSettingsMapArray) {
            (customAnonymizationSettingsMap["fields"] as? List<String>)?.let { fields ->
                val deserializedFields = fields.map { enumValueOf<FieldType>(it.replaceFirstChar { char -> char.uppercase() }) }
                customAnonymizationList.add(
                    DocumentAnonymizationSettings(
                        deserializeDocumentFilter(customAnonymizationSettingsMap["documentFilter"] as? Map<String, Any>),
                        deserializedFields,
                        deserializeDocumentNumberAnonymizationSettings(customAnonymizationSettingsMap["documentNumberAnonymizationSettings"] as? Map<String, Any>)
                    )
                )
            } ?: continue
        }
        return customAnonymizationList
    }

    private fun deserializeDocumentNumberAnonymizationSettings(documentNumberAnonymizationSettingsMap: Map<String, Any>?): DocumentNumberAnonymizationSettings? {
        if (documentNumberAnonymizationSettingsMap == null) return null
        return DocumentNumberAnonymizationSettings(
            prefixDigitsVisible = (documentNumberAnonymizationSettingsMap["prefixDigitsVisible"] as? Int)?.toUByte() ?: 0u,
            suffixDigitsVisible = (documentNumberAnonymizationSettingsMap["suffixDigitsVisible"] as? Int)?.toUByte() ?: 0u,
        )
    }

    private fun deserializeRecognitionModeFilter(recognitionModeFilterMap: Map<String, Any>?): RecognitionModeFilter {
        if (recognitionModeFilterMap == null) return RecognitionModeFilter()
        val filter = RecognitionModeFilter()
        filter.enableMrzId = recognitionModeFilterMap["enableMrzId"] as? Boolean ?: true
        filter.enableMrzVisa = recognitionModeFilterMap["enableMrzVisa"] as? Boolean ?: true
        filter.enablePhotoId = recognitionModeFilterMap["enablePhotoId"] as? Boolean ?: true
        filter.enableBarcodeId = recognitionModeFilterMap["enableBarcodeId"] as? Boolean ?: true
        filter.enableMrzPassport = recognitionModeFilterMap["enableMrzPassport"] as? Boolean ?: true
        filter.enableFullDocumentRecognition =
            recognitionModeFilterMap["enableFullDocumentRecognition"] as? Boolean ?: true
        return filter
    }


    fun deserializeBlinkIdUxSettings(
        blinkidUxSettingsMap: Map<String, Any>?,
        classFilterMap: Map<String, Any>?
    ): BlinkIdUxSettings {
        if (blinkidUxSettingsMap == null) return BlinkIdUxSettings()
        return BlinkIdUxSettings(
            stepTimeoutDuration = (blinkidUxSettingsMap["stepTimeoutDuration"] as? Int
                ?: 15000).milliseconds,
            allowHapticFeedback = (blinkidUxSettingsMap["allowHapticFeedback"] as? Boolean)?: true,
            classFilter = CustomClassFilter(classFilterMap),

        )
    }

    fun deserializeCameraSettings(blinkIdScanningUxSettingsMap: Map<String, Any>?): CameraSettings {
        if (blinkIdScanningUxSettingsMap == null) return CameraSettings()
        return CameraSettings(
            lensFacing = deserializeCameraLens(blinkIdScanningUxSettingsMap["preferredCamera"] as? String)
        )
    }
    fun deserializeCameraLens(value: String?): CameraLensFacing {
        return when (value?.lowercase()) {
            "front" -> CameraLensFacing.LensFacingFront
            "back" -> CameraLensFacing.LensFacingBack
            else -> CameraLensFacing.LensFacingBack
        }
    }
    fun deserializeClassFilter(
        classFilterMap: Map<String, Any>?,
        classInfo: DocumentClassInfo
    ): Boolean {
        if (classFilterMap == null) return true

        var includeClass = false
        var excludeClass = true

        val includedClasses = classFilterMap["includeDocuments"] as? List<Map<String, Any>>
        if (includedClasses != null) {
            for (includedClass in includedClasses) {
                includeClass = includeClass || matchClassFilter(includedClass, classInfo)
            }
        } else {
            includeClass = true
        }

        val excludedClasses = classFilterMap["excludeDocuments"] as? List<Map<String, Any>>
        if (excludedClasses != null) {
            for (excludedClass in excludedClasses) {
                excludeClass = excludeClass && !matchClassFilter(excludedClass, classInfo)
            }
        }

        return includeClass && excludeClass
    }

    private fun matchClassFilter(
        filteredClass: Map<String, Any>,
        classInfo: DocumentClassInfo
    ): Boolean {
        val country = filteredClass["country"] as? String
        val region = filteredClass["region"] as? String
        val documentType = filteredClass["documentType"] as? String

        return (country == null || enumValueOf<Country>(country.replaceFirstChar { char -> char.uppercase() }) == classInfo.country) &&
                (region == null || enumValueOf<Region>(region.replaceFirstChar { char -> char.uppercase() }) == classInfo.region) &&
                (documentType == null || enumValueOf<Type>(documentType.replaceFirstChar { char -> char.uppercase() }) == classInfo.type)
    }

    fun base64ToBitmap(base64Str: String?): Bitmap? {
        return try {
            val decodedBytes = Base64.decode(base64Str, Base64.DEFAULT)
            BitmapFactory.decodeByteArray(decodedBytes, 0, decodedBytes.size)
        } catch (e: IllegalArgumentException) {
            null
        }
    }
}

@Parcelize
private class CustomClassFilter(
    private val classFilterMap: @RawValue Map<String, Any>?
) : ClassFilter, Parcelable {

    override fun classAllowed(documentClass: DocumentClassInfo): Boolean {
        return BlinkIdDeserializationUtils.deserializeClassFilter(classFilterMap, documentClass)
    }
}
