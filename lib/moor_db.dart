import 'package:moor_flutter/moor_flutter.dart';

part 'moor_db.g.dart';

class Homepage extends Table {
  // autoIncrement() sets this to be primary key
  IntColumn get userId => integer().autoIncrement()();
  TextColumn get username => text().withLength(min: 1, max: 20)();
  RealColumn get balance => real()();
}

//class History extends Table {
//  // autoIncrement() sets this to be primary key
//  IntColumn get userId => integer().autoIncrement()();
//  DateTimeColumn get username => dateTime()();
//  RealColumn get amount => real()();
//}

@UseMoor(tables: [Homepage])
class AppDatabase extends _$AppDatabase {
  AppDatabase()
      : super((FlutterQueryExecutor.inDatabaseFolder(
            path: 'db.sqlite', logStatements: true)));

  @override
  //Increase whenever you change the schema
  int get schemaVersion => 1;
}
