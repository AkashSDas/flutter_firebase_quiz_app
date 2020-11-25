import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

import './globals.dart';

class Document<T> {
  final Firestore _db = Firestore.instance;
  final String path;
  DocumentReference ref;

  Document({this.path}) {
    ref = _db.document(path);
  }

  Future<T> getData() {
    /// You can't instantiate a generic type in dart however you can map
    /// a type to a contructor.
    /// In this case the Global class will keep track of the data models
    /// and we can instantiate them based on the generic type that is
    /// passed in.
    return ref.get().then((v) => Global.models[T](v.data) as T);
  }

  Stream<T> streamData() {
    return ref.snapshots().map((v) => Global.models[T](v.data) as T);
  }

  Future<void> upsert(Map data) {
    return ref.setData(Map<String, dynamic>.from(data), merge: true);
  }
}

class Collection<T> {
  final Firestore _db = Firestore.instance;
  final String path;
  CollectionReference ref;

  Collection({this.path}) {
    ref = _db.collection(path);
  }

  Future<List<T>> getData() async {
    var snapshots = await ref.getDocuments();
    return snapshots.documents
        .map((doc) => Global.models[T](doc.data) as T)
        .toList();
  }

  Stream<List<T>> streamData() {
    return ref.snapshots().map(
        (list) => list.documents.map((doc) => Global.models[T](doc.data) as T));
  }
}

/// Since the logic of the below code would have been repeated multiple time
/// therefore it's better to create a generic type (this will avoid code redundancy)
// class DatabaseService {
//   final Firestore _db = Firestore.instance;

//   Future<Quiz> getQuiz(quizId) {
//     return _db
//         .collection('quizzes')
//         .document(quizId)
//         .get()
//         .then((snap) => Quiz.fromMap(snap.data));
//   }
// }

class UserData<T> {
  final Firestore _db = Firestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String collection;

  UserData({this.collection});

  Stream<T> get documentStream {
    return _auth.onAuthStateChanged.switchMap((user) {
      if (user != null) {
        Document<T> doc = Document<T>(path: '$collection/${user.uid}');
        return doc.streamData();
      } else {
        return Stream<T>.value(null);
      }
    });
  }

  Future<T> getDocument() async {
    FirebaseUser user = await _auth.currentUser();

    if (user != null) {
      Document doc = Document<T>(path: '$collection/${user.uid}');
      return doc.getData();
    } else {
      return null;
    }
  }

  Future<void> upsert(Map data) async {
    FirebaseUser user = await _auth.currentUser();
    Document<T> ref = Document(path: '$collection/${user.uid}');
    return ref.upsert(data);
  }
}

///
///
///
/// Examples of using these classes
///
/// var quiz = Document<Quiz>(path: 'quizzes/fortran');
///
/// quiz.streamData();
/// quiz.getData();
///
/// quiz.upsert({'hello': 'world'});
///
/// var quizzes = Collection<Quiz>(path: 'quizzes');
///
/// quizzes.streamData();
///
///
/// var report = UserData<Report>(collection: 'reports/{userId}');
///
/// report.getDocument();
///
/// report.upsert(data);
