import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:travel_permit_reader/util/page_util.dart';

import 'home_page.dart';

class EnterKeyPage extends StatefulWidget {
  @override
  _EnterKeyPageState createState() => _EnterKeyPageState();
}

class _EnterKeyPageState extends State<EnterKeyPage> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode focusnode = FocusNode();
  bool focused = false;
  String _documentKey;

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 1),
        () => FocusScope.of(context).requestFocus(focusnode));

    final maskFormatter = new MaskTextInputFormatter(
        mask: '#####-#####-#####-#####', filter: {"#": RegExp(r'[A-Z0-9]')});
    var titleSection = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        "Digite o código localizado acima do QR code",
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.7,
          color: Color(0xFF007FBC),
        ),
      ),
    );
    var codeFieldSection = TextFormField(
      focusNode: focusnode,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 16),
      decoration: InputDecoration(
          labelText: 'Código', hintText: 'XXXXX-XXXXX-XXXXX-XXXXX'),
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

    var submitButtonSection = Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: RaisedButton(
        onPressed: () {
          if (_formKey.currentState.validate()) {
            _documentKey = maskFormatter.getUnmaskedText();
            Navigator.pop(context, _documentKey);
          }
        },
        color: Color(0xFF007FBC),
        child: Text(
          'Validar',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.7,
            color: Color(0xFFFFFFFF),
          ),
        ),
      ),
    );
    return AppBarScaffold(
      resizeToAvoidBottomInset: false,
      color: Color(0xFFF5F5F5),
      imageLocation: "assets/img/bg_global_grey.svg",
      imageFit: BoxFit.none,
      body: Stack(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(
              left: 50,
              right: 50,
            ),
            width: PageUtil.getScreenWidth(context),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  titleSection,
                  codeFieldSection,
                  submitButtonSection,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
