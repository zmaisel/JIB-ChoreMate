enum Repeating { daily, weekly, monthly, none, start }

class Task {
  int _id;
  String _choreID;
  String _task, _date, _time, _status, _rpt, _assignment;
  Repeating _value;
  //User _user;

  Task(this._task, this._date, this._time, this._status, this._rpt, this._value,
      this._uid);
  Task.withId(this._id, this._task, this._date, this._time, this._status,
      this._rpt, this._value, this._uid);

  int get id => _id;
  String get task => _task;
  String get choreID => _choreID;
  String get date => _date;
  String get time => _time;
  String get status => _status;
  String get rpt => _rpt;
  Repeating get value => _value;
  String get uid => _uid;
  //User get user => _user;

  set task(String newTask) {
    if (newTask.length <= 255) {
      this._task = newTask;
    }
  }
  set id(int id) => this._id = id;

  set choreID(String choreID) => this._choreID = choreID;

  set date(String newDate) => this._date = newDate;

  set time(String newTime) => this._time = newTime;

  set status(String newStatus) => this._status = newStatus;

  //set user(User newUser) => this._user = newUser;
  set uid(String newUid) => this._uid = newUid;

  set rpt(String newRpt) => this._rpt = newRpt;

  set value(Repeating newValue) => this._value = newValue;

  //Convert Task object into MAP object
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) map['id'] = _id;
    map['task'] = _task;
    map['date'] = _date;
    map['time'] = _time;
    map['status'] = _status;
    map['rpt'] = _rpt;
    //map['user'] = _user;
    map['uid'] = _uid;
    return map;
  }

  //Extract Task object from MAP object
  Task.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._task = map['task'];
    this._date = map['date'];
    this._time = map['time'];
    this._status = map['status'];
    this._rpt = map['rpt'];
    //this._user = map['user'];
    this._uid = map['uid'];
  }
}
