import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'package:path/path.dart' as p;
import 'package:travel_permit_reader/api/enums.dart';
import 'package:travel_permit_reader/api/models.dart';
import 'package:travel_permit_reader/api/cnb_client.dart';
import 'package:travel_permit_reader/api/notification_api.dart';
import 'package:travel_permit_reader/pages/notary_details_page.dart';
import 'package:travel_permit_reader/pages/participant_details_page.dart';
import 'package:travel_permit_reader/util/page_util.dart';

import '../tp_exception.dart';

class TravelPermitPage extends StatefulWidget {
  final TravelPermitModel model;
  final dynamic onlineRequestException;

  TravelPermitPage(this.model, {this.onlineRequestException});

  @override
  _TravelPermitPageState createState() => _TravelPermitPageState();
}

//-------------------------------------------------------------------

class _TravelPermitPageState extends State<TravelPermitPage> {
  String get typeDescription {
    switch (widget.model.type) {
      case TravelPermitTypes.domestic:
        return 'Viagem Nacional';
      case TravelPermitTypes.international:
        return 'Viagem Internacional';
      default:
        return null;
    }
  }

  CnbClient _cnbClient;
  CnbClient get cnbClient {
    return _cnbClient ??= CnbClient(widget.model.key);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    if (widget.model.isOffline && widget.onlineRequestException != null) {
      SchedulerBinding.instance.addPostFrameCallback(
          (_) => _handleError(widget.onlineRequestException));
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

    return BackgroundScaffold(
        body: Column(children: <Widget>[
      Container(
        height: PageUtil.getScreenHeight(context, 0.06),
      ),
      Container(
          height: PageUtil.getScreenHeight(context, 0.94),
          width: PageUtil.getScreenWidth(context),
          padding: EdgeInsets.fromLTRB(8, 16, 8, 8),
          decoration: new BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topRight: Radius.circular(80.0)),
          ),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(8, 0, 8, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back),
                        color: AppTheme.primaryBgColor,
                        iconSize: 28,
                      ),
                      Text(
                        'Autorização de viagem',
                        style: AppTheme.barTiteStyle,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(0, 4, 14, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () async {
                              final path =
                                  await cnbClient.getTravelPermitPdfPrivate();
                              if (path == null) return;

                              Share.shareFiles([path],
                                  mimeTypes: ["application/pdf"],
                                  subject: "Autorização de Viagem - PDF",
                                  text: "Compartilhar AEV");
                            },
                            icon: Icon(Icons.share_outlined),
                            color: AppTheme.primaryBgColor,
                            iconSize: 30,
                          ),
                          IconButton(
                            onPressed: () async {
                              final path =
                                  await cnbClient.getTravelPermitPdfPublic();
                              if (path == null) return;

                              NotificationApi.showNotification(
                                  title: p.basename(path),
                                  body: 'Download completed.',
                                  payload: path);
                            },
                            icon: Icon(Icons.download_outlined),
                            color: AppTheme.primaryBgColor,
                            iconSize: 30,
                          ),
                        ],
                      ),
                      Padding(
                          padding: EdgeInsets.only(right: 9),
                          child: Icon(
                              widget.model.isOffline
                                  ? Icons.wifi_off
                                  : Icons.wifi,
                              size: 30,
                              color: widget.model.isOffline
                                  ? AppTheme.alertColor
                                  : AppTheme.successColor)),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
                child: ListView(padding: EdgeInsets.zero, children: [
              _buildPermitValidityState(),
              _buildTravelPermitType(),
              for (final p in participants)
                SummaryCard(
                    typedParticipant: p, isOffline: widget.model.isOffline),
              if (widget.model.notary != null) _buildNotaryInfo(context),
            ])),
          ]))
    ]));
  }

  void _handleError(dynamic ex) {
    final title = 'Exibindo dados offline';
    var message = '$ex';

    if (ex is TPException) {
      switch (ex.code) {
        case TPErrorCodes.cnbClientDecodeResponseError:
          message = 'Erro ao ler resposta do servidor';
          break;
        case TPErrorCodes.cnbClientRequestError:
          message =
              'Não foi possível se comunicar com o servidor. Por favor verifique sua conexão.';
          break;
        case TPErrorCodes.cnbClientResponseError:
          message = ex.message;
          break;
        case TPErrorCodes.documentNotFound:
          message = 'Autorização de viagem não encontrada no servidor';
          break;
        default:
          break;
      }
    }

    PageUtil.showAppDialog(context, title, message);
  }

  Widget _buildTravelPermitType() {
    return BaseCard(
        color: AppTheme.accentFgColor,
        child: Row(children: [
          Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(
                Icons.card_travel,
                size: 30,
                color: AppTheme.defaultFgColor,
              )),
          Text(typeDescription)
        ]));
  }

  Widget _buildPermitValidityState() {
    final now = DateTime.now();
    final isExpired = now.isAfterDateOnly(widget.model.expirationDate) ||
        (widget.model.startDate != null &&
            now.isBefore(widget.model.startDate));
    return BaseCard(
        color: isExpired ? AppTheme.alertColor : AppTheme.successColor,
        child: Row(children: [
          Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(
                isExpired ? Icons.event_busy : Icons.event_available,
                size: 30,
                color: Colors.white,
              )),
          RichText(
            text: new TextSpan(
              style: new TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.white),
              children: widget.model.startDate == null
                  ? <TextSpan>[
                      new TextSpan(
                          text: isExpired ? 'Expirou em ' : 'Vigente até '),
                      new TextSpan(
                          text:
                              '${widget.model.expirationDate.toLocal().toDateString()}',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ]
                  : <TextSpan>[
                      new TextSpan(
                          text: isExpired
                              ? 'Fora do período de '
                              : 'Vigente de '),
                      new TextSpan(
                          text:
                              '${widget.model.startDate.toLocal().toDateString()} à ${widget.model.expirationDate.toLocal().toDateString()}',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ],
            ),
          )
        ]));
  }

  Widget _buildNotaryInfo(context) {
    return BaseCard(
        color: AppTheme.accentFgColor,
        child: InkWell(
            splashColor: AppTheme.primaryFgColor.withAlpha(50),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (c) => NotaryDetailsPage(
                          notaryModel: widget.model.notary,
                        ))),
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
                              Icons.verified,
                              size: 30,
                              color: AppTheme.defaultFgColor,
                            )),
                        Text(
                          "CARTÓRIO EMISSOR",
                          style: AppTheme.headline2Style,
                        ),
                      ]),
                      Icon(Icons.more_vert,
                          size: 20, color: AppTheme.primaryFgColor),
                    ]),
                buildDivider(),
                SizedBox(height: 4),
                Text(widget.model.notary.name,
                    style: AppTheme.bodyStyle, overflow: TextOverflow.ellipsis),
                SizedBox(height: 4),
                Text('CNS: ${widget.model.notary.cns}',
                    textAlign: TextAlign.left, style: AppTheme.body2Sytle),
              ],
            )));
  }
}

//-------------------------------------------------------------------

class BaseCard extends StatelessWidget {
  final Color color;
  final Widget child;

  const BaseCard({Key key, this.color, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Card(
            color: color,
            elevation: 0,
            child: Padding(padding: EdgeInsets.all(12), child: child)));
  }
}

//-------------------------------------------------------------------

class SummaryCard extends StatelessWidget {
  final TypedParticipant typedParticipant;
  final bool isOffline;

  const SummaryCard({Key key, this.typedParticipant, this.isOffline})
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
      case IdDocumentTypes.idCard:
        return 'RG';
      case IdDocumentTypes.professionalCard:
        return 'CTPS';
      case IdDocumentTypes.passport:
        return 'Passaporte';
      case IdDocumentTypes.reservistCard:
        return 'Reservista';
      case IdDocumentTypes.rne:
        return 'RN de Extrangeiro';
      case IdDocumentTypes.birthCertificate:
        return 'Certidão de Nascimento';
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

    return BaseCard(
        color: AppTheme.accentFgColor,
        child: wrapTappable(
            context,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Padding(
                            padding: EdgeInsets.only(right: 8),
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
                      if (!isOffline)
                        Icon(Icons.more_vert,
                            size: 20, color: AppTheme.primaryFgColor)
                    ]),
                buildDivider(),
                SizedBox(height: 4),
                Text(model.name, style: AppTheme.bodyStyle),
                SizedBox(height: 8),
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
            )));
  }
}

Divider buildDivider() {
  return Divider(
    color: AppTheme.defaultFgColor,
  );
}
