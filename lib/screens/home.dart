import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:note_app/components/cards.dart';
import 'package:note_app/components/faderoute.dart';
import 'package:note_app/data/models.dart';
import 'package:note_app/screens/edit.dart';
import 'package:note_app/screens/settings.dart';
import 'package:note_app/screens/view.dart';
import 'package:note_app/services/database.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class MyHomePage extends StatefulWidget {
  Function(Brightness brightness) changeTheme;
  MyHomePage({Key key, this.title, Function(Brightness brightness) changeTheme})
      : super(key: key) {
    this.changeTheme = changeTheme;
  }

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isFlagOn = false;
  bool headerShouldHide = false;
  List<NotesModel> notesList = [];
  TextEditingController searchController = TextEditingController();

  bool isSearchEmpty = true;

  @override
  void initState() {
    super.initState();
    NotesDatabaseService.db.init();
    setNotesFromDB();
  }

  setNotesFromDB() async {
    print("Entered setNotes");
    var fetchedNotes = await NotesDatabaseService.db.getNotesFromDB();
    setState(() {
      notesList = fetchedNotes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          gotoEditNote();
        },
        label: Text('Add Note'.toUpperCase()),
        icon: Icon(Icons.add),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          margin: EdgeInsets.only(top: 2),
          padding: EdgeInsets.only(left: 15, right: 15),
          child: ListView(
            physics: BouncingScrollPhysics(),
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) =>
                              // SettingsPage(changeTheme: widget.changeTheme),
                              SettingsPage(),
                        ),
                      );
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      padding: EdgeInsets.all(16),
                      alignment: Alignment.centerRight,
                      child: Icon(
                        OMIcons.settings,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.grey.shade600
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ],
              ),
              buildHeaderWidget(context),
              buildButtonRow(),
              buildImportantIndicatorText(),
              Container(height: 32),
              ...buildNoteComponentsList(),
              GestureDetector(
                  onTap: gotoEditNote, child: AddNoteCardComponent()),
              Container(height: 100)
            ],
          ),
        ),
      ),
    );
  }

  Widget buildButtonRow() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              setState(() {
                isFlagOn = !isFlagOn;
              });
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 160),
              height: 50,
              width: 50,
              curve: Curves.slowMiddle,
              child: Icon(
                isFlagOn ? Icons.flag : OMIcons.flag,
                color: isFlagOn ? Colors.white : Colors.grey.shade300,
              ),
              decoration: BoxDecoration(
                  color: isFlagOn ? Colors.blue : Colors.transparent,
                  border: Border.all(
                    width: isFlagOn ? 2 : 1,
                    color:
                        isFlagOn ? Colors.blue.shade700 : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(16))),
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(left: 8),
              padding: EdgeInsets.only(left: 16),
              height: 50,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.all(Radius.circular(16))),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      maxLines: 1,
                      onChanged: (value) {
                        handleSearch(value);
                      },
                      autofocus: false,
                      keyboardType: TextInputType.text,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration.collapsed(
                        hintText: 'Search...',
                        hintStyle: TextStyle(
                            color: Colors.grey.shade300,
                            fontSize: 18,
                            fontWeight: FontWeight.w500),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: cancelSearch,
                    icon: Icon(isSearchEmpty ? Icons.search : Icons.cancel,
                        color: Colors.grey.shade300),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHeaderWidget(BuildContext context) {
    return Row(
      children: <Widget>[
        AnimatedContainer(
          duration: Duration(milliseconds: 200),
          curve: Curves.easeIn,
          margin: EdgeInsets.only(top: 8, bottom: 32, left: 10),
          width: headerShouldHide ? 0 : 200,
          child: Text(
            'Your Notes',
            style: TextStyle(
                fontFamily: 'ZillaSlab',
                fontWeight: FontWeight.w700,
                fontSize: 36,
                color: Theme.of(context).primaryColor),
            overflow: TextOverflow.clip,
            softWrap: false,
          ),
        )
      ],
    );
  }

  Widget testListItem(Color color) {
    return NoteCardComponent(
      noteData: NotesModel.random(),
    );
  }

  Widget buildImportantIndicatorText() {
    return AnimatedCrossFade(
      firstChild: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          'Only showing notes marked important'.toUpperCase(),
          style: TextStyle(
              fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w500),
        ),
      ),
      secondChild: Container(
        height: 2,
      ),
      crossFadeState:
          isFlagOn ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      duration: Duration(milliseconds: 200),
    );
  }

  List<Widget> buildNoteComponentsList() {
    List<Widget> noteComponentList = [];
    notesList.sort((a, b) {
      return b.date.compareTo(a.date);
    });
    if (searchController.text.isNotEmpty) {
      notesList.forEach((note) {
        if (note.title
                .toLowerCase()
                .contains(searchController.text.toLowerCase()) ||
            note.content
                .toLowerCase()
                .contains(searchController.text.toLowerCase()))
          noteComponentList.add(NoteCardComponent(
            noteData: note,
            onTapAction: openNoteToRead,
          ));
      });
      return noteComponentList;
    }
    if (isFlagOn) {
      notesList.forEach((note) {
        if (note.isImportant)
          noteComponentList.add(NoteCardComponent(
            noteData: note,
            onTapAction: openNoteToRead,
          ));
      });
    } else {
      notesList.forEach((note) {
        noteComponentList.add(NoteCardComponent(
          noteData: note,
          onTapAction: openNoteToRead,
        ));
      });
    }
    return noteComponentList;
  }

  void handleSearch(String value) {
    if (value.isNotEmpty) {
      setState(() {
        isSearchEmpty = false;
      });
    } else {
      setState(() {
        isSearchEmpty = true;
      });
    }
  }

  void gotoEditNote() {
    Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) =>
              // EditNotePage(triggerRefetch: refetchNotesFromDB),
              EditNotePage(),
        ));
  }

  void refetchNotesFromDB() async {
    await setNotesFromDB();
    print("Refetched notes");
  }

  openNoteToRead(NotesModel noteData) async {
    setState(() {
      headerShouldHide = true;
    });
    await Future.delayed(Duration(milliseconds: 230), () {});
    Navigator.push(
        context,
        FadeRoute(
            page: ViewNotePage(
                triggerRefetch: refetchNotesFromDB, currentNote: noteData)));
    await Future.delayed(Duration(milliseconds: 300), () {});

    setState(() {
      headerShouldHide = false;
    });
  }

  void cancelSearch() {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      searchController.clear();
      isSearchEmpty = true;
    });
  }
}
