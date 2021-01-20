enum TravelPermitTypes {
  domestic,
  international,
}

extension TravelPermitTypesExt on TravelPermitTypes {
  static TravelPermitTypes fromString(String value) {
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
  static ParticipantEntities fromString(String value) {
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
  undefined,
}

extension BioGendersExt on BioGenders {
  static BioGenders fromString(String value) {
    return _EnumCommonParser.parse(value, BioGenders.undefined, {
      'm': BioGenders.male,
      'f': BioGenders.female,
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
}

extension LegalGuardianTypesExt on LegalGuardianTypes {
  static LegalGuardianTypes fromString(String value) {
    return _EnumCommonParser.parse(value, null, {
      'm': LegalGuardianTypes.mother,
      'f': LegalGuardianTypes.father,
      't': LegalGuardianTypes.tutor,
      'g': LegalGuardianTypes.guardian,
    });
  }
}

//-------------------------------------------------------------------

enum BioDocumentTypes {
  idCard,
  professionalCard,
  passport,
  reservistCard,
  rne,
}

extension BioDocumentTypesExt on BioDocumentTypes {
  static BioDocumentTypes fromString(String value) {
    return _EnumCommonParser.parse(value, null, {
      'i': BioDocumentTypes.idCard,
      't': BioDocumentTypes.professionalCard,
      'p': BioDocumentTypes.passport,
      'r': BioDocumentTypes.reservistCard,
      'e': BioDocumentTypes.rne,
    });
  }
}

//-------------------------------------------------------------------

enum ParticipantTypes {
  guardian1,
  guardian2,
  escort,
  underage,
}

//-------------------------------------------------------------------

class _EnumCommonParser {
  static T parse<T>(String value, T defaultValue, Map<String, T> parseMap) {
    var type = parseMap.values.firstWhere(
        (t) => t.toString().toLowerCase() == '$T.$value'.toLowerCase(),
        orElse: () => defaultValue);
    if (type != defaultValue) {
      return type;
    }
    return parseMap[value.toLowerCase()] ?? defaultValue;
  }
}
