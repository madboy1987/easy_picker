library easy_picker;


import 'dart:io';

import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class DirectoryPicker extends StatefulWidget {
  @override
  _DirectoryPickerState createState() => _DirectoryPickerState();
}

class _DirectoryPickerState extends State<DirectoryPicker> {
  List<Directory> nav = [];
  List<Directory> children = [];
  ScrollController scrollController;
  bool canPop = false;

  @override
  void initState() {
    scrollController = ScrollController();
    initDirectories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text('选择目录'),
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: nav.isEmpty
              ? Center(
            child: CircularProgressIndicator(),
          )
              : Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      height: 50,
                      color: Colors.grey[200],
                      child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          controller: scrollController,
                          itemBuilder: (context, index) =>
                              GestureDetector(
                                child: Center(
                                  child: _NavTile(
                                    directory: nav[index],
                                    selected: index == nav.length - 1,
                                    isRoot: index == 0,
                                  ),
                                ),
                                onTap: () async {
                                  if (index == nav.length - 1) {
                                    return;
                                  }
                                  setState(() {
                                    nav.removeRange(
                                        index + 1, nav.length);
                                    getDirectories(nav.last);
                                  });
                                },
                              ),
                          separatorBuilder: (context, index) => Center(
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Text('>'),
                            ),
                          ),
                          itemCount: nav.length),
                    ),
                    Expanded(
                      child: ListView.builder(
                          itemBuilder: (context, index) => ListTile(
                            title: Text(children[index].name),
                            leading: Icon(
                              Icons.folder,
                              color: Colors.amber,
                            ),
                            onTap: () {
                              setState(() {
                                nav.add(children[index]);
                                getDirectories(children[index]);
                              });
                            },
                          ),
                          itemCount: children.length),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                              padding:
                              EdgeInsets.symmetric(horizontal: 10),
                              color: Colors.grey[100],
                              height: 50,
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '已选择：${nav.length == 1 ? '' : nav.last.name}',
                                        style: TextStyle(
                                          color: Colors.lightBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                  RaisedButton(
                                    color: Theme.of(context).primaryColor,
                                    child: Text(
                                      '确定',
                                      style:
                                      TextStyle(color: Colors.white),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(
                                          context,
                                          nav.length == 1
                                              ? null
                                              : nav.last.path);
                                    },
                                  ),
                                ],
                              )),
                        )
                      ],
                    )
                  ],
                ),
              ),
              // selectedUsersControl(),
            ],
          ),
        ),
      ),
      onWillPop: () async {
        if (nav.length == 1 || canPop) {
          return true;
        }
        setState(() {
          nav.removeLast();
          getDirectories(nav.last);
        });
        return false;
      },
    );
  }

  initDirectories() async {
    var path = await ExtStorage.getExternalStorageDirectory();
    setState(() {
      var root = Directory(path);
      nav.add(root);
      getDirectories(root);
    });
  }

  getDirectories(Directory directory) {
    children = [];
    var items = directory.listSync(followLinks: true);
    for (var item in items) {
      if (FileSystemEntity.isFileSync(item.path)) {
        continue;
      }
      var directory = Directory(item.path);
      if (directory.name.startsWith('.')) {
        continue;
      }
      children.add(directory);
    }
    children.sort((a, b) => a.name.compareTo(b.name));
  }
}

class _NavTile extends StatelessWidget {
  final Directory directory;
  final bool selected;
  final bool isRoot;

  _NavTile(
      {@required this.directory,
        @required this.selected,
        @required this.isRoot})
      : assert(directory != null),
        assert(selected != null),
        assert(isRoot != null);

  @override
  Widget build(BuildContext context) {
    String name = directory.name;
    if (isRoot) {
      name = "我的手机";
    }
    if (selected) {
      return Text(
        name,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      );
    }
    return Text(
      name,
      style: TextStyle(color: Colors.grey),
    );
  }
}

extension DirectoryExtension on Directory {
  String get name {
    return p.basename(this.path);
  }
}
