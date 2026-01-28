# Backend Implementation Quick Guide

**For:** Backend Development Team  
**Date:** January 28, 2026  
**Phase:** 3 - Backend Gap Analysis Implementation  
**Urgency:** 🔴 CRITICAL ISSUES MUST BE FIXED

---

## TL;DR - Critical Fixes Required

### 🔴 Must Fix Immediately (Blocking Frontend)

1. **Event_Date Column** (Activities Table)
   - ❌ Problem: Frontend expects `event_date`, DB has `date`
   - ✅ Fix: Rename `date` → `event_date` in activities table
   - ⏱️ Time: 30 minutes
   - 📝 SQL: `ALTER TABLE activities RENAME COLUMN "date" TO "event_date";`

2. **Status Field Format** (All Status Fields)
   - ❌ Problem: Frontend expects lowercase (e.g., 'pending'), DB may be uppercase
   - ✅ Fix: Convert all status values to lowercase, add CHECK constraints
   - ⏱️ Time: 1-2 hours
   - 📝 SQL: `UPDATE table SET status = LOWER(status);`

3. **Missing Columns**
   - ❌ Problem: `is_secret` in complaints, `supervisor_reply` in maintenance
   - ✅ Fix: Add these columns to database
   - ⏱️ Time: 1 hour
   - 📝 SQL: `ALTER TABLE complaints ADD COLUMN is_secret BOOLEAN DEFAULT FALSE;`

4. **Date Validation** (Permissions)
   - ❌ Problem: Frontend submits requests with end_date < start_date
   - ✅ Fix: Add validation in API to reject invalid date ranges
   - ⏱️ Time: 2 hours
   - 📝 Logic: `if (start_date > end_date) return error;`

5. **Daily Attendance Reset**
   - ❌ Problem: Attendance status needs to reset at midnight daily
   - ✅ Fix: Set up PostgreSQL cron job to reset attendance
   - ⏱️ Time: 2 hours
   - 📝 SQL: PostgreSQL cron schedule

**Total Critical Fix Time: 6-8 hours**

---

## 5-Step Implementation Plan

### Step 1: Database Schema Changes (2-4 hours)

**Run these SQL commands in order:**

```sql
-- 1. Rename date to event_date in activities
ALTER TABLE activities RENAME COLUMN "date" TO "event_date";

-- 2. Add missing columns
ALTER TABLE complaints ADD COLUMN IF NOT EXISTS "is_secret" BOOLEAN DEFAULT FALSE;
ALTER TABLE maintenance_requests ADD COLUMN IF NOT EXISTS "supervisor_reply" TEXT DEFAULT '';

-- 3. Normalize status values to lowercase
UPDATE permissions SET status = LOWER(status) WHERE status IS NOT NULL;
UPDATE attendance_logs SET status = LOWER(status) WHERE status IS NOT NULL;
UPDATE complaints SET status = LOWER(status) WHERE status IS NOT NULL;
UPDATE maintenance_requests SET status = LOWER(status) WHERE status IS NOT NULL;

-- 4. Add constraints
ALTER TABLE permissions ADD CONSTRAINT check_permissions_status 
CHECK (status IN ('pending', 'approved', 'rejected', 'cancelled'));

ALTER TABLE attendance_logs ADD CONSTRAINT check_attendance_status 
CHECK (status IN ('present', 'absent', 'late', 'excused'));

ALTER TABLE complaints ALTER COLUMN "is_secret" SET NOT NULL;

-- 5. Create indexes
CREATE INDEX idx_complaints_is_secret ON complaints("is_secret");
CREATE INDEX idx_maintenance_supervisor_reply ON maintenance_requests("supervisor_reply");
```

**Verify:**
```sql
-- These queries should return columns with correct names
SELECT column_name FROM information_schema.columns WHERE table_name = 'activities' AND column_name = 'event_date';
SELECT column_name FROM information_schema.columns WHERE table_name = 'complaints' AND column_name = 'is_secret';
SELECT column_name FROM information_schema.columns WHERE table_name = 'maintenance_requests' AND column_name = 'supervisor_reply';
```

---

### Step 2: API Response Formatting (4-6 hours)

**For each endpoint, ensure responses match this format:**

#### GET /student/activities
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "Activity Title",
      "category": "Sports",
      "date": "2026-02-15",
      "event_date": "2026-02-15",  // ← CRITICAL: Must include this field
      "time": "14:00",
      "location": "Hall A",
      "image_url": "/uploads/activities/photo.jpg",  // ← Relative path
      "is_subscribed": true,  // ← Boolean or 0/1
      "description": "Activity description"
    }
  ]
}
```

#### GET /student/complaints
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "Complaint Title",
      "description": "Details",
      "status": "pending",  // ← LOWERCASE (not 'PENDING')
      "type": "noise",
      "admin_reply": "",  // ← Empty string if no reply
      "is_secret": false,  // ← Include this field
      "created_at": "2026-01-28T10:00:00"
    }
  ]
}
```

#### GET /student/maintenance
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "category": "Electrical",
      "description": "Broken light",
      "status": "pending",  // ← LOWERCASE
      "supervisor_reply": "",  // ← Include this field
      "created_at": "2026-01-20T09:15:00"
    }
  ]
}
```

#### GET /student/permissions
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "type": "Pass",
      "start_date": "2026-02-01",  // ← YYYY-MM-DD format
      "end_date": "2026-02-05",    // ← YYYY-MM-DD format
      "reason": "Family visit",
      "status": "pending",  // ← LOWERCASE
      "created_at": "2026-01-25T10:00:00"
    }
  ]
}
```

#### GET /student/attendance
```json
{
  "success": true,
  "data": [
    {
      "date": "2026-01-28",  // ← YYYY-MM-DD
      "status": "present"  // ← LOWERCASE (present, absent, late, excused)
    }
  ]
}
```

---

### Step 3: Backend Validation & Logic (4-6 hours)

**Critical validations to add:**

#### 3.1 Permissions Date Validation
```javascript
// Add this validation to POST /student/permissions endpoint
POST /student/permissions
Request: {
  "type": "Pass",
  "start_date": "2026-02-01",
  "end_date": "2026-02-05",
  "reason": "Family visit"
}

// VALIDATION (CRITICAL)
if (start_date > end_date) {
  return {
    "success": false,
    "message": "End date must be >= Start date"
  }
}
```

#### 3.2 Attendance Daily Reset
```sql
-- Enable PostgreSQL cron extension (if not already enabled)
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Schedule daily reset at 00:00 UTC
SELECT cron.schedule('reset_attendance_daily', '0 0 * * *', $$
  INSERT INTO attendance_logs (student_id, date, status)
  SELECT id, CURRENT_DATE, 'absent'
  FROM students
  WHERE id NOT IN (
    SELECT student_id FROM attendance_logs 
    WHERE date = CURRENT_DATE
  )
  ON CONFLICT DO NOTHING;
$$);
```

#### 3.3 Clearance Workflow Validation
```javascript
// Add this validation to POST /student/clearance endpoint
POST /student/clearance
{
  "status": "pending",
  "initiated_at": "2026-01-28T12:00:00Z"
}

// VALIDATION: Prevent duplicate active clearances
SELECT * FROM clearance_status 
WHERE student_id = currentStudent 
AND status IN ('pending', 'in_progress');

if (hasActiveCleared) {
  return {
    "success": false,
    "message": "Clearance process already in progress"
  }
}
```

#### 3.4 Complaints Anonymous Handling
```javascript
// When is_secret = true, do NOT expose student info
POST /student/complaints
{
  "title": "...",
  "description": "...",
  "is_secret": true,  // ← Frontend sends this
  "recipient": "Manager"
}

// Backend MUST store is_secret=true
// Backend MUST NOT show student name/ID to admin if is_secret=true
// Backend SHOULD log student ID separately for audit trail
```

---

### Step 4: Testing (4-6 hours)

**Test these scenarios:**

```
✅ GET /student/activities
  - Returns event_date field
  - image_url is relative path
  - is_subscribed is present

✅ GET /student/complaints
  - Status is lowercase (pending, resolved)
  - is_secret field present
  - admin_reply present (empty string if no reply)

✅ POST /student/complaints
  - Accepts is_secret parameter
  - Stores it in database
  - Returns success response

✅ GET /student/maintenance
  - Status is lowercase
  - supervisor_reply field present

✅ GET /student/permissions
  - Status is lowercase
  - Dates are YYYY-MM-DD format
  - All fields present

✅ POST /student/permissions
  - REJECTS if end_date < start_date
  - Returns error message: "End date must be >= Start date"
  - ACCEPTS if end_date >= start_date

✅ GET /student/attendance
  - Status is lowercase (present, absent, late, excused)
  - Dates are YYYY-MM-DD format

✅ GET /student/clearance
  - Returns null data if no active clearance
  - Returns proper object if clearance exists
  - room_check_passed and keys_returned are boolean

✅ POST /student/clearance
  - REJECTS if active clearance already exists
  - Creates new clearance with status='pending'

✅ Daily Attendance Reset
  - At midnight (00:00 UTC), all students get status='absent'
  - Students who check in get status updated to 'present' or 'late'
```

---

### Step 5: Deployment (2-4 hours)

1. **Backup Database**
   ```bash
   pg_dump student_housing_db > backup_before_update.sql
   ```

2. **Run Schema Migration Script**
   ```bash
   psql -U postgres -d student_housing_db < migration.sql
   ```

3. **Verify Changes**
   ```sql
   -- Run all verification queries from Part 1, Section 1.6
   -- in BACKEND_REQUIREMENTS_GAP_ANALYSIS.md
   ```

4. **Deploy API Code Changes**
   - Deploy code with validation logic
   - Deploy response formatting changes
   - Deploy attendance reset scheduler

5. **Test Live Endpoints**
   - Test each endpoint against staging database
   - Verify responses match expected format
   - Test error scenarios

6. **Deploy to Production**
   - Deploy database schema changes
   - Deploy API code
   - Monitor logs for errors
   - Notify frontend team

---

## Files to Review

| Document | What It Contains | Read Time |
|----------|-----------------|-----------|
| **BACKEND_REQUIREMENTS_GAP_ANALYSIS.md** | Complete analysis with all details | 45 min |
| **This file** | Quick implementation guide | 15 min |

---

## Common Issues & Solutions

### Issue 1: "Activities not loading in app"
**Cause:** API returns `date` field but frontend expects `event_date`  
**Solution:** Rename column or modify API response:
```sql
ALTER TABLE activities RENAME COLUMN "date" TO "event_date";
```

### Issue 2: "Status field comparison failing"
**Cause:** Status values are uppercase in DB (PENDING) but frontend expects lowercase  
**Solution:** Normalize values:
```sql
UPDATE table SET status = LOWER(status) WHERE status IS NOT NULL;
```

### Issue 3: "Complaints missing is_secret field"
**Cause:** Column doesn't exist in database  
**Solution:** Add column:
```sql
ALTER TABLE complaints ADD COLUMN "is_secret" BOOLEAN DEFAULT FALSE;
```

### Issue 4: "Permission requests accepted with invalid dates"
**Cause:** No validation for start_date > end_date  
**Solution:** Add validation in API:
```javascript
if (startDate > endDate) {
  throw new Error("End date must be >= Start date");
}
```

### Issue 5: "Attendance not resetting daily"
**Cause:** No scheduled job to reset attendance  
**Solution:** Set up PostgreSQL cron:
```sql
CREATE EXTENSION pg_cron;
SELECT cron.schedule('reset_attendance', '0 0 * * *', '...SQL...');
```

---

## Checklist for Backend Team

### Before Starting
- [ ] Database backup created
- [ ] All SQL scripts reviewed
- [ ] Development environment ready
- [ ] Team communication sent

### During Implementation
- [ ] Step 1: Database schema changes applied
- [ ] Step 2: API response formatting completed
- [ ] Step 3: Validation logic implemented
- [ ] Step 4: All tests passing
- [ ] Step 5: Deployment completed

### After Deployment
- [ ] All endpoints responding correctly
- [ ] No crashes in logs
- [ ] Frontend team confirms integration works
- [ ] Monitor for 24 hours
- [ ] Document any issues found

---

## Estimated Timeline

```
Day 1 (4 hours):
  - Database schema changes (2-4 hours)
  - Setup testing environment (1 hour)
  - Run verification queries (30 min)

Day 2 (6 hours):
  - API response formatting (4 hours)
  - Testing (2 hours)

Day 3 (8 hours):
  - Validation logic implementation (4 hours)
  - More testing (3 hours)
  - Documentation (1 hour)

Day 4 (4 hours):
  - Final testing
  - Deployment
  - Monitoring

Total: 22 hours of work
Spread over: 4 days
Team size: 1-2 developers
```

---

## Success Criteria

✅ **Code:**
- All SQL scripts executed successfully
- No compilation errors in API code
- All tests passing

✅ **Data:**
- event_date field exists in activities table
- is_secret column exists in complaints table
- supervisor_reply column exists in maintenance table
- All status values are lowercase
- All constraints applied

✅ **API:**
- All endpoints return correct JSON format
- All status values are lowercase
- No missing fields in responses
- Error messages clear and helpful

✅ **Integration:**
- Frontend app loads without crashes
- Cache-first pattern works
- Offline mode works with cached data
- All screens display data correctly

✅ **Monitoring:**
- No errors in application logs
- No database errors
- API response times acceptable
- No data loss

---

**Ready to Start:** 🚀 Yes  
**Blocking Issues:** 🔴 5 critical issues  
**Estimated Effort:** 22 hours  
**Team Size:** 1-2 developers

---

Contact Frontend Team immediately upon completion for integration testing.
