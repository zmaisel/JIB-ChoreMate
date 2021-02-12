enum Repeating { daily, weekly, monthly }

class Task {
  int _id;
  String _task, _date, _time, _status;
  Repeating _rpt;

  Task(this._task, this._date, this._time, this._status, this._rpt);
  Task.withId(
      this._id, this._task, this._date, this._time, this._status, this._rpt);

  int get id => _id;
  String get task => _task;
  String get date => _date;
  String get time => _time;
  String get status => _status;
  Repeating get rpt => _rpt;

  //String get assignment => _assignment;

  set task(String newTask) {
    if (newTask.length <= 255) {
      this._task = newTask;
    }
  }

  set date(String newDate) => this._date = newDate;

  set time(String newTime) => this._time = newTime;

  set status(String newStatus) => this._status = newStatus;

  //set assignment(String newAssignment) => this._assignment = newAssignment;

  set rpt(Repeating newRpt) => this._rpt = newRpt;

  //Convert Task object into MAP object
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) map['id'] = _id;
    map['task'] = _task;
    map['date'] = _date;
    map['time'] = _time;
    map['status'] = _status;
    //map['assignment'] = _assignment;
    return map;
  }

  //Extract Task object from MAP object
  Task.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._task = map['task'];
    this._date = map['date'];
    this._time = map['time'];
    this._status = map['status'];
    //this._assignment = map['assignment'];
  }
}
