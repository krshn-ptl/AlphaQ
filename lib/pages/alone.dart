import 'dart:async';
import 'dart:io';
import 'package:clay_containers/clay_containers.dart';
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:emergency_app/components/PopupMenu.dart';
import 'package:emergency_app/components/sendsms.dart';
import 'package:emergency_app/data/data.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
// import 'package:emergency_app/runner/backgroundMicDetection.dart';
import 'package:record/record.dart';
import 'dart:core';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:path_provider/path_provider.dart';
// import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:wakelock/wakelock.dart';

class AlonePage extends StatefulWidget {
  static String id = 'AlonePage';
  @override
  _AlonePageState createState() => _AlonePageState();
}

class _AlonePageState extends State<AlonePage> {
  int timeInMinutes = 0;
  int seconds = 0;
  double percent = 0;
  bool timerIsOn = false;
  Timer time;
  Timer _checktimer;
  double _confidance = 0;
  bool recordIsOn = false;
  bool detectonIsOn = false;
  bool canceltimer = false;
  stt.SpeechToText _speechToText = stt.SpeechToText();

  // bool listening = false;
  String _text;
  @override
  void initState() {
    startRecording();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = currentDisplaySize.height;
    double width = currentDisplaySize.width;
    Color baseColor = Theme.of(context).backgroundColor;
    return Scaffold(
      backgroundColor: baseColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        canceltimer = true;
                        detectonIsOn = false;
                        stopRecord();
                        setState(() {
                          timerIsOn = false;
                          percent = 0;
                          Wakelock.disable();
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: myPopMenu(width, height, context)),
                  /*Container(
                                alignment: Alignment.topLeft,
                                child: myPopMenu(width,height)
                              ),*/
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: height * 0.07316),
                    child: Text(
                      'Alone Mode',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: 20, right: 20, top: height * 0.02316),
                    child: Text(
                      "After the timer starts, if you don't respond (Press the button below) in 15 min, The app will inform your peers that you in danger.",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    child: Hero(
                      tag: "emergency",
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: height * 0.0638, bottom: height * 0.0438),
                        child: ClayContainer(
                          color: baseColor,
                          surfaceColor: baseColor,
                          height: height * 0.280,
                          width: height * 0.280,
                          borderRadius: 130,
                          curveType: CurveType.convex,
                          spread: 20,
                          depth: 30,
                          child: Center(
                            child: ClayContainer(
                              color: baseColor,
                              surfaceColor: baseColor,
                              height: height * 0.270,
                              width: height * 0.270,
                              borderRadius: 200,
                              curveType: CurveType.concave,

                              //depth: 100,
                              child: Center(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      height: height * 0.270,
                                      width: height * 0.270,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        //color: Colors.green
                                      ),
                                      child: CircularPercentIndicator(
                                        radius: height * 0.270,
                                        animation: true,
                                        percent: percent,
                                        animateFromLastPercent: true,
                                        lineWidth: height * 0.040,
                                        circularStrokeCap:
                                            CircularStrokeCap.round,
                                        backgroundColor: Colors.transparent,
                                      ),
                                    ),
                                    Container(
                                        height: height * 0.230,
                                        width: height * 0.230,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                        ),
                                        child: RawMaterialButton(
                                          onPressed: () {
                                            setState(() {
                                              if (!timerIsOn) {
                                                Wakelock.enable();
                                                startRecording();
                                                timerIsOn = true;
                                                listen();
                                                startTimer(time);
                                              } else {
                                                turnOffTimer();
                                                Timer(
                                                    Duration(milliseconds: 600),
                                                    () {
                                                  timerIsOn = true;
                                                  startTimer(time);
                                                });
                                              }
                                            });
                                          },
                                          elevation: 10.0,
                                          fillColor: Colors.red,
                                          highlightColor: Colors.red[900],
                                          highlightElevation: 0,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                            ),
                                            child: !(seconds == 0)
                                                ? Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: height *
                                                                    0.0276),
                                                        child: Text(
                                                          "${seconds ~/ 60}:${seconds % 60}"
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: height *
                                                                  0.060,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                      Text(
                                                        "I'm Here.",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize:
                                                                height * 0.03,
                                                            color:
                                                                Colors.white),
                                                      )
                                                    ],
                                                  )
                                                : Container(
                                                    child: Text(
                                                      "Press to start",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize:
                                                              height * 0.040,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                          ),
                                          /*Container(
                                                            decoration: BoxDecoration(
                                                              image: DecorationImage(
                                                                image: AssetImage(
                                                                    'images/button.png'),
                                                              ),
                                                            ),
                                                          ),*/
                                          padding: EdgeInsets.all(15.0),
                                          shape: CircleBorder(),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Hero(
                    tag: 'red button',
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: RawMaterialButton(
                        onPressed: () {
                          setState(() {
                            Wakelock.disable();
                          });
                          stopRecord();
                          canceltimer = true;
                          detectonIsOn = false;
                          turnOffTimer();
                        },
                        elevation: 8.0,
                        fillColor: Colors.red,
                        highlightColor: Colors.red[900],
                        highlightElevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          child: Text(
                            "Stop",
                            style: TextStyle(
                                fontSize: 27,
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        padding: EdgeInsets.all(10.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> stopRecord() async {
    setState(() {
      recordIsOn = false;
    });
    await Record.stop();
  }

  Future<void> listen() async {
    if (!detectonIsOn) {
      bool init = await _speechToText.initialize(
        onError: (val) => print("onError $val"),
        onStatus: (val) => print("onstatus $val"),
      );
      detectonIsOn = true;
      Timer.periodic(Duration(seconds: 5), (_checktimer) async {
        print(init);
        if (init) {
          _speechToText.listen(
            onResult: (val) => setState(() {
              _text = val.recognizedWords;
              if (val.hasConfidenceRating && val.confidence > 0) {
                _confidance = val.confidence;
              }
            }),
          );
          print("is litensing ${_speechToText.isListening}");
          print("confi $_confidance");
          print("text $_text");
          if (_text == null) {
            // if (_text.contains("help")) {
            //   print("help found");
            // }
            sendSms();
            _checktimer.cancel();
          }
        }
        if (canceltimer) {
          if (_speechToText != null) {
            _speechToText.cancel();
          }
          _checktimer.cancel();
        }
      });
    }
  }

  Future<void> startRecording() async {
    if (!recordIsOn) {
      bool result = await Record.hasPermission();
      print("initcalled");
      var dir;
      if (Platform.isAndroid) dir = await getExternalStorageDirectory();
      if (Platform.isIOS) dir = await getApplicationDocumentsDirectory();
      String path = dir.path +
          '/' +
          DateTime.now().millisecondsSinceEpoch.toString() +
          '.m4a';
      recordIsOn = true;
      //TODO path=/storage/emulated/0/Android/data/com.caffineoverflow.emergency_app/files/1618846367115.m4a
      print(path);
      if (result == true) {
        print("recoeding starded");
        await Record.start(
          path: path, // required
          encoder: AudioEncoder.AAC, // by default
          bitRate: 128000, // by default
          samplingRate: 44100, // by default
        );
      }
    }
  }

  void startTimer(Timer _time) {
    timeInMinutes = 15;
    int tempSec = timeInMinutes * 60;
    seconds = timeInMinutes * 60;
    _time = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (!timerIsOn) {
          timer.cancel();
          seconds = 0;
        } else if (seconds > 0) {
          seconds--;
          percent = (tempSec - seconds) / tempSec;
          if (percent < 0.99) {
            percent += 0.01;
          } else {
            percent = 1;
            sendSms();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Triggering Emergency protocol", textAlign: TextAlign.center,style: TextStyle(color:  Theme.of(context).buttonColor),),
              backgroundColor: Theme.of(context).dividerColor,
              elevation: 2,
              duration: const Duration(seconds: 3),
            ));
            print("Done Biatch! 1");
          }
        } else {
          percent = 0;
          print("Done Biatch! 2");
          timer.cancel();
          timerIsOn = false;
        }
      });
    });

    /*double secPercent = (seconds / 100);
      _time = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          if (seconds > 0) {
            if (!timerIsOn) {
              timer.cancel();
              timeInMinutes = 0;
            } else {
              seconds -= 1;
              //print((double.parse((seconds % secPercent).toStringAsFixed(2))));
              if (seconds % 60 == 0) {
                timeInMinutes--;
                print(timeInMinutes);
              }
              if ( seconds % secPercent == 0) {
                if (percent < 0.99) {
                  percent += 0.01;
                } else {
                  percent = 1;
                  print("Done Biatch!");
                }
              }
            }
          } else {
            percent = 0;
            print("Done Biatch!");
            timer.cancel();
            timerIsOn = false;
          }
        });
      });*/
  }

  void turnOffTimer() {
    timerIsOn = false;
    percent = 0;
  }
}
