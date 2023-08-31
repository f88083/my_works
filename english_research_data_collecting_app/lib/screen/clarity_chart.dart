import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ClarityChart extends StatefulWidget {
  final String clarityFileName;
  final Directory clarityFilePath;
  const ClarityChart(
      {Key? key, required this.clarityFileName, required this.clarityFilePath})
      : super(key: key);
  @override
  _ClarityChartState createState() => _ClarityChartState();
}

class _ClarityChartState extends State<ClarityChart> {
  List<ClarityRecord> _clarityRecordList = [];
  final TooltipBehavior _tooltipBehavior = TooltipBehavior(enable: true);
  final TrackballBehavior _trackballBehavior = TrackballBehavior(
    enable: true,
    activationMode: ActivationMode.singleTap,
    tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
  );
  final ZoomPanBehavior _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true, zoomMode: ZoomMode.x, enablePanning: true);

  @override
  void initState() {
    readTxtFileIntoClarityRecordList();
    super.initState();
  }

  Future<List<ClarityRecord>> readTxtFileIntoClarityRecordList() async {
    var timeStamp = '';
    var clarityIndicator = '';
    List<ClarityRecord> _recordList = [];
    File file = File(widget.clarityFilePath.path);
    Future<List<String>> clarityStringList = file.readAsLines();
    clarityStringList.then((c) {
      for (var i = 0; i < c.length; i++) {
        if (i == 0) {
          var splitted = c[i].substring(1).split(',');
          timeStamp = splitted[0].trim();
          clarityIndicator = splitted[1].trim();
          _recordList
              .add(ClarityRecord(timeStamp, int.parse(clarityIndicator)));
        } else if (i == c.length - 1) {
          continue;
        } else {
          var splitted = c[i].substring(2).split(',');
          timeStamp = splitted[0].trim();
          clarityIndicator = splitted[1].trim();
          // print('Current timestamp is: $timeStamp');
          // stringDateTimeConverter(timeStamp);
          _recordList
              .add(ClarityRecord(timeStamp, int.parse(clarityIndicator)));
          // print(clarityRecordList.length);
        }
      }
      // print(clarityRecordList.toString());

      // setState(() {
      //   _clarityRecordList = _recordList;
      // });

      assignclarityRecordList(_recordList);
      //print(l);
      return _recordList;
    });
    return _recordList;
  }

  void assignclarityRecordList(List<ClarityRecord> input) {
    setState(() {
      _clarityRecordList = input;
    });
  }

  // DateTime stringDateTimeConverter(String inputStr) {
  //   final DateTime convertedDateTime = DateTime.parse(inputStr);
  //   print('Converted: $convertedDateTime');
  //   return convertedDateTime;
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: SfCartesianChart(
        title: ChartTitle(text: widget.clarityFileName),
        tooltipBehavior: _tooltipBehavior,
        trackballBehavior: _trackballBehavior,
        zoomPanBehavior: _zoomPanBehavior,
        primaryXAxis: CategoryAxis(
            edgeLabelPlacement: EdgeLabelPlacement.shift,
            labelIntersectAction: AxisLabelIntersectAction.multipleRows),
        primaryYAxis: NumericAxis(maximum: 100),
        series: <ChartSeries>[
          FastLineSeries<ClarityRecord, String>(
              name: 'Clarity',
              dataSource: _clarityRecordList,
              dataLabelSettings: const DataLabelSettings(
                  isVisible: true, labelAlignment: ChartDataLabelAlignment.top),
              enableTooltip: true,
              xValueMapper: (ClarityRecord record, _) => record.timeStamp,
              yValueMapper: (ClarityRecord record, _) =>
                  record.clarityIndicator),
        ],
      ),
    ));
  }
}

class ClarityRecord {
  ClarityRecord(this.timeStamp, this.clarityIndicator);
  final String timeStamp;
  final int clarityIndicator;

  @override
  String toString() {
    return '$timeStamp, $clarityIndicator';
  }
}
