import 'package:blinkid_flutter/blinkid_flutter.dart';

class UiDocumentFilter {
  CountryID? country;
  RegionID? region;
  DocumentTypeID? documentType;

  UiDocumentFilter({this.country, this.region, this.documentType});
}

const sampleCountries = <CountryID>[
  CountryID.canada,
  CountryID.usa,
  CountryID.croatia,
  CountryID.germany,
  CountryID.uK,
  CountryID.australia,
];

const sampleUsaRegions = <RegionID>[
  RegionID.california,
  RegionID.texas,
  RegionID.newYork,
  RegionID.florida,
];

const sampleDocumentTypes = <DocumentTypeID>[
  DocumentTypeID.id,
  DocumentTypeID.dl,
  DocumentTypeID.passport,
  DocumentTypeID.visa,
];

const redactionModes = <RedactionMode>[
  RedactionMode.none,
  RedactionMode.imageOnly,
  RedactionMode.resultFieldsOnly,
  RedactionMode.fullResult,
];

const sampleRedactionFields = <FieldType>[
  FieldType.firstName,
  FieldType.lastName,
  FieldType.fullName,
  FieldType.documentNumber,
  FieldType.dateOfBirth,
  FieldType.address,
  FieldType.personalIdNumber,
];

DocumentFilter uiToDocumentFilter(UiDocumentFilter ui) {
  return DocumentFilter(
    country: ui.country,
    region: ui.country == CountryID.usa ? ui.region : null,
    documentType: ui.documentType,
  );
}

bool hasDocumentFilterCriteria(UiDocumentFilter ui) {
  return ui.country != null || ui.region != null || ui.documentType != null;
}

UiDocumentFilter emptyUiDocumentFilter() => UiDocumentFilter();
