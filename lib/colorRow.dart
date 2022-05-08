import 'package:eventify/eventify.dart' as eventify;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ColorRow extends StatefulWidget {
  final Color color;
  final Function(Color color, int score) setScore;
  final bool inverted;

  const ColorRow(
    this.color,
    this.inverted,
    this.setScore, {
    Key? key,
  }) : super(key: key);

  @override
  State<ColorRow> createState() => _ColorRowState();
}

class _ColorRowState extends State<ColorRow> {
  List buttonsList = [];
  bool lineActive = true;
  bool editable = false;

  eventify.Listener? listner;
  eventify.Listener? listnerEdit;

  bool isActive(int index) {
    if (editable) return true;
    if (!lineActive) return false;
    for (int i = buttonsList.length - 1; i >= 0; i--) {
      if (i < index) return true;
      if (buttonsList[i]) return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    reset();
  }

  void reset() {
    buttonsList = List.generate(11, (index) => false);
    lineActive = true;
    editable = false;
    listner ??= GetIt.I
        .get<eventify.EventEmitter>()
        .on("reset", null, (_, __) => setState(() => reset()));
    listnerEdit ??= GetIt.I
        .get<eventify.EventEmitter>()
        .on("edit", null, (_, __) => setState(() => editable = !editable));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(11, (index) => index)
          .map((idx) => OutlinedButton(
              onPressed: isActive(idx)
                  ? () => setState(() {
                        buttonsList[idx] = !buttonsList[idx];
                        int numberTrue =
                            buttonsList.where((item) => item == true).length;
                        widget.setScore(widget.color, numberTrue);
                        if (idx == 10 && numberTrue >= 5) lineActive = false;
                      })
                  : null,
              child: buttonsList[idx]
                  ? Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        Icon(
                          Icons.close,
                          color: widget.color.withAlpha(98),
                          size: 30,
                        ),
                        Text((calcIndex(idx)).toString())
                      ],
                    )
                  : Text((calcIndex(idx)).toString()),
              style: OutlinedButton.styleFrom(
                side: BorderSide(width: 2.0, color: widget.color),
                primary: widget.color,
              )))
          .toList()
        ..add(OutlinedButton(
            onPressed: () => setState(() {
                  lineActive = !lineActive;
                }),
            child: Icon(lineActive ? Icons.lock_open : Icons.lock))),
    );
  }

  int calcIndex(int idx) => widget.inverted ? 12 - idx : idx + 2;
}
