import 'package:blinkid_flutter/blinkid_flutter.dart';

class BlinkIdResultBuilder {
  static String getIdResultString(BlinkIdScanningResult? result) {
    if (result == null) {
      return "";
    }

    String resultString =
        buildResult(result.firstName, "First name") +
        buildResult(result.lastName, "Last name") +
        buildResult(result.fullName, "Full name") +
        buildResult(result.localizedName, "Localized name") +
        buildResult(result.additionalNameInformation, "Additional name info") +
        buildResult(result.address, "Address") +
        buildResult(
          result.additionalAddressInformation,
          "Additional address info",
        ) +
        buildResult(result.documentNumber, "Document number") +
        buildResult(
          result.documentAdditionalNumber,
          "Additional document number",
        ) +
        buildResult(result.sex, "Sex") +
        buildResult(result.issuingAuthority, "Issuing authority") +
        buildResult(result.nationality, "Nationality") +
        buildDateResult(result.dateOfBirth, "Date of birth") +
        buildDateResult(result.dateOfIssue, "Date of issue") +
        buildDateResult(result.dateOfExpiry, "Date of expiry") +
        buildResult(result.maritalStatus, "Marital status") +
        buildResult(result.personalIdNumber, "Personal Id Number") +
        buildResult(result.profession, "Profession") +
        buildResult(result.race, "Race") +
        buildResult(result.ethnicity, "Ethnicity") +
        buildResult(result.religion, "Religion") +
        buildResult(result.residentialStatus, "Residential Status") +
        buildResult(result.countryCode, "Country code") +
        buildResult(result.certificateNumber, "Certificate number") +
        buildResult(
          result.nationalInsuranceNumber,
          "National insurance number",
        ) +
        buildParentsInfoResult(result.parentsInfo) +
        buildDriverLicenceResult(result.driverLicenseDetailedInfo) +
        buildDataMatchResult(result.dataMatchResult) +
        buildDocumentClassInfoResult(result.documentClassInfo) +
        buildSubresults(result.subResults);

    return "$resultString\n";
  }

  static String buildSubresults(List<SingleSideScanningResult>? subResults) {
    String subResultsString = "";
    if (subResults != null) {
      for (var singleSideResult in subResults.asMap().entries) {
        final index = singleSideResult.key;
        final result = singleSideResult.value;

        subResultsString += "\nDocument side ${index + 1} information:\n";
        subResultsString += buildVizResult(result.viz);
        subResultsString += buildMrzResult(result.mrz);
        subResultsString += buildBarcodeResult(result.barcode);
      }
    }
    return subResultsString;
  }

  static String buildMrzResult(MrzResult? result) {
    if (result == null) {
      return "";
    }

    String resultString =
        buildStringResult(result.documentCode, "Document code") +
        buildStringResult(result.documentNumber, "Document number") +
        buildStringResult(result.gender, "Gender") +
        buildStringResult(result.issuer, "Issuer") +
        buildStringResult(result.issuerName, "Issuer name") +
        buildStringResult(result.nationality, "Nationality") +
        buildStringResult(result.nationalityName, "Nationality name") +
        buildStringResult(result.opt1, "Opt1") +
        buildStringResult(result.opt2, "Opt2") +
        buildStringResult(result.primaryID, "Primary ID") +
        buildStringResult(result.secondaryID, "Secondary ID") +
        buildDateResult(result.dateOfBirth, "Date of birth") +
        buildDateResult(result.dateOfExpiry, "Date of expiry") +
        buildStringResult(result.rawMRZString, "Raw MRZ string") +
        buildStringResult(
          result.sanitizedDocumentCode,
          "Sanitized document code",
        ) +
        buildStringResult(
          result.sanitizedDocumentNumber,
          "Sanitized document number",
        ) +
        buildStringResult(result.sanitizedIssuer, "Sanitized issuer") +
        buildStringResult(
          result.sanitizedNationality,
          "Sanitized nationality",
        ) +
        buildStringResult(result.sanitizedOpt1, "Sanitized Opt1") +
        buildStringResult(result.sanitizedOpt2, "Sanitized Opt2") +
        buildStringResult(result.documentType?.toString(), "Document type");

    return resultString == "" ? "" : "MRZ result:\n$resultString\n";
  }

  static String buildBarcodeResult(BarcodeResult? result) {
    if (result == null) {
      return "";
    }
    String resultString =
        buildStringResult(
          result.additionalNameInformation,
          "Additional name information",
        ) +
        buildStringResult(result.address, "Address") +
        buildStringResult(
          result.documentAdditionalNumber,
          "Document additional number",
        ) +
        buildStringResult(result.documentNumber, "Document number") +
        buildStringResult(result.employer, "Employer") +
        buildStringResult(result.firstName, "First name") +
        buildStringResult(result.lastName, "Last name") +
        buildStringResult(result.fullName, "Full name") +
        buildStringResult(result.issuingAuthority, "Issuing authority") +
        buildStringResult(result.maritalStatus, "Marital status") +
        buildStringResult(result.nationality, "Nationality") +
        buildDateResult(result.dateOfBirth, "Date of birth") +
        buildDateResult(result.dateOfExpiry, "Date of expiry") +
        buildDateResult(result.dateOfIssue, "Date of issue") +
        buildStringResult(result.middleName, "Middle name") +
        buildStringResult(result.placeOfBirth, "Place of birth") +
        buildStringResult(result.personalIdNumber, "Personal ID number") +
        buildStringResult(result.race, "Race") +
        buildStringResult(result.religion, "Religion") +
        buildStringResult(result.profession, "Profession") +
        buildStringResult(result.residentialStatus, "Residential status") +
        buildStringResult(result.sex, "Sex") +
        buildAddressDetailedInfo(result.addressDetailedInfo) +
        buildDriverLicenseInfo(result.driverLicenseDetailedInfo) +
        buildBarcodeData(result.barcodeData);

    return resultString == "" ? "" : "Barcode result:\n$resultString\n";
  }

  static String buildVizResult(VizResult? result) {
    if (result == null) {
      return "";
    }
    String resultString =
        buildResult(result.firstName, "First name") +
        buildResult(result.lastName, "Last name") +
        buildResult(result.fullName, "Full name") +
        buildResult(result.address, "Address") +
        buildResult(result.placeOfBirth, "Place of birth") +
        buildResult(result.nationality, "Nationality") +
        buildResult(result.maritalStatus, "Marital status") +
        buildResult(result.employer, "Employer") +
        buildResult(result.sponsor, "Sponsor") +
        buildResult(result.bloodType, "Blood type") +
        buildDateResult(result.dateOfBirth, "Date of birth") +
        buildDateResult(result.dateOfExpiry, "Date of expiry") +
        buildDateResult(result.dateOfIssue, "Date of issue") +
        buildResult(result.documentNumber, "Document number") +
        buildResult(result.issuingAuthority, "Issuing authority") +
        buildResult(result.documentSubtype, "Document subtype") +
        buildResult(
          result.additionalOptionalAddressInformation,
          "Additional optional address information",
        ) +
        buildResult(
          result.additionalPersonalIdNumber,
          "Additional personal ID number",
        ) +
        buildResult(
          result.documentAdditionalNumber,
          "Document additional number",
        ) +
        buildResult(
          result.documentOptionalAdditionalNumber,
          "Document optional additional number",
        ) +
        buildResult(result.eligibilityCategory, "Eligibility category") +
        buildResult(result.localizedName, "Localized name") +
        buildResult(result.manufacturingYear, "Manufacturing year") +
        buildResult(result.mothersName, "Mother's name") +
        buildResult(result.fathersName, "Father's name") +
        buildParentsInfoResult(result.parentsInfo) +
        buildResult(result.personalIdNumber, "Personal ID number") +
        buildResult(result.profession, "Profession") +
        buildResult(result.race, "Race") +
        buildResult(result.ethnicity, "Ethnicity") +
        buildResult(result.religion, "Religion") +
        buildResult(result.remarks, "Remarks") +
        buildResult(result.residencePermitType, "Residence permit type") +
        buildResult(result.residentialStatus, "Residential status") +
        buildResult(result.sex, "Sex") +
        buildResult(
          result.specificDocumentValidity,
          "Specific document validity",
        ) +
        buildResult(result.vehicleOwner, "Vehicle owner") +
        buildResult(result.vehicleType, "Vehicle type") +
        buildResult(result.visaType, "Visa type") +
        buildResult(result.countryCode, "Country code") +
        buildResult(result.certificateNumber, "Certificate number") +
        buildResult(
          result.nationalInsuranceNumber,
          "National insurance number",
        ) +
        buildDependentsInfoResult(result.dependentsInfo);

    return resultString == "" ? "" : "VIZ result:\n$resultString\n";
  }

  static String buildAddressDetailedInfo(AddressDetailedInfo? info) {
    if (info == null) return "";
    return buildStringResult(info.street, "Street") +
        buildStringResult(info.city, "City") +
        buildStringResult(info.postalCode, "Postal code") +
        buildStringResult(info.jurisdiction, "Jurisdiction");
  }

  static String buildDriverLicenseInfo(
    DriverLicenseDetailedInfo<String>? info,
  ) {
    if (info == null) return "";
    return buildStringResult(info.restrictions, "Restrictions") +
        buildStringResult(info.endorsements, "Endorsements") +
        buildStringResult(info.vehicleClass, "Vehicle class");
  }

  static String buildResult(StringResult? result, String propertyName) {
    if (result == null || result.value == null || result!.value!.isEmpty) {
      return "";
    }
    String resultString = "";
    if (result.latin != null || result.latin!.isNotEmpty) {
      resultString += "${result.latin} ";
    }

    if (result.arabic != null || result.arabic!.isNotEmpty) {
      resultString += "${result.arabic} ";
    }
    if (result.cyrillic != null || result.cyrillic!.isNotEmpty) {
      resultString += "${result.cyrillic} ";
    }
    if (result.greek != null || result.greek!.isNotEmpty) {
      resultString += "${result.greek} ";
    }
    return "$propertyName: $resultString\n";
  }

  static String buildDocumentClassInfoResult(DocumentClassInfo? result) {
    if (result == null) {
      return "";
    }

    return "\nDocument class information:\n"
        "Country: id=${result.country?.id?.name}, rawValue=${result.country?.rawValue}\n"
        "Region: id=${result.region?.id?.name}, rawValue=${result.region?.rawValue}\n"
        "Document type: id=${result.documentType?.id?.name}, rawValue=${result.documentType?.rawValue}\n";
  }

  static String buildDateResult(DateResult? result, String propertyName) {
    if (result == null || result!.date == null || result.date!.year == 0) {
      return "";
    }

    if (result.originalString is StringResult) {
      return buildResult(result.originalString, propertyName);
    } else {
      return buildStringResult(result.originalString, propertyName);
    }
  }

  static String buildStringResult(String? result, String propertyName) {
    if (result == null || result.isEmpty) {
      return "";
    }

    return "$propertyName: $result\n";
  }

  static String buildIntResult(int? result, String propertyName) {
    if (result == null || result < 0) {
      return "";
    }

    return "$propertyName: $result\n";
  }

  static String buildDriverLicenceResult(DriverLicenseDetailedInfo? result) {
    if (result == null) {
      return "";
    }

    return buildResult(result.restrictions, "Restrictions") +
        buildResult(result.endorsements, "Endorsements") +
        buildResult(result.vehicleClass, "Vehicle class") +
        buildResult(result.conditions, "Conditions");
  }

  static String buildDataMatchResult(DataMatchResult? dataMatchresult) {
    if (dataMatchresult == null) {
      return "";
    }

    String dataMatchResultString =
        "\nData match information:\nState for whole document: ${dataMatchresult.overallState?.name}\n";

    for (DataMatchResultField field in dataMatchresult!.states!) {
      dataMatchResultString += "${field.field?.name}: ${field.state?.name}\n";
    }
    return dataMatchResultString;
  }

  static String buildParentsInfoResult(List<ParentInfo>? parentsInfoResult) {
    if (parentsInfoResult == null) return "";

    String resultString = "";
    for (ParentInfo parentInfo in parentsInfoResult) {
      resultString +=
          buildResult(parentInfo.firstName, "First name") +
          buildResult(parentInfo.lastName, "Last name") +
          buildResult(parentInfo.fullName, "Full name");
    }

    return resultString == "" ? "" : "Parents info:\n$resultString";
  }

  static String buildDependentsInfoResult(
    List<DependentInfo>? dependentInfoResult,
  ) {
    if (dependentInfoResult == null) return "";

    String resultString = "";
    for (DependentInfo dependentInfo in dependentInfoResult) {
      resultString +=
          buildResult(dependentInfo.documentNumber, "Document number") +
          buildResult(dependentInfo.fullName, "Full name") +
          buildResult(dependentInfo.sex, "Sex") +
          buildDateResult(dependentInfo.dateOfBirth, "Date of birth");
    }

    return resultString == "" ? "" : "Dependent info:\n$resultString";
  }

  static String buildBarcodeData(BarcodeData? barcodeDataResult) {
    if (barcodeDataResult == null) return "";
    return buildStringResult(
          barcodeDataResult.barcodeType.toString(),
          "Barcode type",
        ) +
        buildStringResult(barcodeDataResult.stringData, "Barcode string data") +
        buildStringResult(
          barcodeDataResult.uncertain.toString(),
          "Barcode uncertain",
        );
  }
}
