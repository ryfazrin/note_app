import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:note_app/data/models.dart';
import 'package:note_app/services/database.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class ViewNotePage extends StatefulWidget {
  Function() triggerRefetch;
  NotesModel currentNote;
  ViewNotePage({Key key, Function() triggerRefetch, NotesModel currentNote})
      : super(key: key) {
    this.triggerRefetch = triggerRefetch;
    this.currentNote = currentNote;
  }

  @override
  _ViewNotePageState createState() => _ViewNotePageState();
}

class _ViewNotePageState extends State<ViewNotePage> {
  @override
  void initState() {
    super.initState();
    showHeader();
  }

  void showHeader() async {
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        headerShouldShow = true;
      });
    });
  }

  bool headerShouldShow = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          ListView(
            physics: BouncingScrollPhysics(),
            children: <Widget>[
              Container(height: 40),
              Padding(
                padding: const EdgeInsets.only(
                    left: 24.0, right: 24.0, top: 40.0, bottom: 16),
                child: AnimatedOpacity(
                  opacity: headerShouldShow ? 1 : 0,
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeIn,
                  child: Text(
                    widget.currentNote.title,
                    style: TextStyle(
                      fontFamily: 'ZillaSlab',
                      fontWeight: FontWeight.w700,
                      fontSize: 36,
                    ),
                    overflow: TextOverflow.visible,
                    softWrap: true,
                  ),
                ),
              ),
              AnimatedOpacity(
                opacity: headerShouldShow ? 1 : 0,
                duration: Duration(milliseconds: 500),
                child: Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Text(
                    DateFormat.yMd().add_jm().format(widget.currentNote.date),
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade500),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 24.0, top: 36, bottom: 24, right: 24),
                child: Text(
                  widget.currentNote.content,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              )
            ],
          ),
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                height: 80,
                color: Theme.of(context).canvasColor.withOpacity(0.3),
                child: SafeArea(
                    child: Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: handleBack,
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(widget.currentNote.isImportant
                          ? Icons.flag
                          : Icons.outlined_flag),
                      onPressed: () {
                        markImportantAsDirty();
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline),
                      onPressed: handleDelete,
                    ),
                    IconButton(
                      icon: Icon(OMIcons.share),
                      onPressed: handleShare,
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: handleEdit,
                    ),
                  ],
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void handlesave() async {
    await NotesDatabaseService.db.updateNoteInDB(widget.currentNote);
    widget.triggerRefetch();
  }

  void markImportantAsDirty() {
    setState(() {
      widget.currentNote.isImportant = !widget.currentNote.isImportant;
    });
    handlesave();
  }

  void handleDelete() {}

  void handleShare() {}

  void handleEdit() {}

  void handleBack() {}
}
