import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, double> users = Map();
  List<String> userNames = List();

  _readSavedUserData() async {
    final prefs = await SharedPreferences.getInstance();

    final userDataKeys = prefs.getKeys() ?? new List();

    setState(() {
      for (var key in userDataKeys) {
        userNames.add(key);
        users[key] = prefs.getDouble(key);
      }
    });
  }

  _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String nKey;
    double nValue;
    users.forEach((name, amount) {
      nKey = name;
      nValue = amount;
      prefs.setDouble(nKey, nValue);
    });
  }

  _deleteUserData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }

  @override
  void initState() {
    super.initState();
    _readSavedUserData();
  }

  createUserPopupDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController amountController = TextEditingController();

    Size size = MediaQuery.of(context).size;

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Add new entry...",
              textAlign: TextAlign.center,
            ),
            content: Container(
              width: size.width * 0.8,
              height: size.height * 0.2,
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: Container(
                        width: size.width *
                            0.5, //MediaQuery.of(context).size.width * 0.50,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: "Name",
                          ),
                          controller: nameController,
                        )),
                  ),
                  ListTile(
                      leading: Container(
                          width: size.width *
                              0.5, //MediaQuery.of(context).size.width * 0.50,
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: "Amount",
                            ),
                            controller: amountController,
                          ))),
                ],
              ),
            ),
            actions: <Widget>[
              MaterialButton(
                elevation: 5.0,
                child: Text("Give"),
                textColor: Colors.blue,
                onPressed: () {
                  String name = nameController.text.toString();
                  double amount =
                      double.tryParse(amountController.text.toString()) ??
                          double.infinity;
                  if (name != "" && amount != double.infinity) {
                    createUser(name, amount);
                    Navigator.of(context).pop();
                  }
                },
              ),
              MaterialButton(
                elevation: 5.0,
                child: Text("Take"),
                textColor: Colors.blue,
                onPressed: () {
                  String name = nameController.text.toString();
                  double amount =
                      double.tryParse(amountController.text.toString()) ??
                          double.infinity;
                  if (name != "" && amount != double.infinity) {
                    createUser(name, -amount);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        });
  }

  updateUserPopupDialog(BuildContext context, String name) {
    TextEditingController amountController = TextEditingController();

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Update entry..."),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(name),
                TextField(
                  decoration: InputDecoration(
                    labelText: "Amount",
                  ),
                  controller: amountController,
                ),
              ],
            ),
            actions: <Widget>[
              MaterialButton(
                elevation: 5.0,
                child: Text("Give"),
                onPressed: () {
                  double amount =
                      double.tryParse(amountController.text.toString()) ??
                          double.infinity;
                  if (amount != double.infinity) {
                    updateAmount(name, amount);
                    Navigator.of(context).pop();
                  }
                },
              ),
              MaterialButton(
                elevation: 5.0,
                child: Text("Take"),
                onPressed: () {
                  double amount =
                      double.tryParse(amountController.text.toString()) ??
                          double.infinity;
                  if (amount != double.infinity) {
                    updateAmount(name, -amount);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        });
  }

  deleteUserPopupDialog(BuildContext context, String name) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Delete?"),
            content: Text("Are you sure you want to delte entry for $name"),
            actions: <Widget>[
              MaterialButton(
                elevation: 5.0,
                child: Text("No"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              MaterialButton(
                elevation: 5.0,
                child: Text("Yes"),
                onPressed: () {
                  deleteUser(name);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void createUser(String name, double amount) {
    try {
      if (!users.containsKey(name)) {
        setState(() {
          users[name] = amount;
          userNames.add(name);
        });
      } else {
        updateAmount(name, amount);
      }
    } catch (e) {
      print(e.toString());
    }

    _saveUserData();
  }

  void deleteUser(String name) {
    if (users.containsKey(name)) {
      setState(() {
        users.remove(name);
        userNames.remove(name);
        _deleteUserData(name);
      });
    } else {
      print("$name does not exist.");
    }

    _saveUserData();
  }

  void updateAmount(String name, double amount) {
    try {
      setState(() {
        users[name] += amount;
      });
    } catch (e) {
      print(e);
    }

    _saveUserData();
  }

  @override
  Widget build(BuildContext context) {
    //  FirebaseAdMob.instance.initialize(appId: "").then((response) {
    //    myBanner
    //      ..load()
    //      ..show();
    //  });
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: getListView(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => createUserPopupDialog(context),
      ),
    );
  }

  Widget getListView() {
    var listView = ListView.builder(
      itemCount: userNames.length,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            title: Text(userNames[index]),
            trailing: Text(
              users[userNames[index]].toString(),
              style: TextStyle(
                  color: users[userNames[index]] > 0
                      ? Colors.green
                      : users[userNames[index]] == 0
                          ? Colors.black
                          : Colors.redAccent),
            ),
            onTap: () => updateUserPopupDialog(context, userNames[index]),
            onLongPress: () => deleteUserPopupDialog(context, userNames[index]),
          ),
        );
      },
    );

    return listView;
  }

  //static MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
  //  keywords: <String>['games', 'pubg'],
  //  contentUrl: 'https://flutter.io',
  //  childDirected: false,
  //  testDevices: <String>[], // Android emulators are considered test devices
  //);
  //BannerAd myBanner = BannerAd(
  //  // Replace the testAdUnitId with an ad unit id from the AdMob dash.
  //  // https://developers.google.com/admob/android/test-ads
  //  // https://developers.google.com/admob/ios/test-ads
  //  adUnitId: "",
  //  size: AdSize.smartBanner,
  //  targetingInfo: targetingInfo,
  //  listener: (MobileAdEvent event) {
  //    print("BannerAd event is $event");
  //  },
  //);
}
