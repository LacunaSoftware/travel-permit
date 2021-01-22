import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:travel_permit_reader/util/page_util.dart';

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

    var codeFieldSection = TextFormField(
      focusNode: focusnode,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 16),
      decoration: InputDecoration(
          labelText: 'Código', hintText: '00000-00000-00000-00000'),
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
    return BackgroundScaffold(
        color: Color(0xFFF5F5F5),
        imagePath: "assets/img/bg_global_grey.svg",
        body: Padding(
          padding: EdgeInsets.fromLTRB(20, 40, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back),
                    color: Colors.black54,
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0),
                child: Text(
                  "Digite o código localizado acima do QR code",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.7,
                    color: Color(0xFF007FBC),
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
            ],
          ),
        ));
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
