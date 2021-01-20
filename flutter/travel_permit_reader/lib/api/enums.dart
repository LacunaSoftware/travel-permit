enum ParticipantEntities {
  guardian,
  escort,
  underage,
}

//-------------------------------------------------------------------

enum BioGenders {
  male,
  female,
  undefined,
}

//-------------------------------------------------------------------

enum LegalGuardianTypes {
  mother,
  father,
  tutor,
  guardian,
  undefined,
}

//-------------------------------------------------------------------

enum BioDocumentTypes {
  //[Code("IDC")]
  idCard,
  //[Code("PRC")]
  professionalCard,
  //[Code("PAS")]
  passport,
  //[Code("REC")]
  reservistCard,
  //[Code("RNE")]
  rne,
  undefined,
}

//-------------------------------------------------------------------

class EnumParser {
  static BioGenders gendersFromString(String value) {
    final gender = BioGenders.values.firstWhere(
        (t) => t.toString().toLowerCase() == 'BioGenders.$value'.toLowerCase(),
        orElse: () => BioGenders.undefined);
    if (gender != BioGenders.undefined) {
      return gender;
    }

    switch (value?.toLowerCase()) {
      case 'm':
        return BioGenders.male;
      case 'f':
        return BioGenders.female;
      default:
        return BioGenders.undefined;
    }
  }

  static LegalGuardianTypes guardianTypesFromString(String value) {
    var type = LegalGuardianTypes.values.firstWhere(
        (t) =>
            t.toString().toLowerCase() ==
            'LegalGuardianTypes.$value'.toLowerCase(),
        orElse: () => LegalGuardianTypes.undefined);
    if (type != LegalGuardianTypes.undefined) {
      return type;
    }

    switch (value?.toLowerCase()) {
      case 'm':
        return LegalGuardianTypes.mother;
      case 'f':
        return LegalGuardianTypes.father;
      case 't':
        return LegalGuardianTypes.tutor;
      case 'g':
        return LegalGuardianTypes.guardian;
      default:
        return LegalGuardianTypes.undefined;
    }
  }

  static BioDocumentTypes documentTypesFromString(String value) {
    var type = BioDocumentTypes.values.firstWhere(
        (t) =>
            t.toString().toLowerCase() ==
            'BioDocumentTypes.$value'.toLowerCase(),
        orElse: () => BioDocumentTypes.undefined);
    if (type != BioDocumentTypes.undefined) {
      return type;
    }

    switch (value?.toLowerCase()) {
      case 'i':
        return BioDocumentTypes.idCard;
      case 't':
        return BioDocumentTypes.professionalCard;
      case 'p':
        return BioDocumentTypes.passport;
      case 'r':
        return BioDocumentTypes.reservistCard;
      case 'e':
        return BioDocumentTypes.rne;
      default:
        return BioDocumentTypes.undefined;
    }
  }
}
