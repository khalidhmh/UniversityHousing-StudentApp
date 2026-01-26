import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class LocalDBService {
  // Singleton Pattern: نسخة واحدة فقط من الكلاس لضمان استقرار الاتصال
  static final LocalDBService _instance = LocalDBService._internal();
  static Database? _database;

  factory LocalDBService() => _instance;

  LocalDBService._internal();

  // الحصول على قاعدة البيانات (لو مش موجودة بيعملها init)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // تهيئة قاعدة البيانات وإنشاء الجداول
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'housing_local.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        print("📦 Creating Local Database Tables...");

        // 1. Student Profile (بيانات الطالب الشخصية)
        await db.execute('''
          CREATE TABLE student_profile (
            id TEXT PRIMARY KEY, 
            national_id TEXT, 
            full_name TEXT, 
            room_json TEXT, 
            photo_url TEXT
          )
        ''');

        // 2. Attendance Cache (سجل الغياب)
        await db.execute('''
          CREATE TABLE attendance_cache (
            date TEXT PRIMARY KEY, 
            status TEXT
          )
        ''');

        // 3. Complaints Cache (الشكاوى)
        await db.execute('''
          CREATE TABLE complaints_cache (
            id INTEGER PRIMARY KEY, 
            title TEXT, 
            description TEXT, 
            status TEXT, 
            type TEXT, 
            admin_reply TEXT
          )
        ''');

        // 4. Maintenance Cache (الصيانة)
        await db.execute('''
          CREATE TABLE maintenance_cache (
            id INTEGER PRIMARY KEY, 
            category TEXT, 
            description TEXT, 
            status TEXT, 
            supervisor_reply TEXT
          )
        ''');

        // 5. Permissions Cache (التصاريح)
        await db.execute('''
          CREATE TABLE permissions_cache (
            id INTEGER PRIMARY KEY, 
            type TEXT, 
            start_date TEXT, 
            end_date TEXT, 
            status TEXT
          )
        ''');

        // 6. Activities Cache (الأنشطة)
        await db.execute('''
          CREATE TABLE activities_cache (
            id INTEGER PRIMARY KEY, 
            title TEXT, 
            description TEXT, 
            image_url TEXT, 
            location TEXT, 
            event_date TEXT,
            is_subscribed INTEGER
          )
        ''');

        // 7. Clearance Cache (إخلاء الطرف)
        await db.execute('''
          CREATE TABLE clearance_cache (
            id INTEGER PRIMARY KEY, 
            status TEXT, 
            room_check_passed INTEGER, 
            keys_returned INTEGER
          )
        ''');

        // 8. Announcements Cache (الإعلانات)
        await db.execute('''
          CREATE TABLE announcements_cache (
            id INTEGER PRIMARY KEY, 
            title TEXT, 
            body TEXT, 
            created_at TEXT
          )
        ''');

        print("✅ Local Database Created Successfully");
      },
    );
  }

  // --- دالة عامة وذكية لتخزين أي بيانات (Batch Insert/Update) ---
  Future<void> cacheData(String tableName, List<Map<String, dynamic>> data) async {
    final db = await database;
    Batch batch = db.batch();

    // 1. مسح البيانات القديمة (اختياري، حسب استراتيجية الكاش)
    // هنا بنعتمد على الـ REPLACE عشان نحدث الموجود ونضيف الجديد
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

  // --- دوال الاسترجاع (Getters) ---

  // 1. هات بروفايل الطالب
  Future<Map<String, dynamic>?> getStudentProfile() async {
    final db = await database;
    final res = await db.query('student_profile', limit: 1);
    return res.isNotEmpty ? res.first : null;
  }

  // 2. هات سجل الغياب
  Future<List<Map<String, dynamic>>> getAttendanceLogs() async {
    final db = await database;
    return await db.query('attendance_cache', orderBy: "date DESC");
  }

  // 3. هات الشكاوى
  Future<List<Map<String, dynamic>>> getComplaints() async {
    final db = await database;
    return await db.query('complaints_cache', orderBy: "id DESC");
  }

  // 4. هات طلبات الصيانة
  Future<List<Map<String, dynamic>>> getMaintenanceRequests() async {
    final db = await database;
    return await db.query('maintenance_cache', orderBy: "id DESC");
  }

  // 5. هات التصاريح
  Future<List<Map<String, dynamic>>> getPermissions() async {
    final db = await database;
    return await db.query('permissions_cache', orderBy: "start_date DESC");
  }

  // 6. هات الأنشطة
  Future<List<Map<String, dynamic>>> getActivities() async {
    final db = await database;
    return await db.query('activities_cache', orderBy: "event_date ASC");
  }

  // 7. هات الإعلانات
  Future<List<Map<String, dynamic>>> getAnnouncements() async {
    final db = await database;
    return await db.query('announcements_cache', orderBy: "created_at DESC");
  }

  // 8. هات حالة إخلاء الطرف
  Future<Map<String, dynamic>?> getClearanceStatus() async {
    final db = await database;
    final res = await db.query('clearance_cache', limit: 1);
    return res.isNotEmpty ? res.first : null;
  }

  // --- تنظيف البيانات عند تسجيل الخروج ---
  Future<void> clearAllData() async {
    final db = await database;
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