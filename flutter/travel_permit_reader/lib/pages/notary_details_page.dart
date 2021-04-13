import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travel_permit_reader/api/models.dart';
import 'package:travel_permit_reader/pages/travel_permit_page.dart';
import 'package:travel_permit_reader/util/page_util.dart';

class NotaryDetailsPage extends StatelessWidget {
  final NotaryModel notaryModel;
  const NotaryDetailsPage({Key key, this.notaryModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> details = [
      buildLabelText('Nome'),
      buildDetailsText(notaryModel.name),
      buildDivider(),
      //-----------------------------
      buildLabelText('CNS'),
      buildDetailsText(notaryModel.cns),
      buildDivider(),
      //-----------------------------
      buildLabelText('Tabelião'),
      buildDetailsText(notaryModel.ownerName),
      buildDivider(),
      //-----------------------------
      buildLabelText('Telefone'),
      buildDetailsText(notaryModel.phoneNumber),
    ];

    details.add(SizedBox(height: 30));

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
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                    color: AppTheme.primaryBgColor,
                  ),
                ],
              ),
              Expanded(
                  child: ListView(
                children: [...details],
              )),
            ],
          ))
    ]));
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
}
