import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:choremate/models/task.dart';
import 'package:choremate/models/user.dart';
import 'package:choremate/models/reminder.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper; //Singleton DatabaseHelper
  static Database _database; //Singleton Database
  String path;

  //variables for chore table
  String taskTable = "task_table";
  String colId = "id";
  String colTask = "task";
  String colDate = "date";
  String colTime = "time";
  String colStatus = "status";
  String colAssignment = "assignment";
  String colRpt = "rpt";

  //variables for user table
  String userTable = "user_table";
  final String tableUser = "User";
  final String columnName = "name";
  final String columnUserName = "username";
  final String columnPassword = "password";

  //variables for reminder table
  String taskTable = "reminder_table";
  String rId = "id";
  String message = "message";

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  DatabaseHelper.internal();

  //initialize the database
  Future<Database> initializeDatabase() async {
    //Get the directory path for both Android and iOS to store Database.
    Directory directory = await getApplicationDocumentsDirectory();
    path = join(directory.path, "task.db");
    print(path);

    //Open/Create the database at the given path
    var taskDatabase = await openDatabase(path,
        version: 1, onCreate: _createDb, onUpgrade: _onUpgrade);
    listTables();
    //updateTaskTable(taskDatabase);
    return taskDatabase;
  }

  //create the database with the chore, user, and reminder tables
  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $taskTable ($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTask TEXT, $colDate TEXT, $colTime TEXT, $colStatus TEXT, $colRpt TEXT, $colAssignment TEXT)');
    await db.execute(

        "CREATE TABLE $userTable(id INTEGER PRIMARY KEY, $columnName TEXT, $columnUserName TEXT, $columnPassword TEXT, flaglogged TEXT)");
    await db.execute(
        'CREATE TABLE $reminderTable ($rId INTEGER PRIMARY KEY AUTOINCREMENT, $message TEXT)');
  }

  //upgrade method, not sure if we need this yet
  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute("ALTER TABLE $taskTable ADD assignment TEXT");
  }

  //debug method to see tables in database
  listTables() async {
    Database dbClient = _database;
    List<Map<String, dynamic>> tables = await dbClient.query('sqlite_master');
    print(tables);
    print(_database.getVersion());
  }

  //Fetch Operation: Get all chore objects from database
  Future<List<Map<String, dynamic>>> getTaskMapList() async {
    Database db = await this.database;
    //var result = db.rawQuery('SELECT * FROM $taskTable order by $colDate, $colTime ASC');
    var result = db.query(taskTable, orderBy: '$colStatus, $colDate, $colTime');
    return result;
  }

  //only get the incomplete chores from database
  Future<List<Map<String, dynamic>>> getInCompleteTaskMapList() async {
    Database db = await this.database;
    var result = db.rawQuery(
        'SELECT * FROM $taskTable where $colStatus = "" order by $colDate, $colTime ASC');
    return result;
  }

  //only get the completed chores from database
  Future<List<Map<String, dynamic>>> getCompleteTaskMapList() async {
    Database db = await this.database;
    var result = db.rawQuery(
        'SELECT * FROM $taskTable where $colStatus = "Task Completed" order by $colDate, $colTime ASC');
    return result;
  }

  //Insert Operation: Insert a chore object to database
  Future<int> insertTask(Task task) async {
    Database db = await this.database;
    var result = await db.insert(taskTable, task.toMap());
    print(await db.query("task_table"));
    return result;
  }

  //Update Operation: Update a chore object and save it to database
  Future<int> updateTask(Task task) async {
    var db = await this.database;
    var result = await db.update(taskTable, task.toMap(),
        where: '$colId = ?', whereArgs: [task.id]);
    return result;
  }

  //Delete Operation: Delete a chore object from database
  Future<int> deleteTask(int id) async {
    var db = await this.database;
    int result = await db.rawDelete('DELETE FROM $taskTable WHERE $colId=$id');
    return result;
  }

  //Get no. of chore objects in database
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) FROM $taskTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  //get the chore list to display
  Future<List<Task>> getTaskList() async {
    var taskMapList = await getTaskMapList(); //Get Map List from database
    int count = taskMapList.length;

    List<Task> taskList = List<Task>();
    //For loop to create Task List from a Map List
    for (int i = 0; i < count; i++) {
      taskList.add(Task.fromMapObject(taskMapList[i]));
    }
    return taskList;
  }

  //get the incomplete chore list to display
  Future<List<Task>> getInCompleteTaskList() async {
    var taskMapList =
        await getInCompleteTaskMapList(); //Get Map List from database
    int count = taskMapList.length;

    List<Task> taskList = List<Task>();
    //For loop to create Task List from a Map List
    for (int i = 0; i < count; i++) {
      taskList.add(Task.fromMapObject(taskMapList[i]));
    }
    return taskList;
  }

  // get the completed chore list to display
  Future<List<Task>> getCompleteTaskList() async {
    var taskMapList =
        await getCompleteTaskMapList(); //Get Map List from database
    int count = taskMapList.length;

    List<Task> taskList = List<Task>();
    //For loop to create Task List from a Map List
    for (int i = 0; i < count; i++) {
      taskList.add(Task.fromMapObject(taskMapList[i]));
    }
    return taskList;
  }

  //insert a user to database
  Future<int> saveUser(User user) async {
    Database dbClient = await this.database;
    print(user.name);
    var res = await dbClient.insert(userTable, user.toMap());
    List<Map> list = await dbClient.rawQuery('SELECT * FROM User');
    print(list);
    return res;
  }

  //delete user from database
  Future<int> deleteUser(User user) async {
    var dbClient = await database;
    int res = await dbClient.delete(userTable,
        where: '$columnUserName = ?', whereArgs: [user.username]);
    return res;
  }

  //select a user from the database
  Future<User> selectUser(User user) async {
    print("Select User");
    print(user.username);
    print(user.password);
    var dbClient = await database;
    List<Map> maps = await dbClient.query(userTable,
        columns: [columnUserName, columnPassword],
        where: "$columnUserName = ? and $columnPassword = ?",
        whereArgs: [user.username, user.password]);
    print(maps);
    if (maps.length > 0) {
      print("User Exist !!!");
      return user;
    } else {
      return null;
    }
  }

  // Adding reminders to database

  //Fetch Operation: Get all reminder objects from database
  Future<List<Map<String, dynamic>>> getReminderMapList() async {
    Database db = await this.database;
    //var result = db.rawQuery('SELECT * FROM $reminderTable order by $rId ASC');
    var result = db.query(reminderTable, orderBy: '$rId ASC');
    return result;
  }

  //Insert Operation: Insert a reminder object to database
  Future<int> insertReminder(Reminder reminder) async {
    Database db = await this.database;
    var result = await db.insert(reminderTable, reminder.toMap());
    print(await db.query("reminder_table"));
    return result;
  }

  //Delete Operation: Delete a reminder object from database
  Future<int> deleteReminder(int id) async {
    var db = await this.database;
    int result = await db.rawDelete('DELETE FROM $reminderTable WHERE $rId=$id');
    return result;
  }

  //get the reminder list to display
  Future<List<Reminder>> getReminderList() async {
    var reminderMapList = await getReminderMapList(); //Get Map List from database
    int count = reminderMapList.length;

    List<Reminder> reminderList = List<Reminder>();
    //For loop to create Reminder List from a Map List
    for (int i = 0; i < count; i++) {
      reminderList.add(Reminder.fromMapObject(reminderMapList[i]));
    }
    return reminderList;
  }

}
