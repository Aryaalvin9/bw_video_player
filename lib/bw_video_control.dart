import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/rendering.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/services.dart';
import 'helper/utils.dart';
import 'package:intl/intl.dart';

class bw_video_control extends StatefulWidget {
  bw_video_control({
    Key? key,
    required this.urlVid,
    required this.isFullWatch
  }) : super(key: key);

  final String urlVid;
  final bool isFullWatch;

  @override
  _bw_video_controlState createState() => _bw_video_controlState();
}

class _bw_video_controlState extends State<bw_video_control> {
  late VideoPlayerController _controller;

  late Future <void> _initialize;

  String durationTotal = "";
  String duration = "";
  bool isBufring = false;
  bool isMute = false;
  bool isFullScreen = false;
  double widthCursore = 200;


  var _isShowingWidgetOutline = false;
  var orientation = Orientation;

  @override
  void initState() {
     _controller = VideoPlayerController.network(widget.urlVid);
     _initialize = _controller.initialize();
      _controller.addListener(() {
        setState(() {
          if(_controller.value.isBuffering){
            isBufring = true;
          }else{
            isBufring = false;
          }
        });
      });
     _controller.setLooping(true);
     _controller.setVolume(1.0);
     durationTotal = formatDuration(_controller.value.duration);
     duration = formatDuration(_controller.value.position);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child:  Stack(
        children: <Widget> [
          FutureBuilder(
            future: _initialize,
            builder: (context, snapshot) {
              if(snapshot.connectionState == ConnectionState.done){
                return AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: Stack(
                    children: <Widget>[
                      VideoPlayer(_controller),
                      Visibility(
                        child: Center(child: CircularProgressIndicator(),),
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        visible: isBufring,
                      )
                    ],
                  )
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                ); 
              }
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
            height: 50,
            color: Color(0x20ffffff),
            margin: EdgeInsets.symmetric(horizontal: 5),
            child:  Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 0),
                child:  IconButton(
                onPressed: (){
                  setState(() {
                    if(_controller.value.isPlaying){
                      _controller.pause();
                    } else{
                      _controller.play();
                    }
                  });
                }, 
                icon: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow_sharp)
                ),
              ),
              Container(
                height: 35,
                child: Stack(
                children: <Widget>[
                    Row(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topLeft,
                          child:Container(
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            child: Text(formatDuration(_controller.value.position), 
                                        style: TextStyle(
                                        fontSize: 12,),
                                    )
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text("/",
                                   style: TextStyle(
                                   fontSize: 12,),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: 5),
                                    child: Text(formatDuration(_controller.value.duration),
                                        style: TextStyle(
                                        fontSize: 12,),
                                    )
                                   ),
                          )
                       
                      ],
                    ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                    width: widthCursore,
                    child: VideoProgressIndicator(_controller, allowScrubbing: widget.isFullWatch),
                  ),
                  )
                ],
                ),
              ),
              Container(
                width: 20,
                margin: EdgeInsets.symmetric(horizontal: 5),
                child:  Align(
                  alignment: Alignment.center,
                  child:  IconButton(
                    onPressed: (){
                      setState(() {
                        if(_controller.value.volume == 1){
                          isMute = true;
                          _controller.setVolume(0);
                        } else{
                          isMute = false;
                          _controller.setVolume(1);
                        }
                      });
                    }, 
                    icon: Icon(isMute ? Icons.volume_off : Icons.volume_up)
                  ),
                )
              ),
              Container(
                  width: 20,
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  child:  Align(
                    alignment: Alignment.center,
                    child:  IconButton(
                      onPressed: (){
                        setState(() {
                        });
                      }, 
                      icon: Icon(Icons.settings)
                    ),
                  )
              ),
              Container(
                width: 20,
                margin: EdgeInsets.symmetric(horizontal: 5),
                child:  Align(
                  alignment: Alignment.center,
                  child:  IconButton(
                    onPressed: (){
                      setState(() {
                        if(MediaQuery.of(context).orientation == Orientation.portrait){
                            SystemChrome.setPreferredOrientations([
                                DeviceOrientation.landscapeLeft,
                                DeviceOrientation.landscapeRight,
                              ]);
                              widthCursore = 460;
                              isFullScreen = true;
                        }else{
                            SystemChrome.setPreferredOrientations([
                              DeviceOrientation.portraitDown,
                              DeviceOrientation.portraitUp,
                            ]);
                            widthCursore = 200;
                            isFullScreen = false;
                        }
                      });
                    }, 
                    icon: Icon(isFullScreen? Icons.fullscreen_exit : Icons.fullscreen)
                  ),
                )
              ),
            ],
          ),
          ),
          )
        ]
      ),
      ) 
    );
  }
}
