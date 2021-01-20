import 'package:travel_permit_reader/api/enums.dart';
import 'package:travel_permit_reader/util/page_util.dart';
import 'package:travel_permit_reader/util/qrcode_data.dart';

class TravelPermitModel {
  final String key;
  final DateTime expirationDate;
  final TravelPermitTypes type;
  final GuardianModel requiredGuardian;
  final GuardianModel optionalGuardian;
  final AdultModel escort;
  final UnderageModel underage;
  final bool isOffline;

  TravelPermitModel._({
    this.key,
    this.expirationDate,
    this.type,
    this.requiredGuardian,
    this.optionalGuardian,
    this.escort,
    this.underage,
    this.isOffline,
  });

  factory TravelPermitModel.fromJson(String key, Map<String, dynamic> json) {
    return TravelPermitModel._(
        isOffline: false,
        key: key,
        expirationDate: DateTime.parse(json['expirationDate']),
        type: TravelPermitTypesExt.fromString(json['type']),
        requiredGuardian: GuardianModel.fromJson(json['requiredGuardian']),
        optionalGuardian: GuardianModel.fromJson(json['optionalGuardian']),
        escort: AdultModel.fromJson(json['escort']),
        underage: UnderageModel.fromJson(json['underage']));
  }

  factory TravelPermitModel.fromQRCode(QRCodeData data) {
    return TravelPermitModel._(
      isOffline: true,
      key: data.documentKey,
      expirationDate: DateTime.parse(data.expirationDate),
      type: TravelPermitTypesExt.fromString(data.travelPermitType),
      //-------------------------------------------------------------------
      requiredGuardian: StringExt.isNullOrEmpty(data.requiredGuardianName)
          ? null
          : GuardianModel._(
              name: data.requiredGuardianName,
              documentNumber: data.requiredGuardianDocumentNumber,
              documentIssuer: data.requiredGuardianDocumentIssuer,
              documentType: BioDocumentTypesExt.fromString(
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
              documentType: BioDocumentTypesExt.fromString(
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
                  BioDocumentTypesExt.fromString(data.escortDocumentType),
            ),
      //-------------------------------------------------------------------
      underage: StringExt.isNullOrEmpty(data.underageName)
          ? null
          : UnderageModel._(
              name: data.underageName,
              documentNumber: data.underageDocumentNumber,
              documentIssuer: data.underageDocumentIssuer,
              documentType:
                  BioDocumentTypesExt.fromString(data.underageDocumentType),
              birthDate: DateTime.parse(data.underageBirthDate),
              bioGender: BioGendersExt.fromString(data.underageBioGender)),
    );
  }
}

//-------------------------------------------------------------------

abstract class ParticipantModel {
  final String identifier;
  final String name;
  final String documentNumber;
  final BioDocumentTypes documentType;
  final String documentIssuer;
  final DateTime issueDate;

  ParticipantModel._(
      {this.identifier,
      this.name,
      this.documentNumber,
      this.documentType,
      this.documentIssuer,
      this.issueDate});
}

//-------------------------------------------------------------------

class AdultModel extends ParticipantModel {
  final String addressCity;
  final String addressState;
  final String zipCode;
  final String streetAddress;
  final String addressNumber;
  final String additionalAddressInfo;
  final String neighborhood;
  final String phoneNumber;
  final String email;
  final String bioId;

  AdultModel._(
      {identifier,
      name,
      documentNumber,
      documentType,
      documentIssuer,
      issueDate,
      this.addressCity,
      this.addressState,
      this.zipCode,
      this.streetAddress,
      this.addressNumber,
      this.additionalAddressInfo,
      this.neighborhood,
      this.phoneNumber,
      this.email,
      this.bioId})
      : super._(
          identifier: identifier,
          name: name,
          documentNumber: documentNumber,
          documentType: documentType,
          documentIssuer: documentIssuer,
          issueDate: issueDate,
        );

  factory AdultModel.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return AdultModel._(
      identifier: json['identifier'],
      name: json['name'],
      documentNumber: json['documentNumber'],
      documentType: BioDocumentTypesExt.fromString(json['documentType']),
      documentIssuer: json['documentIssuer'],
      issueDate: DateTime.parse(json['issueDate']),
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
    );
  }
}

//-------------------------------------------------------------------

class GuardianModel extends AdultModel {
  final LegalGuardianTypes guardianship;

  GuardianModel._(
      {this.guardianship,
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
      issueDate})
      : super._(
          addressCity: addressCity,
          addressState: addressState,
          zipCode: zipCode,
          streetAddress: streetAddress,
          addressNumber: addressNumber,
          additionalAddressInfo: additionalAddressInfo,
          neighborhood: neighborhood,
          phoneNumber: phoneNumber,
          email: email,
          bioId: bioId,
          identifier: identifier,
          name: name,
          documentNumber: documentNumber,
          documentType: documentType,
          documentIssuer: documentIssuer,
          issueDate: issueDate,
        );

  factory GuardianModel.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return GuardianModel._(
      guardianship: LegalGuardianTypesExt.fromString(json['guardianship']),
      identifier: json['identifier'],
      name: json['name'],
      documentNumber: json['documentNumber'],
      documentType: BioDocumentTypesExt.fromString(json['documentType']),
      documentIssuer: json['documentIssuer'],
      issueDate: DateTime.parse(json['issueDate']),
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
    );
  }
}

//-------------------------------------------------------------------

class UnderageModel extends ParticipantModel {
  final BioGenders bioGender;
  final DateTime birthDate;
  final String cityOfBirth;
  final String stateOfBirth;

  UnderageModel._(
      {identifier,
      name,
      documentNumber,
      documentType,
      documentIssuer,
      issueDate,
      this.bioGender,
      this.birthDate,
      this.cityOfBirth,
      this.stateOfBirth})
      : super._(
            identifier: identifier,
            name: name,
            documentNumber: documentNumber,
            documentType: documentType,
            documentIssuer: documentIssuer,
            issueDate: issueDate);

  factory UnderageModel.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return UnderageModel._(
      identifier: json['identifier'],
      name: json['name'],
      documentNumber: json['documentNumber'],
      documentType: BioDocumentTypesExt.fromString(json['documentType']),
      documentIssuer: json['documentIssuer'],
      issueDate: DateTime.parse(json['issueDate']),
      bioGender: BioGendersExt.fromString(json['gender']),
      birthDate: DateTime.parse(json['birthDate']),
      cityOfBirth: json['cityOfBirth'],
      stateOfBirth: json['stateOfBirth'],
    );
  }
}

//-------------------------------------------------------------------

class TypedParticipant {
  final ParticipantModel participant;
  final ParticipantTypes type;

  TypedParticipant(this.participant, this.type);
}
