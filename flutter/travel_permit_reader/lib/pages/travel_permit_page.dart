import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as p;
import 'package:travel_permit_reader/api/enums.dart';
import 'package:travel_permit_reader/api/models.dart';
import 'package:travel_permit_reader/api/notification_api.dart';
import 'package:travel_permit_reader/pages/notary_details_page.dart';
import 'package:travel_permit_reader/pages/participant_details_page.dart';
import 'package:travel_permit_reader/util/page_util.dart';
import 'package:travel_permit_reader/util/pdf_util.dart';

import '../tp_exception.dart';

class TravelPermitPage extends StatefulWidget {
  final TravelPermitModel model;
  final JudiciaryTravelPermitModel? judiciaryModel;
  final TravelPermitSignatureInfo? signatureInfo;
  final dynamic onlineRequestException;

  TravelPermitPage(this.model, this.judiciaryModel,
      {this.signatureInfo, this.onlineRequestException});

  @override
  _TravelPermitPageState createState() => _TravelPermitPageState();
}

//-------------------------------------------------------------------

class _TravelPermitPageState extends State<TravelPermitPage> {
  String? get typeDescription {
    switch (widget.model.type) {
      case TravelPermitTypes.domestic:
        return 'Viagem Nacional';
      case TravelPermitTypes.international:
        return 'Viagem Internacional';
      default:
        return null;
    }
  }

  PdfUtil? _pdfUtil;
  PdfUtil get pdfUtil {
    return _pdfUtil ??= PdfUtil(widget.model, widget.judiciaryModel);
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
        TypedParticipant(widget.model.escort!, ParticipantTypes.escort),
      if (widget.model.underage != null)
        TypedParticipant(widget.model.underage!, ParticipantTypes.underage),
      if (widget.judiciaryModel?.judge != null)
        TypedParticipant(widget.judiciaryModel!.judge!, ParticipantTypes.judge),
      if (widget.model.requiredGuardian != null)
        TypedParticipant(
            widget.model.requiredGuardian!, ParticipantTypes.guardian1),
      if (widget.model.optionalGuardian != null)
        TypedParticipant(
            widget.model.optionalGuardian!, ParticipantTypes.guardian2),
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
                      Container(
                        width: PageUtil.getScreenWidth(context, 0.55),
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                'Autorização de viagem',
                                style: AppTheme.barTiteStyle,
                              ),
                            ),
                          ],
                        ),
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
                                  await pdfUtil.getTravelPermitPdfPrivate();
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
                                  await pdfUtil.getTravelPermitPdfPublic();
                              if (path == null) return;

                              final didShowNotification =
                                  await NotificationApi.showNotification(
                                      title: p.basename(path),
                                      body: 'Download completed.',
                                      payload: path);
                              if (!didShowNotification) {
                                PageUtil.showAppDialog(
                                    context,
                                    'Download concluído.',
                                    "O download do arquivo foi concluído. Caso queira abrir o arquivo, clique no botão abaixo.",
                                    positiveButton: ButtonAction(
                                        "Abrir", () => OpenFilex.open(path)),
                                    negativeButton: ButtonAction("Voltar"));
                              }
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

  Widget _buildDestinationInfo(bool isDestinationSpecific) {
    final country = widget.judiciaryModel?.destination?.country ?? '';
    final state = widget.judiciaryModel?.destination?.state ?? '';
    final city = widget.judiciaryModel?.destination?.city ?? '';

    final cityState =
        (city.isNotEmpty && state.isNotEmpty) ? '$city, $state' : city + state;

    return isDestinationSpecific
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(country, style: AppTheme.bodyStyle),
                StringExt.isNullOrEmpty(cityState)
                    ? Container()
                    : Text(cityState),
              ],
            ),
          )
        : Container();
  }

  Widget _buildTravelPermitType() {
    final isDestinationSpecific =
        widget.judiciaryModel?.destination?.type == DestinationTypes.specific;

    return BaseCard(
        color: AppTheme.accentFgColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Icon(
                    Icons.card_travel,
                    size: 30,
                    color: AppTheme.defaultFgColor,
                  )),
              Text(typeDescription ?? '')
            ]),
            isDestinationSpecific ? buildDivider() : Container(),
            _buildDestinationInfo(isDestinationSpecific),
          ],
        ));
  }

  Widget _buildPermitValidityState() {
    final now = DateTime.now();
    final isExpired = now.isAfterDateOnly(widget.model.expirationDate) ||
        (widget.model.startDate != null &&
            now.isBeforeDateOnly(widget.model.startDate!));
    final isCanceled = widget.signatureInfo?.isCanceled ?? false;
    return BaseCard(
      color:
          isExpired || isCanceled ? AppTheme.alertColor : AppTheme.successColor,
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(
              isCanceled
                  ? Icons.cancel_outlined
                  : isExpired
                      ? Icons.event_busy
                      : Icons.event_available,
              size: 30,
              color: Colors.white,
            ),
          ),
          Flexible(
            child: RichText(
              text: new TextSpan(
                style: new TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Colors.white),
                children: isCanceled
                    ? <TextSpan>[
                        new TextSpan(
                            text: 'Autorização cancelada',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                      ]
                    : widget.model.startDate == null
                        ? <TextSpan>[
                            new TextSpan(
                                text:
                                    isExpired ? 'Expirou em ' : 'Vigente até '),
                            new TextSpan(
                                text:
                                    '${widget.model.expirationDate.toDateString()}',
                                style: TextStyle(fontWeight: FontWeight.w700)),
                          ]
                        : <TextSpan>[
                            new TextSpan(
                                text: isExpired
                                    ? 'Fora do período de '
                                    : 'Vigente de '),
                            new TextSpan(
                                text:
                                    '${widget.model.startDate?.toDateString()} à ${widget.model.expirationDate.toDateString()}',
                                style: TextStyle(fontWeight: FontWeight.w700)),
                          ],
              ),
            ),
          ),
        ],
      ),
    );
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
                          notaryModel: widget.model.notary!,
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
                Text(widget.model.notary!.name,
                    style: AppTheme.bodyStyle, overflow: TextOverflow.ellipsis),
                SizedBox(height: 4),
                Text('CNS: ${widget.model.notary!.cns}',
                    textAlign: TextAlign.left, style: AppTheme.body2Sytle),
              ],
            )));
  }
}

//-------------------------------------------------------------------

class BaseCard extends StatelessWidget {
  final Color color;
  final Widget child;

  const BaseCard({Key? key, required this.color, required this.child})
      : super(key: key);

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

  const SummaryCard(
      {Key? key, required this.typedParticipant, this.isOffline = false})
      : super(key: key);

  ParticipantModel get model => typedParticipant.participant;

  bool get isJudge {
    return typedParticipant.type == ParticipantTypes.judge;
  }

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
      case ParticipantTypes.judge:
        return 'Juiz autorizador';
      default:
        return '';
    }
  }

  IconData? get participantIcon {
    switch (typedParticipant.type) {
      case ParticipantTypes.guardian1:
      case ParticipantTypes.guardian2:
      case ParticipantTypes.judge:
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
      case BioGenders.others:
        return 'Outros';
      default:
        return 'Indefinido';
    }
  }

  String get getGuardianshipStr {
    if (model is! EscortModel && model is! GuardianModel) {
      return '';
    }

    final guardianship = model is EscortModel
        ? (model as EscortModel).guardianship
        : (model as GuardianModel).guardianship;

    switch (guardianship) {
      case LegalGuardianTypes.mother:
        return "Mãe";
      case LegalGuardianTypes.father:
        return "Pai";
      case LegalGuardianTypes.tutor:
        return "Tutor";
      case LegalGuardianTypes.guardian:
        return "Guardião";
      case LegalGuardianTypes.thirdPartyRelated:
        return "Terceiro com parentesco";
      case LegalGuardianTypes.thirdPartyNotRelated:
        return "Terceiro sem parentesco";
      default:
        return "";
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
                if (documentTypeDescription != '')
                  Text(
                      '$documentTypeDescription: ${model.documentNumber} (${model.documentIssuer})',
                      textAlign: TextAlign.left,
                      style: AppTheme.body2Sytle),
                if (underage?.birthDate != null)
                  Text(
                      'Nascimento: ${underage!.birthDate!.toDateString()} ${underage.bioGender != BioGenders.undefined ? '\n' + bioGenderDescription : ''}',
                      textAlign: TextAlign.left,
                      style: AppTheme.body2Sytle),
                if (getGuardianshipStr.isNotEmpty)
                  Text('Parentesco: ${getGuardianshipStr}',
                      textAlign: TextAlign.left, style: AppTheme.body2Sytle),
              ],
            )));
  }
}

Divider buildDivider() {
  return Divider(
    color: AppTheme.defaultFgColor,
  );
}
