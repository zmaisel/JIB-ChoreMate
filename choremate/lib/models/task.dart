enum Repeating { daily, weekly, monthly, none, start }

class Task {
  int _id;
  String _choreID, _choreIDUser;
  String _task, _date, _time, _status, _rpt, _assignment, _assignmentUID;
  Repeating _value;
  DateTime _dateTime;
  //User _user;

  Task(
      this._task,
      this._date,
      this._time,
      this._status,
      this._rpt,
      this._value,
      this._assignment,
      this._choreID,
      this._assignmentUID,
      this._choreIDUser,
      this._dateTime);
  Task.withId(
      this._id,
      this._task,
      this._date,
      this._time,
      this._status,
      this._rpt,
      this._value,
      this._assignment,
      this._choreID,
      this._assignmentUID,
      this._choreIDUser,
      this._dateTime);

  int get id => _id;
  String get task => _task;
  String get choreID => _choreID;
  String get date => _date;
  String get time => _time;
  String get status => _status;
  String get rpt => _rpt;
  Repeating get value => _value;
  String get assignment => _assignment;
  String get assignmentUID => _assignmentUID;
  String get choreIDUser => _choreIDUser;
  DateTime get dateTime => _dateTime;
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
  set assignment(String newAssignment) => this._assignment = newAssignment;

  set assignmentUID(String newAssignmentUID) =>
      this._assignmentUID = newAssignmentUID;

  set rpt(String newRpt) => this._rpt = newRpt;

  set value(Repeating newValue) => this._value = newValue;

  set choreIDUser(String newChoreIDUser) => this._choreIDUser = newChoreIDUser;

  set dateTime(DateTime newDateTime) => this._dateTime = newDateTime;

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
    map['assignment'] = _assignment;
    map['assignmentUID'] = _assignmentUID;
    map['choreID'] = _choreID;
    map['value'] = _value;
    map['choreIDUser'] = _choreIDUser;
    map['dateTime'] = _dateTime;
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
    this._assignment = map['assignment'];
    this._assignmentUID = map['assignmentUID'];
    this._choreID = map['choreID'];
    this._value = map['value'];
    this._choreIDUser = map['choreIDUser'];
    this._dateTime = map['dateTime'];
  }
}
