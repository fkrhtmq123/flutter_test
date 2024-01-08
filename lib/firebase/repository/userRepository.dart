import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application/firebase/model/user.dart';

class UserRepository {
  final usersManager = FirebaseFirestore.instance.collection("users");

  // get
  Future<List<QueryDocumentSnapshot<User>>> getUser(String email) async {
    final userRef = usersManager.withConverter<User>(
        fromFirestore: (snapshot, _) => User.fromJson(snapshot.data()!),
        toFirestore: (user, _) => user.insertUserData());

    final userSnapshot = await userRef.where("email", isEqualTo: email).get();

    return userSnapshot.docs;
  }

  // insert
  Future<String> createUser(User user) async {
    final data = await usersManager.add(user.insertUserData());
    return data.id;
  }
}
