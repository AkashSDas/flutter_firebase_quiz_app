import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/services.dart';
import '../shared/shared.dart';

class ProfileScreen extends StatelessWidget {
  final AuthService auth = AuthService();

  @override
  Widget build(BuildContext context) {
    Report report = Provider.of<Report>(context);
    FirebaseUser user = Provider.of<FirebaseUser>(context);

    if (user != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          title: Text(user.displayName ?? 'Guest'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              (user.photoUrl != null)
                  ? Container(
                      width: 100,
                      height: 100,
                      margin: EdgeInsets.only(top: 50),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(user.photoUrl),
                        ),
                      ),
                    )
                  : Container(),
              Spacer(),
              Text(
                user.email ?? '',
                style: Theme.of(context).textTheme.headline5,
              ),
              Spacer(),
              (report != null)
                  ? Text(
                      '${report.total ?? 0}',
                      style: Theme.of(context).textTheme.bodyText1,
                    )
                  : Container(),
              Text(
                'Quizzes Completed',
                style: Theme.of(context).textTheme.headline6,
              ),
              Spacer(),
              FlatButton(
                child: Text('logout'),
                color: Colors.red,
                onPressed: () async {
                  await auth.signOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/',
                    (route) => false,
                  );
                },
              ),
              Spacer()
            ],
          ),
        ),
      );
    } else {
      return LoadingScreen();
    }
  }
}
