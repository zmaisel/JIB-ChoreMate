class Event {
  String _title;
  String _summary;
  DateTime _date;
  String _uid;
  String _user;
  String _groupID;
  String _id;

  Event(this._title, this._summary, this._date, this._uid, this._user,
      this._groupID, _id);

  String get title => _title;
  String get summary => _summary;
  DateTime get date => _date;
  String get uid => _uid;
  String get user => _user;
  String get groupID => _groupID;
  String get id => _id;

  set title(String newTitle) {
    if (newTitle.length <= 255) {
      this._title = newTitle;
    }
  }

  set summary(String newSummary) => this._summary = newSummary;

  set date(DateTime newDate) => this._date = newDate;

  set uid(String newUid) => this._uid = newUid;

  set user(String newUser) => this._user = newUser;

  set groupID(String newGroupID) => this._groupID = newGroupID;

  set id(String newID) => this._id = newID;

  //Convert Message object into MAP object
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['title'] = _title;
    map['summary'] = _summary;
    map['date'] = _date;
    map['uid'] = _uid;
    map['user'] = _user;
    map['groupID'] = _groupID;
    map['id'] = _id;
    return map;
  }

  //Extract Message object from MAP object
  Event.fromMapObject(Map<String, dynamic> map) {
    this._title = map['title'];
    this._summary = map['summary'];
    this._date = map['date'];
    this._uid = map['uid'];
    this._user = map['user'];
    this._groupID = map['groupID'];
    this._id = map['id'];
  }
}
