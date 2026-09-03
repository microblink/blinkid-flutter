import 'types.dart';

/// Represents the results of scanning a document.
///
/// This class contains the results of scanning a document, including the extracted data
/// and images from the document.
class BlinkIdScanningResult {
  /// The document class information.
  ///
  /// See [DocumentClassInfo] for more information.
  DocumentClassInfo? documentClassInfo;

  /// Info on whether the data extracted from multiple sides matches.
  ///
  /// See [DataMatchResult] for more information.
  DataMatchResult? dataMatchResult;

  /// The first name of the document owner.
  StringResult? firstName;

  /// The last name of the document owner.
  StringResult? lastName;

  /// The full name of the document owner.
  StringResult? fullName;

  /// The additional name information of the document owner.
  StringResult? additionalNameInformation;

  /// The localized name of the document owner.
  StringResult? localizedName;

  /// The fathers name of the document owner.
  StringResult? fathersName;

  /// The mothers name of the document owner.
  StringResult? mothersName;

  /// The address of the document owner.
  StringResult? address;

  /// The additional address information of the document owner.
  StringResult? additionalAddressInformation;

  /// The one more additional address information of the document owner.
  StringResult? additionalOptionalAddressInformation;

  /// The place of birth of the document owner.
  StringResult? placeOfBirth;

  /// The nationality of the document owner.
  StringResult? nationality;

  /// The race of the document owner.
  StringResult? race;

  /// The ethnicity of the document owner.
  StringResult? ethnicity;

  /// The religion of the document owner.
  StringResult? religion;

  /// The profession of the document owner.
  StringResult? profession;

  /// The marital status of the document owner.
  StringResult? maritalStatus;

  /// The residential status of the document owner.
  StringResult? residentialStatus;

  /// The employer of the document owner.
  StringResult? employer;

  /// The sex of the document owner.
  StringResult? sex;

  /// The sponsor of the document owner.
  StringResult? sponsor;

  /// The blood type of the document owner.
  StringResult? bloodType;

  /// The document number.
  StringResult? documentNumber;

  /// cardAccessNumber
  StringResult? cardAccessNumber;

  /// The personal identification number.
  StringResult? personalIdNumber;

  /// The additional number of the document.
  StringResult? documentAdditionalNumber;

  /// The one more additional number of the document.
  StringResult? documentOptionalAdditionalNumber;

  /// The additional personal identification number.
  StringResult? additionalPersonalIdNumber;

  /// The issuing authority of the document.
  StringResult? issuingAuthority;

  /// The transcription of the document subtype.
  StringResult? documentSubtype;

  /// The remarks on the residence permit.
  StringResult? remarks;

  /// The residence permit type.
  StringResult? residencePermitType;

  /// The manufacturing year.
  StringResult? manufacturingYear;

  /// The vehicle type.
  StringResult? vehicleType;

  /// The vehicle owner.
  StringResult? vehicleOwner;

  /// The eligibility category.
  StringResult? eligibilityCategory;

  /// The specific document validity.
  StringResult? specificDocumentValidity;

  /// The visa type of the document.
  StringResult? visaType;

  /// The country code of the document owner.
  StringResult? countryCode;

  /// The certificate number of the document owner.
  StringResult? certificateNumber;

  /// The national insurance number of the document owner.
  StringResult? nationalInsuranceNumber;

  /// The date of birth of the document owner.
  DateResult<StringResult>? dateOfBirth;

  /// The date of issue of the document.
  DateResult<StringResult>? dateOfIssue;

  /// The date of expiry of the document.
  DateResult<StringResult>? dateOfExpiry;

  /// The date of entry of the document owner.
  DateResult<StringResult>? dateOfEntry;

  /// The locality code of the document owner.
  StringResult? localityCode;

  /// The maiden name of the document owner.
  StringResult? maidenName;

  /// The municipality code of the document owner.
  StringResult? municipalityCode;

  /// The municipality of registration of the document owner.
  StringResult? municipalityOfRegistration;

  /// The polling station code of the document owner.
  StringResult? pollingStationCode;

  /// The registration center code of the document owner.
  StringResult? registrationCenterCode;

  /// The section code of the document owner.
  StringResult? sectionCode;

  /// The state code of the document owner.
  StringResult? stateCode;

  /// The state of the document owner.
  StringResult? stateName;

  /// Determines if date of expiry is permanent.
  bool? dateOfExpiryPermanent;

  /// The driver license detailed info.
  ///
  /// See [DriverLicenseDetailedInfo] for more information.
  DriverLicenseDetailedInfo<StringResult>? driverLicenseDetailedInfo;

  /// The dependents info.
  ///
  /// See [DependentInfo] for more information.
  List<DependentInfo>? dependentsInfo;

  /// The results of scanning each side of the document.
  ///
  /// See [SingleSideScanningResult] for more information.
  List<SingleSideScanningResult>? subResults;

  /// Returns the input image for the first scanning side in the Base64 format.
  /// or `null` if the input image is not available.
  String? firstInputImage;

  /// Returns the input image for the second scanning side in the Base64 format.
  /// or `null` if the input image is not available.
  String? secondInputImage;

  /// Returns the input image containing parsable barcode.
  /// or `null` if the barcode input image is not available.
  String? barcodeInputImage;

  /// Returns the cropped document image for the first scanning side.
  /// or `null` if the document image is not available.
  String? firstDocumentImage;

  /// Returns the cropped document image for the second scanning side.
  /// or `null` if the document image is not available.
  ///
  String? secondDocumentImage;

  /// Returns the cropped face image with additional info.
  /// or `null` if the face image is not available.
  ///
  /// See [DetailedCroppedImageResult] for more information.
  DetailedCroppedImageResult? faceImage;

  /// Returns the cropped signature image with additional info.
  /// or `null` if the signature image is not available.
  ///
  /// See [DetailedCroppedImageResult] for more information.
  DetailedCroppedImageResult? signatureImage;

  ///  The effective date of the document.
  DateResult<StringResult>? effectiveDate;

  /// The parents info.
  ///
  /// See [ParentInfo] for more information.
  List<ParentInfo>? parentsInfo;

  /// The husband name of the document owner.
  StringResult? husbandName;

  /// The legal status of the document owner.
  StringResult? legalStatus;

  /// The social security status of the document owner.
  StringResult? socialSecurityStatus;

  /// The work restriction of the document owner.
  StringResult? workRestriction;

  /// Represents the results of scanning a document.
  ///
  /// This class contains the results of scanning a document, including the extracted data
  /// and images from the document.
  BlinkIdScanningResult(Map<String, dynamic> nativeBlinkIdScanningResult) {
    documentClassInfo =
        nativeBlinkIdScanningResult['documentClassInfo'] != null
            ? DocumentClassInfo(
              Map<String, dynamic>.from(
                nativeBlinkIdScanningResult['documentClassInfo'],
              ),
            )
            : null;
    dataMatchResult =
        nativeBlinkIdScanningResult["dataMatchResult"] != null
            ? DataMatchResult(
              Map<String, dynamic>.from(
                nativeBlinkIdScanningResult["dataMatchResult"],
              ),
            )
            : null;

    firstName = createStringResult(nativeBlinkIdScanningResult, 'firstName');
    lastName = createStringResult(nativeBlinkIdScanningResult, 'lastName');
    fullName = createStringResult(nativeBlinkIdScanningResult, 'fullName');
    additionalNameInformation = createStringResult(
      nativeBlinkIdScanningResult,
      'additionalNameInformation',
    );
    localizedName = createStringResult(
      nativeBlinkIdScanningResult,
      'localizedName',
    );
    fathersName = createStringResult(
      nativeBlinkIdScanningResult,
      'fathersName',
    );
    mothersName = createStringResult(
      nativeBlinkIdScanningResult,
      'mothersName',
    );
    address = createStringResult(nativeBlinkIdScanningResult, 'address');
    additionalAddressInformation = createStringResult(
      nativeBlinkIdScanningResult,
      'additionalAddressInformation',
    );
    additionalOptionalAddressInformation = createStringResult(
      nativeBlinkIdScanningResult,
      'additionalOptionalAddressInformation',
    );
    placeOfBirth = createStringResult(
      nativeBlinkIdScanningResult,
      'placeOfBirth',
    );
    nationality = createStringResult(
      nativeBlinkIdScanningResult,
      'nationality',
    );
    race = createStringResult(nativeBlinkIdScanningResult, 'race');
    ethnicity = createStringResult(nativeBlinkIdScanningResult, 'ethnicity');
    religion = createStringResult(nativeBlinkIdScanningResult, 'religion');
    profession = createStringResult(nativeBlinkIdScanningResult, 'profession');
    maritalStatus = createStringResult(
      nativeBlinkIdScanningResult,
      'maritalStatus',
    );
    residentialStatus = createStringResult(
      nativeBlinkIdScanningResult,
      'residentialStatus',
    );
    employer = createStringResult(nativeBlinkIdScanningResult, 'employer');
    sex = createStringResult(nativeBlinkIdScanningResult, 'sex');
    sponsor = createStringResult(nativeBlinkIdScanningResult, 'sponsor');
    bloodType = createStringResult(nativeBlinkIdScanningResult, 'bloodType');
    documentNumber = createStringResult(
      nativeBlinkIdScanningResult,
      'documentNumber',
    );
    cardAccessNumber = createStringResult(
      nativeBlinkIdScanningResult,
      "cardAccessNumber",
    );
    personalIdNumber = createStringResult(
      nativeBlinkIdScanningResult,
      'personalIdNumber',
    );
    documentAdditionalNumber = createStringResult(
      nativeBlinkIdScanningResult,
      'documentAdditionalNumber',
    );
    documentOptionalAdditionalNumber = createStringResult(
      nativeBlinkIdScanningResult,
      'documentOptionalAdditionalNumber',
    );
    additionalPersonalIdNumber = createStringResult(
      nativeBlinkIdScanningResult,
      'additionalPersonalIdNumber',
    );
    issuingAuthority = createStringResult(
      nativeBlinkIdScanningResult,
      'issuingAuthority',
    );
    documentSubtype = createStringResult(
      nativeBlinkIdScanningResult,
      'documentSubtype',
    );
    remarks = createStringResult(nativeBlinkIdScanningResult, 'remarks');
    residencePermitType = createStringResult(
      nativeBlinkIdScanningResult,
      'residencePermitType',
    );
    manufacturingYear = createStringResult(
      nativeBlinkIdScanningResult,
      'manufacturingYear',
    );
    vehicleType = createStringResult(
      nativeBlinkIdScanningResult,
      'vehicleType',
    );
    vehicleOwner = createStringResult(
      nativeBlinkIdScanningResult,
      'vehicleOwner',
    );
    eligibilityCategory = createStringResult(
      nativeBlinkIdScanningResult,
      'eligibilityCategory',
    );
    specificDocumentValidity = createStringResult(
      nativeBlinkIdScanningResult,
      'specificDocumentValidity',
    );
    visaType = createStringResult(nativeBlinkIdScanningResult, 'visaType');
    dateOfBirth =
        nativeBlinkIdScanningResult["dateOfBirth"] != null
            ? DateResult<StringResult>(
              Map<String, dynamic>.from(
                nativeBlinkIdScanningResult["dateOfBirth"],
              ),
            )
            : null;
    dateOfIssue =
        nativeBlinkIdScanningResult["dateOfIssue"] != null
            ? DateResult<StringResult>(
              Map<String, dynamic>.from(
                nativeBlinkIdScanningResult["dateOfIssue"],
              ),
            )
            : null;
    dateOfExpiry =
        nativeBlinkIdScanningResult["dateOfExpiry"] != null
            ? DateResult<StringResult>(
              Map<String, dynamic>.from(
                nativeBlinkIdScanningResult["dateOfExpiry"],
              ),
            )
            : null;
    dateOfEntry =
        nativeBlinkIdScanningResult["dateOfEntry"] != null
            ? DateResult<StringResult>(
              Map<String, dynamic>.from(
                nativeBlinkIdScanningResult["dateOfEntry"],
              ),
            )
            : null;
    localityCode = createStringResult(
      nativeBlinkIdScanningResult,
      "localityCode",
    );
    maidenName = createStringResult(nativeBlinkIdScanningResult, "maidenName");
    municipalityCode = createStringResult(
      nativeBlinkIdScanningResult,
      "municipalityCode",
    );
    municipalityOfRegistration = createStringResult(
      nativeBlinkIdScanningResult,
      "municipalityOfRegistration",
    );
    pollingStationCode = createStringResult(
      nativeBlinkIdScanningResult,
      "pollingStationCode",
    );
    registrationCenterCode = createStringResult(
      nativeBlinkIdScanningResult,
      "registrationCenterCode",
    );
    sectionCode = createStringResult(
      nativeBlinkIdScanningResult,
      "sectionCode",
    );
    stateCode = createStringResult(nativeBlinkIdScanningResult, "stateCode");
    stateName = createStringResult(nativeBlinkIdScanningResult, "stateName");
    dateOfExpiryPermanent =
        nativeBlinkIdScanningResult["dateOfExpiryPermanent"];
    driverLicenseDetailedInfo =
        nativeBlinkIdScanningResult["driverLicenseDetailedInfo"] != null
            ? DriverLicenseDetailedInfo<StringResult>(
              Map<String, dynamic>.from(
                nativeBlinkIdScanningResult["driverLicenseDetailedInfo"],
              ),
            )
            : null;
    dependentsInfo =
        nativeBlinkIdScanningResult["dependentsInfo"] != null
            ? (nativeBlinkIdScanningResult["dependentsInfo"] as List<dynamic>)
                .map((item) => DependentInfo(Map<String, dynamic>.from(item)))
                .toList()
            : null;
    subResults =
        nativeBlinkIdScanningResult["subResults"] != null
            ? (nativeBlinkIdScanningResult["subResults"] as List<dynamic>)
                .map(
                  (item) =>
                      SingleSideScanningResult(Map<String, dynamic>.from(item)),
                )
                .toList()
            : null;
    firstInputImage = nativeBlinkIdScanningResult["firstInputImage"];
    secondInputImage = nativeBlinkIdScanningResult["secondInputImage"];
    barcodeInputImage = nativeBlinkIdScanningResult["barcodeImage"];
    firstDocumentImage = nativeBlinkIdScanningResult["firstDocumentImage"];
    secondDocumentImage = nativeBlinkIdScanningResult["secondDocumentImage"];
    faceImage =
        nativeBlinkIdScanningResult["faceImage"] != null
            ? DetailedCroppedImageResult(
              Map<String, dynamic>.from(
                nativeBlinkIdScanningResult["faceImage"],
              ),
            )
            : null;
    signatureImage =
        nativeBlinkIdScanningResult["signatureImage"] != null
            ? DetailedCroppedImageResult(
              Map<String, dynamic>.from(
                nativeBlinkIdScanningResult["signatureImage"],
              ),
            )
            : null;

    countryCode = createStringResult(
      nativeBlinkIdScanningResult,
      'countryCode',
    );
    certificateNumber = createStringResult(
      nativeBlinkIdScanningResult,
      'certificateNumber',
    );
    nationalInsuranceNumber = createStringResult(
      nativeBlinkIdScanningResult,
      'nationalInsuranceNumber',
    );
    effectiveDate =
        nativeBlinkIdScanningResult["effectiveDate"] != null
            ? DateResult<StringResult>(
              Map<String, dynamic>.from(
                nativeBlinkIdScanningResult["effectiveDate"],
              ),
            )
            : null;
    parentsInfo =
        nativeBlinkIdScanningResult["parentsInfo"] != null
            ? (nativeBlinkIdScanningResult["parentsInfo"] as List<dynamic>)
                .map((item) => ParentInfo(Map<String, dynamic>.from(item)))
                .toList()
            : null;
    husbandName = createStringResult(
      nativeBlinkIdScanningResult,
      'husbandName',
    );
    legalStatus = createStringResult(
      nativeBlinkIdScanningResult,
      'legalStatus',
    );
    socialSecurityStatus = createStringResult(
      nativeBlinkIdScanningResult,
      'socialSecurityStatus',
    );
    workRestriction = createStringResult(
      nativeBlinkIdScanningResult,
      'workRestriction',
    );
  }
}
