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
        buildLabelText('CPF'),
        buildDetailsText(StringExt.formatCpf(model.identifier)),
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
                      color: AppTheme.primaryBgColor,
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

    details.addAll(buildAddress());

    return details;
  }

  List<Widget> buildAddress() {
    List<Widget> details = [];
    if ([
      model.streetAddress,
      model.addressNumber,
      model.additionalAddressInfo,
      model.neighborhood,
      model.addressCity,
      model.addressState
    ].any((s) => !StringExt.isNullOrEmpty(s))) {
      details.addAll([
        buildLabelText('Endereço'),
        buildDetailsText('${model.streetAddress} ${model.addressNumber}' +
            '${!StringExt.isNullOrEmpty(model.additionalAddressInfo) ? '\n' + model.additionalAddressInfo : ''}' +
            '${!StringExt.isNullOrEmpty(model.neighborhood) ? '\n' + model.neighborhood : ''}' +
            '${!StringExt.isNullOrEmpty(model.addressCity + model.addressState) ? '\n' + model.addressCity + ' - ' + model.addressState : ''}'),
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

    details.addAll(buildAddress());

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
