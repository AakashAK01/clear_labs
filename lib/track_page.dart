import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'database/location_db.dart';

class TrackPage extends StatefulWidget {
  const TrackPage({super.key});

  @override
  State<TrackPage> createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {
  List<Map<String, dynamic>> _locationList = [];

  @override
  void initState() {
    super.initState();
    _refreshCity();
  }

  void _refreshCity() async {
    final data = await LocationDatabaseHelper.getlocation();
    setState(() {
      _locationList = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: const Text(
                  'Tracks',
                  style: TextStyle(fontSize: 24.0, color: Colors.black),
                ),
              ),
              if (_locationList.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 100,
                        ),
                        Text(
                          "Oops!! Looks like you have no recents.",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _locationList.length,
                  itemBuilder: ((context, index) => InkWell(
                        onTap: (() {
                          print(_locationList[index]['time']);
                        }),
                        child: Container(
                          margin: const EdgeInsets.all(15),
                          child: ListTile(
                            title: Text(_locationList[index]['time']),
                            subtitle: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Latitude: ${_locationList[index]['latitude']}, ',
                                ),
                                Text(
                                    "Longitude: ${_locationList[index]['longitude']}")
                              ],
                            ),
                            trailing: SizedBox(
                              width: 100,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  InkWell(
                                      onTap: () {
                                        _deleteCity(_locationList[index]['id']);
                                      },
                                      child: Icon(Icons.delete))
                                ],
                              ),
                            ),
                          ),
                        ),
                      )),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteCity(int id) async {
    await LocationDatabaseHelper.deleteCity(id);
    final snackBar = SnackBar(
      content: Text("Location has been deleted Successfully"),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    _refreshCity();
  }
}
