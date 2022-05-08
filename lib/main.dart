import 'package:eventify/eventify.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

import 'colorRow.dart';

Future<void> main() async {
  GetIt.I.registerSingleton<EventEmitter>(EventEmitter());
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qwixx Scoreboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(
        title: 'Qwixx Scoreboard',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List rating = [1, 3, 6, 10, 15, 21, 28, 36, 45, 55, 66, 78];

  final List<Color> colors = [
    Colors.red,
    Colors.amberAccent,
    Colors.green,
    Colors.blue,
  ];

  late List<bool> missRolls;

  late Map scores;

  @override
  void initState() {
    super.initState();
    reset();
  }

  void reset() {
    missRolls = List.generate(4, (idx) => false);
    scores = {
      colors[0]: 0,
      colors[1]: 0,
      colors[2]: 0,
      colors[3]: 0,
    };
  }

  void setScore(Color color, int score) {
    setState(() {
      scores[color] = score == 0 ? 0 : rating[score - 1];
    });
  }

  void setMissRolls(bool? b, int idx) {
    setState(() {
      missRolls[idx] = b!;
    });
  }

  int calcMissRollsScore() =>
      missRolls.where((element) => element == true).length * 5;

  @override
  Widget build(BuildContext context) {
    var minHeight = 264.7;
    var minWidth = 818.9;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              GetIt.I.get<EventEmitter>().emit("edit");
            },
            icon: const Icon(Icons.edit),
            tooltip: "edit all buttons",
          ),
          IconButton(
            onPressed: () {
              GetIt.I.get<EventEmitter>().emit("reset");
              setState(() {
                reset();
              });
              return;
            },
            icon: const Icon(IconData(0xe514, fontFamily: 'MaterialIcons')),
            tooltip: "rest board",
          ),
        ],
      ),

      body: Container(
        constraints: const BoxConstraints.expand(),
        padding: const EdgeInsets.all(16.0),
        child: FittedBox(
          alignment: Alignment.topCenter,
          fit: BoxFit.contain,
          child: SizedBox(
            height: minHeight,
            width: minWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var color in colors.sublist(0, 2))
                  ColorRow(color, false, setScore),
                for (var color in colors.sublist(2, 4))
                  ColorRow(color, true, setScore),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: null,
                      child: Text(scores[colors[0]].toString()),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(width: 2.0, color: colors[0]),
                        primary: colors[0],
                      ),
                    ),
                    const Text("+"),
                    OutlinedButton(
                      onPressed: null,
                      child: Text(scores[colors[1]].toString()),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(width: 2.0, color: colors[1]),
                        primary: colors[1],
                      ),
                    ),
                    const Text("+"),
                    OutlinedButton(
                      onPressed: null,
                      child: Text(scores[colors[2]].toString()),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(width: 2.0, color: colors[2]),
                        primary: colors[2],
                      ),
                    ),
                    const Text("+"),
                    OutlinedButton(
                      onPressed: null,
                      child: Text(scores[colors[3]].toString()),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(width: 2.0, color: colors[3]),
                        primary: colors[3],
                      ),
                    ),
                    const Text("-"),
                    OutlinedButton(
                      onPressed: null,
                      child: Text((calcMissRollsScore()).toString()),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(width: 2.0, color: Colors.grey),
                        primary: Colors.grey,
                      ),
                    ),
                    const Text("="),
                    OutlinedButton(
                      onPressed: null,
                      child: Text((scores.values
                                  .reduce((value, element) => value + element) -
                              calcMissRollsScore())
                          .toString()),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(width: 2.0, color: Colors.grey),
                        primary: Colors.grey,
                      ),
                    ),
                    for (var i in List.generate(4, (index) => index))
                      Checkbox(
                        onChanged: (b) => setMissRolls(b, i),
                        value: missRolls[i],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
