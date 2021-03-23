class Reminder {
  int _id;
  String _message;

  Reminder(this._message);
  Reminder.withId(this._id);

  int get id => _id;
  String get reminder => _reminder;

  set reminder(String newReminder) {
    if (newReminder.length <= 255) {
      this._message = newReminder;
    }
  }

  set id(int id) => this._id = id;

  //Convert Reminder object into MAP object
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) map['id'] = _id;
    map['message'] = _message;
    return map;
  }

  //Extract Reminder object from MAP object
  Reminder.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._message = map['message'];
  }
}