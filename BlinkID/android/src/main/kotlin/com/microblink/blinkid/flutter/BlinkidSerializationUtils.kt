package com.microblink.blinkid.flutter

import android.graphics.Bitmap
import android.util.Base64
import com.microblink.blinkid.core.result.AddressDetailedInfo
import com.microblink.blinkid.core.result.AlphabetType
import com.microblink.blinkid.core.result.DataMatchFieldState
import com.microblink.blinkid.core.result.DataMatchFieldType
import com.microblink.blinkid.core.result.DataMatchResult
import com.microblink.blinkid.core.result.DataMatchState
import com.microblink.blinkid.core.result.DateResult
import com.microblink.blinkid.core.result.DependentInfo
import com.microblink.blinkid.core.result.DetailedCroppedImageResult
import com.microblink.blinkid.core.result.DriverLicenseDetailedInfo
import com.microblink.blinkid.core.result.ParentInfo
import com.microblink.blinkid.core.result.Rectangle
import com.microblink.blinkid.core.result.ScanningSide
import com.microblink.blinkid.core.result.SingleSideScanningResult
import com.microblink.blinkid.core.result.StringResult
import com.microblink.blinkid.core.result.VehicleClassInfo
import com.microblink.blinkid.core.result.barcode.BarcodeData
import com.microblink.blinkid.core.result.barcode.BarcodeElement
import com.microblink.blinkid.core.result.barcode.BarcodeResult
import com.microblink.blinkid.core.result.barcode.BarcodeType
import com.microblink.blinkid.core.result.classinfo.DocumentClassInfo
import com.microblink.blinkid.core.result.mrz.MrzResult
import com.microblink.blinkid.core.result.viz.VizResult
import com.microblink.blinkid.core.session.BlinkIdScanningResult
import org.json.JSONObject
import java.io.ByteArrayOutputStream
import kotlin.collections.set

object BlinkIdSerializationUtils {
    fun serializeBlinkIdScanningResult(scanningResult: BlinkIdScanningResult?): String? {
        val scanningResultDict: MutableMap<String, Any?> = mutableMapOf()

        scanningResult?.documentClassInfo?.let {
            scanningResultDict["documentClassInfo"] = serializeDocumentClassInfo(it)
        }
        scanningResult?.dataMatchResult?.let {
            scanningResultDict["dataMatchResult"] = serializeDataMatchResult(it)
        }
        scanningResult?.firstName?.let {
            scanningResultDict["firstName"] = serializeStringResult(it)
        }
        scanningResult?.lastName?.let {
            scanningResultDict["lastName"] = serializeStringResult(it)
        }
        scanningResult?.fullName?.let {
            scanningResultDict["fullName"] = serializeStringResult(it)
        }
        scanningResult?.additionalNameInformation?.let {
            scanningResultDict["additionalNameInformation"] = serializeStringResult(it)
        }
        scanningResult?.localizedName?.let {
            scanningResultDict["localizedName"] = serializeStringResult(it)
        }
        scanningResult?.fathersName?.let {
            scanningResultDict["fathersName"] = serializeStringResult(it)
        }
        scanningResult?.mothersName?.let {
            scanningResultDict["mothersName"] = serializeStringResult(it)
        }
        scanningResult?.address?.let {
            scanningResultDict["address"] = serializeStringResult(it)
        }
        scanningResult?.additionalAddressInformation?.let {
            scanningResultDict["additionalAddressInformation"] = serializeStringResult(it)
        }
        scanningResult?.additionalOptionalAddressInformation?.let {
            scanningResultDict["additionalOptionalAddressInformation"] = serializeStringResult(it)
        }
        scanningResult?.placeOfBirth?.let {
            scanningResultDict["placeOfBirth"] = serializeStringResult(it)
        }
        scanningResult?.nationality?.let {
            scanningResultDict["nationality"] = serializeStringResult(it)
        }
        scanningResult?.race?.let {
            scanningResultDict["race"] = serializeStringResult(it)
        }
        scanningResult?.religion?.let {
            scanningResultDict["religion"] = serializeStringResult(it)
        }
        scanningResult?.profession?.let {
            scanningResultDict["profession"] = serializeStringResult(it)
        }
        scanningResult?.maritalStatus?.let {
            scanningResultDict["maritalStatus"] = serializeStringResult(it)
        }
        scanningResult?.residentialStatus?.let {
            scanningResultDict["residentialStatus"] = serializeStringResult(it)
        }
        scanningResult?.employer?.let {
            scanningResultDict["employer"] = serializeStringResult(it)
        }
        scanningResult?.sex?.let {
            scanningResultDict["sex"] = serializeStringResult(it)
        }
        scanningResult?.sponsor?.let {
            scanningResultDict["sponsor"] = serializeStringResult(it)
        }
        scanningResult?.bloodType?.let {
            scanningResultDict["bloodType"] = serializeStringResult(it)
        }
        scanningResult?.documentNumber?.let {
            scanningResultDict["documentNumber"] = serializeStringResult(it)
        }
        scanningResult?.cardAccessNumber?.let {
            scanningResultDict["cardAccessNumber"] = serializeStringResult(it)
        }
        scanningResult?.personalIdNumber?.let {
            scanningResultDict["personalIdNumber"] = serializeStringResult(it)
        }
        scanningResult?.documentAdditionalNumber?.let {
            scanningResultDict["documentAdditionalNumber"] = serializeStringResult(it)
        }
        scanningResult?.documentOptionalAdditionalNumber?.let {
            scanningResultDict["documentOptionalAdditionalNumber"] = serializeStringResult(it)
        }
        scanningResult?.additionalPersonalIdNumber?.let {
            scanningResultDict["additionalPersonalIdNumber"] = serializeStringResult(it)
        }
        scanningResult?.issuingAuthority?.let {
            scanningResultDict["issuingAuthority"] = serializeStringResult(it)
        }
        scanningResult?.documentSubtype?.let {
            scanningResultDict["documentSubtype"] = serializeStringResult(it)
        }
        scanningResult?.remarks?.let {
            scanningResultDict["remarks"] = serializeStringResult(it)
        }
        scanningResult?.residencePermitType?.let {
            scanningResultDict["residencePermitType"] = serializeStringResult(it)
        }
        scanningResult?.manufacturingYear?.let {
            scanningResultDict["manufacturingYear"] = serializeStringResult(it)
        }
        scanningResult?.vehicleType?.let {
            scanningResultDict["vehicleType"] = serializeStringResult(it)
        }
        scanningResult?.eligibilityCategory?.let {
            scanningResultDict["eligibilityCategory"] = serializeStringResult(it)
        }
        scanningResult?.specificDocumentValidity?.let {
            scanningResultDict["specificDocumentValidity"] = serializeStringResult(it)
        }
        scanningResult?.visaType?.let {
            scanningResultDict["visaType"] = serializeStringResult(it)
        }
        scanningResult?.vehicleOwner?.let {
            scanningResultDict["vehicleOwner"] = serializeStringResult(it)
        }
        scanningResult?.certificateNumber?.let {
            scanningResultDict["certificateNumber"] = serializeStringResult(it)
        }
        scanningResult?.countryCode?.let {
            scanningResultDict["countryCode"] = serializeStringResult(it)
        }
        scanningResult?.nationalInsuranceNumber?.let {
            scanningResultDict["nationalInsuranceNumber"] = serializeStringResult(it)
        }
        scanningResult?.localityCode?.let {
            scanningResultDict["localityCode"] = serializeStringResult(it)
        }
        scanningResult?.maidenName?.let {
            scanningResultDict["maidenName"] = serializeStringResult(it)
        }
        scanningResult?.municipalityCode?.let {
            scanningResultDict["municipalityCode"] = serializeStringResult(it)
        }
        scanningResult?.municipalityOfRegistration?.let {
            scanningResultDict["municipalityOfRegistration"] = serializeStringResult(it)
        }
        scanningResult?.pollingStationCode?.let {
            scanningResultDict["pollingStationCode"] = serializeStringResult(it)
        }
        scanningResult?.registrationCenterCode?.let {
            scanningResultDict["registrationCenterCode"] = serializeStringResult(it)
        }
        scanningResult?.sectionCode?.let {
            scanningResultDict["sectionCode"] = serializeStringResult(it)
        }
        scanningResult?.stateCode?.let {
            scanningResultDict["stateCode"] = serializeStringResult(it)
        }
        scanningResult?.stateName?.let {
            scanningResultDict["stateName"] = serializeStringResult(it)
        }
        scanningResult?.dateOfBirth?.let {
            scanningResultDict["dateOfBirth"] = serializeDateResult(it)
        }
        scanningResult?.dateOfIssue?.let {
            scanningResultDict["dateOfIssue"] = serializeDateResult(it)
        }
        scanningResult?.dateOfExpiry?.let {
            scanningResultDict["dateOfExpiry"] = serializeDateResult(it)
        }
        scanningResult?.dateOfEntry?.let {
            scanningResultDict["dateOfEntry"] = serializeDateResult(it)
        }
        scanningResult?.effectiveDate?.let {
            scanningResultDict["effectiveDate"] = serializeDateResult(it)
        }
        scanningResult?.dateOfExpiryPermanent?.let {
            scanningResultDict["dateOfExpiryPermanent"] = it
        }
        scanningResult?.driverLicenseDetailedInfo?.let {
            scanningResultDict["driverLicenseDetailedInfo"] = serializeDriverLicenseDetailedInfo(it)
        }
        scanningResult?.dependentsInfo?.let {
            scanningResultDict["dependentsInfo"] =
                it.map { dependentInfo -> serializeDependentInfo(dependentInfo) }
        }
        scanningResult?.subResults?.let {
            scanningResultDict["subResults"] = it.map { subResult -> serializeSubResult(subResult) }
        }
        scanningResult?.parentsInfo?.let {
            scanningResultDict["parentsInfo"] = it.map { parentInfo -> serializeParentInfo(parentInfo) }
        }
        scanningResult?.husbandName?.let {
            scanningResultDict["husbandName"] = serializeStringResult(it)
        }
        scanningResult?.legalStatus?.let {
            scanningResultDict["legalStatus"] = serializeStringResult(it)
        }
        scanningResult?.socialSecurityStatus?.let {
            scanningResultDict["socialSecurityStatus"] = serializeStringResult(it)
        }
        scanningResult?.workRestriction?.let {
            scanningResultDict["workRestriction"] = serializeStringResult(it)
        }
        scanningResult?.inputImage(ScanningSide.First)?.let {
            scanningResultDict["firstInputImage"] = encodeBase64Image(it.bitmap)
        }
        scanningResult?.inputImage(ScanningSide.Second)?.let {
            scanningResultDict["secondInputImage"] = encodeBase64Image(it.bitmap)
        }
        scanningResult?.barcodeImage()?.let {
            scanningResultDict["barcodeImage"] = encodeBase64Image(it.bitmap)
        }
        scanningResult?.documentImage(ScanningSide.First)?.let {
            scanningResultDict["firstDocumentImage"] = encodeBase64Image(it.bitmap)
        }
        scanningResult?.documentImage(ScanningSide.Second)?.let {
            scanningResultDict["secondDocumentImage"] = encodeBase64Image(it.bitmap)
        }
        scanningResult?.faceImage()?.let {
            scanningResultDict["faceImage"] = serializeDetailedCroppedImageResult(it)
        }
        scanningResult?.signatureImage()?.let {
            scanningResultDict["signatureImage"] = serializeDetailedCroppedImageResult(it)
        }

        return JSONObject(scanningResultDict).toString()
    }

    private fun <T> serializeDateResult(dateResult: DateResult<T>?): Map<String, Any?> {
        val dateResultDict: MutableMap<String, Any?> = mutableMapOf()
        dateResultDict["date"] = serializeSimpleDateResult(dateResult)
        dateResultDict["filledByDomainKnowledge"] = dateResult?.filledByDomainKnowledge
        dateResultDict["successfullyParsed"] = dateResult?.successfullyParsed
        dateResultDict["originalString"] = serializeStringType(dateResult?.originalString)
        return dateResultDict
    }

    private fun <T> serializeSimpleDateResult(dateResult: DateResult<T>?): Map<String, Any?> {
        val simpleDateResultDict: MutableMap<String, Any?> = mutableMapOf()
        dateResult?.day?.let {
            simpleDateResultDict["day"] = it
        }
        dateResult?.month?.let {
            simpleDateResultDict["month"] = it
        }
        dateResult?.year?.let {
            simpleDateResultDict["year"] = it
        }
        return simpleDateResultDict
    }

    private fun serializeDocumentClassInfo(documentClassInfo: DocumentClassInfo): Map<String, Any?> {
        val documentClassInfoDict: MutableMap<String, Any?> = mutableMapOf()
        documentClassInfo.country?.name?.let {
            documentClassInfoDict["country"] = it.replaceFirstChar { char -> char.lowercase() }
        }
        documentClassInfo.region?.name?.let {
            documentClassInfoDict["region"] = it.replaceFirstChar { char -> char.lowercase() }
        }
        documentClassInfo.type?.name?.let {
            documentClassInfoDict["documentType"] = it.replaceFirstChar { char -> char.lowercase() }
        }
        documentClassInfo.countryName?.let {
            documentClassInfoDict["countryName"] = it
        }
        documentClassInfo.isoAlpha2CountryCode?.let {
            documentClassInfoDict["isoAlpha2CountryCode"] = it
        }
        documentClassInfo.isoAlpha3CountryCode?.let {
            documentClassInfoDict["isoAlpha3CountryCode"] = it
        }
        return documentClassInfoDict
    }

    private fun serializeDataMatchResult(dataMatchResult: DataMatchResult): Map<String, Any?> =
        mapOf(
            "states" to dataMatchResult.statePerField.map { serializeDataMatchField(it) },
            "overallState" to serializeDataMatchState(dataMatchResult.overallState),
        )

    private fun serializeDataMatchField(dataMatchField: DataMatchFieldState): Map<String, Any> =
        mapOf(
            "field" to serializeDataMatchFieldType(dataMatchField.fieldType),
            "state" to serializeDataMatchState(dataMatchField.state),
        )

    private fun serializeDataMatchFieldType(fieldType: DataMatchFieldType): String =
        when (fieldType) {
            DataMatchFieldType.DateOfBirth -> "dateOfBirth"
            DataMatchFieldType.DateOfExpiry -> "dateOfExpiry"
            DataMatchFieldType.DocumentNumber -> "documentNumber"
            DataMatchFieldType.DocumentAdditionalNumber -> "documentAdditionalNumber"
            DataMatchFieldType.DocumentOptionalAdditionalNumber -> "documentOptionalAdditionalNumber"
            DataMatchFieldType.PersonalIdNumber -> "personalIdNumber"
        }

    private fun serializeDataMatchState(state: DataMatchState): String =
        when (state) {
            DataMatchState.NotPerformed -> "notPerformed"
            DataMatchState.Failed -> "failed"
            DataMatchState.Success -> "success"
        }

    private fun serializeStringResult(stringResult: StringResult): Map<String, Any?> {
        val stringResultDict: MutableMap<String, Any?> = mutableMapOf()

        stringResultDict["value"] = stringResult.value(AlphabetType.Latin)
        stringResultDict["latin"] = stringResult.value(AlphabetType.Latin)
        stringResultDict["arabic"] = stringResult.value(AlphabetType.Arabic)
        stringResultDict["cyrillic"] = stringResult.value(AlphabetType.Cyrillic)
        stringResultDict["greek"] = stringResult.value(AlphabetType.Greek)

        val locationDict: MutableMap<String, Any?> = mutableMapOf()
        stringResult.location(AlphabetType.Latin)?.let {
            locationDict["latin"] = serializeLocation(it)
        }
        stringResult.location(AlphabetType.Arabic)?.let {
            locationDict["arabic"] = serializeLocation(it)
        }
        stringResult.location(AlphabetType.Cyrillic)?.let {
            locationDict["cyrillic"] = serializeLocation(it)
        }
        stringResult.location(AlphabetType.Greek)?.let {
            locationDict["greek"] = serializeLocation(it)
        }

        val sideDict: MutableMap<String, Any?> = mutableMapOf()
        stringResult.side(AlphabetType.Latin)?.let {
            sideDict["latin"] = it.ordinal
        }
        stringResult.side(AlphabetType.Arabic)?.let {
            sideDict["arabic"] = it.ordinal
        }
        stringResult.side(AlphabetType.Cyrillic)?.let {
            sideDict["cyrillic"] = it.ordinal
        }
        stringResult.side(AlphabetType.Greek)?.let {
            sideDict["greek"] = it.ordinal
        }
        stringResultDict["side"] = sideDict

        return stringResultDict
    }

    private fun serializeLocation(rectangle: Rectangle): Map<String, Any?> =
        mapOf(
            "x" to rectangle.x.toDouble(),
            "y" to rectangle.y.toDouble(),
            "width" to rectangle.width.toDouble(),
            "height" to rectangle.height.toDouble(),
        )

    private fun <T> serializeDriverLicenseDetailedInfo(driverLicenseDetailedInfo: DriverLicenseDetailedInfo<T>?): Map<String, Any?> =
        mapOf(
            "conditions" to serializeStringType(driverLicenseDetailedInfo?.conditions),
            "endorsements" to serializeStringType(driverLicenseDetailedInfo?.endorsements),
            "restrictions" to serializeStringType(driverLicenseDetailedInfo?.restrictions),
            "vehicleClass" to serializeStringType(driverLicenseDetailedInfo?.vehicleClass),
            "vehicleClassesInfo" to
                driverLicenseDetailedInfo?.vehicleClassesInfo?.map {
                    serializeVehicleClassInfo(
                        it,
                    )
                },
        )

    private fun <T> serializeVehicleClassInfo(vehicleClassInfo: VehicleClassInfo<T>): Map<String, Any?> =
        mapOf(
            "effectiveDate" to serializeDateResult(vehicleClassInfo.effectiveDate),
            "expiryDate" to serializeDateResult(vehicleClassInfo.expiryDate),
            "licenceType" to serializeStringType(vehicleClassInfo.licenceType),
            "vehicleClass" to serializeStringType(vehicleClassInfo.vehicleClass),
        )

    private fun serializeDependentInfo(dependentInfo: DependentInfo): Map<String, Any?> {
        val dependentInfoDict: MutableMap<String, Any?> = mutableMapOf()

        dependentInfo.fullName?.let {
            dependentInfoDict["fullName"] = serializeStringResult(it)
        }
        dependentInfo.sex?.let {
            dependentInfoDict["sex"] = serializeStringResult(it)
        }
        dependentInfo.dateOfBirth?.let {
            dependentInfoDict["dateOfBirth"] = serializeDateResult(it)
        }
        dependentInfo.documentNumber?.let {
            dependentInfoDict["documentNumber"] = serializeStringResult(it)
        }
        return dependentInfoDict
    }

    private fun serializeSubResult(subResult: SingleSideScanningResult): Map<String, Any?> =
        mapOf(
            "viz" to serializeVizResult(subResult.viz),
            "mrz" to serializeMrzResult(subResult.mrz),
            "barcode" to serializeBarcodeResult(subResult.barcode),
            "inputImage" to encodeBase64Image(subResult.inputImage?.bitmap),
            "barcodeImage" to encodeBase64Image(subResult.barcodeImage?.bitmap),
            "documentImage" to encodeBase64Image(subResult.documentImage?.bitmap),
            "faceImage" to serializeDetailedCroppedImageResult(subResult.faceImage),
            "signatureImage" to serializeDetailedCroppedImageResult(subResult.signatureImage),
        )

    private fun serializeBarcodeResult(barcodeResult: BarcodeResult?): Map<String, Any?> =
        mapOf(
            "barcodeData" to serializeBarcodeData(barcodeResult?.barcodeData),
            "parsed" to barcodeResult?.parsed,
            "firstName" to barcodeResult?.firstName,
            "middleName" to barcodeResult?.middleName,
            "lastName" to barcodeResult?.lastName,
            "fullName" to barcodeResult?.fullName,
            "additionalNameInformation" to barcodeResult?.additionalNameInformation,
            "address" to barcodeResult?.address,
            "nationality" to barcodeResult?.nationality,
            "placeOfBirth" to barcodeResult?.placeOfBirth,
            "race" to barcodeResult?.race,
            "religion" to barcodeResult?.religion,
            "profession" to barcodeResult?.profession,
            "maritalStatus" to barcodeResult?.maritalStatus,
            "residentialStatus" to barcodeResult?.residentialStatus,
            "employer" to barcodeResult?.employer,
            "sex" to barcodeResult?.sex,
            "dateOfBirth" to serializeDateResult(barcodeResult?.dateOfBirth),
            "dateOfIssue" to serializeDateResult(barcodeResult?.dateOfIssue),
            "dateOfExpiry" to serializeDateResult(barcodeResult?.dateOfExpiry),
            "documentNumber" to barcodeResult?.documentNumber,
            "personalIdNumber" to barcodeResult?.personalIdNumber,
            "documentAdditionalNumber" to barcodeResult?.documentAdditionalNumber,
            "issuingAuthority" to barcodeResult?.issuingAuthority,
            "addressDetailedInfo" to serializeAddressDetailedInfo(barcodeResult?.addressDetailedInfo),
            "driverLicenseDetailedInfo" to serializeDriverLicenseDetailedInfo(barcodeResult?.driverLicenseDetailedInfo),
            "extendedElements" to serializeBarcodeExtendedElements(barcodeResult?.extendedElements?.barcodeElements),
        )

    private fun serializeAddressDetailedInfo(addressDetailedInfo: AddressDetailedInfo?): Map<String, Any?> =
        mapOf(
            "city" to addressDetailedInfo?.city,
            "postalCode" to addressDetailedInfo?.postalCode,
            "jurisdiction" to addressDetailedInfo?.jurisdiction,
            "street" to addressDetailedInfo?.street,
        )

    private fun serializeBarcodeData(barcodeData: BarcodeData?): Map<String, Any?> =
        mapOf(
            "barcodeType" to serializeBarcodeType(barcodeData?.barcodeType),
            "rawData" to barcodeData?.rawData.toString(),
            "stringData" to barcodeData?.stringData,
            "uncertain" to barcodeData?.uncertain,
        )

    private fun serializeBarcodeType(barcodeType: BarcodeType?): String =
        when (barcodeType) {
            BarcodeType.None -> "none"
            BarcodeType.QRCode -> "qrCode"
            BarcodeType.DataMatrix -> "dataMatrix"
            BarcodeType.UPCE -> "upce"
            BarcodeType.UPCA -> "upca"
            BarcodeType.EAN8 -> "ean8"
            BarcodeType.EAN13 -> "ean13"
            BarcodeType.Code128 -> "code128"
            BarcodeType.Code39 -> "code39"
            BarcodeType.ITF -> "itf"
            BarcodeType.Aztec -> "aztec"
            BarcodeType.PDF417 -> "pdf417"
            null -> "none"
        }

    private fun serializeMrzResult(mrzResult: MrzResult?): Map<String, Any?> =
        mapOf(
            "rawMRZString" to mrzResult?.rawMRZString,
            "documentCode" to mrzResult?.documentCode,
            "issuer" to mrzResult?.issuer,
            "documentNumber" to mrzResult?.documentNumber,
            "opt1" to mrzResult?.opt1,
            "opt2" to mrzResult?.opt2,
            "gender" to mrzResult?.gender,
            "nationality" to mrzResult?.nationality,
            "primaryID" to mrzResult?.primaryID,
            "secondaryID" to mrzResult?.secondaryID,
            "issuerName" to mrzResult?.issuerName,
            "nationalityName" to mrzResult?.nationalityName,
            "verified" to mrzResult?.verified,
            "dateOfBirth" to serializeDateResult(mrzResult?.dateOfBirth),
            "dateOfExpiry" to serializeDateResult(mrzResult?.dateOfExpiry),
            "documentType" to mrzResult?.documentType?.ordinal,
            "sanitizedOpt1" to mrzResult?.sanitizedOpt1,
            "sanitizedOpt2" to mrzResult?.sanitizedOpt2,
            "sanitizedNationality" to mrzResult?.sanitizedNationality,
            "sanitizedIssuer" to mrzResult?.sanitizedIssuer,
            "sanitizedDocumentCode" to mrzResult?.sanitizedDocumentCode,
            "sanitizedDocumentNumber" to mrzResult?.sanitizedDocumentNumber,
        )

    private fun serializeVizResult(vizResult: VizResult?): Map<String, Any?> {
        val vizResultDict: MutableMap<String, Any> = mutableMapOf()

        vizResult?.firstName?.let {
            vizResultDict["firstName"] = serializeStringResult(it)
        }
        vizResult?.lastName?.let {
            vizResultDict["lastName"] = serializeStringResult(it)
        }
        vizResult?.fullName?.let {
            vizResultDict["fullName"] = serializeStringResult(it)
        }
        vizResult?.additionalNameInformation?.let {
            vizResultDict["additionalNameInformation"] = serializeStringResult(it)
        }
        vizResult?.localizedName?.let {
            vizResultDict["localizedName"] = serializeStringResult(it)
        }
        vizResult?.fathersName?.let {
            vizResultDict["fathersName"] = serializeStringResult(it)
        }
        vizResult?.mothersName?.let {
            vizResultDict["mothersName"] = serializeStringResult(it)
        }
        vizResult?.address?.let {
            vizResultDict["address"] = serializeStringResult(it)
        }
        vizResult?.additionalAddressInformation?.let {
            vizResultDict["additionalAddressInformation"] = serializeStringResult(it)
        }
        vizResult?.additionalOptionalAddressInformation?.let {
            vizResultDict["additionalOptionalAddressInformation"] = serializeStringResult(it)
        }
        vizResult?.placeOfBirth?.let {
            vizResultDict["placeOfBirth"] = serializeStringResult(it)
        }
        vizResult?.nationality?.let {
            vizResultDict["nationality"] = serializeStringResult(it)
        }
        vizResult?.race?.let {
            vizResultDict["race"] = serializeStringResult(it)
        }
        vizResult?.religion?.let {
            vizResultDict["religion"] = serializeStringResult(it)
        }
        vizResult?.profession?.let {
            vizResultDict["profession"] = serializeStringResult(it)
        }
        vizResult?.maritalStatus?.let {
            vizResultDict["maritalStatus"] = serializeStringResult(it)
        }
        vizResult?.residentialStatus?.let {
            vizResultDict["residentialStatus"] = serializeStringResult(it)
        }
        vizResult?.sex?.let {
            vizResultDict["sex"] = serializeStringResult(it)
        }
        vizResult?.employer?.let {
            vizResultDict["employer"] = serializeStringResult(it)
        }
        vizResult?.sponsor?.let {
            vizResultDict["sponsor"] = serializeStringResult(it)
        }
        vizResult?.bloodType?.let {
            vizResultDict["bloodType"] = serializeStringResult(it)
        }
        vizResult?.dateOfBirth?.let {
            vizResultDict["dateOfBirth"] = serializeDateResult(it)
        }
        vizResult?.dateOfIssue?.let {
            vizResultDict["dateOfIssue"] = serializeDateResult(it)
        }
        vizResult?.dateOfExpiry?.let {
            vizResultDict["dateOfExpiry"] = serializeDateResult(it)
        }
        vizResult?.dateOfEntry?.let {
            vizResultDict["dateOfEntry"] = serializeDateResult(it)
        }
        vizResult?.dateOfExpiryPermanent?.let {
            vizResultDict["dateOfExpiryPermanent"] = it
        }
        vizResult?.effectiveDate?.let {
            vizResultDict["effectiveDate"] = serializeDateResult(it)
        }
        vizResult?.documentNumber?.let {
            vizResultDict["documentNumber"] = serializeStringResult(it)
        }
        vizResult?.cardAccessNumber?.let {
            vizResultDict["cardAccessNumber"] = serializeStringResult(it)
        }
        vizResult?.personalIdNumber?.let {
            vizResultDict["personalIdNumber"] = serializeStringResult(it)
        }
        vizResult?.documentAdditionalNumber?.let {
            vizResultDict["documentAdditionalNumber"] = serializeStringResult(it)
        }
        vizResult?.documentOptionalAdditionalNumber?.let {
            vizResultDict["documentOptionalAdditionalNumber"] = serializeStringResult(it)
        }
        vizResult?.additionalPersonalIdNumber?.let {
            vizResultDict["additionalPersonalIdNumber"] = serializeStringResult(it)
        }
        vizResult?.issuingAuthority?.let {
            vizResultDict["issuingAuthority"] = serializeStringResult(it)
        }
        vizResult?.visaType?.let {
            vizResultDict["visaType"] = serializeStringResult(it)
        }
        vizResult?.certificateNumber?.let {
            vizResultDict["certificateNumber"] = serializeStringResult(it)
        }
        vizResult?.countryCode?.let {
            vizResultDict["countryCode"] = serializeStringResult(it)
        }
        vizResult?.driverLicenseDetailedInfo?.let {
            vizResultDict["driverLicenseDetailedInfo"] = serializeDriverLicenseDetailedInfo(it)
        }
        vizResult?.documentSubtype?.let {
            vizResultDict["documentSubtype"] = serializeStringResult(it)
        }
        vizResult?.remarks?.let {
            vizResultDict["remarks"] = serializeStringResult(it)
        }
        vizResult?.residencePermitType?.let {
            vizResultDict["residencePermitType"] = serializeStringResult(it)
        }
        vizResult?.manufacturingYear?.let {
            vizResultDict["manufacturingYear"] = serializeStringResult(it)
        }
        vizResult?.nationalInsuranceNumber?.let {
            vizResultDict["nationalInsuranceNumber"] = serializeStringResult(it)
        }
        vizResult?.vehicleType?.let {
            vizResultDict["vehicleType"] = serializeStringResult(it)
        }
        vizResult?.eligibilityCategory?.let {
            vizResultDict["eligibilityCategory"] = serializeStringResult(it)
        }
        vizResult?.specificDocumentValidity?.let {
            vizResultDict["specificDocumentValidity"] = serializeStringResult(it)
        }
        vizResult?.dependentsInfo?.let {
            vizResultDict["dependentsInfo"] =
                it.map { dependentInfo -> serializeDependentInfo(dependentInfo) }
        }
        vizResult?.vehicleOwner?.let {
            vizResultDict["vehicleOwner"] = serializeStringResult(it)
        }
        vizResult?.parentsInfo?.let {
            vizResultDict["parentsInfo"] = it.map { parentInfo -> serializeParentInfo(parentInfo) }
        }
        vizResult?.localityCode?.let {
            vizResultDict["localityCode"] = serializeStringResult(it)
        }
        vizResult?.maidenName?.let {
            vizResultDict["maidenName"] = serializeStringResult(it)
        }
        vizResult?.municipalityCode?.let {
            vizResultDict["municipalityCode"] = serializeStringResult(it)
        }
        vizResult?.municipalityOfRegistration?.let {
            vizResultDict["municipalityOfRegistration"] = serializeStringResult(it)
        }
        vizResult?.pollingStationCode?.let {
            vizResultDict["pollingStationCode"] = serializeStringResult(it)
        }
        vizResult?.registrationCenterCode?.let {
            vizResultDict["registrationCenterCode"] = serializeStringResult(it)
        }
        vizResult?.sectionCode?.let {
            vizResultDict["sectionCode"] = serializeStringResult(it)
        }
        vizResult?.stateCode?.let {
            vizResultDict["stateCode"] = serializeStringResult(it)
        }
        vizResult?.stateName?.let {
            vizResultDict["stateName"] = serializeStringResult(it)
        }
        vizResult?.husbandName?.let {
            vizResultDict["husbandName"] = serializeStringResult(it)
        }
        vizResult?.legalStatus?.let {
            vizResultDict["legalStatus"] = serializeStringResult(it)
        }
        vizResult?.socialSecurityStatus?.let {
            vizResultDict["socialSecurityStatus"] = serializeStringResult(it)
        }
        vizResult?.workRestriction?.let {
            vizResultDict["workRestriction"] = serializeStringResult(it)
        }
        return vizResultDict
    }

    private fun serializeDetailedCroppedImageResult(detailedCroppedImageResult: DetailedCroppedImageResult?): Map<String, Any?> {
        val detailedCroppedImageResultDict: MutableMap<String, Any?> = mutableMapOf()
        detailedCroppedImageResult?.bitmap?.let {
            encodeBase64Image(it)?.let { image ->
                detailedCroppedImageResultDict["image"] = image
            }
        }
        detailedCroppedImageResult?.location?.let {
            detailedCroppedImageResultDict["location"] = serializeLocation(it)
        }
        detailedCroppedImageResult?.side?.let {
            detailedCroppedImageResultDict["side"] = it.ordinal
        }
        return detailedCroppedImageResultDict
    }

    private fun serializeBarcodeExtendedElements(barcodeExtendedElements: Array<BarcodeElement>?): Map<String, Any?> {
        val barcodeExtendedElementsDict: MutableMap<String, Any?> = mutableMapOf()
        barcodeExtendedElements?.let {
            it.map { element ->
                barcodeExtendedElementsDict[element.key.name.replaceFirstChar { char -> char.lowercase() }] =
                    element.value
            }
        }
        return barcodeExtendedElementsDict
    }

    private fun serializeParentInfo(parentInfo: ParentInfo): Map<String, Any> {
        val parentInfoDict: MutableMap<String, Any> = mutableMapOf()
        parentInfo.firstName?.let {
            parentInfoDict["firstName"] = serializeStringResult(it)
        }
        parentInfo.lastName?.let {
            parentInfoDict["lastName"] = serializeStringResult(it)
        }
        return parentInfoDict
    }

    private fun serializeStringType(value: Any?): Any? =
        when (value) {
            is StringResult -> serializeStringResult(value)
            is String -> value
            else -> null
        }

    private fun encodeBase64Image(image: Bitmap?): String? =
        image?.let { bmp ->
            val outputStream = ByteArrayOutputStream()
            outputStream.use { stream ->
                bmp.compress(Bitmap.CompressFormat.JPEG, 95, stream)
                Base64.encodeToString(
                    stream.toByteArray(),
                    Base64.NO_WRAP,
                )
            }
        }
}
