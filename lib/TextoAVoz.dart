import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'dart:convert' as convert;
import 'package:http/http.dart' as http;



class TextoAVoz extends StatefulWidget {
  @override
  _TextoAVozState createState() => _TextoAVozState();
}

class _TextoAVozState extends State<TextoAVoz> {
  bool _hasSpeech = false;
  bool _stressTest = false;
  double level = 0.0;
  int _stressLoops = 0;
  String lastWords = "";
  String lastError = "";
  String lastStatus = "";
  String _currentLocaleId = "";
  List<LocaleName> _localeNames = [];
  final SpeechToText speech = SpeechToText();


  String opcionElegida = '';



  @override
  void initState() {
    super.initState();
  }

  Future<void> initSpeechState() async {
    bool hasSpeech = await speech.initialize(
        onError: errorListener, onStatus: statusListener);
    if (hasSpeech) {
      _localeNames = await speech.locales();

      var systemLocale = await speech.systemLocale();
      _currentLocaleId = systemLocale.localeId;
    }

    if (!mounted) return;

    setState(() {
      _hasSpeech = hasSpeech;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('voz a texto'),
        ),
        body: Column(children: [
          Center(
            child: Text(
              'voz a tex',
              style: TextStyle(fontSize: 22.0),
            ),
          ),
          Container(
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    FlatButton(
                      child: Text('comenzar'),
                      onPressed: _hasSpeech ? null : initSpeechState,
                    ),

                    /*
                    FlatButton(
                      child: Text('Stress Test'),
                      onPressed: stressTest,
                    ),
                    */

                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    FlatButton(
                      child: Text('Iniciar'),
                      onPressed: !_hasSpeech || speech.isListening
                          ? null
                          : startListening,
                    ),
                    FlatButton(
                      child: Text('Parar'),
                      onPressed: speech.isListening ? stopListening : null,
                    ),
                    FlatButton(
                      child: Text('Cancelar'),
                      onPressed: speech.isListening ? cancelListening : null,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    DropdownButton(
                      onChanged: (selectedVal) => _switchLang(selectedVal),
                      value: _currentLocaleId,
                      items: _localeNames
                          .map(
                            (localeName) => DropdownMenuItem(
                              value: localeName.localeId,
                              child: Text(localeName.name),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              children: <Widget>[
                Center(
                  child: Text(
                    'Palabras reconocidas',
                    style: TextStyle(fontSize: 22.0),
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: <Widget>[
                      Container(
                        color: Theme.of(context).selectedRowColor,
                        child: Center(
                          child: Text(
                            lastWords,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        bottom: 10,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: .26,
                                    spreadRadius: level * 1.5,
                                    color: Colors.black.withOpacity(.05))
                              ],
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                            ),
                            child: IconButton(icon: Icon(Icons.mic)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: <Widget>[
                Center(
                  child: Text(
                    'Error Status',
                    style: TextStyle(fontSize: 22.0),
                  ),
                ),
                Center(
                  child: Text(lastError),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            color: Theme.of(context).backgroundColor,
            child: Center(
              child: speech.isListening
                  ? Text(
                      "Estoy escuchando...",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  : Text(
                      'No estoy escuchando',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),

          RaisedButton(
            child: Text("PROCESAR TEXTO"),
            onPressed: (){
              //procesarTextoAPIGoogle();
              showDialog(
                context: context,
                builder: (BuildContext context){
                  return SimpleDialog(
                    title: const Text('Escoge una opcion'),
                    children: <Widget>[
                      SimpleDialogOption(
                        child: const Text('analyzeEntities'),
                        onPressed: () {
                          opcionElegida = 'analyzeEntities';
                          procesarTextoAPIGoogle();
                        },
                      ),
                      SimpleDialogOption(
                        child: const Text('analyzeSentiment'),
                        onPressed: () {
                          opcionElegida = 'analyzeSentiment';
                          procesarTextoAPIGoogle();
                        },
                      ),
                      SimpleDialogOption(
                        child: const Text('analyzeSyntax'),
                        onPressed: () {
                          opcionElegida = 'analyzeSyntax';
                          procesarTextoAPIGoogle();
                        },
                      ),
                      SimpleDialogOption(
                        child: const Text('classifyText'),
                        onPressed: () {
                          opcionElegida = 'classifyText';
                          procesarTextoAPIGoogle();                       
                        },
                      ),
                      
                    ],
                  );
                }
              );

            }
          ),

        ]),
      
    );
  }

/*
  void stressTest() {
    if (_stressTest) {
      return;
    }
    _stressLoops = 0;
    _stressTest = true;
    print("Starting stress test...");
    startListening();
  }
*/

  Future<void> procesarTextoAPIGoogle() async {
    var url = 'https://language.googleapis.com/v1/documents:' + opcionElegida + '?key=AIzaSyAWfttKQi-ngJ-8obKZSwGOf6eputEpabY';
    
    String json = "{'document' : {'type': 'PLAIN_TEXT', 'language': 'es','content': '" + lastWords.trim() + "' } }";

    // Await the http get response, then decode the json-formatted response.
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json
    );

    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      print(jsonResponse);

      showDialog(
        context: context,
        builder: (BuildContext context){
            return AlertDialog(
              content: Text(jsonResponse.toString()),
            );
        }
      );
      
    } else {
      print('Request failed with status: ${response.body}.');
      showDialog(
        context: context,
        builder: (BuildContext context){
            return AlertDialog(
              content: Text(response.body.toString()),
            );
        }
      );
    }
  }


  void changeStatusForStress(String status) {
    if (!_stressTest) {
      return;
    }
    if (speech.isListening) {
      stopListening();
    } else {
      if (_stressLoops >= 100) {
        _stressTest = false;
        print("Stress test complete.");
        return;
      }
      print("Stress loop: $_stressLoops");
      ++_stressLoops;
      startListening();
    }
  }

  void startListening() {
    lastWords = "";
    lastError = "";
    speech.listen(
        onResult: resultListener,
        listenFor: Duration(seconds: 10),
        localeId: _currentLocaleId,
        onSoundLevelChange: soundLevelListener,
        cancelOnError: true,
        partialResults: true);
    setState(() {});
  }

  void stopListening() {
    speech.stop();
    setState(() {
      level = 0.0;
    });
  }

  void cancelListening() {
    speech.cancel();
    setState(() {
      level = 0.0;
    });
  }

  void resultListener(SpeechRecognitionResult result) {
    setState(() {
      lastWords = "${result.recognizedWords} - ${result.finalResult}";
    });
  }

  void soundLevelListener(double level) {
    setState(() {
      this.level = level;
    });
  }

  void errorListener(SpeechRecognitionError error) {
    setState(() {
      lastError = "${error.errorMsg} - ${error.permanent}";
    });
  }

  void statusListener(String status) {
    changeStatusForStress(status);
    setState(() {
      lastStatus = "$status";
    });
  }

  _switchLang(selectedVal) {
    setState(() {
      _currentLocaleId = selectedVal;
    });
    print(selectedVal);
  }
}