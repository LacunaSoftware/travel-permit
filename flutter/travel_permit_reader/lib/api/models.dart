import 'package:travel_permit_reader/api/enums.dart';
import 'package:travel_permit_reader/util/page_util.dart';
import 'package:travel_permit_reader/util/qrcode_data.dart';

class TravelPermitModel {
  final String key;
  final DateTime? startDate;
  final DateTime expirationDate;
  final TravelPermitTypes? type;
  final GuardianModel? requiredGuardian;
  final GuardianModel? optionalGuardian;
  final EscortModel? escort;
  final UnderageModel? underage;
  final NotaryModel? notary;
  final bool isOffline;
  final String? qrcodeData;

  TravelPermitModel._({
    required this.key,
    this.startDate,
    required this.expirationDate,
    this.type,
    this.requiredGuardian,
    this.optionalGuardian,
    this.escort,
    this.underage,
    this.notary,
    required this.isOffline,
    this.qrcodeData,
  });

  factory TravelPermitModel.fromJson(String key, Map<String, dynamic> json) {
    return TravelPermitModel._(
        isOffline: false,
        key: key,
        startDate: StringExt.isNullOrEmpty(json['startDate'])
          ? null
          : DateTime.parse(json['startDate']),
        expirationDate: DateTime.parse(json['expirationDate']),
        type: TravelPermitTypesExt.fromString(json['type']),
        requiredGuardian: json['requiredGuardian'] == null
          ? null
          : GuardianModel.fromJson(json['requiredGuardian']),
        optionalGuardian: json['optionalGuardian'] == null
          ? null
          : GuardianModel.fromJson(json['optionalGuardian']),
        escort: json['escort'] == null
          ? null
          : EscortModel.fromJson(json['escort']),
        underage: json['underage'] == null
          ? null
          : UnderageModel.fromJson(json['underage']),
        notary: json['notary'] == null
          ? null
          : NotaryModel.fromJson(json['notary']),
    );
  }

  factory TravelPermitModel.fromQRCode(QRCodeData data) {
    return TravelPermitModel._(
      isOffline: true,
      key: data.documentKey,
      startDate: StringExt.isNullOrEmpty(data.startDate)
          ? null
          : DateTime.parse(data.startDate!),
      expirationDate: DateTime.parse(data.expirationDate),
      type: TravelPermitTypesExt.fromString(data.travelPermitType),
      //-------------------------------------------------------------------
      requiredGuardian: StringExt.isNullOrEmpty(data.requiredGuardianName)
          ? null
          : GuardianModel._(
              name: data.requiredGuardianName,
              documentNumber: data.requiredGuardianDocumentNumber,
              documentIssuer: data.requiredGuardianDocumentIssuer,
              documentType: IdDocumentTypesExt.fromString(
                  data.requiredGuardianDocumentType!),
              guardianship: LegalGuardianTypesExt.fromString(
                  data.requiredGuardianGuardianship!)),
      //-------------------------------------------------------------------
      optionalGuardian: StringExt.isNullOrEmpty(data.optionalGuardianName)
          ? null
          : GuardianModel._(
              name: data.optionalGuardianName,
              documentNumber: data.optionalGuardianDocumentNumber,
              documentIssuer: data.optionalGuardianDocumentIssuer,
              documentType: IdDocumentTypesExt.fromString(
                  data.optionalGuardianDocumentType),
              guardianship: LegalGuardianTypesExt.fromString(
                  data.optionalGuardianGuardianship)),
      //-------------------------------------------------------------------
      escort: StringExt.isNullOrEmpty(data.escortName)
          ? null
          : EscortModel._(
              name: data.escortName,
              documentNumber: data.escortDocumentNumber,
              documentIssuer: data.escortDocumentIssuer,
              documentType: IdDocumentTypesExt.fromString(data.escortDocumentType),
              guardianship: LegalGuardianTypesExt.fromString(data.escortGuardianship),
            ),
      //-------------------------------------------------------------------
      underage: StringExt.isNullOrEmpty(data.underageName)
          ? null
          : UnderageModel._(
              name: data.underageName,
              documentNumber: data.underageDocumentNumber,
              documentIssuer: data.underageDocumentIssuer,
              documentType:
                  IdDocumentTypesExt.fromString(data.underageDocumentType),
              birthDate: DateTime.parse(data.underageBirthDate!),
              bioGender: BioGendersExt.fromString(data.underageBioGender)),
      qrcodeData: data.getQRCodeData(),
    );
  }
}

//-------------------------------------------------------------------

abstract class ParticipantModel {
  final String? identifier;
  final String name;
  final String? documentNumber;
  final IdDocumentTypes? documentType;
  final String? documentIssuer;
  final DateTime? issueDate;
  final String? photoUrl;
  final String? addressCity;
  final String? addressState;
  final String? zipCode;
  final String? streetAddress;
  final String? addressNumber;
  final String? additionalAddressInfo;
  final String? neighborhood;
  final String? country;
  final String? addressForeignStateName;
  final String? addressForeignCityName;

  ParticipantModel._({
    this.identifier,
    required this.name,
    this.documentNumber,
    this.documentType,
    this.documentIssuer,
    this.issueDate,
    this.photoUrl,
    this.addressCity,
    this.addressState,
    this.zipCode,
    this.streetAddress,
    this.addressNumber,
    this.additionalAddressInfo,
    this.neighborhood,
    this.country,
    this.addressForeignStateName,
    this.addressForeignCityName,
  });
}

//-------------------------------------------------------------------

class AdultModel extends ParticipantModel {
  final String? phoneNumber;
  final String? email;

  AdultModel._({
    this.phoneNumber,
    this.email,
    identifier,
    name,
    documentNumber,
    documentType,
    documentIssuer,
    issueDate,
    photoUrl,
    addressCity,
    addressState,
    zipCode,
    streetAddress,
    addressNumber,
    additionalAddressInfo,
    neighborhood,
    country,
    addressForeignStateName,
    addressForeignCityName,
  }) : super._(
          identifier: identifier,
          name: name,
          documentNumber: documentNumber,
          documentType: documentType,
          documentIssuer: documentIssuer,
          issueDate: issueDate,
          photoUrl: photoUrl,
          addressCity: addressCity,
          addressState: addressState,
          zipCode: zipCode,
          streetAddress: streetAddress,
          addressNumber: addressNumber,
          additionalAddressInfo: additionalAddressInfo,
          neighborhood: neighborhood,
          country: country,
          addressForeignStateName: addressForeignStateName,
          addressForeignCityName: addressForeignCityName,
        );

  factory AdultModel.fromJson(Map<String, dynamic> json) {
    return AdultModel._(
      identifier: json['identifier'],
      name: json['name'],
      documentNumber: json['documentNumber'],
      documentType: IdDocumentTypesExt.fromString(json['documentType']),
      documentIssuer: json['documentIssuer'],
      issueDate: DateTime.parse(json['issueDate']),
      photoUrl: json['pictureLocation'],
      addressCity: json['addressCity'],
      addressState: json['addressState'],
      zipCode: json['zipCode'],
      streetAddress: json['streetAddress'],
      addressNumber: json['addressNumber'],
      additionalAddressInfo: json['additionalAddressInfo'],
      neighborhood: json['neighborhood'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      country: json['country'],
      addressForeignStateName: json['addressForeignStateName'],
      addressForeignCityName: json['addressForeignCityName'],
    );
  }
}

//-------------------------------------------------------------------

class EscortModel extends AdultModel {
  final LegalGuardianTypes? guardianship;

  EscortModel._({
    this.guardianship,
    phoneNumber,
    email,
    identifier,
    name,
    documentNumber,
    documentType,
    documentIssuer,
    issueDate,
    photoUrl,
    addressCity,
    addressState,
    zipCode,
    streetAddress,
    addressNumber,
    additionalAddressInfo,
    neighborhood,
    country,
    addressForeignStateName,
    addressForeignCityName,
  }) : super._(
          phoneNumber: phoneNumber,
          email: email,
          identifier: identifier,
          name: name,
          documentNumber: documentNumber,
          documentType: documentType,
          documentIssuer: documentIssuer,
          issueDate: issueDate,
          photoUrl: photoUrl,
          addressCity: addressCity,
          addressState: addressState,
          zipCode: zipCode,
          streetAddress: streetAddress,
          addressNumber: addressNumber,
          additionalAddressInfo: additionalAddressInfo,
          neighborhood: neighborhood,
          country: country,
          addressForeignStateName: addressForeignStateName,
          addressForeignCityName: addressForeignCityName,
        );

  factory EscortModel.fromJson(Map<String, dynamic> json) {
    return EscortModel._(
      identifier: json['identifier'],
      name: json['name'],
      documentNumber: json['documentNumber'],
      documentType: IdDocumentTypesExt.fromString(json['documentType']),
      documentIssuer: json['documentIssuer'],
      issueDate: DateTime.parse(json['issueDate']),
      photoUrl: json['pictureLocation'],
      addressCity: json['addressCity'],
      addressState: json['addressState'],
      zipCode: json['zipCode'],
      streetAddress: json['streetAddress'],
      addressNumber: json['addressNumber'],
      additionalAddressInfo: json['additionalAddressInfo'],
      neighborhood: json['neighborhood'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      country: json['country'],
      addressForeignStateName: json['addressForeignStateName'],
      addressForeignCityName: json['addressForeignCityName'],
      guardianship: LegalGuardianTypesExt.fromString(json['guardianship']),
    );
  }
}

//-------------------------------------------------------------------

class GuardianModel extends AdultModel {
  final LegalGuardianTypes? guardianship;
  final bool? livedInBrazil;
  final String? lastCityInBrazil;
  final String? lastStateInBrazil;

  GuardianModel._({
    this.guardianship,
    this.livedInBrazil,
    this.lastCityInBrazil,
    this.lastStateInBrazil,
    addressCity,
    addressState,
    zipCode,
    streetAddress,
    addressNumber,
    additionalAddressInfo,
    neighborhood,
    phoneNumber,
    email,
    bioId,
    identifier,
    name,
    documentNumber,
    documentType,
    documentIssuer,
    issueDate,
    photoUrl,
    country,
    addressForeignStateName,
    addressForeignCityName,
  }) : super._(
          addressCity: addressCity,
          addressState: addressState,
          zipCode: zipCode,
          streetAddress: streetAddress,
          addressNumber: addressNumber,
          additionalAddressInfo: additionalAddressInfo,
          neighborhood: neighborhood,
          phoneNumber: phoneNumber,
          email: email,
          identifier: identifier,
          name: name,
          documentNumber: documentNumber,
          documentType: documentType,
          documentIssuer: documentIssuer,
          issueDate: issueDate,
          photoUrl: photoUrl,
          country: country,
          addressForeignStateName: addressForeignStateName,
          addressForeignCityName: addressForeignCityName,
        );

  factory GuardianModel.fromJson(Map<String, dynamic> json) {
    return GuardianModel._(
      guardianship: LegalGuardianTypesExt.fromString(json['guardianship']),
      livedInBrazil: json['livedInBrazil'],
      lastCityInBrazil: json['lastCityInBrazil'],
      lastStateInBrazil: json['lastStateInBrazil'],
      identifier: json['identifier'],
      name: json['name'],
      documentNumber: json['documentNumber'],
      documentType: IdDocumentTypesExt.fromString(json['documentType']),
      documentIssuer: json['documentIssuer'],
      issueDate: DateTime.parse(json['issueDate']),
      photoUrl: json['pictureLocation'],
      addressCity: json['addressCity'],
      addressState: json['addressState'],
      zipCode: json['zipCode'],
      streetAddress: json['streetAddress'],
      addressNumber: json['addressNumber'],
      additionalAddressInfo: json['additionalAddressInfo'],
      neighborhood: json['neighborhood'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      bioId: json['bioId'],
      country: json['country'],
      addressForeignStateName: json['addressForeignStateName'],
      addressForeignCityName: json['addressForeignCityName'],
    );
  }
}

//-------------------------------------------------------------------

class UnderageModel extends ParticipantModel {
  final BioGenders? bioGender;
  final DateTime? birthDate;
  final String? cityOfBirth;
  final String? stateOfBirth;

  UnderageModel._({
    this.bioGender,
    this.birthDate,
    this.cityOfBirth,
    this.stateOfBirth,
    identifier,
    name,
    documentNumber,
    documentType,
    documentIssuer,
    issueDate,
    photoUrl,
    addressCity,
    addressState,
    zipCode,
    streetAddress,
    addressNumber,
    additionalAddressInfo,
    neighborhood,
    country,
    addressForeignStateName,
    addressForeignCityName,
  }) : super._(
          identifier: identifier,
          name: name,
          documentNumber: documentNumber,
          documentType: documentType,
          documentIssuer: documentIssuer,
          issueDate: issueDate,
          photoUrl: photoUrl,
          addressCity: addressCity,
          addressState: addressState,
          zipCode: zipCode,
          streetAddress: streetAddress,
          addressNumber: addressNumber,
          additionalAddressInfo: additionalAddressInfo,
          neighborhood: neighborhood,
          country: country,
          addressForeignStateName: addressForeignStateName,
          addressForeignCityName: addressForeignCityName,
        );

  factory UnderageModel.fromJson(Map<String, dynamic> json) {
    return UnderageModel._(
      identifier: json['identifier'],
      name: json['name'],
      documentNumber: json['documentNumber'],
      documentType: IdDocumentTypesExt.fromString(json['documentType']),
      documentIssuer: json['documentIssuer'],
      issueDate: DateTime.parse(json['issueDate']),
      photoUrl: json['pictureLocation'],
      addressCity: json['addressCity'],
      addressState: json['addressState'],
      zipCode: json['zipCode'],
      streetAddress: json['streetAddress'],
      addressNumber: json['addressNumber'],
      additionalAddressInfo: json['additionalAddressInfo'],
      neighborhood: json['neighborhood'],
      bioGender: BioGendersExt.fromString(json['gender']),
      birthDate: DateTime.parse(json['birthDate']),
      cityOfBirth: json['cityOfBirth'],
      stateOfBirth: json['stateOfBirth'],
      country: json['country'],
      addressForeignStateName: json['addressForeignStateName'],
      addressForeignCityName: json['addressForeignCityName'],
    );
  }
}

//-------------------------------------------------------------------

class CnbErrorModel {
  final String message;
  final CnbErrorCodes code;
  CnbErrorModel._({required this.message, required this.code});
  factory CnbErrorModel.fromJson(Map<String, dynamic> json) {
    try {
      return CnbErrorModel._(
          message: json['message'],
          code: CnbErrorCodesExt.fromString(json['code']));
    } catch (ex) {}

    return CnbErrorModel._(
      message: 'Ocorreu um erro deconhecido',
      code: CnbErrorCodes.unknown,
    );
  }
}

//-------------------------------------------------------------------

class TypedParticipant {
  final ParticipantModel participant;
  final ParticipantTypes type;

  TypedParticipant(this.participant, this.type);
}

//-------------------------------------------------------------------

class NotaryModel {
  final String name;
  final String? cns;
  final String? ownerName;
  final String? phoneNumber;

  NotaryModel._({required this.name, this.cns, this.ownerName, this.phoneNumber});

  factory NotaryModel.fromJson(Map<String, dynamic> json) {
    return NotaryModel._(
        name: json['name'],
        cns: json['cns'],
        ownerName: json['ownerName'],
        phoneNumber: json['phoneNumber']);
  }
}

//-------------------------------------------------------------------

class JudgeModel extends ParticipantModel {
  JudgeModel._({
    identifier,
    required name,
  }) : super._(
    name: name,
    identifier: identifier,
  );

  factory JudgeModel.fromJson(Map<String, dynamic> json) {
    return JudgeModel._(
        name: json['name'],
        identifier: json['identifier'],
    );
  }
}

//-------------------------------------------------------------------

class JudiciaryTravelPermitModel {
  final JudgeModel? judge;
  final NotaryModel? notary;

  JudiciaryTravelPermitModel._({
    this.judge,
    this.notary,
  });

  factory JudiciaryTravelPermitModel.fromJson(Map<String, dynamic> json) {
    return JudiciaryTravelPermitModel._(
      judge: json['judge'] != null
        ? JudgeModel.fromJson(json['judge'])
        : null,
      notary: json['notary'] != null
        ? NotaryModel.fromJson(json['notary'])
        : null,
    );
  }

  factory JudiciaryTravelPermitModel.fromQRCode(QRCodeData data) {
    return JudiciaryTravelPermitModel._(
      judge: StringExt.isNullOrEmpty(data.judgeName)
        ? null
        : JudgeModel._(name: data.judgeName),
      notary: StringExt.isNullOrEmpty(data.organizationName)
        ? null
        : NotaryModel._(name: data.organizationName!),
    );
  }
}

//-------------------------------------------------------------------

class TravelPermitValidationInfo {
  final TravelPermitModel travelPermit;
  final JudiciaryTravelPermitModel? judiciaryTravelPermit;

  TravelPermitValidationInfo._({
    required this.travelPermit,
    this.judiciaryTravelPermit,
  });

  factory TravelPermitValidationInfo.fromJson(String key, Map<String, dynamic> json) {
    final judiciaryTravelPermit = json['judiciaryTravelPermit'] != null
      ? JudiciaryTravelPermitModel.fromJson(json['judiciaryTravelPermit'])
      : null;
    var travelPermit = json['travelPermit'] != null
      ? TravelPermitModel.fromJson(key, json['travelPermit'])
      : null;

    if (json['judiciaryTravelPermit'] != null) {
      travelPermit = TravelPermitModel.fromJson(key, json['judiciaryTravelPermit']);
    }

    return TravelPermitValidationInfo._(
      travelPermit: travelPermit!,
      judiciaryTravelPermit: judiciaryTravelPermit,
    );
  }

  factory TravelPermitValidationInfo.fromQRCode(QRCodeData data) {
    return TravelPermitValidationInfo._(
      travelPermit: TravelPermitModel.fromQRCode(data),
      judiciaryTravelPermit: JudiciaryTravelPermitModel.fromQRCode(data),
    );
  }
}
