class Message {
  String _messageID;
  String _message;

  Message(this._message, this._messageID);

  String get message => _message;
  String get messageID => _messageID;

  set message(String newMessage) {
    if (newMessage.length <= 255) {
      this._message = newMessage;
    }
  }

  set messageID(String messageID) => this._messageID = messageID;

  //Convert Message object into MAP object
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['message'] = _message;
    map['messageID'] = _messageID;
    return map;
  }

  //Extract Message object from MAP object
  Message.fromMapObject(Map<String, dynamic> map) {
    this._message = map['message'];
    this._messageID = map['messageID'];
  }
}