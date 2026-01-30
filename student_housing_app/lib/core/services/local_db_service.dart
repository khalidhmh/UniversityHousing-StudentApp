import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class LocalDBService {
  static final LocalDBService _instance = LocalDBService._internal();
  static Database? _database;

  // getter لسهولة الوصول لقاعدة البيانات من خارج الكلاس لو احتجت
  Database? get localDatabase => _database;

  factory LocalDBService() => _instance;

  LocalDBService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // ✅ غيرنا الاسم لـ v4 عشان نجبر التطبيق يعمل جداول جديدة بالنظام الجديد
    String path = join(await getDatabasesPath(), 'student_housing_v4.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        print("📦 Creating Local Database Tables (V4)...");

        // 1. Student Profile (Added phone)
        await db.execute('''
          CREATE TABLE student_profile (
            id TEXT PRIMARY KEY, 
            national_id TEXT, 
            full_name TEXT, 
            student_id TEXT, 
            college TEXT,
            level TEXT,          
            address TEXT,        
            housing_type TEXT,   
            room_json TEXT, 
            photo_url TEXT,
            phone TEXT           -- ✅ جديد
          )
        ''');

        // 2. Attendance Cache (Added supervisor_name)
        await db.execute('''
          CREATE TABLE attendance_cache (
            date TEXT PRIMARY KEY, 
            status TEXT,
            supervisor_name TEXT -- ✅ جديد
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

        // 4. Maintenance Cache (Added location_type, image_url)
        await db.execute('''
          CREATE TABLE maintenance_cache (
            id INTEGER PRIMARY KEY, 
            category TEXT, 
            description TEXT, 
            status TEXT, 
            supervisor_reply TEXT,
            created_at TEXT,
            location_type TEXT,  -- ✅ جديد
            image_url TEXT       -- ✅ جديد
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
            is_subscribed INTEGER,
            participant_count INTEGER
          )
        ''');

        // 7. Clearance Cache (Added notes, request_date)
        await db.execute('''
          CREATE TABLE clearance_cache (
            id INTEGER PRIMARY KEY, 
            status TEXT, 
            room_check_passed INTEGER, 
            keys_returned INTEGER,
            initiated_at TEXT,
            notes TEXT,          -- ✅ جديد
            request_date TEXT    -- ✅ جديد
          )
        ''');

        // 8. Announcements Cache (Added publisher)
        await db.execute('''
          CREATE TABLE announcements_cache (
            id INTEGER PRIMARY KEY, 
            title TEXT, 
            body TEXT, 
            category TEXT,
            priority TEXT,
            created_at TEXT,
            publisher TEXT       -- ✅ جديد
          )
        ''');

        print("✅ Local Database V4 Created Successfully");
      },
    );
  }

  // ===========================================================================
  // CRUD Operations
  // ===========================================================================

  Future<void> cacheData(String tableName, List<Map<String, dynamic>> data) async {
    final db = await database;
    Batch batch = db.batch();

    // مسح البيانات القديمة لضمان عدم التكرار وتحديث الكاش بالكامل
    await db.delete(tableName);

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

  // --- Getters ---

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
    // حذف محتوى جميع الجداول عند تسجيل الخروج
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