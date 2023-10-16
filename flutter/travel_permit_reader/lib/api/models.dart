import 'package:travel_permit_reader/api/enums.dart';
import 'package:travel_permit_reader/tp_exception.dart';
import 'package:travel_permit_reader/util/page_util.dart';
import 'package:travel_permit_reader/util/qrcode_data.dart';

class TravelPermitModel {
  final String key;
  final DateTime startDate;
  final DateTime expirationDate;
  final TravelPermitTypes type;
  final GuardianModel requiredGuardian;
  final GuardianModel optionalGuardian;
  final AdultModel escort;
  final UnderageModel underage;
  final NotaryModel notary;
  final bool isOffline;
  final String qrcodeData;

  TravelPermitModel._({
    this.key,
    this.startDate,
    this.expirationDate,
    this.type,
    this.requiredGuardian,
    this.optionalGuardian,
    this.escort,
    this.underage,
    this.notary,
    this.isOffline,
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
        requiredGuardian: GuardianModel.fromJson(json['requiredGuardian']),
        optionalGuardian: GuardianModel.fromJson(json['optionalGuardian']),
        escort: AdultModel.fromJson(json['escort']),
        underage: UnderageModel.fromJson(json['underage']),
        notary: NotaryModel.fromJson(json['notary']));
  }

  factory TravelPermitModel.fromQRCode(QRCodeData data) {
    return TravelPermitModel._(
      isOffline: true,
      key: data.documentKey,
      startDate: StringExt.isNullOrEmpty(data.startDate)
          ? null
          : DateTime.parse(data.startDate),
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
                  data.requiredGuardianDocumentType),
              guardianship: LegalGuardianTypesExt.fromString(
                  data.requiredGuardianGuardianship)),
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
          : AdultModel._(
              name: data.escortName,
              documentNumber: data.escortDocumentNumber,
              documentIssuer: data.escortDocumentIssuer,
              documentType:
                  IdDocumentTypesExt.fromString(data.escortDocumentType),
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
              birthDate: DateTime.parse(data.underageBirthDate),
              bioGender: BioGendersExt.fromString(data.underageBioGender)),
      qrcodeData: data.getQRCodeData(),
    );
  }
}

//-------------------------------------------------------------------

abstract class ParticipantModel {
  final String identifier;
  final String name;
  final String documentNumber;
  final IdDocumentTypes documentType;
  final String documentIssuer;
  final DateTime issueDate;
  final String photoUrl;
  final String addressCity;
  final String addressState;
  final String zipCode;
  final String streetAddress;
  final String addressNumber;
  final String additionalAddressInfo;
  final String neighborhood;
  final String country;
  final String addressForeignStateName;
  final String addressForeignCityName;

  ParticipantModel._({
    this.identifier,
    this.name,
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
  final String phoneNumber;
  final String email;

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
    if (json == null) {
      return null;
    }
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

class GuardianModel extends AdultModel {
  final LegalGuardianTypes guardianship;
  final bool livedInBrazil;
  final String lastCityInBrazil;
  final String lastStateInBrazil;

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
    if (json == null) {
      return null;
    }
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
  final BioGenders bioGender;
  final DateTime birthDate;
  final String cityOfBirth;
  final String stateOfBirth;

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
    if (json == null) {
      return null;
    }
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
  CnbErrorModel._({this.message, this.code});
  factory CnbErrorModel.fromJson(Map<String, dynamic> json) {
    try {
      if (json == null) {
        throw TPException('Null parameter: json');
      }
      return CnbErrorModel._(
          message: json['message'],
          code: CnbErrorCodesExt.fromString(json['code']));
    } catch (ex) {}
    return null;
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
  final String cns;
  final String ownerName;
  final String phoneNumber;

  NotaryModel._({this.name, this.cns, this.ownerName, this.phoneNumber});

  factory NotaryModel.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return NotaryModel._(
        name: json['name'],
        cns: json['cns'],
        ownerName: json['ownerName'],
        phoneNumber: json['phoneNumber']);
  }
}
