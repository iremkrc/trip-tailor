import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:flutter_html/flutter_html.dart';


class NotesPage extends StatefulWidget {
  final String tripId;
  const NotesPage({super.key, required this.tripId});
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final DatabaseReference notesRef = FirebaseDatabase.instance.ref();
  List<Map<dynamic, dynamic>> notesList = [];
  bool _isLoading = false;
  late StreamSubscription<DatabaseEvent> _notesSubscription;
  final HtmlEditorController _noteController = HtmlEditorController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _notesSubscription = notesRef.child('notes/${widget.tripId}').onValue.listen((event) {
      var tempNotes = <Map<dynamic, dynamic>>[];
      for (var child in event.snapshot.children) {
        tempNotes.add({
          "key": child.key,
          "data": child.value,
        });}
      if (mounted) {
        setState(() {
          notesList = tempNotes;});
      }});
  }

  @override
  void dispose() {
    _notesSubscription.cancel();
    super.dispose();
  }

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {return null;}
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {return null;}
    }
    if (permission == LocationPermission.deniedForever) {return null;}
    return await Geolocator.getCurrentPosition();
  }

  void _addOrUpdateNote(String note, [String? noteId]) async {
    setState(() {
      _isLoading = true;
    });
    Position? position;
    try {
      position = await _getCurrentLocation();
    } catch (e) {
      position = null;}
    Map<String, dynamic> noteData = {
      'note': note,
      'timestamp': DateTime.now().toIso8601String(),
    };
    if (position != null) {
      noteData['location'] = {
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
    }
    if (noteId == null) {
      await notesRef.child('notes/${widget.tripId}').push().set(noteData);
    } else {
      await notesRef.child('notes/${widget.tripId}/$noteId').update(noteData);
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
    _noteController.clear();
    setState(() {
      _isLoading = false;  });
  }

  void _showAddEditNoteDialog({String? noteId, String initialNote = ''}) {
  if (noteId != null) {
    _noteController.setText(initialNote);
  }
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(noteId == null ? 'Add Note' : 'Edit Note'),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: SingleChildScrollView(
            child: HtmlEditor(
              controller: _noteController,
              htmlEditorOptions: HtmlEditorOptions(
                hint: "Enter your note here...",
                initialText: initialNote,
              ),
              htmlToolbarOptions: const HtmlToolbarOptions(
                toolbarType: ToolbarType.nativeGrid,
              ),
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
              _noteController.clear();
            },
          ),
          TextButton(
            child: const Text('Save'),
            onPressed: () async {
              final String note = await _noteController.getText();
              _addOrUpdateNote(note, noteId);
            },
          ),
        ],
      );
    },
  ).then((_) {
    _noteController.clear();
  });
}
  void _deleteNote(String noteId) {
    notesRef.child('notes/${widget.tripId}/$noteId').remove();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Notes"),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: notesList.length,
                  itemBuilder: (context, index) {
                    var note = notesList[index]['data'];
                    return ListTile(
                      title: Html(data: note['note']),
                      subtitle: Text(
                        "Last updated: ${note['timestamp']}\n"
                            "Location: ${note['location'] != null ? '${note['location']['latitude']}, ${note['location']['longitude']}':'N/A'}",
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showAddEditNoteDialog(
                              noteId: notesList[index]['key'],
                              initialNote: note['note'],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteNote(notesList[index]['key']),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditNoteDialog(),
        tooltip: 'Add Note',
        child: const Icon(Icons.add),
      ),
    );}
}
