
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:d1_payload_generator_gui/components/multilinetextbox.components.dart';
import 'package:d1_payload_generator_gui/components/switch.component.dart';
import 'package:d1_payload_generator_gui/components/textbox.component.dart';
import 'package:d1_payload_generator_gui/exceptions/custom.exception.dart';
import 'package:d1_payload_generator_gui/services/json.service.dart';
import 'package:d1_payload_generator_gui/services/generator.service.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class GeneratePage extends StatefulWidget {
    @override
  _GeneratePageState createState() => _GeneratePageState();
}

class _GeneratePageState extends State<GeneratePage> with TickerProviderStateMixin {

  final _logger = Logger("Generator");

  List _bpoIds = [];
  bool _pretty = true;
  bool _allowRandomQty = true;
  bool _includeAllSpo = true;
  bool _offNet3rdPartyProvider = true;
  List _productOffersWithPlace = [];

  double _progressValue = 0;
  String _progressText = "";

  Generator? gen;

  final _bpoIdsController = TextEditingController();
  final _outputFolderController = TextEditingController();
  final _fdLocController = TextEditingController();

  late AnimationController controller;

  @override
  void initState() {

    super.initState();
    gen = Generator();
    WidgetsBinding.instance!.addPostFrameCallback((_) => _initSettings());
    _bpoIdsController.addListener(_printLatestValue);
    _outputFolderController.addListener(_printLatestValue);
    _fdLocController.addListener(_printLatestValue);
   
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    _bpoIdsController.dispose();
    _fdLocController.dispose();
    _outputFolderController.dispose();
    super.dispose();
  }

  _printLatestValue() {
    print("Second text field: ${_outputFolderController.text}");
  }

  String _bpoIdsToString(List bpoIds) {
    var concatenate = StringBuffer();

    bpoIds.forEach((item){
      concatenate.write('"'+item+'",');
    });
    return concatenate.toString();
  }

  // Fetch content from the json file
  Future<void> _initSettings() async {
    final data = await loadSettings();
    setState(() {
      _bpoIds = data["BPO_IDs"];
      _bpoIdsController.text = _bpoIdsToString(data["BPO_IDs"]);
      _fdLocController.text = data["FD_LOCATION"];
      _outputFolderController.text = data["OUTPUT_FOLDER"];
      _pretty = data["PRETTIFY"];
      _allowRandomQty = data["ALLOW_RANDOM_QTY"];
      _includeAllSpo = data["INCLUDE_ALL_SPO"];
      _offNet3rdPartyProvider = data["OFF_NET_3RD_PARTY_PROVIDER"];
      _productOffersWithPlace = data["PRODUCT_OFFERS_WITH_PLACE"];
    });
  }
  
  _generate() {
    progressWait(gen!.getGeneratedPayloadList().toList(), (completed, total) { })
      .then(gen!.handleError)
      .whenComplete(() => setState(() {
        _progressText = "Generate Complete.";
      }));
  }
  
  Future<List<T>> progressWait<T>(List<Future<T>> futures, void progress(int completed, int total)) {
    int total = futures.length;
    int completed = 0;

    FutureOr<T> complete(e) {
      completed++;
      progress(completed, total);
      setState(() {
        _progressValue = (completed / total).toDouble();
        _progressText = e.toString();
      });
      return e;
    }
    return Future.wait([for (var future in futures) future.then(complete)]);
  }

  void prettyOnChanged(bool newValue) {setState(() { _pretty = newValue; });}
  void alloRandomQtyOnChanged(bool newValue) {setState(() { _allowRandomQty = newValue; });}
  void includeAllSpoOnChanged(bool newValue) {setState(() { _includeAllSpo = newValue; });}
  void offNet3rdPartyProviderOnChanged(bool newValue) {setState(() { _offNet3rdPartyProvider = newValue; });}

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Generate Payload"),
          Card(
            margin: EdgeInsets.all(10),
            child: MultilineTextBox(label: "BPO IDs", controller: _bpoIdsController),
          ),
          Card(
            margin: EdgeInsets.all(10),
            child: Column(
              children: [
                CustomTextBox(label: "FD Location", controller: _fdLocController),
                CustomTextBox(label: "Output Folder", controller: _outputFolderController),
                CustomSwitch(label: "Pretty", value: _pretty, onChanged: prettyOnChanged),
                CustomSwitch(label: "Allow Random Qty", value: _allowRandomQty, onChanged: alloRandomQtyOnChanged),
                CustomSwitch(label: "Include All SPO", value: _includeAllSpo, onChanged: includeAllSpoOnChanged),
                CustomSwitch(label: "Off Net 3rd Party Provider", value: _offNet3rdPartyProvider, onChanged: offNet3rdPartyProviderOnChanged),
              ],
            )
          ),
          SizedBox(height: 16,),
          LinearProgressIndicator(
            value: _progressValue,
            semanticsLabel: 'Linear progress indicator',
          ),
          SizedBox(height: 16,),
          Row(
            children: [
              ElevatedButton(
                child: Text('Reload File'),
                onPressed: _initSettings,
              ),
              SizedBox(width: 16,),
              ElevatedButton(
                child: Text('Save'),
                onPressed: _initSettings,
              ),
              SizedBox(width: 16,),
              ElevatedButton(
                child: Text('Generate'),
                onPressed: _generate,
              ),
              SizedBox(width: 16),
              Text(_progressText, overflow: TextOverflow.ellipsis,softWrap: false,),
            ],
          ),
        ],
      ),
      );
  }
}