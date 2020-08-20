import 'package:agenda_de_contatos/models/contact.model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Deficicão de valores default para a table.
final String contactTable = "contactTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn = "imgColumn";

class ContactService {
  // Deficinicão para criar um singleton
  static final ContactService instance = ContactService.internal();

  factory ContactService() => instance;

  ContactService.internal();

  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "contactsNew.db");
    return await openDatabase(
      path,
      version: 1,
      onCreate: (
        Database db,
        int newerVersion,
      ) async {
        await db.execute(
          "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT, $phoneColumn TEXT, $imgColumn TEXT)",
        );
      },
    );
  }

  Future<Contact> saveContact(Contact contact) async {
    Database dbContanct = await db;
    contact.id = await dbContanct.insert(contactTable, contact.toMap());
    return contact;
  }

  Future<Contact> getContact(int id) async {
    Database dbContanct = await db;
    List<Map> maps = await dbContanct.query(contactTable,
        columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
        where: "$idColumn = ?",
        whereArgs: [id]);
    if (maps.length > 0) {
      return Contact.fromMap(maps.first);
    }
    return null;
  }

  Future<int> deleteContact(int id) async {
    Database dbContanct = await db;
    return await dbContanct.delete(
      contactTable,
      where: "$idColumn = ?",
      whereArgs: [id],
    );
  }

  Future<int> updateContact(Contact contact) async {
    Database dbContact = await db;
    return await dbContact.update(
      contactTable,
      contact.toMap(),
      where: "$idColumn = ?",
      whereArgs: [contact.id],
    );
  }

  Future<List> getAllContacts() async {
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    List<Contact> listContact = List();
    for (Map m in listMap) {
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }

  Future<int> getNumber() async {
    Database dbContanct = await db;
    return Sqflite.firstIntValue(await dbContanct.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

  Future close() async {
    Database dbContanct = await db;
    dbContanct.close();
  }

}
