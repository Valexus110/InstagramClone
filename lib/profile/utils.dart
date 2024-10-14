import '../main.dart';

enum StartPageEntries {
  feed("Feed", 0),
  search("Search", 1),
  addPost("Add Post", 2),
  userList("User List", 3),
  profile("Profile", 4);

  const StartPageEntries(this.label, this.number);

  final String label;
  final int number;
}

String getEnumString(StartPageEntries enumValue) {
  switch (enumValue) {
    case StartPageEntries.feed:
      return locale.feed;
    case StartPageEntries.search:
      return locale.searchUser;
    case StartPageEntries.addPost:
      return locale.addPost;
    case StartPageEntries.userList:
      return locale.usersYouMightKnow;
    case StartPageEntries.profile:
      return locale.profile;
  }
}