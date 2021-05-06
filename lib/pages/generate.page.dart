
import 'dart:async';

import 'package:d1_payload_generator_gui/components/multilinetextbox.components.dart';
import 'package:d1_payload_generator_gui/components/switch.component.dart';
import 'package:d1_payload_generator_gui/components/textbox.component.dart';
import 'package:d1_payload_generator_gui/services/json.service.dart';
import 'package:d1_payload_generator_gui/services/generator.service.dart';
import 'package:d1_payload_generator_gui/style.dart';
import 'package:d1_payload_generator_gui/utils/constants.util.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class GeneratePage extends StatefulWidget {
    @override
  _GeneratePageState createState() => _GeneratePageState();
}

class _GeneratePageState extends State<GeneratePage> with TickerProviderStateMixin {

  final _logger = Logger("Generator");

  Map data = {};

  List _bpoIds = [];
  bool _pretty = true;
  bool _allowRandomQty = true;
  bool _includeAllSpo = true;
  bool _offNet3rdPartyProvider = true;
  List _productOffersWithPlace = [];

  double _progressValue = 0;
  String _progressText = "";

  Generator? gen;

  final _scrollController = ScrollController();

  final _bpoIdsController = TextEditingController();
  final _outputFolderController = TextEditingController();
  final _fdLocController = TextEditingController();
  final _productOffersWithPlaceController = TextEditingController();

  @override
  void initState() {

    super.initState();
    gen = Generator();
    WidgetsBinding.instance!.addPostFrameCallback((_) => _initSettings());
    _bpoIdsController.addListener(_bpoIdsOnChanged);
    _outputFolderController.addListener(_outputFolderOnChanged);
    _fdLocController.addListener(_fdOnChanged);
    _productOffersWithPlaceController.addListener(_productOffersWithPlaceChanged);
  }

  @override
  void dispose() {
    _bpoIdsController.dispose();
    _fdLocController.dispose();
    _outputFolderController.dispose();
    _productOffersWithPlaceController.dispose();
    super.dispose();
  }
  
  void saveOnChanged() {
    saveSettings(encoderWithInd(data)).whenComplete(() => setState(() {
      _progressText = "Settings updated.";
    }));
  }

  void _bpoIdsOnChanged() {
    data[BPO_IDs] = _bpoIdsController.text
      .replaceAll("\"", "")
      .split(",");
    saveOnChanged();
  }

  void _fdOnChanged() {
    data[FD_LOCATION] = _fdLocController.text;
    saveOnChanged();
  }

  void _outputFolderOnChanged() {
    data[OUTPUT_FOLDER] = _outputFolderController.text;
    saveOnChanged();
  }
  
  void _productOffersWithPlaceChanged() {
    data[PRODUCT_OFFERS_WITH_PLACE] = _productOffersWithPlaceController.text
      .replaceAll("\"", "")
      .split(",");
    saveOnChanged();
  }

  String _listToString(List bpoIds) {
    final concatenate = StringBuffer();

    bpoIds.asMap().forEach((i, item){
      concatenate.write('${i==0?"":","}"'+item+'"');
    });
    return concatenate.toString();
  }

  void prettyOnChanged(bool newValue) {
    setState(() { 
      _pretty = data[PRETTY] = newValue; 
    });
    saveOnChanged();
  }
  void alloRandomQtyOnChanged(bool newValue) {
    setState(() { 
      _allowRandomQty = data[ALLOW_RANDOM_QTY] = newValue; 
    });
    saveOnChanged();
  }
  void includeAllSpoOnChanged(bool newValue) {
    setState(() { 
      _includeAllSpo = data[INCLUDE_ALL_SPO] = newValue; 
    });
    saveOnChanged();
  }
    
  void offNet3rdPartyProviderOnChanged(bool newValue) {
    setState(() { 
      _offNet3rdPartyProvider = data[OFF_NET_3RD_PARTY_PROVIDER] = newValue;
    });
    saveOnChanged();
  }

  Future<void> _initSettings() async {
    data = await loadSettings();
    setState(() {
      _bpoIds = data[BPO_IDs];
      _bpoIdsController.text = _listToString(data[BPO_IDs]);
      _fdLocController.text = data[FD_LOCATION];
      _outputFolderController.text = data[OUTPUT_FOLDER];
      _pretty = data[PRETTY];
      _allowRandomQty = data[ALLOW_RANDOM_QTY];
      _includeAllSpo = data[INCLUDE_ALL_SPO];
      _offNet3rdPartyProvider = data[OFF_NET_3RD_PARTY_PROVIDER];
      _productOffersWithPlaceController.text = _listToString(data[PRODUCT_OFFERS_WITH_PLACE]);
    });
  }
  
  void _generate() {
    _progressWait(gen!.getGeneratedPayloadList().toList(), (completed, total) { })
      .then(gen!.handleError)
      .whenComplete(() => setState(() {
        _progressText = "Generate Complete.";
      }));
  }
  
  Future<List<T>> _progressWait<T>(List<Future<T>> futures, void progress(int completed, int total)) {
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

  Widget build(BuildContext context) {
    return Scrollbar( controller: _scrollController,
      isAlwaysShown: true,
      child:Padding(
      padding: const EdgeInsets.all(25),
      child: //Scrollbar(
        //isAlwaysShown: true,
        //controller: _scrollController,
        /* child: */ ListView(
          controller: _scrollController,
          children: [
            Card(
              color: cardBgGray,
              margin: EdgeInsets.all(10),
              child: MultilineTextBox(label: "BPO IDs", controller: _bpoIdsController),
            ),
            Card(
              color: cardBgGray,
              margin: EdgeInsets.all(10),
              child: Column(
                children: [
                  CustomTextBox(label: "FD Location", controller: _fdLocController),
                  CustomTextBox(label: "Output Folder", controller: _outputFolderController),
                  CustomSwitch(label: "Pretty", value: _pretty, onChanged: prettyOnChanged),
                  CustomSwitch(label: "Allow Random Qty", value: _allowRandomQty, onChanged: alloRandomQtyOnChanged),
                  CustomSwitch(label: "Include All SPO", value: _includeAllSpo, onChanged: includeAllSpoOnChanged),
                  CustomSwitch(label: "Off Net 3rd Party Provider", value: _offNet3rdPartyProvider, onChanged: offNet3rdPartyProviderOnChanged),
                  CustomTextBox(label: "Product Offers With Place", controller: _productOffersWithPlaceController),
                ],
              )
            ),
            SizedBox(height: 16,),
            LinearProgressIndicator(
              value: _progressValue,
              semanticsLabel: 'Linear progress indicator',
              backgroundColor: Colors.purple,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
            ),
            SizedBox(height: 16,),
            Row(
              children: [
                SizedBox(width: 16,),
                ElevatedButton(
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.purple)),
                  child: Text('Generate', style: whiteText,),
                  onPressed: _generate,
                ),
                SizedBox(width: 16),
                Text(_progressText,
                  style: TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis, softWrap: false,
                ),
              ],
            ),
          ],
        ),
      )
    );
  }
}