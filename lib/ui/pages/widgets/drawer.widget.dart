import 'package:flutter/material.dart';
import 'package:recipe_finder/config/global.params.dart';

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
          children: [
            DrawerHeader(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [
                          Colors.black,
                          Colors.greenAccent,
                        ]
                    )
                ),
                child: Center(
                    child: CircleAvatar(
                      backgroundImage: new AssetImage("images/logo.png"),
                      radius: 50,
                    ))
            ),
            ...(GlobalParams.menu as List).map((item) {
              return Column(
                  children: [
                    ListTile(
                      title: Text('${item['title']}', style: TextStyle(fontSize: 22)),
                      leading: item['icon'],
                      trailing: Icon(Icons.arrow_right, color: Colors.black38),
                      onTap: () {
                        Navigator.pushNamed(context, '${item['route']}');
                      },
                    ),
                    Divider(height: 2, color: Colors.black12),
                  ]
              );
            })

          ]
      ),
    );
  }
}