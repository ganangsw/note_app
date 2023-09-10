class DbConstants {
  DbConstants._();

  static const String dbName = 'note.db';
  static const String tbName = 'tb_note';
  static const String colId = 'id';
  static const String colTitle = 'title';
  static const String colDescription = 'description';
  static const String colDate = 'date';
  static const String colPriority = 'priority';

  static const String createDB =
      'CREATE TABLE $tbName($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, '
      '$colDescription TEXT, $colPriority INTEGER, $colDate TEXT)';
}
