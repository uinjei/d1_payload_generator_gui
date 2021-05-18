import 'dart:async';
import 'dart:io';

import 'package:recase/recase.dart';

import 'package:d1_payload_generator_gui/components/textbox.component.dart';
import 'package:d1_payload_generator_gui/services/io.services.dart';
import 'package:d1_payload_generator_gui/services/json.service.dart';
import 'package:d1_payload_generator_gui/style.dart';
import 'package:d1_payload_generator_gui/utils/constants.util.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

final _logger = Logger("Editor");

class EditorPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {

  List<FileSystemEntity> payloads = [];
  final _scrollController = ScrollController();
  final _payloadScrollController = ScrollController();
  List<dynamic> orderItems = [];
  Map data = {};
  Map settingsData = {};
  bool loading = false;

  List<List<TextEditingController>> reservationControllers = List.empty(growable: true);

  String selectedPayloadPath = "";
  int selectedIndex = -1;

  List<Item> expandedData = [];

  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => _init());
    
  }

  void _saveOnChanged() {
    data["orderItem"][0]["orderItem"] = orderItems;
    savePayload(selectedPayloadPath ,encoderWithInd(data)).whenComplete(() => setState(() {
      //_progressText = "Settings updated.";
    }));
  }

  void _init() async {
    _logger.info("initialize");

    settingsData = await loadSettings();
    final _payloads = await _dirContents(Directory(settingsData[OUTPUT_FOLDER]));

    setState(() {
      payloads = _payloads;
    });
  }

  void _updateControllersState() {
    for (var i = 0; i < reservationControllers.length; i++) { 
      List c = reservationControllers[i];
      for (var j = 0; j < c.length; j++) {
        final charValue = orderItems[i]["product"]["characteristic"][j]["value"];
        c[j].text = charValue is String?charValue:charValue.toString();
      }
    }

  }

  Future<List<FileSystemEntity>> _dirContents(Directory dir) {
    var files = <FileSystemEntity>[];
    var completer = Completer<List<FileSystemEntity>>();
    final lister = dir.list(recursive: false);
    lister.listen ( 
        (file) => files.add(file),
        onDone: () => completer.complete(files)
        );
    return completer.future;
  }

  void _getSelectedPayload(path, index) async {

    setState(() {
      loading = true;
    });

    data = await readFile(path);
    orderItems = data["orderItem"][0]["orderItem"];
    reservationControllers = List.empty(growable: true);
    selectedPayloadPath = path;
    
    _generateItems(orderItems).then((value) {
      setState(() {
        expandedData = value;
        selectedIndex = index;
      });
    }).whenComplete(() {
      setState(() {
        loading = false;
      });
    });
   
  }

  Future<List<Item>> _generateItems(data) async {
    return List.generate(data.length, (int index) {
      final orderItem = orderItems[index];

      var c = List<TextEditingController>.empty(growable: true);

      for (var i = 0; i < orderItem["product"]["characteristic"].length; i++) {
        
        TextEditingController _characteristicController;
        _characteristicController = TextEditingController();
        _characteristicController.addListener(() {
          orderItem["product"]["characteristic"][i]["value"] = _characteristicController.text;
          _saveOnChanged();
        });
        c.add(_characteristicController);
      }

      reservationControllers.add(c);

      _updateControllersState();

      return Item(
        headerValue: "Order Item $index",
        expandedValue: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Extensions"),
              Text("ReservationId: ${orderItem["extensions"]["reservationId"]}"),
              Divider(),
              Text("Quantity: ${orderItem["quantity"]}"),
              Divider(),
              Text("Product Offering"),
              Text("Id: ${orderItem["productOffering"]["id"]}"),
              Divider(),
              Text("Action: ${orderItem["action"]}"),
              Divider(),
              ...generateListedProperties(orderItem["modifyReason"],"Modify Reason"),
              Divider(),
              ...generateListedProperties(orderItem["externalIdentifier"],"External Identifier"),
              Divider(),
              Text("Product"),
              Text("Product Specification"),
              Text("Id: ${orderItem["product"]["productSpecification"]["id"]}"),
              ...generateListedTextBoxProperties(orderItem["product"]["characteristic"],"Characteristic", c),
              ...generateListedProperties(orderItem["product"]["place"], "Place"),
            ],
          )
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    payloads.removeWhere((element) => element.path.contains("error-"));
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Scrollbar(
          controller: _scrollController,
          child: SizedBox(
          width: 320,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: ListView.separated(
              separatorBuilder: (BuildContext context, int index) => Divider(),
              itemCount: payloads.length,
              controller: _scrollController,
              itemBuilder: (context, index) {
                final path = payloads[index].path.split("\\").last;
                final parts = path.split("_");
                final timing = parts[2]=="D"?"Advance":"Arrear";
                final proration = parts[3].split(".").first=="P"?"Prorated":"Non Prorated";
                return Material(
                  child: Ink(
                    color: selectedIndex==index?Colors.black.withOpacity(0.12):Colors.white,
                    child: ListTile(
                      //dense: true,
                      //contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
                      title: Text(parts[0], /* style: TextStyle(fontSize: 14), */),
                      subtitle: Row(
                        children: [
                          Text('${parts[1]} | $timing | $proration', style: TextStyle(fontSize: 12),),
                        ],
                      ),
                      trailing: Icon(Icons.chevron_right),
                      /* tileColor: Colors.white, */
                      onTap: () => _getSelectedPayload(payloads[index].path, index),
                    )
                  ),
                );
              }),
             ),
          ),
        ),
        Expanded(
          child: Card(
          color: cardBgGray,
          margin: EdgeInsets.all(10),
            child: Scrollbar(
              controller: _payloadScrollController,
              child: SingleChildScrollView(
              controller: _payloadScrollController,
                child: Container(
                  child: expandedData.isEmpty?Container(
                    alignment: Alignment.center,
                    child: Text("No Selected BPO"),
                    height: 500,
                  )
                  :loading?Container(
                    alignment: Alignment.center,
                    child: Text("Fetching..."),
                    height: 500,
                  ): ExpansionPanelList(
                    expansionCallback: (int index, bool isExpanded) {
                      setState(() {
                        expandedData[index].isExpanded = !isExpanded;
                      });
                    },
                    children: expandedData.map<ExpansionPanel>((Item item) {
                      return ExpansionPanel(
                        headerBuilder: (BuildContext context, bool isExpanded) {
                          return ListTile(
                            //dense: true,
                            //contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
                            title: Text(item.headerValue),
                          );
                        },
                        body: ListTile(
                          dense: true,
                          //contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
                          title: item.expandedValue,
                          /* subtitle: item.expandedSubValue, */
                          trailing: Icon(Icons.copy),
                          onTap: () {
                            /* setState(() {
                              expandedData.removeWhere((currentItem) => item == currentItem);
                            }); */
                          }
                        ),
                        isExpanded: item.isExpanded,
                      );
                    }).toList(),
                  ),
                ),
              ),
            )
          ),
        ),
      ],
    );
  }
}

class Item {
  Item({
    required this.expandedValue,
    required this.headerValue,
    this.isExpanded = false,
  });

  Widget expandedValue;
  String headerValue;
  bool isExpanded;
}

List<Widget> generateListedProperties(List<dynamic>? list, String parent) {
  if (list==null || list.isEmpty)
    return [Text("Empty")];

  final nameSet = list[0].keys.toList();
  return List.generate(list.length, (index) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("$parent $index"),
      ...List.generate(nameSet.length, (ind) => Text("${ReCase(nameSet[ind]).titleCase}: ${list[index][nameSet[ind]]}"))
    ],
  ));
}

List<Widget> generateListedTextBoxProperties(List<dynamic> list, String parent, List<TextEditingController> controllers) {
  if (list.isEmpty)
    return [Text("Empty")];

  return List.generate(list.length, (index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$parent $index"),
        CustomTextBox(label: "${ReCase(list[index]["name"]).titleCase}", controller: controllers[index]),
      ],
    );
  });
}