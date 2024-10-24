import 'package:advanced_calendar_day_view/src/extensions/date_time_extension.dart';
import 'package:flutter/material.dart';

import '../../models/advanced_day_event.dart';
import '../../models/overflow_event.dart';
import '../../models/typedef.dart';
import '../../widgets/background_ignore_pointer.dart';

class TimeTableViewRow<T extends Object> extends StatefulWidget {
  const TimeTableViewRow({
    Key? key,
    required this.oEvents,
    required this.overflowItemBuilder,
    required this.heightUnit,
    required this.eventColumnWith,
    required this.showMoreOnRowButton,
    this.moreOnRowButton,
    required this.ignored,
    required this.totalHeight,
    required this.cropBottomEvents,
  }) : super(key: key);

  final OverflowEventsRow<T> oEvents;
  final DayViewItemBuilder<T> overflowItemBuilder;
  final double heightUnit;
  final double eventColumnWith;
  final double totalHeight;
  final Widget? moreOnRowButton;
  final bool showMoreOnRowButton;

  final bool cropBottomEvents;

  final bool ignored;

  @override
  State<TimeTableViewRow<T>> createState() => _TimeTableViewRowState<T>();
}

class _TimeTableViewRowState<T extends Object> extends State<TimeTableViewRow<T>> {
  late ScrollController _scrollCtrl;
  bool _atEndOfList = true;

  @override
  void initState() {
    super.initState();
    _atEndOfList = true;
    _scrollCtrl = ScrollController();

    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels == _scrollCtrl.position.maxScrollExtent) {
        if (!_atEndOfList) {
          setState(() {
            _atEndOfList = true;
          });
        }
      } else {
        if (_atEndOfList) {
          setState(() {
            _atEndOfList = false;
          });
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_scrollCtrl.hasClients && _scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent) {
        setState(() {
          _atEndOfList = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = (widget.heightUnit * widget.oEvents.start.minuteUntil(widget.oEvents.end).abs());

    return Container(
      width: widget.eventColumnWith,
      height: maxHeight,
      constraints: BoxConstraints(
        maxHeight: maxHeight,
        minHeight: maxHeight,
      ),
      child: Stack(
        children: [
          ListView.builder(
            controller: _scrollCtrl,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: widget.oEvents.events.length,
            itemBuilder: (context, index) {
              final event = widget.oEvents.events.elementAt(index);
              final width = widget.eventColumnWith / widget.oEvents.events.length;
              final topGap = event.start.minuteFrom(widget.oEvents.start) * widget.heightUnit;

              final tilePossibleHeight = (event.durationInMins * widget.heightUnit);

              final tileHeight = (maxHeight < (topGap + tilePossibleHeight) && widget.cropBottomEvents) ? (maxHeight - topGap) : (event.durationInMins * widget.heightUnit);

              final tileConstraints = BoxConstraints(
                maxHeight: tileHeight,
                minHeight: tileHeight,
                minWidth: width,
                maxWidth: widget.eventColumnWith,
              );

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: topGap),
                  StopBackgroundIgnorePointer(
                    ignored: widget.ignored,
                    child: widget.overflowItemBuilder(
                      context,
                      tileConstraints,
                      index,
                      event,
                    ),
                  ),
                ],
              );
            },
          ),
          if (widget.showMoreOnRowButton)
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  _scrollCtrl.animateTo(
                    (_scrollCtrl.offset + (widget.eventColumnWith - 10)).clamp(
                      0,
                      _scrollCtrl.position.maxScrollExtent,
                    ),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                },
                child: AnimatedOpacity(
                  opacity: _atEndOfList ? 0 : 1,
                  duration: const Duration(milliseconds: 300),
                  child: widget.moreOnRowButton ??
                      Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(color: Colors.black38.withOpacity(.8), shape: BoxShape.circle),
                        child: const Icon(
                          Icons.arrow_right,
                          color: Colors.white,
                        ),
                      ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
