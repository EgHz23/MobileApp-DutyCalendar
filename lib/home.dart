// lib/home.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  Map<DateTime, List<Map<String, dynamic>>> _events = {};
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final List<String> _calendarFormats = ['Week', 'Month'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Events',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.blueAccent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _calendarFormat == CalendarFormat.month ? 'Month' : 'Week',
                onChanged: (String? newValue) {
                  setState(() {
                    if (newValue == 'Month') {
                      _calendarFormat = CalendarFormat.month;
                    } else {
                      _calendarFormat = CalendarFormat.week;
                    }
                  });
                },
                items: _calendarFormats
                    .map((format) => DropdownMenuItem<String>(
                          value: format,
                          child: Text(format),
                        ))
                    .toList(),
                icon: Icon(Icons.calendar_view_month, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarStyle: CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      shape: BoxShape.circle,
                    ),
                    markersMaxCount: 1,
                    markerDecoration: BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  eventLoader: (day) => _events[day] ?? [],
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: (_events[_selectedDay] ?? [])
                    .map((event) => Dismissible(
                          key: Key(event['name']),
                          background: Container(
                            color: Colors.blue,
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(left: 20),
                            child: Icon(Icons.edit, color: Colors.white),
                          ),
                          secondaryBackground: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: 20),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.startToEnd) {
                              _editEventDialog(context, event);
                              return false;
                            } else if (direction == DismissDirection.endToStart) {
                              return await _confirmDeleteDialog(context);
                            }
                            return false;
                          },
                          onDismissed: (direction) {
                            setState(() {
                              _events[_selectedDay]?.remove(event);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Event deleted")),
                            );
                          },
                          child: Card(
                            margin: EdgeInsets.symmetric(vertical: 5),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              title: Text(
                                event['name'],
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                "Time: ${event['time'].format(context)}",
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              trailing: Icon(
                                Icons.edit,
                                color: Colors.blueAccent,
                              ),
                              onTap: () => _editEventDialog(context, event),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addEventDialog(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  Future<bool> _confirmDeleteDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text("Confirm Delete", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to delete this event?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;
  }

  void _addEventDialog(BuildContext context) {
    final TextEditingController _eventController = TextEditingController();
    TimeOfDay? _selectedTime;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text("Add Event", style: TextStyle(fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _eventController,
                  decoration: InputDecoration(hintText: "Enter event name"),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () async {
                    _selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (_selectedTime != null) {
                      setState(() {}); // Trigger the dialog to rebuild and show selected time
                    }
                  },
                  child: Text(
                    _selectedTime == null
                        ? "Select Time"
                        : "Time: ${_selectedTime!.format(context)}",
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  if (_eventController.text.isNotEmpty && _selectedTime != null) {
                    setState(() {
                      final newEvent = {
                        'name': _eventController.text,
                        'time': _selectedTime!,
                      };
                      if (_events[_selectedDay] != null) {
                        _events[_selectedDay]!.add(newEvent);
                      } else {
                        _events[_selectedDay] = [newEvent];
                      }
                      // Sort events by time
                      _events[_selectedDay]!.sort((a, b) =>
                          a['time'].hour.compareTo(b['time'].hour) == 0
                              ? a['time'].minute.compareTo(b['time'].minute)
                              : a['time'].hour.compareTo(b['time'].hour));
                    });
                  }
                  Navigator.pop(context);
                },
                child: Text("Add", style: TextStyle(color: Colors.blueAccent)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _editEventDialog(BuildContext context, Map<String, dynamic> event) {
    final TextEditingController _eventController = TextEditingController(text: event['name']);
    TimeOfDay _selectedTime = event['time'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text("Edit Event", style: TextStyle(fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _eventController,
                  decoration: InputDecoration(hintText: "Edit event name"),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () async {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime,
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _selectedTime = pickedTime;
                      });
                    }
                  },
                  child: Text("Time: ${_selectedTime.format(context)}"),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    if (_eventController.text.isNotEmpty) {
                      final eventIndex = _events[_selectedDay]!.indexOf(event);
                      _events[_selectedDay]![eventIndex] = {
                        'name': _eventController.text,
                        'time': _selectedTime,
                      };
                      // Sort events by time
                      _events[_selectedDay]!.sort((a, b) =>
                          a['time'].hour.compareTo(b['time'].hour) == 0
                              ? a['time'].minute.compareTo(b['time'].minute)
                              : a['time'].hour.compareTo(b['time'].hour));
                    }
                  });
                  Navigator.pop(context);
                },
                child: Text("Save", style: TextStyle(color: Colors.blueAccent)),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _events[_selectedDay]?.remove(event);
                  });
                  Navigator.pop(context);
                },
                child: Text("Delete", style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      ),
    );
  }
}
