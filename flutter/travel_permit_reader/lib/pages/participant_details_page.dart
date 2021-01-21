import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travel_permit_reader/api/enums.dart';
import 'package:travel_permit_reader/api/models.dart';
import 'package:travel_permit_reader/pages/travel_permit_page.dart';
import 'package:travel_permit_reader/util/page_util.dart';

class ParticipantDetailsPage extends SummaryCard {
  const ParticipantDetailsPage({Key key, TypedParticipant typedParticipant})
      : super(key: key, typedParticipant: typedParticipant);

  String get guardianshipDescription {
    switch ((model as GuardianModel).guardianship) {
      case LegalGuardianTypes.father:
        return 'Pai';
      case LegalGuardianTypes.guardian:
        return 'Responável';
      case LegalGuardianTypes.mother:
        return 'Mãe';
      case LegalGuardianTypes.tutor:
        return 'Tutor';
      default:
        return 'Indefinido';
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> details = [
      getLabelText('Nome'),
      getDetailsText(model.name),
      if (!StringExt.isNullOrEmpty(model.identifier)) getPicture(),
      getDivider(),
    ];
    if (!StringExt.isNullOrEmpty(model.identifier)) {
      details.addAll([
        getLabelText('Id'),
        getDetailsText(model.identifier),
        getDivider(),
      ]);
    }

    details.addAll([
      getLabelText(documentTypeDescription),
      getDetailsText(
          '${model.documentNumber} (${model.documentIssuer})\nEmitido em ${model.issueDate.toDateString()}'),
      getDivider(),
    ]);

    if (model is GuardianModel) {
      details.addAll(getGuardianDetails());
    }

    if (model is AdultModel) {
      details.addAll(getAdultDetails());
    }

    if (model is UnderageModel) {
      details.addAll(getUnderageDetails());
    }

    details.add(SizedBox(height: 30));

    return Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: Padding(
            padding: EdgeInsets.fromLTRB(20, 30, 20, 20),
            child: SingleChildScrollView(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back),
                      color: Colors.black54,
                      iconSize: 30,
                    ),
                  ],
                ),
                ...details
              ],
            ))));
  }

  List<Widget> getAdultDetails() {
    final adult = model as AdultModel;
    List<Widget> details = [];

    if (!StringExt.isNullOrEmpty(adult.email)) {
      details.addAll([
        getLabelText('Email'),
        getDetailsText(adult.email),
        getDivider(),
      ]);
    }

    if (!StringExt.isNullOrEmpty(adult.phoneNumber)) {
      details.addAll([
        getLabelText('Telefone'),
        getDetailsText(adult.phoneNumber),
        getDivider(),
      ]);
    }

    if ([
      adult.streetAddress,
      adult.addressNumber,
      adult.additionalAddressInfo,
      adult.neighborhood,
      adult.addressCity,
      adult.addressState
    ].any((s) => !StringExt.isNullOrEmpty(s))) {
      details.addAll([
        getLabelText('Endereço'),
        getDetailsText('${adult.streetAddress} ${adult.addressNumber}' +
            '${!StringExt.isNullOrEmpty(adult.additionalAddressInfo) ? '\n' + adult.additionalAddressInfo : ''}' +
            '${!StringExt.isNullOrEmpty(adult.neighborhood) ? '\n' + adult.neighborhood : ''}' +
            '${!StringExt.isNullOrEmpty(adult.addressCity + adult.addressState) ? '\n' + adult.addressCity + ' - ' + adult.addressState : ''}'),
      ]);
    }

    return details;
  }

  List<Widget> getGuardianDetails() {
    return [
      getLabelText('Tipo de responsável'),
      getDetailsText(guardianshipDescription),
      getDivider(),
    ];
  }

  List<Widget> getUnderageDetails() {
    final underage = model as UnderageModel;
    List<Widget> details = [];

    if (underage.bioGender != null) {
      details.addAll([
        getLabelText('Gênero Biológico'),
        getDetailsText(bioGenderDescription),
        getDivider(),
      ]);
    }

    if (underage.birthDate != null ||
        [underage.cityOfBirth, underage.stateOfBirth]
            .any((s) => !StringExt.isNullOrEmpty(s))) {
      details.addAll([
        getLabelText('Nascimento'),
        getDetailsText('${underage.birthDate.toDateString()}' +
            (!StringExt.isNullOrEmpty(
                    underage.cityOfBirth + underage.stateOfBirth)
                ? '\n${underage.cityOfBirth} - ${underage.stateOfBirth}'
                : '')),
        getDivider(),
      ]);
    }
    return details;
  }

  Widget getLabelText(String label) {
    return Padding(
        padding: EdgeInsets.only(top: 5, bottom: 5),
        child: Text(label.toUpperCase(),
            style: TextStyle(
                fontSize: 15,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w400,
                color: Colors.black45)));
  }

  Widget getDetailsText(String detail) {
    return Padding(
        padding: EdgeInsets.only(left: 10, bottom: 2),
        child: Text(detail ?? '',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)));
  }

  Widget getPicture() {
    String imgname;
    switch (model.identifier) {
      case '09197689890':
        imgname = 'homer';
        break;
      case '30619285966':
        imgname = 'marge';
        break;
      case '97627993300':
        imgname = 'bart';
        break;
      case '51846064163':
        imgname = 'flanders';
        break;
      default:
        imgname = null;
    }
    if (imgname == null) {
      return Container();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 10, bottom: 5),
          child: Image.asset(
            "assets/img/$imgname.png",
            height: 150,
          ),
        ),
      ],
    );
  }
}
