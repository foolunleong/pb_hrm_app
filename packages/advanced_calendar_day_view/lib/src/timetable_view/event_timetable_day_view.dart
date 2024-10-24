import 'package:advanced_calendar_day_view/src/extensions/date_time_extension.dart';
import 'package:flutter/material.dart';

import '../models/advanced_day_event.dart';
import '../models/typedef.dart';

/// Day View that only show time slot with Events
///
/// this day view doesn't display with a fixed time gap
/// it listed and sorted by the time that the events start
class EventTimeTableDayView<T extends Object> extends StatefulWidget {
  const EventTimeTableDayView({
    Key? key,
    required this.events,
    required this.eventDayViewItemBuilder,
    this.timeTextColor,
    this.timeTextStyle,
    this.dividerColor,
    this.itemSeparatorBuilder,
    this.rowPadding,
    this.timeSlotPadding,
    this.primary,
    this.physics,
    this.controller,
    this.timeTitleColumnWidth = 50.0,
    this.time12 = false,
    this.showHourly = false,
  }) : super(key: key);

  /// List of events to be display in the day view
  final List<AdvancedDayEvent<T>> events;

  /// color of time point label
  final Color? timeTextColor;

  /// style of time point label
  final TextStyle? timeTextStyle;

  /// builder for each item
  final EventDayViewItemBuilder<T> eventDayViewItemBuilder;

  /// build separator between each item
  final IndexedWidgetBuilder? itemSeparatorBuilder;

  /// time slot divider color
  final Color? dividerColor;

  /// padding for event row
  final EdgeInsetsGeometry? rowPadding;

  ///padding for time slot
  final EdgeInsetsGeometry? timeSlotPadding;

  final bool? primary;
  final ScrollPhysics? physics;
  final ScrollController? controller;

  /// show time in 12 hour format
  final bool time12;

  /// show event by hour only
  final bool showHourly;

  /// The width of the column that contain list of time points
  final double timeTitleColumnWidth;

  @override
  State<EventTimeTableDayView> createState() => _EventTimeTableDayViewState<T>();
}

class _EventTimeTableDayViewState<T extends Object> extends State<EventTimeTableDayView<T>> {
  List<DateTime> _timesInDay = [];

  @override
  void initState() {
    super.initState();
    _timesInDay = getTimeList();
  }

  List<DateTime> getTimeList() {
    Set<DateTime> list = {};
    list.addAll(widget.events.map((e) => widget.showHourly ? e.start.hourOnly() : e.start.cleanSec()).toList()
      ..sort(
        (a, b) {
          int hourComparison = a.hour.compareTo(b.hour);
          if (hourComparison != 0) {
            return hourComparison;
          } else {
            return a.minute.compareTo(b.minute);
          }
        },
      ));
    return list.toList();
  }

  @override
  void didUpdateWidget(covariant EventTimeTableDayView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _timesInDay = getTimeList();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SafeArea(
          child: ListView.builder(
            shrinkWrap: true,
            primary: widget.primary,
            controller: widget.controller,
            physics: widget.physics ?? const ClampingScrollPhysics(),
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            itemCount: _timesInDay.length,
            itemBuilder: (context, index) {
              final time = _timesInDay.elementAt(index);
              final events = widget.events.where(
                (event) => widget.showHourly ? event.startAtHour(time) : event.startAt(time),
              );

              return Padding(
                padding: widget.timeSlotPadding ?? const EdgeInsets.symmetric(vertical: 5),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Divider(
                      color: widget.dividerColor ?? Colors.amber,
                      height: 0,
                      thickness: 1,
                      indent: widget.timeTitleColumnWidth + 3,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Transform(
                          transform: Matrix4.translationValues(0, -20, 0),
                          child: SizedBox(
                            height: 40,
                            width: widget.timeTitleColumnWidth,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                widget.time12 ? time.hourDisplay12 : time.hourDisplay24,
                                style: widget.timeTextStyle ?? TextStyle(color: widget.timeTextColor),
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: widget.rowPadding ?? const EdgeInsets.all(0),
                            child: ListView.separated(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: events.length,
                              separatorBuilder: widget.itemSeparatorBuilder ?? (context, index) => const SizedBox(height: 5),
                              itemBuilder: (context, index) {
                                return widget.eventDayViewItemBuilder(
                                  context,
                                  index,
                                  events.elementAt(index),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}