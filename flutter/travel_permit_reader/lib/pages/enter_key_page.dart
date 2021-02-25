import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:travel_permit_reader/util/page_util.dart';

class EnterKeyPage extends StatefulWidget {
  @override
  _EnterKeyPageState createState() => _EnterKeyPageState();
}

//-------------------------------------------------------------------

class _EnterKeyPageState extends State<EnterKeyPage> {
  final _formKey = GlobalKey<FormState>();
  final focusnode = FocusNode();
  final maskFormatter = new MaskTextInputFormatter(
      mask: '#####-#####-#####-#####', filter: {"#": RegExp(r'[A-Z0-9]')});
  bool focused = false;
  String _documentKey;

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 1),
        () => FocusScope.of(context).requestFocus(focusnode));

    var codeFieldSection = TextFormField(
      textInputAction: TextInputAction.go,
      onFieldSubmitted: (value) => _submit(value),
      focusNode: focusnode,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 16),
      decoration: InputDecoration(
          labelText: 'Código',
          hintText: '00000-00000-00000-00000',
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)))),
      keyboardType: TextInputType.text,
      inputFormatters: [new UpperCaseTextFormatter(), maskFormatter],
      validator: (value) {
        if (value.isEmpty) {
          return 'Digite o código';
        }
        return null;
      },
      onSaved: (value) {
        _documentKey = maskFormatter.getUnmaskedText();
      },
    );

    final submitButtonSection = Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: FlatButton(
        onPressed: () => _submit(),
        minWidth: PageUtil.getScreenHeight(context, 0.80),
        height: 48,
        color: AppTheme.primaryBgColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(444.0)),
        child: Text(
          'Validar código',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.7,
            color: Color(0xFFFFFFFF),
          ),
        ),
      ),
    );
    return BackgroundScaffold(
        color: AppTheme.primaryBgColor,
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <
            Widget>[
          Container(
            height: PageUtil.getScreenHeight(context, 0.06),
          ),
          Expanded(
            child: Container(
                height: PageUtil.getScreenHeight(context, 0.70),
                width: PageUtil.getScreenWidth(context),
                decoration: new BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.only(topRight: Radius.circular(80.0)),
                ),
                child: Container(
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon: Icon(Icons.arrow_back),
                                    color: AppTheme.primaryBgColor,
                                    iconSize: 28,
                                  ),
                                ],
                              ),
                              // Input code illustration ------------------------------
                              Visibility(
                                visible: (PageUtil.getScreenHeight(context, 1) >
                                        700) ==
                                    true,
                                child: Container(
                                    height:
                                        PageUtil.getScreenHeight(context, 0.20),
                                    padding: EdgeInsets.fromLTRB(0, 10, 0, 24),
                                    child: SvgPicture.asset(
                                      "assets/img/AEVInputCode.svg",
                                    )),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 12, 0, 24),
                                child: Text(
                                  "Digite o código localizado acima do QR code",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: 'Rubik',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.7,
                                    color: AppTheme.defaultFgColor,
                                  ),
                                ),
                              ),
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: <Widget>[
                                    codeFieldSection,
                                    submitButtonSection,
                                  ],
                                ),
                              ),
                            ])))),
          ),
        ]));
  }

  void _submit([String rawInputvalue]) {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _documentKey = maskFormatter.getUnmaskedText();
    if (StringExt.isNullOrEmpty(_documentKey)) {
      _documentKey = rawInputvalue;
    }
    Navigator.pop(context, _documentKey);
  }
}

//-------------------------------------------------------------------

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text?.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
