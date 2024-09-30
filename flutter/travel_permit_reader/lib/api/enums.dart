enum TravelPermitTypes {
  domestic,
  international,
}

extension TravelPermitTypesExt on TravelPermitTypes {
  static TravelPermitTypes? fromString(String? value) {
    return _EnumCommonParser.parse(value, null, {
      'd': TravelPermitTypes.domestic,
      'i': TravelPermitTypes.international,
    });
  }
}

//-------------------------------------------------------------------

enum ParticipantEntities {
  guardian,
  escort,
  underage,
}

extension ParticipantEntitiesExt on ParticipantEntities {
  static ParticipantEntities? fromString(String value) {
    return _EnumCommonParser.parse(value, null, {
      'g': ParticipantEntities.guardian,
      'e': ParticipantEntities.escort,
      'u': ParticipantEntities.underage,
    });
  }
}

//-------------------------------------------------------------------

enum BioGenders {
  male,
  female,
  others,
  undefined,
}

extension BioGendersExt on BioGenders {
  static BioGenders? fromString(String? value) {
    return _EnumCommonParser.parse(value, BioGenders.undefined, {
      'm': BioGenders.male,
      'f': BioGenders.female,
      'o': BioGenders.others,
      'u': BioGenders.undefined,
    });
  }
}

//-------------------------------------------------------------------

enum LegalGuardianTypes {
  mother,
  father,
  tutor,
  guardian,
  thirdPartyRelated,
  thirdPartyNotRelated,
}

extension LegalGuardianTypesExt on LegalGuardianTypes {
  static LegalGuardianTypes? fromString(String? value) {
    return _EnumCommonParser.parse(value, null, {
      'm': LegalGuardianTypes.mother,
      'f': LegalGuardianTypes.father,
      't': LegalGuardianTypes.tutor,
      'g': LegalGuardianTypes.guardian,
      'r': LegalGuardianTypes.thirdPartyRelated,
      's': LegalGuardianTypes.thirdPartyNotRelated,
    });
  }
}

//-------------------------------------------------------------------

enum IdDocumentTypes {
  idCard,
  professionalCard,
  passport,
  reservistCard,
  rne,
  birthCertificate,
}

extension IdDocumentTypesExt on IdDocumentTypes {
  static IdDocumentTypes? fromString(String? value) {
    return _EnumCommonParser.parse(value, null, {
      'i': IdDocumentTypes.idCard,
      't': IdDocumentTypes.professionalCard,
      'p': IdDocumentTypes.passport,
      'r': IdDocumentTypes.reservistCard,
      'e': IdDocumentTypes.rne,
      'c': IdDocumentTypes.birthCertificate,
    });
  }
}

//-------------------------------------------------------------------

enum CnbErrorCodes {
  documentInvalidKey,
  documentIsDeleted,
  travelPermitNotEnabled,
  travelPermitInfoMissing,
  travelPermitNotConcluded,
  documentIsNotTravelPermit,
  unknown,
}

extension CnbErrorCodesExt on CnbErrorCodes {
  static CnbErrorCodes fromString(String value) {
    return _EnumCommonParser.parse(value, CnbErrorCodes.unknown, {});
  }
}

//-------------------------------------------------------------------

enum ParticipantTypes {
  guardian1,
  guardian2,
  escort,
  underage,
  judge,
}

//-------------------------------------------------------------------

class _EnumCommonParser {
  static T? parse<T>(String? value, T? defaultValue, Map<String, T> parseMap) {
    var type = null;
    try {
      type = parseMap.values.firstWhere(
          (t) => t.toString().toLowerCase() == '$T.$value'.toLowerCase(),
          orElse: () => defaultValue!,
      );
    } catch (_) {
      type = defaultValue;
    }
    if (type != defaultValue) {
      return type;
    }
    return parseMap[value?.toLowerCase()] ?? defaultValue;
  }
}
