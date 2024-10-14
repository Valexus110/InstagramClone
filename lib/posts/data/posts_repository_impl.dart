part of '../ui/posts_controller.dart';

class _PostsRepositoryImpl implements PostsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final storageRepository = StorageController();

  @override
  Future<void> addBookmark(
      String currentPostId, String currentUid, bool saved) async {
    if (saved) {
      await _firestore
          .collection(savedPosts)
          .doc(currentUid)
          .collection(posts)
          .doc(currentPostId)
          .delete();
    } else {
      var doc = await _firestore.collection(posts).doc(currentPostId).get();
      var data = Post.toJson(doc.data()!);
      await _firestore
          .collection(savedPosts)
          .doc(currentUid)
          .collection(posts)
          .doc(currentPostId)
          .set(data);
    }
  }

  @override
  Future<void> deletePost(String currentPostId) async {
    try {
      await _firestore.collection(posts).doc(currentPostId).delete();
      await storageRepository.deleteImageFromStorage(posts, currentPostId);
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  @override
  Future<void> getSavedPosts() async {
    try {
      var userSnap =
          await _firestore.collection(users).doc(_auth.currentUser!.uid).get();
      var postsSnap = await _firestore
          .collection(posts)
          .orderBy(datePublished, descending: true)
          .get();
      var currSaved = userSnap.data()![saved];
      var cnt = 0;
      for (int i = 0; i < postsSnap.docs.length; i++) {
        if (currSaved.length > cnt &&
            postsSnap.docs[i].data()[postId] == currSaved[cnt]) {
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
              .collection(users)
              .doc(_auth.currentUser!.uid)
              .collection(savedPosts)
              .doc(post[postId])
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
  Future<void> likePost(
      String currentPostId, String currentUid, List currentLikes) async {
    try {
      if (currentLikes.contains(currentUid)) {
        await _firestore.collection(posts).doc(currentPostId).update({
          likes: FieldValue.arrayRemove([currentUid]),
        });
      } else {
        await _firestore.collection(posts).doc(currentPostId).update({
          likes: FieldValue.arrayUnion([currentUid]),
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  @override
  Future<String> uploadPost(
      String currentDescription,
      Uint8List file,
      String currentUid,
      String currentUsername,
      String currentProfileImage) async {
    String res = locale.anErrorOccurred;
    try {
      String currentPostId = const Uuid().v1();
      String currentPhotoUrl = await storageRepository.uploadImageToStorage(
          posts, file, true, currentPostId);
      var post = Post.toJson({
        description: currentDescription,
        uid: currentUid,
        postId: currentPostId,
        username: currentUsername,
        datePublished: DateTime.now(),
        postUrl: currentPhotoUrl,
        profileImage: currentProfileImage,
        likes: []
      });
      _firestore.collection(posts).doc(currentPostId).set(post);
      res = success;
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  @override
  Stream<List<Post>> getListOfPosts(String userId) {
    var postsList = FirebaseFirestore.instance
        .collection(savedPosts)
        .doc(userId)
        .collection(posts)
        .orderBy(datePublished, descending: true)
        .snapshots();

    return postsList.map(
        (snapshot) => snapshot.docs.map((doc) => Post.fromJson(doc)).toList());
  }

  @override
  Future<Map<String, dynamic>?>? getIsPostSaved(String postId) async {
    return (await _firestore
            .collection(savedPosts)
            .doc(_auth.currentUser!.uid)
            .collection(posts)
            .doc(postId)
            .get())
        .data();
  }
}
