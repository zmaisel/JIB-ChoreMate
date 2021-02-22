class User {
  String _name;
  String _username;
  String _password;
  String _flaglogged;
  String _groupId;

  User(this._name, this._username, this._password, this._flaglogged);

  User.map(dynamic obj) {
    this._name = obj['name'];
    this._username = obj['username'];
    this._password = obj['password'];
    this._flaglogged = obj['password'];
    //this._groupId = obj['groupId'];
  }

  String get name => _name;
  String get username => _username;
  String get password => _password;
  String get flaglogged => _flaglogged;
  //String get groupId => _groupId;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["name"] = _name;
    map["username"] = _username;
    map["password"] = _password;
    map["flaglogged"] = _flaglogged;
    //map["groupId"] = _groupId;
    return map;
  }
}
