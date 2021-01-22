import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travel_permit_reader/api/enums.dart';
import 'package:travel_permit_reader/api/models.dart';
import 'package:travel_permit_reader/pages/participant_details_page.dart';
import 'package:travel_permit_reader/util/page_util.dart';

class TravelPermitPage extends StatefulWidget {
  final TravelPermitModel model;

  TravelPermitPage(this.model);

  @override
  _TravelPermitPageState createState() => _TravelPermitPageState();
}

class _TravelPermitPageState extends State<TravelPermitPage> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

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

    return BackgroundScaffold(
        imagePath: 'assets/img/bg_global_grey.svg',
        body: Padding(
          padding: EdgeInsets.fromLTRB(10, 30, 10, 0),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back),
                  color: AppTheme.defaultFgColor,
                ),
                Text(
                  'Autorização de viagem',
                  style: AppTheme.barTiteStyle,
                ),
                Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(
                        widget.model.isOffline ? Icons.wifi_off : Icons.wifi,
                        size: 30,
                        color: widget.model.isOffline
                            ? AppTheme.alertColor
                            : AppTheme.primaryFgColor)),
              ],
            ),
            _buildPermitValidityState(),
            Expanded(
                child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 5),
              itemCount: participants.length,
              itemBuilder: (context, index) => SummaryCard(
                  typedParticipant: participants[index],
                  index: index,
                  isOffline: widget.model.isOffline),
            ))
          ]),
        ));
  }

  Widget _buildPermitValidityState() {
    final isExpired = DateTime.now().isAfter(widget.model.expirationDate);
    return Card(
      color: isExpired ? AppTheme.alertColor : AppTheme.successColor,
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(
                isExpired ? Icons.event_busy : Icons.event_available,
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
                new TextSpan(text: isExpired ? 'Expirou em ' : 'Vigente até '),
                new TextSpan(
                    text:
                        '${widget.model.expirationDate.toLocal().toDateString()}',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          )
        ]),
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final TypedParticipant typedParticipant;
  final bool isOffline;
  final int index;

  const SummaryCard(
      {Key key, this.typedParticipant, this.isOffline, this.index})
      : super(key: key);

  ParticipantModel get model => typedParticipant.participant;

  String get participantDescription {
    switch (typedParticipant.type) {
      case ParticipantTypes.guardian1:
        return 'Responsável';
      case ParticipantTypes.guardian2:
        return 'Responsável 2';
      case ParticipantTypes.escort:
        return 'Acompanhante';
      case ParticipantTypes.underage:
        return 'Menor';
      default:
        return '';
    }
  }

  IconData get participantIcon {
    switch (typedParticipant.type) {
      case ParticipantTypes.guardian1:
      case ParticipantTypes.guardian2:
        return Icons.person;
      case ParticipantTypes.escort:
        return Icons.escalator_warning;
      case ParticipantTypes.underage:
        return Icons.child_care;
      default:
        return null;
    }
  }

  String get documentTypeDescription {
    switch (model.documentType) {
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

  String get bioGenderDescription {
    if (model is! UnderageModel) {
      return '';
    }
    switch ((model as UnderageModel).bioGender) {
      case BioGenders.female:
        return 'Feminino';
      case BioGenders.male:
        return 'Masculino';
      default:
        return 'Indefinido';
    }
  }

  Widget wrapTappable(BuildContext context, Widget child) {
    return isOffline
        ? Container(child: child)
        : InkWell(
            splashColor: AppTheme.primaryFgColor.withAlpha(50),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (c) => ParticipantDetailsPage(
                          key: key,
                          typedParticipant: typedParticipant,
                        ))),
            child: child);
  }

  @override
  Widget build(BuildContext context) {
    final underage = typedParticipant.type == ParticipantTypes.underage
        ? model as UnderageModel
        : null;

    return Padding(
        padding: EdgeInsets.only(bottom: 5),
        child: Card(
            elevation: 4,
            child: wrapTappable(
                context,
                Padding(
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
                                      participantIcon,
                                      size: 30,
                                      color: AppTheme.defaultFgColor,
                                    )),
                                Text(
                                  participantDescription.toUpperCase(),
                                  style: AppTheme.headline2Style,
                                )
                              ]),
                              if (isOffline)
                                Icon(Icons.more_vert,
                                    size: 20, color: AppTheme.primaryFgColor)
                            ]),
                        getDivider(),
                        SizedBox(height: 2),
                        Text(model.name, style: AppTheme.bodyStyle),
                        SizedBox(height: 5),
                        Text(
                            '$documentTypeDescription: ${model.documentNumber} (${model.documentIssuer})',
                            textAlign: TextAlign.left,
                            style: AppTheme.body2Sytle),
                        if (underage?.birthDate != null)
                          Text(
                              'Nascimento: ${underage.birthDate.toDateString()} ${underage?.bioGender != BioGenders.undefined ? '\n' + bioGenderDescription : ''}',
                              textAlign: TextAlign.left,
                              style: AppTheme.body2Sytle),
                      ],
                    )))));
  }

  Divider getDivider() {
    return Divider(
      color: Colors.black38,
    );
  }
}
