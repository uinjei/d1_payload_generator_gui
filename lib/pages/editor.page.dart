import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:cupertino_list_tile/cupertino_list_tile.dart';
import 'package:d1_payload_generator_gui/components/customdivider.component.dart';
import 'package:d1_payload_generator_gui/components/textboxsmall.component.dart';
import 'package:d1_payload_generator_gui/utils/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import 'package:recase/recase.dart';

import 'package:d1_payload_generator_gui/services/io.services.dart';
import 'package:d1_payload_generator_gui/services/json.service.dart';
import 'package:d1_payload_generator_gui/utils/constants.util.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

final _logger = Logger("Editor");

class EditorPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  List<Map> payloads = [];
  final _scrollController = ScrollController();
  final _payloadScrollController = ScrollController();
  List<dynamic> orderItems = [];
  Map data = {};
  Map settingsData = {};
  String fdLoc = "";
  bool loading = false;
  List spoNames = [];
  final duplicateController = TextEditingController();
  String dupFile = "";

  final util = Util();

  List<List<TextEditingController>> characteristicControllers =
      List.empty(growable: true);

  String selectedPayloadPath = "";
  Map metadata = {};
  int selectedIndex = -1;

  List<Item> expandedData = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => _init());
    duplicateController.addListener(() { dupFile = duplicateController.text; });
  }

  @override
  void dispose() {
    characteristicControllers.forEach((orderItems) {
      orderItems.forEach((characteristic) {
        characteristic.dispose();
      });
    });
    duplicateController.dispose();
    super.dispose();
  }

  Future<void> _saveOnChanged() async {
    data["orderItem"][0]["orderItem"] = orderItems;
    await savePayload(selectedPayloadPath,
            '/**$PREF_META${json.encode(metadata)}**/\n${indentJson(data)}')
        .whenComplete(() => setState(() {
              //_progressText = "Settings updated.";
            }));
  }

  _getOfferDetails(spoId) async {
    final spo = await readFile("$fdLoc/$PRODUCT_OFFERING_FOLDER/$spoId.json");
    //_logger.info(spo["id"]);
    return await spo["localizedName"]
        .firstWhere((elem) => elem["locale"] == LOCALE)["value"];
  }

  void _init() async {
    _logger.info("initialize");

    settingsData = await loadSettings();
    fdLoc = settingsData[FD_LOCATION];

    _dirContents(Directory(settingsData[OUTPUT_FOLDER]))
        .then((_payloads) => setState(() {
              payloads = _payloads;
            }));
  }

  void _updateControllersState() {
    for (var i = 0; i < characteristicControllers.length; i++) {
      List c = characteristicControllers[i];
      for (var j = 0; j < c.length; j++) {
        final charValue =
            orderItems[i]["product"]["characteristic"][j]["value"];
        c[j].text = charValue is String ? charValue : charValue.toString();
      }
    }
  }

  Future<List<Map>> _dirContents(Directory dir) async {
    final lister = dir.list(recursive: false);
    final mm = lister.map((event) async => {
      "metadata": metadata = await _getMeta(event.path),
      "file": event,
    });
    return Future.wait(await mm.toList());
  }

  _getMeta(path) async => await readFileMeta(path);

  void _getSelectedPayload(path, index) async {
    setState(() {
      loading = true;
    });

    data = await readFileContent(path);
    final meta = await readFileMeta(path);
    orderItems = data["orderItem"][0]["orderItem"];
    orderItems.sort((a, b) =>
        a["productOffering"]["id"].compareTo(b["productOffering"]["id"]));
    final grouped = orderItems.groupListsBy((element) => element["productOffering"]["id"]);

    characteristicControllers = List.empty(growable: true);
    selectedPayloadPath = path;
    metadata = meta;

    spoNames = (await Future.wait(grouped.values.map((value) {
      final isSingle = value.length == 1;
      return Future.wait(value.asMap().entries.map((e) async {
        final k = e.key;
        final v = e.value;
        if (v["productOfferingGroupOption"] != null) {
          final bpoLoc = util.generateJSONFileLocation(
              PRODUCT_OFFERING_FOLDER, meta["id"]);
          final offerGroupName =
              (await readFile(bpoLoc))["bundledProdOfferGroupOption"]
                  .firstWhere((e) =>
                      e["groupOptionId"] ==
                      v["productOfferingGroupOption"]["groupOptionId"])["name"]
                  .firstWhere((e) => e["locale"] == LOCALE)["value"];
          return "$offerGroupName ${isSingle ? "" : k + 1}";
        }
        return "${await _getOfferDetails(value[k]["productOffering"]["id"])} ${isSingle ? "" : k + 1}";
      }));
    })))
        .expand((element) => element)
        .toList();

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

  void _duplicatePayload(payload) {
    final File p = payload["file"];
    p.copySync("${settingsData[OUTPUT_FOLDER]}/$dupFile.json");
    duplicateController.text = "";
  }

  Future<List<Item>> _generateItems(data) async {
    return List.generate(data.length, (int index) {
      final orderItem = orderItems[index];

      var c = List<TextEditingController>.empty(growable: true);

      for (var i = 0; i < orderItem["product"]["characteristic"].length; i++) {
        TextEditingController characteristicController;
        characteristicController = TextEditingController();
        characteristicController.addListener(() {
          orderItem["product"]["characteristic"][i]["value"] =
              characteristicController.text;
          _saveOnChanged();
        });
        c.add(characteristicController);
      }

      characteristicControllers.add(c);

      _updateControllersState();

      return Item(
        headerValue: "${spoNames[index]}",
        expandedValue: Container(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Extensions",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "ReservationId: ${orderItem["extensions"]["reservationId"]}",
            ),
            CustomDivider(),
            Text("Quantity: ${orderItem["quantity"]}"),
            CustomDivider(),
            Text(
              "Product Offering",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("Id: ${orderItem["productOffering"]["id"]}"),
            CustomDivider(),
            Text("Action: ${orderItem["action"]}"),
            CustomDivider(),
            ...generateListedProperties(
                orderItem["modifyReason"], "Modify Reason"),
            CustomDivider(),
            ...generateListedProperties(
                orderItem["externalIdentifier"], "External Identifier"),
            CustomDivider(),
            Text(
              "Product",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "Product Specification",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("Id: ${orderItem["product"]["productSpecification"]["id"]}"),
            ...generateListedTextBoxProperties(
                orderItem["product"]["characteristic"], "Characteristic", c),
            ...generateListedProperties(orderItem["product"]["place"], "Place"),
          ],
        )),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    payloads.removeWhere((element) => element["file"].path.contains("error-"));
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 320,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: ListView.builder(
                itemCount: payloads.length,
                controller: _scrollController,
                itemBuilder: (context, index) {
                  final p = payloads[index]["file"].path;
                  final path = p.split("\\").last;
                  final metadata = payloads[index]["metadata"];
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      color: selectedIndex == index
                          ? Colors.black.withOpacity(0.03)
                          : Colors.white,
                    ),
                    child: CupertinoListTile(
                      hoverColor: Colors.black.withOpacity(0.03),
                      title: Text(
                        metadata["name"],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(path, style: TextStyle(fontSize: 10)),
                          Text(
                            '${metadata["currency"]} | ${metadata["timing"]} | ${metadata["proration"]}',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: SizedBox(
                            /* width: 32,
                            height: 32, */
                            child: CupertinoContextMenu(
                              child: Icon(
                                CupertinoIcons.ellipsis_vertical_circle
                              ),
                              actions: <Widget>[
                                CupertinoContextMenuAction(
                                  child: Text('Copy to clipboard'),
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    final payload = await readFileContent(p);
                                    Clipboard.setData(ClipboardData(text: indentJson(payload)));
                                    showToast("Copied to clipboard");
                                  },
                                ),
                                CupertinoContextMenuAction(
                                  child: const Text('Copy payload file'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    showCupertinoDialog(context: context, builder: (context) => CupertinoAlertDialog(
                                  title: Text("Enter name"),
                                  content: CupertinoTextField(
                                    controller: duplicateController
                                  ),
                                  actions: <Widget>[
                                    CupertinoDialogAction(
                                      child: Text("Cancel"),
                                      onPressed: () => Navigator.of(context).pop(false),
                                    ),
                                    CupertinoDialogAction(
                                      child: Text("Ok"),
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                        _duplicatePayload(payloads[index]);
                                        _init();
                                        showToast("Payload duplicated");
                                      },
                                    ),
                                  ],
                                ));
                                  },
                                ),
                              ],
                            ),
                          ),
                          /* CupertinoButton(
                            child: Icon(CupertinoIcons.doc_on_clipboard),
                              onPressed: () async {
                                final payload = await readFileContent(p);
                                Clipboard.setData(ClipboardData(text: indentJson(payload)));
                                showToast("Copied to clipboard");
                            },
                          ), */
                         /*  CupertinoButton(
                            child: Icon(CupertinoIcons.doc_on_clipboard),
                              onPressed: () async {
                                showCupertinoDialog(context: context, builder: (context) => CupertinoAlertDialog(
                                  title: Text("Enter name"),
                                  content: CupertinoTextField(
                                    controller: duplicateController
                                  ),
                                  actions: <Widget>[
                                    CupertinoDialogAction(
                                      child: Text("Cancel"),
                                      onPressed: () => Navigator.of(context).pop(false),
                                    ),
                                    CupertinoDialogAction(
                                      child: Text("Ok"),
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                        _duplicatePayload(payloads[index]);
                                        _init();
                                        showToast("Payload duplicated");
                                      },
                                    ),
                                  ],
                                ));
                                //showToast("Copied to clipboard");
                            },
                          ), */
                      onTap: () => _getSelectedPayload(
                          payloads[index]["file"].path, index),
                    ),
                  );
                }),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: SingleChildScrollView(
              controller: _payloadScrollController,
              child: Container(
                child: expandedData.isEmpty
                    ? Container(
                        alignment: Alignment.center,
                        child: Text("No Selected BPO"),
                        height: 500,
                      )
                    : loading
                        ? Container(
                            alignment: Alignment.center,
                            child: Text("Please wait..."),
                            height: 500,
                          )
                        : Theme(
                            data: ThemeData(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                            ),
                            child: ExpansionPanelList(
                              expansionCallback: (int index, bool isExpanded) {
                                setState(() {
                                  expandedData[index].isExpanded = !isExpanded;
                                });
                              },
                              children: expandedData
                                  .asMap()
                                  .entries
                                  .map<ExpansionPanel>((MapEntry item) {
                                final value = item.value;
                                final index = item.key;
                                return ExpansionPanel(
                                  canTapOnHeader: true,
                                  headerBuilder:
                                      (BuildContext context, bool isExpanded) {
                                    return ListTile(
                                      mouseCursor: ListTileCursor(),
                                      title: Text(value.headerValue),
                                    );
                                  },
                                  body: ListTile(
                                    dense: true,
                                    title: value.expandedValue,
                                    trailing: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: CupertinoButton(
                                          child:
                                              Icon(CupertinoIcons.doc_on_doc),
                                          onPressed: () async {
                                            orderItems.add(orderItems[index]);
                                            await _saveOnChanged();
                                            _getSelectedPayload(
                                                payloads[selectedIndex]["file"]
                                                    .path,
                                                selectedIndex);
                                            showToast("Order Item duplicated");
                                          }),
                                    ),
                                  ),
                                  isExpanded: value.isExpanded,
                                );
                              }).toList(),
                            ),
                          ),
              ),
            ),
          ),
          /* ), */
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
  if (list == null || list.isEmpty) return [];

  final nameSet = list[0].keys.toList();
  final isSingle = list.length == 1;
  return List.generate(
      list.length,
      (index) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$parent ${isSingle ? "" : index + 1}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...List.generate(
                  nameSet.length,
                  (ind) => Text(
                      "${ReCase(nameSet[ind]).titleCase}: ${list[index][nameSet[ind]]}"))
            ],
          ));
}

List<Widget> generateListedTextBoxProperties(List<dynamic> list, String parent,
    List<TextEditingController> controllers) {
  if (list.isEmpty) return [];

  final isSingle = list.length == 1;

  return List.generate(list.length, (index) {
    final title = "${ReCase(list[index]["name"]).titleCase}";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$parent ${isSingle ? "" : index + 1}",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextBoxSmall(
          label: title,
          controller: controllers[index],
          enabled: title != "Equipment Group",
        ),
      ],
    );
  });
}

class ListTileCursor extends MaterialStateMouseCursor {
  @override
  MouseCursor resolve(Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled)) {
      return SystemMouseCursors.click;
    }
    return SystemMouseCursors.click;
  }

  @override
  String get debugDescription => 'ListTileCursor()';
}
