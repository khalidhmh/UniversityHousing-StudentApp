import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class LocalDBService {
  static final LocalDBService _instance = LocalDBService._internal();
  static Database? _database;

  factory LocalDBService() => _instance;

  LocalDBService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'housing_local_v2.db'); // ✅ غيرنا الاسم عشان يعمل داتا بيز جديدة نظيفة

    return await openDatabase(
        path,
        version: 2, // ✅ علينا الفيرجن
        onCreate: (db, version) async {
          print("📦 Creating Local Database Tables...");

          // 1. Student Profile (تم إضافة student_id و college)
          await db.execute('''
          CREATE TABLE student_profile (
            id TEXT PRIMARY KEY, 
            national_id TEXT, 
            full_name TEXT, 
            room_json TEXT, 
            photo_url TEXT,
            student_id TEXT, 
            college TEXT
          )
        ''');

          // 2. Attendance Cache
          await db.execute('''
          CREATE TABLE attendance_cache (
            date TEXT PRIMARY KEY, 
            status TEXT
          )
        ''');

          // 3. Complaints Cache
          await db.execute('''
          CREATE TABLE complaints_cache (
            id INTEGER PRIMARY KEY, 
            title TEXT, 
            description TEXT, 
            status TEXT, 
            type TEXT, 
            admin_reply TEXT,
            created_at TEXT
          )
        ''');

          // 4. Maintenance Cache
          await db.execute('''
          CREATE TABLE maintenance_cache (
            id INTEGER PRIMARY KEY, 
            category TEXT, 
            description TEXT, 
            status TEXT, 
            supervisor_reply TEXT,
            created_at TEXT
          )
        ''');

          // 5. Permissions Cache
          await db.execute('''
          CREATE TABLE permissions_cache (
            id INTEGER PRIMARY KEY, 
            type TEXT, 
            start_date TEXT, 
            end_date TEXT, 
            status TEXT,
            reason TEXT,
            created_at TEXT
          )
        ''');

          // 6. Activities Cache
          await db.execute('''
          CREATE TABLE activities_cache (
            id INTEGER PRIMARY KEY, 
            title TEXT, 
            description TEXT, 
            image_url TEXT, 
            location TEXT, 
            event_date TEXT,
            category TEXT,
            is_subscribed INTEGER
          )
        ''');

          // 7. Clearance Cache
          await db.execute('''
          CREATE TABLE clearance_cache (
            id INTEGER PRIMARY KEY, 
            status TEXT, 
            room_check_passed INTEGER, 
            keys_returned INTEGER,
            initiated_at TEXT
          )
        ''');

          // 8. Announcements Cache (تم إضافة category و priority)
          await db.execute('''
          CREATE TABLE announcements_cache (
            id INTEGER PRIMARY KEY, 
            title TEXT, 
            body TEXT, 
            category TEXT,
            priority TEXT,
            created_at TEXT
          )
        ''');

          print("✅ Local Database Created Successfully");
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          // لو التحديث حصل واليوزر منزل التطبيق، بنمسح الجداول القديمة ونعملها من جديد
          print("♻️ Upgrading Database from $oldVersion to $newVersion");
          await db.execute("DROP TABLE IF EXISTS student_profile");
          await db.execute("DROP TABLE IF EXISTS attendance_cache");
          await db.execute("DROP TABLE IF EXISTS complaints_cache");
          await db.execute("DROP TABLE IF EXISTS maintenance_cache");
          await db.execute("DROP TABLE IF EXISTS permissions_cache");
          await db.execute("DROP TABLE IF EXISTS activities_cache");
          await db.execute("DROP TABLE IF EXISTS clearance_cache");
          await db.execute("DROP TABLE IF EXISTS announcements_cache");
          // onCreate هينادى أوتوماتيك بعد الـ upgrade لو محتاج
        }
    );
  }

  Future<void> cacheData(String tableName, List<Map<String, dynamic>> data) async {
    final db = await database;
    Batch batch = db.batch();

    for (var item in data) {
      batch.insert(
        tableName,
        item,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
    print("💾 Cached ${data.length} items into $tableName");
  }

  // ... باقي دوال الـ Getters زي ما هي ...
  Future<Map<String, dynamic>?> getStudentProfile() async {
    final db = await database;
    final res = await db.query('student_profile', limit: 1);
    return res.isNotEmpty ? res.first : null;
  }

  Future<List<Map<String, dynamic>>> getAttendanceLogs() async {
    final db = await database;
    return await db.query('attendance_cache', orderBy: "date DESC");
  }

  Future<List<Map<String, dynamic>>> getComplaints() async {
    final db = await database;
    return await db.query('complaints_cache', orderBy: "id DESC");
  }

  Future<List<Map<String, dynamic>>> getMaintenanceRequests() async {
    final db = await database;
    return await db.query('maintenance_cache', orderBy: "id DESC");
  }

  Future<List<Map<String, dynamic>>> getPermissions() async {
    final db = await database;
    return await db.query('permissions_cache', orderBy: "start_date DESC");
  }

  Future<List<Map<String, dynamic>>> getActivities() async {
    final db = await database;
    return await db.query('activities_cache', orderBy: "event_date ASC");
  }

  Future<List<Map<String, dynamic>>> getAnnouncements() async {
    final db = await database;
    return await db.query('announcements_cache', orderBy: "created_at DESC");
  }

  Future<Map<String, dynamic>?> getClearanceStatus() async {
    final db = await database;
    final res = await db.query('clearance_cache', limit: 1);
    return res.isNotEmpty ? res.first : null;
  }

  Future<void> clearAllData() async {
    final db = await database;
    // نمسح البيانات بس من غير ما نمسح الجداول
    await db.delete('student_profile');
    await db.delete('attendance_cache');
    await db.delete('complaints_cache');
    await db.delete('maintenance_cache');
    await db.delete('permissions_cache');
    await db.delete('activities_cache');
    await db.delete('clearance_cache');
    await db.delete('announcements_cache');
    print("🗑️ Local Data Cleared");
  }
}