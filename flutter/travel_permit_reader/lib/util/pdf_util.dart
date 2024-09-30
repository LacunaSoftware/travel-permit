import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart' as d;
import 'package:travel_permit_reader/api/enums.dart';
import 'package:travel_permit_reader/api/models.dart';
import 'package:travel_permit_reader/api/cnb_client.dart';
import 'package:travel_permit_reader/util/file_util.dart';
import 'package:travel_permit_reader/util/page_util.dart';
import 'package:travel_permit_reader/util/permission_util.dart';

class PdfUtil {
  TravelPermitModel _model;
  JudiciaryTravelPermitModel? _judiciaryModel;
  File? _pdf;

  CnbClient? _cnbClient;
  CnbClient get cnbClient {
    return _cnbClient ??= CnbClient();
  }

  PdfUtil(this._model, this._judiciaryModel);

  Future<String?> getTravelPermitPdfPrivate() async {
    if (_pdf == null || !await _pdf!.exists()) _pdf = await getTravelPermitPdf(true);

    return _pdf?.path;
  }

  Future<String?> getTravelPermitPdfPublic() async {
    if (_pdf == null || !await _pdf!.exists()) {
      _pdf = await PermissionUtil.checkStoragePermission() ? await getTravelPermitPdf(false) : null;
    } else {
      _pdf = await FileUtil.moveToPublic(_pdf!);
    }

    return _pdf?.path;
  }

  Future<File> getTravelPermitPdf(bool isTemp) async => _model.isOffline ? generateTravelPermitOffline(isTemp) : FileUtil.createFromResponse(await cnbClient.getTravelPermitPdfRequest(_model.key), "Autorização de Viagem - ${_model.key}.pdf", isTemp);

  Future<File> generateTravelPermitOffline(bool isTemp) async {
    // Initialising variables
    final isInternational = _model.type == TravelPermitTypes.international;
    final startDate = _model.startDate?.toLocal().toDateString();
    final expirationDate = _model.expirationDate.toLocal().toDateString();
    final isAuthorizedByJudge = _judiciaryModel?.judge?.name != null && _judiciaryModel?.notary?.name != null;

    final helvetica = pw.Font.helvetica();
    final font11 = pw.TextStyle(font: helvetica, fontSize: 11);
    final font12 = pw.TextStyle(font: helvetica, fontSize: 12);
    final bold12 = pw.TextStyle(font: pw.Font.helveticaBold(), fontSize: 12);

    final List<pw.Widget> doc = [];

    // Adding Brazilian Logo
    doc.add(pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [await getImage('brasil_logo.png', width: 70, height: 70)]));

    // Adding Title
    doc.add(pw.Paragraph(text: 'AUTORIZAÇÃO DE VIAGEM ${isInternational ? "INTERNACIONAL" : "NACIONAL"}', textAlign: pw.TextAlign.center, style: bold12, margin: pw.EdgeInsets.only(top: 10, bottom: 2)));

    // Adding Description
    doc.add(pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, crossAxisAlignment: pw.CrossAxisAlignment.start, children: [pw.Text('PARA CRIANÇAS OU ADOLESCENTES - RES.: ${isInternational ? "131/2011" : "295/2019"}-CNJ', style: font11), pw.ConstrainedBox(constraints: pw.BoxConstraints.tightFor(width: 110), child: pw.Text('Válida ${startDate == null ? "" : "de $startDate\n"}até $expirationDate', style: font11, textAlign: pw.TextAlign.right))]));

    // Main Info Paragraph Opening
    final List<pw.TextSpan> personsInfos = [];

    // Judge
    if (isAuthorizedByJudge) {
      addSpan(personsInfos, 'O(a) MM. Juiz(a) de Direito Dr.(a) ', font12);
      addSpan(personsInfos, _judiciaryModel!.judge!.name, bold12);
      addSpan(personsInfos, ', na qualidade de responsável pelo(a) ', font12);
      addSpan(personsInfos, _judiciaryModel!.notary!.name, bold12);
    }

    /// Required Guardian
    if (_model.requiredGuardian != null && !isAuthorizedByJudge) {
      addSpan(personsInfos, 'Eu, ', font12);
    }

    /// Optional Guardian
    if (_model.optionalGuardian != null && !isAuthorizedByJudge) {
      addSpan(personsInfos, ' e eu, ', font12);
      addGuardianInfo(_model.optionalGuardian!, personsInfos, font12, bold12);
    }

    /// We/I authorise
    addSpan(personsInfos, ', ${_model.optionalGuardian != null && !isAuthorizedByJudge ? "AUTORIZAMOS" : "AUTORIZO"} ' + 'a circular livremente ${startDate == null ? "até" : "no período de $startDate a"} $expirationDate' + ', ${isInternational ? "em território internacional," : "dentro do território nacional,"} ', font12);

    if (_model.escort == null) {
      addSpan(personsInfos, 'desacompanhado(a), ', font12);
    }

    /// Underage
    if (_model.underage != null) {
      addSpan(personsInfos, _model.underage!.name, bold12);
      addSpan(personsInfos, ', nascido(a) em ${_model.underage!.birthDate?.toLocal().toDateString()}', font12);
      addSpan(personsInfos, ', sexo ${getGenderStr(_model.underage!.bioGender)}', font12);
      addDocumentPhrase(_model.underage!, personsInfos, font12);
    }

    /// Escort
    if (_model.escort != null) {
      addSpan(personsInfos, isInternational ? ', na companhia de ' : ', desde que acompanhada(o) de ', font12);
      addSpan(personsInfos, _model.escort!.name, bold12);
      if (_model.escort!.guardianship != null) {
        addSpan(personsInfos, ', na qualidade de ', font12);
        addSpan(personsInfos, '${getResponsibilityStr(_model.escort!.guardianship)}', bold12);
      }

      addDocumentPhrase(_model.escort!, personsInfos, font12);
    }

    addSpan(personsInfos, '.', font12);

    // Main Info Paragraph Closure
    doc.add(pw.Padding(padding: pw.EdgeInsets.only(top: 20), child: pw.RichText(text: pw.TextSpan(children: personsInfos))));

    // International Obs.
    if (isInternational) {
      doc.add(pw.Paragraph(text: 'Observação: Salvo se expressamente consignado, este documento não constitui autorização para fixação de residência permanente no exterior.', style: font12, margin: pw.EdgeInsets.only(top: 10)));
    }

    // Emission Date
    d.initializeDateFormatting('pt_BR');
    final dateNow = DateTime.now();
    doc.add(pw.Paragraph(text: "Data de emissão: ${dateNow.day} de ${DateFormat('MMMM', 'pt_BR').format(dateNow)} de ${dateNow.year}", textAlign: pw.TextAlign.center, style: font12, margin: pw.EdgeInsets.only(top: 20, bottom: 25)));

    // CNJ and CNB logos
    doc.add(pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceAround, children: [pw.Text('____________________', style: font12), await getImage('cnj.jpg', width: 25, height: 25), await getImage('logo-cnb.jpg', width: 25, height: 25), pw.Text('____________________', style: font12)]));

    // Validation Code and QRCode
    final List<pw.Widget> codeInfo = [];
    codeInfo.add(pw.Column(children: [pw.Paragraph(text: 'Código de Validação:\n${formatValidationCode(_model.key)}', textAlign: pw.TextAlign.center, style: pw.TextStyle(font: helvetica, fontSize: 10), margin: pw.EdgeInsets.only(top: 10, bottom: 2)), pw.BarcodeWidget(data: _model.qrcodeData!, barcode: pw.Barcode.qrCode(), width: 150, height: 150)]));

    codeInfo.add(pw.Paragraph(text: "A autenticidade desse documento pode ser confirmada no endereço eletrônico https://aev.e-notariado.org.br ou pelo app AEV - Autorização de Viagens e-notariado, disponível nas lojas Google Play ou App Store.", style: font11, margin: pw.EdgeInsets.only(top: 20)));

    // Finishing PDF
    final structure = [pw.Container(child: pw.Column(children: doc), margin: pw.EdgeInsets.fromLTRB(40, 5, 40, 0)), pw.Column(children: codeInfo)];
    final name = "${_model.underage?.name.replaceAll(RegExp(r'[^A-Za-zÀ-ÖØ-öø-ÿ0-9_ -]'), '_')} - Autorização de Viagem.pdf";
    return createFromWidgets(structure, name, isTemp);
  }

  Future<File> createFromWidgets(List<pw.Widget> doc, String pdfName, bool isTemp) async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(pageFormat: PdfPageFormat.a4, margin: pw.EdgeInsets.all(20), build: (pw.Context context) => pw.Column(children: doc, mainAxisAlignment: pw.MainAxisAlignment.spaceBetween)));
    final pdfBytes = await pdf.save();
    return FileUtil.createFromBytes(pdfBytes, pdfName, isTemp);
  }

  Future<pw.Image> getImage(String asset, {required double width, required double height}) async {
    final imgData = await rootBundle.load('assets/img/$asset');
    final memImg = pw.MemoryImage(imgData.buffer.asUint8List());
    return pw.Image(memImg, width: width, height: height);
  }

  void addSpan(List<pw.TextSpan> paragraph, String text, pw.TextStyle font) => paragraph.add(pw.TextSpan(text: text, style: font));

  void addDocumentPhrase(ParticipantModel participant, List<pw.TextSpan> paragraph, pw.TextStyle font) => addSpan(paragraph, ', portador(a) ${getDocumentTypeStr(participant.documentType)} ' + 'nº ${participant.documentNumber}, expedida(o) pela ${participant.documentIssuer}', font);

  void addGuardianInfo(GuardianModel guardian, List<pw.TextSpan> paragraph, pw.TextStyle font, pw.TextStyle bold) {
    addSpan(paragraph, guardian.name, bold);
    addDocumentPhrase(guardian, paragraph, font);
    addSpan(paragraph, ', na qualidade de ', font);
    addSpan(paragraph, getResponsibilityStr(guardian.guardianship), bold);
  }

  String formatValidationCode(String code) {
    final charsPerGroup = code.length ~/ 4;
    return new List<String>.generate(4, (i) {
      final initial = i * charsPerGroup;
      return code.substring(initial, initial + charsPerGroup);
    }).join('-');
  }

  String getDocumentTypeStr(IdDocumentTypes? type) {
    switch (type) {
      case IdDocumentTypes.idCard:
        return "do RG";
      case IdDocumentTypes.professionalCard:
        return "da Carteira profissional";
      case IdDocumentTypes.passport:
        return "do Passaporte";
      case IdDocumentTypes.reservistCard:
        return "da Carteira de reservista";
      case IdDocumentTypes.birthCertificate:
        return "da Certidão de nascimento";
      default:
        return "";
    }
  }

  String getResponsibilityStr(LegalGuardianTypes? type) {
    switch (type) {
      case LegalGuardianTypes.mother:
        return "mãe";
      case LegalGuardianTypes.father:
        return "pai";
      case LegalGuardianTypes.tutor:
        return "tutor";
      case LegalGuardianTypes.guardian:
        return "guardião";
      case LegalGuardianTypes.thirdPartyRelated:
        return "terceiro com parentesco";
      case LegalGuardianTypes.thirdPartyNotRelated:
        return "terceiro sem parentesco";
      default:
        return "";
    }
  }

  String getGenderStr(BioGenders? gender) {
    switch (gender) {
      case BioGenders.male:
        return "masculino";
      case BioGenders.female:
        return "feminino";
      case BioGenders.others:
        return "outros";
      default:
        return "";
    }
  }
}
