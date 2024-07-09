part of '../ui/posts_controller.dart';

class _PostsRepositoryImpl implements PostsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final storageRepository = StorageController();

  @override
  Future<void> addBookmark(String postId, String uid, bool saved) async {
    if (saved) {
      await _firestore
          .collection('savedPosts')
          .doc(uid)
          .collection('posts')
          .doc(postId)
          .delete();
    } else {
      var doc = await _firestore.collection('posts').doc(postId).get();
      var data = Post.toJson(doc.data()!);
      await _firestore
          .collection('savedPosts')
          .doc(uid)
          .collection('posts')
          .doc(postId)
          .set(data);
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
      await storageRepository.deleteImageFromStorage("posts", postId);
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  @override
  Future<void> getSavedPosts() async {
    try {
      var userSnap = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();
      var postsSnap = await _firestore
          .collection('posts')
          .orderBy('datePublished', descending: true)
          .get();
      var currSaved = userSnap.data()!['saved'];
      var cnt = 0;
      for (int i = 0; i < postsSnap.docs.length; i++) {
        if (currSaved.length > cnt &&
            postsSnap.docs[i].data()['postId'] == currSaved[cnt]) {
          var post = Post.toJson(postsSnap.docs[i].data());
          // Post post = Post(
          //     description: data['description'],
          //     uid: data['uid'],
          //     postId: data['postId'],
          //     username: data['username'],
          //     datePublished: data['datePublished'],
          //     postUrl: data['photoUrl'],
          //     profileImage: data['profileImage'],
          //     likes: data['likes']);
          _firestore
              .collection('users')
              .doc(_auth.currentUser!.uid)
              .collection('savedPosts')
              .doc(post['postId'])
              .set(post);
          cnt++;
        } else if (currSaved.length == cnt) {
          break;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  @override
  Future<void> likePost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection("posts").doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore.collection("posts").doc(postId).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  @override
  Future<String> uploadPost(String description, Uint8List file, String uid,
      String username, String profileImage) async {
    String res = "some error occurred";
    try {
      String postId = const Uuid().v1();
      String photoUrl = await storageRepository.uploadImageToStorage(
          "posts", file, true, postId);
      var post = Post.toJson({
        'description': description,
        'uid': uid,
        'postId': postId,
        'username': username,
        'datePublished': DateTime.now(),
        'postUrl': photoUrl,
        'profileImage': profileImage,
        'likes': []
      });
      _firestore.collection('posts').doc(postId).set(post);
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  @override
  Stream<List<Post>> getListOfPosts(String userId) {
    var posts = FirebaseFirestore.instance
        .collection('savedPosts')
        .doc(userId)
        .collection('posts')
        .orderBy('datePublished', descending: true)
        .snapshots();

    return posts.map(
        (snapshot) => snapshot.docs.map((doc) => Post.fromJson(doc)).toList());
  }

  @override
  Future<Map<String, dynamic>?>? getIsPostSaved(String postId) async {
    return (await _firestore
            .collection('savedPosts')
            .doc(_auth.currentUser!.uid)
            .collection('posts')
            .doc(postId)
            .get()).data();
  }
}
