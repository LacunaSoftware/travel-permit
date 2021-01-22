import 'package:cached_network_image/cached_network_image.dart';
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
    if (model is! GuardianModel) {
      return '';
    }
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
      buildLabelText('Nome'),
      buildDetailsText(model.name),
      buildPicture(),
      buildDivider(),
    ];
    if (!StringExt.isNullOrEmpty(model.identifier)) {
      details.addAll([
        buildLabelText('Id'),
        buildDetailsText(model.identifier),
        buildDivider(),
      ]);
    }

    details.addAll([
      buildLabelText(documentTypeDescription),
      buildDetailsText(
          '${model.documentNumber} (${model.documentIssuer})\nEmitido em ${model.issueDate.toDateString()}'),
      buildDivider(),
    ]);

    if (model is GuardianModel) {
      details.addAll(buildGuardianDetails());
    }

    if (model is AdultModel) {
      details.addAll(buildAdultDetails());
    }

    if (model is UnderageModel) {
      details.addAll(buildUnderageDetails());
    }

    details.add(SizedBox(height: 30));

    return BackgroundScaffold(
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
                      color: AppTheme.defaultFgColor,
                    ),
                  ],
                ),
                ...details
              ],
            ))));
  }

  List<Widget> buildAdultDetails() {
    final adult = model as AdultModel;
    List<Widget> details = [];

    if (!StringExt.isNullOrEmpty(adult.email)) {
      details.addAll([
        buildLabelText('Email'),
        buildDetailsText(adult.email),
        buildDivider(),
      ]);
    }

    if (!StringExt.isNullOrEmpty(adult.phoneNumber)) {
      details.addAll([
        buildLabelText('Telefone'),
        buildDetailsText(adult.phoneNumber),
        buildDivider(),
      ]);
    }

    // Address
    if ([
      adult.streetAddress,
      adult.addressNumber,
      adult.additionalAddressInfo,
      adult.neighborhood,
      adult.addressCity,
      adult.addressState
    ].any((s) => !StringExt.isNullOrEmpty(s))) {
      details.addAll([
        buildLabelText('Endereço'),
        buildDetailsText('${adult.streetAddress} ${adult.addressNumber}' +
            '${!StringExt.isNullOrEmpty(adult.additionalAddressInfo) ? '\n' + adult.additionalAddressInfo : ''}' +
            '${!StringExt.isNullOrEmpty(adult.neighborhood) ? '\n' + adult.neighborhood : ''}' +
            '${!StringExt.isNullOrEmpty(adult.addressCity + adult.addressState) ? '\n' + adult.addressCity + ' - ' + adult.addressState : ''}'),
      ]);
    }

    return details;
  }

  List<Widget> buildGuardianDetails() {
    return [
      buildLabelText('Tipo de responsável'),
      buildDetailsText(guardianshipDescription),
      buildDivider(),
    ];
  }

  List<Widget> buildUnderageDetails() {
    final underage = model as UnderageModel;
    List<Widget> details = [];

    if (underage.bioGender != null) {
      details.addAll([
        buildLabelText('Gênero Biológico'),
        buildDetailsText(bioGenderDescription),
        buildDivider(),
      ]);
    }

    if (underage.birthDate != null ||
        [underage.cityOfBirth, underage.stateOfBirth]
            .any((s) => !StringExt.isNullOrEmpty(s))) {
      details.addAll([
        buildLabelText('Nascimento'),
        buildDetailsText('${underage.birthDate.toDateString()}' +
            (!StringExt.isNullOrEmpty(
                    underage.cityOfBirth + underage.stateOfBirth)
                ? '\n${underage.cityOfBirth} - ${underage.stateOfBirth}'
                : '')),
        buildDivider(),
      ]);
    }
    return details;
  }

  Widget buildLabelText(String label) {
    return Padding(
        padding: EdgeInsets.only(top: 5, bottom: 5),
        child: Text(label.toUpperCase(), style: AppTheme.headlineStyle));
  }

  Widget buildDetailsText(String detail) {
    return Padding(
        padding: EdgeInsets.only(left: 10, bottom: 2),
        child: Text(detail ?? '', style: AppTheme.bodyStyle));
  }

  Widget buildPicture() {
    return Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 5),
        child: Container(
          height: 150,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              StringExt.isNullOrEmpty(model.photoUrl)
                  ? Image.asset(
                      "assets/img/participant-placeholder.png",
                      fit: BoxFit.contain,
                    )
                  : CachedNetworkImage(
                      imageUrl: model.photoUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.error, size: 50),
                    )
            ],
          ),
        ));
  }
}
