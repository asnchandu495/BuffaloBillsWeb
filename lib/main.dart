import 'dart:async';
import 'dart:convert';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:webappflutter/viewModel.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key,});


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> values = ['50', '58', '62',  '72', '99',  '103', '52', '57', '65',  '84', '99','107', '57', '62', '69',  '78', '96',  '105',
    '51', '58', '68',  '80', '96',  '100', '40', '54', '66',  '77', '99',  '102', '45', '52', '68',  '84', '91',  '110', ];

  int currentIndex = 0;
  late Timer timer;

  late VideoPlayerController videoPlayerController;

  late ChewieController chewieController;

  String dateTime = DateTime.now().toString();

  late Stream<DateTime> dateTimeStream;

  late DateTime currentTime;
  // EntriesData data = entriesData;

  Future<void> readJson() async {
    final String response = await rootBundle.loadString('assets/data.json');
    final data = await json.decode(response);
    final parsed = EntriesData.fromJson(data);
    setState(() {
      print(parsed);
      entriesData = parsed ;
      print(parsed.totalEntries);
      print(parsed.entriesPerMinute);

    });
  }





@override
  void initState() {
    super.initState();
    startTimer();
    dateTimeStream = Stream.periodic(const Duration(milliseconds: 1), (_){
      return DateTime.now();
    });
    currentTime = DateTime.now();

    dateTimeStream.listen((time) {
      setState(() {
        currentTime = time;
      });
    });
    setState(() {
      readJson();
    });


    videoPlayerController = VideoPlayerController.asset('assets/video.mp4');
    // ..initialize().then((_){
    //   setState(() {
    //     WidgetsBinding.instance.addPostFrameCallback((_) {
    //  videoPlayerController.setLooping(true);
    //  videoPlayerController.play();
    //     });
    //   });
    //
    // });
    chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
      aspectRatio: 16/9,
      autoPlay: true,
      showControls: false,
      looping: true,
      allowFullScreen: false,

    );

  }

  void startTimer(){
    timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        currentIndex = (currentIndex +1 ) % values.length;
        checkAndShowToast(values[currentIndex]);
        if(int.tryParse(values[currentIndex])! >= 100){
        makeApiCall();
        }
      });
    });
  }
  
  Future<void> makeApiCall() async {
    final url = Uri.parse("https://jsonplaceholder.typicode.com/posts");
    final response = await http.get(url);
    if(response.statusCode == 200){
      print("API call success");


    } else {
      print("API call Failed");
    }
  }

  void checkAndShowToast(String value){
    int intValue = int.tryParse(value) ?? 0;
    if(intValue >= 100) {
     Fluttertoast.showToast(msg: 'Gate 4 reached limited people',
     toastLength: Toast.LENGTH_LONG,
     gravity: ToastGravity.BOTTOM,
     textColor: Colors.white,
     backgroundColor: Colors.red,
     webPosition: 'center',
     webBgColor: '#FF0000',
     fontSize: 16.0);

    }
  }
  
  Color getColorForValue(String value){
    int intValue = int.tryParse(value) ?? 0; 
    if(intValue <70 ){
      return Colors.green;
    } else if(intValue >= 70 && intValue <100){
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }


  @override
  Widget build(BuildContext context) {
final formattedTime = DateFormat('d.MM.y.hh.mm.ss').format(currentTime);
    return Scaffold(
      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: const Text("Video Analytics"),
      ),
      body: Row(
        children: <Widget>[

          Expanded(
       flex: 1,
              child: Chewie(controller: chewieController)
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[50],
              padding: const EdgeInsets.only(left: 40, top: 15, bottom: 15),
              child:  Column(

                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Camera Id : AS159BG', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black54),),
                          const Text('Gate no : 4',style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black54),),
                          Text("Time : $formattedTime",style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black54),),
                          const Text('Entries Per Minute : ',style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black54),),
                        ],
                      )
                  ),
                   Center(
                    child: Text(values[currentIndex], style: TextStyle(fontSize: 220, fontWeight: FontWeight.bold, color: getColorForValue(values[currentIndex])),),
                  ),
                   Expanded(
                      child:  Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Entries : ${entriesData.totalEntries ?? ""} ',style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black54),)
                        ],
                      )
                  ),

                ],

              ),
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: (){},
      //   child: const Icon(Icons.add),
      // ),
    );
  }
  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieController.dispose();
    dateTimeStream.drain();
    timer.cancel();
    Fluttertoast.cancel();
    super.dispose();
  }
}