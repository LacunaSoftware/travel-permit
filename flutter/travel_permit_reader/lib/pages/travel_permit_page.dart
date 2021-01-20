import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travel_permit_reader/api/enums.dart';
import 'package:travel_permit_reader/api/models.dart';
import 'package:travel_permit_reader/pages/background.dart';
import 'package:travel_permit_reader/util/page_util.dart';

class TravelPermitPage extends StatefulWidget {
  final TravelPermitModel model;

  TravelPermitPage(this.model);

  @override
  _TravelPermitPageState createState() => _TravelPermitPageState();
}

class _TravelPermitPageState extends State<TravelPermitPage> {
  TypedParticipant selectedParticipant;
  int selectedParticipantIndex;

  void selectParticipant(TypedParticipant selectedParticipant, int index) {
    setState(() {
      this.selectedParticipant = selectedParticipant;
      selectedParticipantIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    if (selectedParticipant != null) {
      return WillPopScope(
          onWillPop: () async => false,
          child: DetailsCard(
            model: selectedParticipant,
            index: selectedParticipantIndex,
            onTap: (m, i) => setState(() => this.selectedParticipant = null),
          ));
    }

    var participants = <TypedParticipant>[
      if (widget.model.escort != null)
        TypedParticipant(widget.model.escort, ParticipantTypes.escort),
      if (widget.model.underage != null)
        TypedParticipant(widget.model.underage, ParticipantTypes.underage),
      if (widget.model.requiredGuardian != null)
        TypedParticipant(
            widget.model.requiredGuardian, ParticipantTypes.guardian1),
      if (widget.model.optionalGuardian != null)
        TypedParticipant(
            widget.model.optionalGuardian, ParticipantTypes.guardian2),
    ];

    return WillPopScope(
        onWillPop: () async => false,
        child: BackgroundScaffold(
            appBar: AppBar(
              titleSpacing: 0.0,
              title: Text(
                'Autorização de viagem',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
              leading: IconButton(
                iconSize: 18.0,
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.blue,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(
                        widget.model.isOffline ? Icons.wifi_off : Icons.wifi,
                        size: 30,
                        color: widget.model.isOffline
                            ? Colors.redAccent
                            : Colors.blue))
              ],
              backgroundColor: Colors.white,
            ),
            color: Color(0xFFF5F5F5),
            imagePath: 'assets/img/bg_global_grey.svg',
            body: Padding(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Column(children: [
                _buildPermitValidityState(),
                Expanded(
                    child: ListView.builder(
                  itemCount: participants.length,
                  itemBuilder: (context, index) => SummaryCard(
                      model: participants[index],
                      index: index,
                      onTap: (m, i) => selectParticipant(m, i),
                      isOffline: widget.model.isOffline),
                ))
              ]),
            )));
  }

  Widget _buildPermitValidityState() {
    final expired = DateTime.now().isAfter(widget.model.expirationDate);
    return Padding(
        padding: EdgeInsets.only(bottom: 5),
        child: Card(
          color: expired ? Color(0xFFFF4444) : Color(0xFF00C851),
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Icon(
                    expired ? Icons.event_busy : Icons.event_available,
                    size: 25,
                    color: Colors.white,
                  )),
              RichText(
                text: new TextSpan(
                  style: new TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.white),
                  children: <TextSpan>[
                    new TextSpan(
                        text: expired ? 'Expirou em ' : 'Vigente até '),
                    new TextSpan(
                        text:
                            '${widget.model.expirationDate.toLocal().toDateString()}',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              )
            ]),
          ),
        ));
  }
}

class SummaryCard extends StatelessWidget {
  final TypedParticipant model;
  final bool isOffline;
  final int index;
  final Function(TypedParticipant model, int index) onTap;

  const SummaryCard(
      {Key key, this.model, this.onTap, this.isOffline, this.index})
      : super(key: key);

  String get _participantDescription {
    if (model is GuardianModel) {
      return 'Responsável${index > 2 ? ' 2' : ''}';
    } else if (model is UnderageModel) {
      return 'Menor';
    } else {
      return 'Acompanhante';
    }
  }

  IconData get _participantIcon {
    if (model is GuardianModel) {
      return Icons.person;
    } else if (model is UnderageModel) {
      return Icons.child_care;
    } else {
      return Icons.escalator_warning;
    }
  }

  String get _documentTypeDescription {
    switch (model.participant.documentType) {
      case BioDocumentTypes.idCard:
        return 'RG';
      case BioDocumentTypes.professionalCard:
        return 'CTPS';
      case BioDocumentTypes.passport:
        return 'Passaporte';
      case BioDocumentTypes.reservistCard:
        return 'Reservista';
      case BioDocumentTypes.rne:
        return 'RN de Extrangeiro';
      default:
        return '';
    }
  }

  String get _bioGenderDescription {
    switch ((model as UnderageModel).bioGender) {
      case BioGenders.female:
        return 'Feminino';
      case BioGenders.male:
        return 'Masculino';
      default:
        return 'Indefinido';
    }
  }

  String get _guardianshipDescription {
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

  Widget wrapTappable(Widget child) {
    return isOffline
        ? Container(child: child)
        : InkWell(
            splashColor: Colors.blue.withAlpha(50),
            onTap: () => onTap(model, index),
            child: child);
  }

  @override
  Widget build(BuildContext context) {
    final underage = model is UnderageModel ? model as UnderageModel : null;
    return Padding(
        padding: EdgeInsets.only(bottom: 5),
        child: Card(
            elevation: 4,
            child: wrapTappable(Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: Icon(
                                  _participantIcon,
                                  size: 30,
                                  color: Colors.black54,
                                )),
                            Text(
                              _participantDescription.toUpperCase(),
                              style: TextStyle(fontSize: 12),
                            )
                          ]),
                          isOffline
                              ? Text('')
                              : Icon(
                                  Icons.more_vert,
                                  size: 20,
                                  color: Colors.lightBlue,
                                )
                        ]),
                    _getDivider(),
                    SizedBox(height: 2),
                    Text(model.participant.name,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                    SizedBox(height: 5),
                    Text(
                        '$_documentTypeDescription: ${model.participant.documentNumber} (${model.participant.documentIssuer})',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black45)),
                    if (underage?.birthDate != null)
                      Text(
                          'Nascimento: ${underage.birthDate.toDateString()} ${underage?.bioGender != BioGenders.undefined ? '\n' + _bioGenderDescription : ''}',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black45)),
                  ],
                )))));
  }

  Divider _getDivider() {
    return Divider(
      color: Colors.black38,
    );
  }
}

class DetailsCard extends SummaryCard {
  const DetailsCard(
      {Key key,
      TypedParticipant model,
      int index,
      Function(TypedParticipant model, int index) onTap})
      : super(key: key, model: model, onTap: onTap, index: index);

  @override
  Widget build(BuildContext context) {
    List<Widget> details = [
      _getLabelText('Nome'),
      _getDetailText(model.participant.name),
      if (!StringExt.isNullOrEmpty(model.participant.identifier)) _getPicture(),
      _getDivider(),
    ];
    if (!StringExt.isNullOrEmpty(model.participant.identifier)) {
      details.addAll([
        _getLabelText('Id'),
        _getDetailText(model.participant.identifier),
        _getDivider(),
      ]);
    }

    details.addAll([
      _getLabelText(_documentTypeDescription),
      _getDetailText(
          '${model.participant.documentNumber} (${model.participant.documentIssuer})\nEmitido em ${model.participant.issueDate.toDateString()}'),
      _getDivider(),
    ]);

    if (model is GuardianModel) {
      details.addAll(_getGuardianDetails());
    }

    if (model is AdultModel) {
      details.addAll(_getAdultDetails());
    }

    if (model is UnderageModel) {
      details.addAll(_getUnderageDetails());
    }

    details.add(SizedBox(height: 30));

    return Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        appBar: AppBar(
          titleSpacing: 0.0,
          title: Text(
            'Detalhes $_participantDescription',
            style: TextStyle(
              color: Colors.blue,
            ),
          ),
          leading: IconButton(
            iconSize: 18.0,
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.blue,
            ),
            onPressed: () => onTap(model, index),
          ),
          backgroundColor: Colors.white,
        ),
        body: Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: SingleChildScrollView(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: details,
            ))));
  }

  List<Widget> _getAdultDetails() {
    final adult = model as AdultModel;
    List<Widget> details = [];

    if (!StringExt.isNullOrEmpty(adult.email)) {
      details.addAll([
        _getLabelText('Email'),
        _getDetailText(adult.email),
        _getDivider(),
      ]);
    }

    if (!StringExt.isNullOrEmpty(adult.phoneNumber)) {
      details.addAll([
        _getLabelText('Telefone'),
        _getDetailText(adult.phoneNumber),
        _getDivider(),
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
        _getLabelText('Endereço'),
        _getDetailText('${adult.streetAddress} ${adult.addressNumber}' +
            '${!StringExt.isNullOrEmpty(adult.additionalAddressInfo) ? '\n' + adult.additionalAddressInfo : ''}' +
            '${!StringExt.isNullOrEmpty(adult.neighborhood) ? '\n' + adult.neighborhood : ''}' +
            '${!StringExt.isNullOrEmpty(adult.addressCity + adult.addressState) ? '\n' + adult.addressCity + ' - ' + adult.addressState : ''}'),
      ]);
    }

    return details;
  }

  List<Widget> _getGuardianDetails() {
    return [
      _getLabelText('Tipo de responsável'),
      _getDetailText(_guardianshipDescription),
      _getDivider(),
    ];
  }

  List<Widget> _getUnderageDetails() {
    final underage = model as UnderageModel;
    List<Widget> details = [];

    if (underage.bioGender != null) {
      details.addAll([
        _getLabelText('Gênero Biológico'),
        _getDetailText(_bioGenderDescription),
        _getDivider(),
      ]);
    }

    if (underage.birthDate != null ||
        [underage.cityOfBirth, underage.stateOfBirth]
            .any((s) => !StringExt.isNullOrEmpty(s))) {
      details.addAll([
        _getLabelText('Nascimento'),
        _getDetailText('${underage.birthDate.toDateString()}' +
            (!StringExt.isNullOrEmpty(
                    underage.cityOfBirth + underage.stateOfBirth)
                ? '\n${underage.cityOfBirth} - ${underage.stateOfBirth}'
                : '')),
        _getDivider(),
      ]);
    }
    return details;
  }

  Widget _getLabelText(String label) {
    return Padding(
        padding: EdgeInsets.only(top: 5, bottom: 5),
        child: Text(label.toUpperCase(),
            style: TextStyle(
                fontSize: 15,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w400,
                color: Colors.black45)));
  }

  Widget _getDetailText(String detail) {
    return Padding(
        padding: EdgeInsets.only(left: 10, bottom: 2),
        child: Text(detail ?? '',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)));
  }

  Widget _getPicture() {
    String imgname;
    switch (model.participant.identifier) {
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
