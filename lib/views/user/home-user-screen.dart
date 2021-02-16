import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ifeventos/views/splash-screen/splash-screen.dart';

class HomeUserScreen extends StatefulWidget {
  @override
  _HomeUserScreenState createState() => _HomeUserScreenState();
}

class _HomeUserScreenState extends State<HomeUserScreen> {

  final user = GetStorage().read('userData');

  _logout() async {
    await GetStorage().remove('username');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SplashScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffdddddd),

      body: Container(
        child: SingleChildScrollView(
          child: Container(
            width: double.maxFinite,
            padding: EdgeInsets.only(left: 15, right: 15, top: 40, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,

              children: <Widget>[
                Container(
                  width: 150,
                  height: 150,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(75),
                    child: this.user["photo"] != null && this.user["photo"] != "" ? 
                    Image.network(this.user["photo"]) :
                    Container(
                      width: 150,
                      height: 150,
                      color: Colors.blueGrey,
                      child: Center(
                        child: Text(
                          this.user["name"][0],
                          style: TextStyle(
                            fontSize: 60,
                            color: Colors.white
                          ),
                        ),
                      ),
                    )
                  ),
                ),

                SizedBox(height: 20),
                Text(
                  this.user["name"],
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[800]
                  ),
                ),

                SizedBox(height: 20),
                SizedBox(
                  height: 50,
                  width: double.maxFinite,
                  child: RaisedButton(
                    onPressed: () {
                      _logout();
                    },
                    child: Text(
                      "Sair",
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 18,
                        fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                ),
              ]
            ),
          )
        )
      ),
    );
  }
}