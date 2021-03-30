class Message {
  String _messageID;
  String _message;
  String _sentToUID;
  String _sentTo;

  Message(this._message, this._messageID, this._sentToUID, this._sentTo);

  String get message => _message;
  String get messageID => _messageID;
  String get sentToUID => _sentToUID;
  String get sentTo => _sentTo;

  set message(String newMessage) {
    if (newMessage.length <= 255) {
      this._message = newMessage;
    }
  }

  set messageID(String messageID) => this._messageID = messageID;

  set sentToUID(String sentToUID) => this._sentToUID = sentToUID;

  set sentTo(String newSentTo) => this._sentTo = newSentTo;

  //Convert Message object into MAP object
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['message'] = _message;
    map['messageID'] = _messageID;
    map['sentToUID'] = _sentToUID;
    map['sentTo'] = _sentTo;
    return map;
  }

  //Extract Message object from MAP object
  Message.fromMapObject(Map<String, dynamic> map) {
    this._message = map['message'];
    this._messageID = map['messageID'];
    this._sentToUID = map['sentToUID'];
    this._sentTo = map['sentTo'];
  }
}
