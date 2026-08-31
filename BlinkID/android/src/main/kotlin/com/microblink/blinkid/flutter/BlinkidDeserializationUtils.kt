package com.microblink.blinkid.flutter

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Parcelable
import android.util.Base64
import android.util.Log
import com.microblink.blinkid.core.BlinkIdSdkSettings
import com.microblink.blinkid.core.network.RequestTimeout
import com.microblink.blinkid.core.result.FieldType
import com.microblink.blinkid.core.result.classinfo.Country
import com.microblink.blinkid.core.result.classinfo.DocumentClassInfo
import com.microblink.blinkid.core.result.classinfo.Region
import com.microblink.blinkid.core.result.classinfo.Type
import com.microblink.blinkid.core.session.BlinkIdSessionSettings
import com.microblink.blinkid.core.session.InputImageSource
import com.microblink.blinkid.core.session.ScanningMode
import com.microblink.blinkid.core.settings.DocumentFilter
import com.microblink.blinkid.core.settings.DocumentNumberRedactionSettings
import com.microblink.blinkid.core.settings.RedactionMode
import com.microblink.blinkid.core.settings.RedactionSettings
import com.microblink.blinkid.core.settings.RedactionSettingsResolver
import com.microblink.blinkid.core.settings.ScanningSettings
import com.microblink.blinkid.core.settings.SensitivityLevel
import com.microblink.blinkid.core.settings.scanning.BarcodeModuleSettings
import com.microblink.blinkid.core.settings.scanning.DocumentCaptureModuleSettings
import com.microblink.blinkid.core.settings.scanning.MrzModuleSettings
import com.microblink.blinkid.core.settings.scanning.VizModuleSettings
import com.microblink.blinkid.ux.camera.CameraLensFacing
import com.microblink.blinkid.ux.camera.CameraSettings
import com.microblink.blinkid.ux.settings.BlinkIdUxSettings
import com.microblink.blinkid.ux.settings.ClassFilter
import kotlinx.parcelize.Parcelize
import kotlinx.parcelize.RawValue
import kotlin.time.Duration.Companion.milliseconds

object BlinkIdDeserializationUtils {
    internal const val TAG = "BlinkIdFlutter"
    private const val DEFAULT_RESOURCE_DOWNLOAD_URL = "https://models.cdn.microblink.com/resources"
    private const val DEFAULT_RESOURCES_LOCAL_FOLDER = "MLModels"

    fun deserializeBlinkIdSdkSettings(blinkIdSdkSettingsMap: Map<String, Any>?): BlinkIdSdkSettings? {
        val licenseKey = blinkIdSdkSettingsMap?.get("licenseKey") as? String ?: return null

        val sdkSettings =
            BlinkIdSdkSettings(
                licenseKey = licenseKey,
                licensee = blinkIdSdkSettingsMap["licensee"] as? String,
                downloadResources = blinkIdSdkSettingsMap["downloadResources"] as? Boolean ?: true,
                resourceDownloadUrl =
                    blinkIdSdkSettingsMap["resourceDownloadUrl"] as? String
                        ?: DEFAULT_RESOURCE_DOWNLOAD_URL,
                resourceLocalFolder =
                    blinkIdSdkSettingsMap["resourceLocalFolder"] as? String
                        ?: DEFAULT_RESOURCES_LOCAL_FOLDER,
                resourceRequestTimeout =
                    deserializeResourceRequestTimeout(
                        blinkIdSdkSettingsMap["resourceRequestTimeout"] as? Map<String, Any>,
                    ),
                microblinkProxyUrl = blinkIdSdkSettingsMap["microblinkProxyUrl"] as? String,
            )

        return sdkSettings
    }

    fun deserializeBlinkIdSessionSettings(
        blinkIdSdkSessionSettingsMap: Map<String, Any>?,
        isDirectApi: Boolean,
    ): BlinkIdSessionSettings {
        if (blinkIdSdkSessionSettingsMap == null) return BlinkIdSessionSettings()

        val scanningSettingsMap =
            blinkIdSdkSessionSettingsMap["scanningSettings"] as? Map<String, Any>
        val scanningSettings = deserializeScanningSettings(scanningSettingsMap)
        logSessionSettings(
            source = if (isDirectApi) "directApi" else "performScan",
            sessionMap = blinkIdSdkSessionSettingsMap,
            scanningSettingsMap = scanningSettingsMap,
            scanningSettings = scanningSettings,
        )

        return BlinkIdSessionSettings(
            inputImageSource = if (isDirectApi) InputImageSource.Photo else InputImageSource.Video,
            scanningMode = deserializeScanningMode(blinkIdSdkSessionSettingsMap["scanningMode"] as? String),
            scanningSettings = scanningSettings,
        )
    }

    private fun deserializeScanningMode(value: String?): ScanningMode =
        when (value?.lowercase()) {
            "single" -> ScanningMode.Single
            "automatic" -> ScanningMode.Automatic
            else -> ScanningMode.Automatic
        }

    private fun deserializeScanningSettings(scanningSettingsMap: Map<String, Any>?): ScanningSettings {
        if (scanningSettingsMap == null) return ScanningSettings()
        // Absent key → SDK default (module enabled). Present-but-null key → explicit
        return ScanningSettings(
            documentCaptureModule =
                resolveModuleSettings(
                    scanningSettingsMap,
                    "documentCaptureModule",
                    DocumentCaptureModuleSettings(),
                    ::deserializeDocumentCaptureModuleSettings,
                ),
            barcodeModule =
                resolveModuleSettings(
                    scanningSettingsMap,
                    "barcodeModule",
                    BarcodeModuleSettings(),
                    ::deserializeBarcodeModuleSettings,
                ),
            mrzModule =
                resolveModuleSettings(
                    scanningSettingsMap,
                    "mrzModule",
                    MrzModuleSettings(),
                    ::deserializeMrzModuleSettings,
                ),
            vizModule =
                resolveModuleSettings(
                    scanningSettingsMap,
                    "vizModule",
                    VizModuleSettings(),
                    ::deserializeVizModuleSettings,
                ),
            maxAllowedMismatchesPerField =
                (scanningSettingsMap["maxAllowedMismatchesPerField"] as? Int)?.toUInt()
                    ?: 0u,
        )
    }

    private fun <T> resolveModuleSettings(
        map: Map<String, Any>,
        key: String,
        default: T,
        deserialize: (Map<String, Any>) -> T,
    ): T? {
        if (!map.containsKey(key)) return default
        val value = map[key] ?: return null
        val moduleMap = value as? Map<String, Any> ?: return default
        return deserialize(moduleMap)
    }

    private fun deserializeDocumentCaptureModuleSettings(map: Map<String, Any>): DocumentCaptureModuleSettings =
        DocumentCaptureModuleSettings(
            inputImageCropped = map["inputImageCropped"] as? Boolean ?: false,
            unsupportedDocumentsAllowed = map["unsupportedDocumentsAllowed"] as? Boolean ?: false,
            secondSideWithNoExtractableDataSkipped = map["secondSideWithNoExtractableDataSkipped"] as? Boolean ?: true,
            passportDataPageScanOnly = map["passportDataPageScanOnly"] as? Boolean ?: true,
            faceImageExtractionEnabled = map["faceImageExtractionEnabled"] as? Boolean ?: false,
            faceImagePresenceMandatory = map["faceImagePresenceMandatory"] as? Boolean ?: false,
            inputImageReturnEnabled = map["inputImageReturnEnabled"] as? Boolean ?: false,
            documentImageReturnEnabled = map["documentImageReturnEnabled"] as? Boolean ?: false,
            inputImageMargin = (map["inputImageMargin"] as? Number)?.toFloat(),
            dotsPerInch = map["dotsPerInch"] as? Int ?: 250,
            extensionFactor = (map["extensionFactor"] as? Number)?.toFloat() ?: 0.0f,
            blurSensitivityLevel = deserializeSensitivityLevel(map["blurSensitivityLevel"] as? String),
            imageWithBlurRejected = map["imageWithBlurRejected"] as? Boolean ?: true,
            glareSensitivityLevel = deserializeSensitivityLevel(map["glareSensitivityLevel"] as? String),
            imageWithGlareRejected = map["imageWithGlareRejected"] as? Boolean ?: true,
            tiltSensitivityLevel = deserializeSensitivityLevel(map["tiltSensitivityLevel"] as? String),
            imageWithPoorLightingRejected = map["imageWithPoorLightingRejected"] as? Boolean ?: true,
            imageWithHandOcclusionRejected = map["imageWithHandOcclusionRejected"] as? Boolean ?: true,
        )

    private fun deserializeSensitivityLevel(value: String?): SensitivityLevel =
        when (value?.lowercase()) {
            "off" -> SensitivityLevel.Off
            "low" -> SensitivityLevel.Low
            "mid" -> SensitivityLevel.Mid
            "high" -> SensitivityLevel.High
            else -> SensitivityLevel.Mid
        }

    private fun deserializeBarcodeModuleSettings(map: Map<String, Any>): BarcodeModuleSettings =
        BarcodeModuleSettings(
            presenceMandatory = map["presenceMandatory"] as? Boolean ?: false,
            barcodeImageReturnEnabled = map["barcodeImageReturnEnabled"] as? Boolean ?: false,
            pdf417ScanningEnabled = map["pdf417ScanningEnabled"] as? Boolean ?: true,
            qrScanningEnabled = map["qrScanningEnabled"] as? Boolean ?: true,
            upceScanningEnabled = map["upceScanningEnabled"] as? Boolean ?: false,
            upcaScanningEnabled = map["upcaScanningEnabled"] as? Boolean ?: false,
            code128ScanningEnabled = map["code128ScanningEnabled"] as? Boolean ?: false,
            code39ScanningEnabled = map["code39ScanningEnabled"] as? Boolean ?: false,
            ean8ScanningEnabled = map["ean8ScanningEnabled"] as? Boolean ?: false,
            ean13ScanningEnabled = map["ean13ScanningEnabled"] as? Boolean ?: false,
            itfScanningEnabled = map["itfScanningEnabled"] as? Boolean ?: false,
            dataMatrixScanningEnabled = map["dataMatrixScanningEnabled"] as? Boolean ?: false,
        )

    private fun deserializeMrzModuleSettings(map: Map<String, Any>): MrzModuleSettings =
        MrzModuleSettings(
            presenceMandatory = map["presenceMandatory"] as? Boolean ?: false,
        )

    private fun deserializeVizModuleSettings(map: Map<String, Any>): VizModuleSettings =
        VizModuleSettings(
            presenceMandatory = map["presenceMandatory"] as? Boolean ?: false,
            signatureImageExtractionEnabled = map["signatureImageExtractionEnabled"] as? Boolean ?: false,
            characterValidationEnabled = map["characterValidationEnabled"] as? Boolean ?: true,
            resultAggregationEnabled = map["resultAggregationEnabled"] as? Boolean ?: true,
        )

    private fun deserializeResourceRequestTimeout(resourceRequestTimeoutMap: Map<String, Any>?): RequestTimeout {
        if (resourceRequestTimeoutMap == null) return RequestTimeout.DEFAULT
        return RequestTimeout(
            connectionTimeout = (resourceRequestTimeoutMap["connectionTimeoutMilliseconds"] as? Int ?: 10000).milliseconds,
            writeTimeout = (resourceRequestTimeoutMap["writeTimeoutMilliseconds"] as? Int ?: 10000).milliseconds,
            readTimeout = (resourceRequestTimeoutMap["readTimeoutMilliseconds"] as? Int ?: 10000).milliseconds,
        )
    }

    private fun deserializeDocumentFilter(documentFilterMap: Map<String, Any>?): DocumentFilter =
        if (documentFilterMap != null) {
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

    private fun deserializeRedactionMode(value: String?): RedactionMode =
        when (value?.lowercase()) {
            "none" -> RedactionMode.None
            "imageonly" -> RedactionMode.ImageOnly
            "resultfieldsonly" -> RedactionMode.ResultFieldsOnly
            "fullresult" -> RedactionMode.FullResult
            else -> RedactionMode.FullResult
        }

    fun deserializeRedactionSettings(redactionSettingsMap: Map<String, Any>?): RedactionSettings? {
        if (redactionSettingsMap == null) return null
        val mode = deserializeRedactionMode(redactionSettingsMap["mode"] as? String)
        val fields =
            toStringList(redactionSettingsMap["fields"])?.map {
                enumValueOf<FieldType>(it.replaceFirstChar { char -> char.uppercase() })
            } ?: emptyList()
        if (fields.isEmpty()) {
            Log.w(
                TAG,
                "deserializeRedactionSettings: no fields deserialized from ${redactionSettingsMap["fields"]}",
            )
        }
        val docNumSettings =
            deserializeDocumentNumberRedactionSettings(
                toStringKeyedMap(redactionSettingsMap["documentNumberRedactionSettings"]),
            )
        val redactMrz = redactionSettingsMap["redactMrzResult"] as? Boolean ?: false
        val redactBarcode = redactionSettingsMap["redactBarcodeResult"] as? Boolean ?: false
        return RedactionSettings(
            mode,
            fields,
            docNumSettings ?: DocumentNumberRedactionSettings(),
            redactMrz,
            redactBarcode,
        )
    }

    private fun deserializeDocumentNumberRedactionSettings(
        documentNumberRedactionSettingsMap: Map<String, Any>?,
    ): DocumentNumberRedactionSettings? {
        if (documentNumberRedactionSettingsMap == null) return null
        return DocumentNumberRedactionSettings(
            prefixDigitsVisible = toInt(documentNumberRedactionSettingsMap["prefixDigitsVisible"])?.toUByte() ?: 0u,
            suffixDigitsVisible = toInt(documentNumberRedactionSettingsMap["suffixDigitsVisible"])?.toUByte() ?: 0u,
        )
    }

    fun deserializeRedactionSettingsResolver(redactionSettingsResolverMap: Map<String, Any>?): RedactionSettingsResolver? {
        if (redactionSettingsResolverMap == null) return null
        val documentRedactionList =
            toStringKeyedMapList(
                redactionSettingsResolverMap["documentRedactionList"],
            ) ?: return null
        if (documentRedactionList.isEmpty()) return null

        val entries =
            documentRedactionList.mapNotNull { redactionDict ->
                val settings = deserializeRedactionSettings(redactionDict) ?: return@mapNotNull null
                val documentFilters =
                    toStringKeyedMapList(redactionDict["documentFilter"])
                        .orEmpty()
                        .map(::deserializeSerializableDocumentFilter)
                ParsedRedactionEntry(settings, documentFilters)
            }
        if (entries.isEmpty()) return null

        if (Log.isLoggable(TAG, Log.DEBUG)) {
            Log.d(
                TAG,
                "deserializeRedactionSettingsResolver entries=${entries.size}, " +
                    "modes=${entries.map { it.settings.redactionMode }}, " +
                    "fieldCounts=${entries.map { it.settings.fields.size }}",
            )
        }
        return CustomRedactionSettingsResolver(entries)
    }

    private fun toStringKeyedMap(value: Any?): Map<String, Any>? {
        val map = value as? Map<*, *> ?: return null
        return map.entries
            .mapNotNull { (key, mapValue) ->
                (key as? String)?.let { stringKey ->
                    if (mapValue == null) return@mapNotNull null
                    stringKey to mapValue
                }
            }.toMap()
    }

    private fun toStringList(value: Any?): List<String>? {
        val rawList = value as? List<*> ?: return null
        return rawList.mapNotNull { it as? String }
    }

    private fun toInt(value: Any?): Int? =
        when (value) {
            is Int -> value
            is Long -> value.toInt()
            is Number -> value.toInt()
            else -> null
        }

    private fun toStringKeyedMapList(value: Any?): List<Map<String, Any>>? {
        val rawList = value as? List<*> ?: return null
        return rawList.mapNotNull { item -> toStringKeyedMap(item) }
    }

    internal fun matchesDocumentFilter(
        documentFilter: DocumentFilter,
        classInfo: DocumentClassInfo,
    ): Boolean =
        matchesFilterField(documentFilter.country, Country.None, classInfo.country) &&
            matchesFilterField(documentFilter.region, Region.None, classInfo.region) &&
            matchesFilterField(documentFilter.type, Type.None, classInfo.type)

    private fun <T> matchesFilterField(
        filterValue: T?,
        noneValue: T,
        classInfoValue: T,
    ): Boolean = filterValue == null || filterValue == noneValue || filterValue == classInfoValue

    fun deserializeBlinkIdUxSettings(
        blinkidUxSettingsMap: Map<String, Any>?,
        classFilterMap: Map<String, Any>?,
        redactionSettingsResolverMap: Map<String, Any>? = null,
        sessionSettingsMap: Map<String, Any>? = null,
    ): BlinkIdUxSettings {
        if (blinkidUxSettingsMap == null && sessionSettingsMap == null) return BlinkIdUxSettings()
        val uxMap = blinkidUxSettingsMap ?: emptyMap()

        // this handling is needed because on Android, timeouts are taken from UX settings, not session settings
        val stepTimeoutMs =
            (uxMap["stepTimeoutDuration"] as? Int)
                ?: (sessionSettingsMap?.get("stepTimeoutDuration") as? Int)
                ?: 60000
        val inactivityTimeoutMs =
            (uxMap["inactivityTimeoutDuration"] as? Int)
                ?: (sessionSettingsMap?.get("inactivityTimeoutDuration") as? Int)
                ?: 10000
        return BlinkIdUxSettings(
            stepTimeoutDuration = stepTimeoutMs.milliseconds,
            inactivityTimeoutDuration = inactivityTimeoutMs.milliseconds,
            allowHapticFeedback = (uxMap["allowHapticFeedback"] as? Boolean) ?: true,
            classFilter = CustomClassFilter(classFilterMap),
            redactionSettingsResolver = deserializeRedactionSettingsResolver(redactionSettingsResolverMap),
        )
    }

    fun deserializeCameraSettings(blinkIdScanningUxSettingsMap: Map<String, Any>?): CameraSettings {
        if (blinkIdScanningUxSettingsMap == null) return CameraSettings()
        return CameraSettings(
            lensFacing = deserializeCameraLens(blinkIdScanningUxSettingsMap["preferredCamera"] as? String),
        )
    }

    fun deserializeCameraLens(value: String?): CameraLensFacing =
        when (value?.lowercase()) {
            "front" -> CameraLensFacing.LensFacingFront
            "back" -> CameraLensFacing.LensFacingBack
            else -> CameraLensFacing.LensFacingBack
        }

    fun deserializeClassFilter(
        classFilterMap: Map<String, Any>?,
        classInfo: DocumentClassInfo,
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

    private fun deserializeSerializableDocumentFilter(documentFilterMap: Map<String, Any>): SerializableDocumentFilter =
        SerializableDocumentFilter(
            country = documentFilterMap["country"] as? String,
            region = documentFilterMap["region"] as? String,
            documentType = documentFilterMap["documentType"] as? String,
        )

    internal fun matchClassFilter(
        filteredClass: Map<String, Any>,
        classInfo: DocumentClassInfo,
    ): Boolean {
        val country = filteredClass["country"] as? String
        val region = filteredClass["region"] as? String
        val documentType = filteredClass["documentType"] as? String

        return (country == null || enumValueOf<Country>(country.replaceFirstChar { char -> char.uppercase() }) == classInfo.country) &&
            (region == null || enumValueOf<Region>(region.replaceFirstChar { char -> char.uppercase() }) == classInfo.region) &&
            (documentType == null || enumValueOf<Type>(documentType.replaceFirstChar { char -> char.uppercase() }) == classInfo.type)
    }

    fun base64ToBitmap(base64Str: String?): Bitmap? =
        try {
            val decodedBytes = Base64.decode(base64Str, Base64.DEFAULT)
            BitmapFactory.decodeByteArray(decodedBytes, 0, decodedBytes.size)
        } catch (e: IllegalArgumentException) {
            null
        }

    private fun logSessionSettings(
        source: String,
        sessionMap: Map<String, Any>,
        scanningSettingsMap: Map<String, Any>?,
        scanningSettings: ScanningSettings,
    ) {
        if (!Log.isLoggable(TAG, Log.DEBUG)) return
        Log.d(TAG, "[$source] scanningMode=${sessionMap["scanningMode"]}")
        Log.d(
            TAG,
            "[$source] raw modules: documentCapture=${scanningSettingsMap?.get("documentCaptureModule")}, " +
                "barcode=${scanningSettingsMap?.get("barcodeModule")}, " +
                "mrz=${scanningSettingsMap?.get("mrzModule")}, " +
                "viz=${scanningSettingsMap?.get("vizModule")}",
        )
        Log.d(
            TAG,
            "[$source] deserialized modules: documentCapture=${scanningSettings.documentCaptureModule}, " +
                "barcode=${scanningSettings.barcodeModule}, " +
                "mrz=${scanningSettings.mrzModule}, " +
                "viz=${scanningSettings.vizModule}",
        )
        scanningSettings.barcodeModule?.let {
            Log.d(TAG, "[$source] barcode.presenceMandatory=${it.presenceMandatory}")
        }
        scanningSettings.mrzModule?.let {
            Log.d(TAG, "[$source] mrz.presenceMandatory=${it.presenceMandatory}")
        }
        scanningSettings.vizModule?.let {
            Log.d(TAG, "[$source] viz.presenceMandatory=${it.presenceMandatory}")
        }
    }
}

@Parcelize
private class CustomClassFilter(
    private val classFilterMap: @RawValue Map<String, Any>?,
) : ClassFilter,
    Parcelable {
    override fun classAllowed(documentClass: DocumentClassInfo): Boolean =
        BlinkIdDeserializationUtils.deserializeClassFilter(classFilterMap, documentClass)
}

@Parcelize
private data class SerializableDocumentFilter(
    val country: String? = null,
    val region: String? = null,
    val documentType: String? = null,
) : Parcelable {
    fun toMatchMap(): Map<String, Any> =
        buildMap {
            country?.let { put("country", it) }
            region?.let { put("region", it) }
            documentType?.let { put("documentType", it) }
        }
}

@Parcelize
private data class ParsedRedactionEntry(
    val settings: RedactionSettings,
    val documentFilters: List<SerializableDocumentFilter>,
) : Parcelable

@Parcelize
private class CustomRedactionSettingsResolver(
    private val entries: List<ParsedRedactionEntry>,
) : RedactionSettingsResolver,
    Parcelable {
    override fun resolveRedactionSettings(classInfo: DocumentClassInfo): RedactionSettings? {
        val debugLoggable = Log.isLoggable(BlinkIdDeserializationUtils.TAG, Log.DEBUG)
        for (entry in entries) {
            if (shouldUseRedactionSettings(entry.documentFilters, classInfo)) {
                if (debugLoggable) {
                    Log.d(
                        BlinkIdDeserializationUtils.TAG,
                        "resolveRedactionSettings matched class=${classInfo.country}/" +
                            "${classInfo.region}/${classInfo.type}, mode=${entry.settings.redactionMode}, " +
                            "fields=${entry.settings.fields.size}",
                    )
                }
                return entry.settings
            }
        }
        if (debugLoggable) {
            Log.d(
                BlinkIdDeserializationUtils.TAG,
                "resolveRedactionSettings no matching entry for class=${classInfo.country}/" +
                    "${classInfo.region}/${classInfo.type}, " +
                    "filters=${entries.map { entry ->
                        entry.documentFilters.map { filter ->
                            "${filter.country}/${filter.region}/${filter.documentType}"
                        }
                    }}",
            )
        }
        return null
    }

    private fun shouldUseRedactionSettings(
        documentFilters: List<SerializableDocumentFilter>,
        classInfo: DocumentClassInfo,
    ): Boolean {
        if (documentFilters.isEmpty()) return true
        return documentFilters.any { filter ->
            BlinkIdDeserializationUtils.matchClassFilter(filter.toMatchMap(), classInfo)
        }
    }
}
