import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    title: 'SGA',
    debugShowCheckedModeBanner: false,
    home: Notice(),
  ));
}

class Notice extends StatefulWidget {
  @override
  _NoticeState createState() => _NoticeState();
}

class _NoticeState extends State<Notice> {
  var noticeData;
  var _multiple = "", dropdownValue, number = '', text = '', checkbox = '';

  Future _getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _multiple = prefs.getString('_multiple');
      dropdownValue = prefs.getString('dropdownValue');
      number = prefs.getString('number');
      text = prefs.getString('text');
      checkbox = prefs.getString('checkbox');
    });

    var response =
        await http.get("https://example-response.herokuapp.com/getSurvey");
    setState(() {
      noticeData = json.decode(response.body);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: noticeData == null
          ? Center(
              child: Text('Loading...'),
            )
          : ListView(
              children: [
                ListView.builder(
                    primary: false,
                    shrinkWrap: true,
                    itemCount: noticeData.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: <Widget>[
                              ListTile(
                                leading: noticeData[index]["required"] == true
                                    ? Required()
                                    : null,
                                title: Text(
                                  noticeData[index]["question"],
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: type(noticeData[index]),
                                      ),
                                      color: Colors.white60,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    }),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RaisedButton(
                      onPressed: () async {
                        //print(_required);
                        print(_multiple+dropdownValue+number+checkbox);
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.setString('_multiple', _multiple);
                        prefs.setString('dropdownValue', dropdownValue);
                        prefs.setString('number', number);
                        prefs.setString('text', text);
                        prefs.setString('checkbox', checkbox);
                        Fluttertoast.showToast(
                            msg: "Submitted",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0);

                      },
                      textColor: Colors.white,
                      padding: const EdgeInsets.all(0.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          gradient: LinearGradient(
                            colors: <Color>[
                              Color(0xFF0D47A1),
                              Color(0xFF1976D2),
                              Color(0xFF42A5F5),
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.all(10.0),
                        child:
                        const Text('Submit', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                  ),
                )
              ],
            ),
    );
  }

  Widget type(data) {
    var type = data['type'];
    if (type == 'Checkbox') {

      var option = data['options'];
      var optionList = option.split(', ');
      return ListView.builder(
        shrinkWrap: true,
        primary: false,
        itemCount: optionList.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            decoration: BoxDecoration(
                color: Colors.white60, borderRadius: BorderRadius.circular(3)),
            child: CheckboxListTile(
              value: checkbox == optionList[index] ? true : false,
              onChanged: (value) {
                setState(() {
                  checkbox = optionList[index];
                });
              },
              title: Text(optionList[index]),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          );
        },
      );
    } else if (type == 'multiple choice') {

      var option = data['options'];
      var optionList = option.split(', ');
      return ListView.builder(
        primary: false,
        shrinkWrap: true,
        itemCount: optionList.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            alignment: Alignment.centerLeft,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    color: _multiple == optionList[index]
                        ? Colors.red
                        : Colors.white60,
                    child: Text(
                      optionList[index],
                      textAlign: TextAlign.left,
                    ),
                    onPressed: () {
                      setState(() {
                        _multiple = optionList[index];
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else if (type == 'text') {

      return Row(
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white60,
                  borderRadius: BorderRadius.circular(3)),
              child: TextField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: text,
                  hintStyle: TextStyle(color: Colors.black),
                ),

                onChanged: (value) {
                  setState(() {
                    text = value;
                  });
                }
              ),
            ),
          )
        ],
      );
    } else if (type == 'number') {

      return Row(
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white60,
                  borderRadius: BorderRadius.circular(3)),
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: number,
                  hintStyle: TextStyle(color: Colors.black),
                ),
                  onChanged: (value) {
                    setState(() {
                      number = value;
                    });
                  }
              ),
            ),
          )
        ],
      );
    } else if (type == 'dropdown') {

      var option = data['options'];
      var optionList = option.split(', ');
      return Row(
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white60,
                  borderRadius: BorderRadius.circular(3)),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: DropdownButton<String>(
                  value: dropdownValue == null ? optionList[0] : dropdownValue,
                  style: TextStyle(color: Colors.black),
                  underline: Container(
                    height: 2,
                    color: Colors.black,
                  ),
                  onChanged: (String newValue) {
                    setState(() {
                      dropdownValue = newValue;

                    });
                  },
                  items:
                      optionList.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget Required() {
    return CircleAvatar(
        radius: 1,
        child: Icon(
          Icons.star,
          color: Colors.red,
        ));
  }
}

class Data {
  var question, type, options, required;

  Data({this.question, this.type, this.options, this.required});
}
