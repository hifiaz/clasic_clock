// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:analog_clock/minute_hand.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' show radians;

import 'container_hand.dart';
import 'drawn_hand.dart';

/// Total distance traveled by a second or a minute hand, each second or minute,
/// respectively.
final radiansPerTick = radians(360 / 60);

/// Total distance traveled by an hour hand, each hour, in radians.
final radiansPerHour = radians(360 / 12);

/// A basic analog clock.
///
/// You can do better than this!
class AnalogClock extends StatefulWidget {
  const AnalogClock(this.model);

  final ClockModel model;

  @override
  _AnalogClockState createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock> {
  var _now = DateTime.now();
  var _temperature = '';
  // var _temperatureRange = '';
  var _condition = '';
  var _location = '';
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    // Set the initial values.
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(AnalogClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _temperature = widget.model.temperatureString;
      // _temperatureRange = '(${widget.model.low} - ${widget.model.highString})';
      _condition = widget.model.weatherString;
      _location = widget.model.location;
    });
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
      // Update once per second. Make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
    });
  }

  String weather(String value) {
    if (value == 'foggy') {
      return 'assets/foggy.png';
    } else if (value == 'rainy') {
      return 'assets/rainy.png';
    } else if (value == 'snowy') {
      return 'assets/snowy.png';
    } else if (value == 'sunny') {
      return 'assets/sunny.png';
    } else if (value == 'thunderstorm') {
      return 'assets/thunderstorm.png';
    } else if (value == 'windy') {
      return 'assets/windy.png';
    } else {
      return 'assets/cloudy.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    // There are many ways to apply themes to your clock. Some are:
    //  - Inherit the parent Theme (see ClockCustomizer in the
    //    flutter_clock_helper package).
    //  - Override the Theme.of(context).colorScheme.
    //  - Create your own [ThemeData], demonstrated in [AnalogClock].
    //  - Create a map of [Color]s to custom keys, demonstrated in
    //    [DigitalClock].
    final customTheme = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).copyWith(
            // Hour hand.
            primaryColor: Color(0xFFddd4c4),
            // Minute hand.
            highlightColor: Color(0xFFddd4c4),
            // Second hand.
            accentColor: Color(0xFFfb3b2f),
            backgroundColor: Color(0xFF12445f),
          )
        : Theme.of(context).copyWith(
            primaryColor: Color(0xFFD2E3FC),
            highlightColor: Color(0xFFddd4c4),
            accentColor: Color(0xFF8AB4F8),
            backgroundColor: Color(0xFF3C4043),
          );

    final time = DateFormat.Hms().format(DateTime.now());
    // final weatherInfo = DefaultTextStyle(
    //   style: TextStyle(color: customTheme.primaryColor),
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       Text(_temperature),
    //       Text(_temperatureRange),
    //       Text(_condition),
    //       Text(_location),
    //     ],
    //   ),
    // );

    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Analog clock with time $time',
        value: time,
      ),
      child: Container(
        color: customTheme.backgroundColor,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: line(customTheme.highlightColor),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: line(customTheme.highlightColor),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: line(customTheme.highlightColor),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: line(customTheme.highlightColor),
            ),
            // temperature(),
            location(),
            // Example of a hand drawn with [CustomPainter].

            // Example of a hand drawn with [Container].
            ContainerHand(
              color: Colors.transparent,
              size: 0.5,
              angleRadians: _now.hour * radiansPerHour +
                  (_now.minute / 60) * radiansPerHour,
              child: Transform.translate(
                offset: Offset(0.0, -60.0),
                child: Container(
                  width: 32,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Color(0xff161614),
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                  child: Container(
                    width: 20,
                    height: 100,
                    margin: EdgeInsets.only(
                      bottom: 40.0,
                      right: 8.0,
                      left: 8.0,
                      top: 8.0,
                    ),
                    decoration: BoxDecoration(
                      color: customTheme.highlightColor,
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                  ),
                ),
              ),
            ),
            MinuteHand(
              color: customTheme.highlightColor,
              thickness: 8,
              size: 0.9,
              angleRadians: _now.minute * radiansPerTick,
            ),
            DrawnHand(
              color: customTheme.accentColor,
              thickness: 3,
              size: 1,
              angleRadians: _now.second * radiansPerTick,
            ),

            // Positioned(
            //   left: 0,
            //   bottom: 0,
            //   child: Padding(
            //     padding: const EdgeInsets.all(8),
            //     child: weatherInfo,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget location() {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 100.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _location,
              style: TextStyle(color: Colors.white),
            ),
            Text(
              _temperature,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 5),
            condition()
          ],
        ),
      ),
    );
  }

  Widget condition() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 45.0,
            height: 45.0,
            decoration: BoxDecoration(
                color: Color(0xff161614),
                border: Border.all(
                  width: 3.0,
                  color: Colors.black,
                ),
                borderRadius: BorderRadius.circular(50)),
            child: Padding(
                padding: EdgeInsets.all(5),
                child: Image.asset(
                  weather(_condition),
                )),
          ),
          SizedBox(height: 5),
          Text(
            _condition,
            style: TextStyle(color: Colors.white),
          )
        ],
      ),
    );
  }

  Widget line(Color value) {
    return Container(
      width: 35.0,
      height: 15.0,
      margin: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: value,
        borderRadius: BorderRadius.all(Radius.circular(32.0)),
      ),
    );
  }
}

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width, 0.0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(TriangleClipper oldClipper) => false;
}
