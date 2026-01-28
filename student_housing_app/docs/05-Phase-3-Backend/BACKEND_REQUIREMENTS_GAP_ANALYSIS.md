# Backend Requirements for Student Housing App v2

**Formal Technical Report**  
**Phase 3: Backend & Database Gap Analysis**  
**Date:** January 28, 2026  
**Status:** Ready for Backend Implementation  
**Target Database:** PostgreSQL  

---

## Executive Summary

The frontend has been refactored to use a **Reactive Repository Pattern** with local caching. The app now expects specific field names, consistent JSON structures, and standardized response formats from the API.

This report documents:
1. **Database schema mismatches** and required SQL fixes
2. **API response standardization** for critical endpoints
3. **Business logic & validation** rules to enforce
4. **Implementation action plan** for backend developers

**Critical Finding:** The Frontend already expects certain field names that may not match the current database schema (e.g., `event_date` vs `date`). These mismatches must be fixed to prevent runtime crashes.

---

## Part 1: Database Schema Updates

### Overview of Required Changes

The frontend's `DataRepository` expects specific field names from the database. Current mismatches must be fixed to prevent data loading failures.

### 1.1 Activities Table - CRITICAL

#### Current Issue
```
API returns:  'date' field
Frontend expects: 'event_date' field
Result: 🔴 CRASH - Activities don't display
```

#### SQL Fix Required

**Rename column in activities table:**
```sql
-- Backup before running (if using older PostgreSQL)
ALTER TABLE activities RENAME COLUMN "date" TO "event_date";

-- Verify the change
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'activities' 
AND column_name IN ('date', 'event_date');
```

**Alternative (if data migration needed):**
```sql
-- If you need to preserve the old column for legacy reasons:
ALTER TABLE activities ADD COLUMN "event_date" TIMESTAMP;

-- Migrate existing data
UPDATE activities SET "event_date" = "date" WHERE "event_date" IS NULL;

-- Then either:
-- Option A: Drop old column (preferred)
ALTER TABLE activities DROP COLUMN "date";

-- Option B: Keep both and use event_date as primary
-- (Not recommended - adds technical debt)
```

#### Affected Frontend Code
- **ActivitiesViewModel**: Maps `event_date` → `date` for UI display
- **DataRepository.getActivities()**: Returns activities with `event_date` field
- **LocalDBService**: Caches activities with `event_date` field

**Verification Query:**
```sql
SELECT id, title, event_date FROM activities LIMIT 5;
```

---

### 1.2 Complaints Table - Missing `is_secret` Column

#### Current Issue
```
Frontend sends: 'is_secret' boolean flag when submitting complaints
Database should store: Whether complaint is anonymous
```

#### SQL Fix Required

**Add missing column:**
```sql
-- Add the is_secret column if it doesn't exist
ALTER TABLE complaints 
ADD COLUMN IF NOT EXISTS "is_secret" BOOLEAN DEFAULT FALSE;

-- Create index for filtering
CREATE INDEX IF NOT EXISTS idx_complaints_is_secret 
ON complaints("is_secret");
```

#### Expected API Usage
```dart
// From ComplaintsViewModel.submitComplaint()
final result = await _dataRepository.submitComplaint(
  title: 'Complaint Title',
  description: 'Description',
  recipient: 'Recipient Name',
  isSecret: true,  // ← This must be stored in is_secret column
);
```

#### Migration SQL (if data already exists)
```sql
-- Backfill existing complaints with default value
UPDATE complaints 
SET "is_secret" = FALSE 
WHERE "is_secret" IS NULL;

-- Make column NOT NULL
ALTER TABLE complaints 
ALTER COLUMN "is_secret" SET NOT NULL;
```

---

### 1.3 Maintenance Table - Missing `supervisor_reply` Column

#### Current Issue
```
Frontend displays: 'supervisor_reply' field in maintenance requests list
Database should provide: Admin response to maintenance request
```

#### SQL Fix Required

**Add missing column:**
```sql
ALTER TABLE maintenance_requests 
ADD COLUMN IF NOT EXISTS "supervisor_reply" TEXT DEFAULT '';

-- Create index for quick access
CREATE INDEX IF NOT EXISTS idx_maintenance_supervisor_reply 
ON maintenance_requests("supervisor_reply");
```

#### Expected Structure
```dart
// From DataRepository._fetchAndCacheMaintenance()
'supervisor_reply': item['supervisor_reply'] ?? ''
```

#### Migration SQL
```sql
-- Ensure column exists and is nullable (for existing data)
ALTER TABLE maintenance_requests 
ADD COLUMN IF NOT EXISTS "supervisor_reply" TEXT;

-- Set default for future records
ALTER TABLE maintenance_requests 
ALTER COLUMN "supervisor_reply" SET DEFAULT '';
```

---

### 1.4 Permissions Table - Status Field Format

#### Current Issue
```
Frontend expects: status values in LOWERCASE (pending, approved, rejected)
Database may return: UPPERCASE or mixed case (PENDING, Approved)
```

#### SQL Fix Required

**Standardize status values:**
```sql
-- Normalize existing data to lowercase
UPDATE permissions 
SET "status" = LOWER("status");

-- Create CHECK constraint to enforce format
ALTER TABLE permissions 
ADD CONSTRAINT check_permissions_status 
CHECK ("status" IN ('pending', 'approved', 'rejected', 'cancelled'));

-- For postgresql 10+, you can use an enum type:
CREATE TYPE permission_status_enum AS ENUM ('pending', 'approved', 'rejected', 'cancelled');

ALTER TABLE permissions 
ALTER COLUMN "status" TYPE permission_status_enum USING "status"::permission_status_enum;
```

#### Expected Values from Frontend
```
✅ 'pending'   - Request awaiting review
✅ 'approved'  - Request approved by admin
✅ 'rejected'  - Request denied by admin
✅ 'cancelled' - Request cancelled by student
```

---

### 1.5 Attendance Table - Status Field Format

#### Current Issue
```
Frontend expects: status values in LOWERCASE
Database returns: May be in different case
```

#### SQL Fix Required

**Standardize attendance status values:**
```sql
-- Normalize existing data
UPDATE attendance_logs 
SET "status" = LOWER("status");

-- Add constraint
ALTER TABLE attendance_logs 
ADD CONSTRAINT check_attendance_status 
CHECK ("status" IN ('present', 'absent', 'late', 'excused'));

-- Optional: Create enum type for type safety
CREATE TYPE attendance_status_enum AS ENUM ('present', 'absent', 'late', 'excused');

ALTER TABLE attendance_logs 
ALTER COLUMN "status" TYPE attendance_status_enum USING "status"::attendance_status_enum;
```

#### Expected Values
```
✅ 'present' - Student marked present
✅ 'absent'  - Student absent
✅ 'late'    - Student late for check-in
✅ 'excused' - Absence is excused
```

---

### 1.6 General Schema Validation

**Run this query to verify all required columns exist:**
```sql
-- Check Activities table
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'activities' 
AND column_name IN ('id', 'title', 'event_date', 'category', 'time', 'location', 'image_url', 'is_subscribed')
ORDER BY column_name;

-- Check Complaints table
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'complaints' 
AND column_name IN ('id', 'title', 'description', 'status', 'is_secret', 'admin_reply', 'created_at')
ORDER BY column_name;

-- Check Maintenance table
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'maintenance_requests' 
AND column_name IN ('id', 'category', 'description', 'status', 'supervisor_reply', 'created_at')
ORDER BY column_name;

-- Check Permissions table
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'permissions' 
AND column_name IN ('id', 'type', 'start_date', 'end_date', 'status', 'reason', 'created_at')
ORDER BY column_name;

-- Check Attendance table
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'attendance_logs' 
AND column_name IN ('id', 'date', 'status')
ORDER BY column_name;

-- Check Clearance table
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'clearance_status' 
AND column_name IN ('id', 'student_id', 'status', 'room_check_passed', 'keys_returned', 'initiated_at')
ORDER BY column_name;
```

---

## Part 2: API Response Standardization

### Overview

The frontend's `DataRepository` expects specific JSON formats from each endpoint. Responses MUST match exactly or the app will fail to load data properly.

### 2.1 GET `/student/profile` - Student Profile

#### Expected Response Format
```json
{
  "success": true,
  "data": {
    "id": "student_123",
    "national_id": "123456789",
    "full_name": "محمد أحمد",
    "student_id": "2024001",
    "college": "Engineering",
    "room": {
      "room_no": "A-101",
      "building": "Building A",
      "floor": 1
    },
    "photo_url": "/uploads/students/photo.jpg"
  }
}
```

#### Critical Field Requirements
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `id` | string | ✅ Yes | Student's unique ID |
| `national_id` | string | ✅ Yes | National ID number |
| `full_name` | string | ✅ Yes | Student's full name in Arabic |
| `student_id` | string | ✅ Yes | University student number |
| `college` | string | ✅ Yes | College/Faculty name |
| `room` | object | ✅ Yes | Current room assignment (or null if not assigned) |
| `room.room_no` | string | ✅ Yes | Room number (e.g., "A-101") |
| `room.building` | string | ✅ Yes | Building name |
| `photo_url` | string | ⚠️ Optional | Relative URL to student photo |

#### Frontend Code Using This
```dart
// From DataRepository._fetchAndCacheStudentProfile()
'photo_url': ApiService.getImageUrl(profileData['photo_url'])
// ApiService handles URL conversion to full URL
```

#### Error Response Format (if applicable)
```json
{
  "success": false,
  "message": "Student not found or not authenticated",
  "data": null
}
```

---

### 2.2 GET `/student/activities` - List of Activities

#### Expected Response Format
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "Workshop on Leadership",
      "description": "A comprehensive workshop on leadership skills",
      "category": "Workshop",
      "location": "Hall A",
      "date": "2026-02-15",
      "time": "14:00",
      "image_url": "/uploads/activities/workshop.jpg",
      "is_subscribed": true
    },
    {
      "id": 2,
      "title": "Sports Day",
      "description": "Annual sports day for all students",
      "category": "Sports",
      "location": "Sports Stadium",
      "date": "2026-02-20",
      "time": "10:00",
      "image_url": "/uploads/activities/sports.jpg",
      "is_subscribed": false
    }
  ]
}
```

#### Critical Mapping Rules
| API Field | Frontend Expects | Notes |
|-----------|-----------------|-------|
| `date` OR `event_date` | `event_date` | 🔴 CRITICAL: API returns `date`, Frontend maps it to `event_date` |
| `image_url` | `image_url` | Relative path - ApiService converts to full URL |
| `is_subscribed` | `is_subscribed` | Boolean (true/false) OR 0/1 - Frontend normalizes to 0/1 |

#### Frontend Normalization Code
```dart
// From ActivitiesViewModel._normalizeActivityData()
'date': item['event_date'] ?? item['date'] ?? ''  // Handles both field names
'imagePath': ApiService.getImageUrl(item['image_url'] ?? item['imagePath'] ?? item['image_path'] ?? '')  // Multiple fallbacks
```

#### Backend Requirement
**API MUST return:** Either `date` OR `event_date` field (not optional)
**API MUST return:** `image_url` as relative path
**API SHOULD return:** `is_subscribed` as boolean or 0/1

---

### 2.3 POST `/student/activities/{id}/subscribe` - Subscribe to Activity

#### Request Format
```json
{
  "activity_id": 1,
  "subscribe": true
}
```

#### Expected Response
```json
{
  "success": true,
  "message": "Subscribed successfully",
  "data": {
    "id": 1,
    "is_subscribed": true
  }
}
```

---

### 2.4 GET `/student/complaints` - List of Complaints

#### Expected Response Format
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "Noise in the corridor",
      "description": "Excessive noise during study hours",
      "status": "pending",
      "type": "noise",
      "admin_reply": "",
      "created_at": "2026-01-15T10:30:00"
    },
    {
      "id": 2,
      "title": "Broken Wi-Fi",
      "description": "Wi-Fi not working in room A-101",
      "status": "resolved",
      "type": "technical",
      "admin_reply": "Wi-Fi router has been repaired",
      "created_at": "2026-01-10T14:20:00"
    }
  ]
}
```

#### Critical Field Requirements
| Field | Type | Required | Format | Notes |
|-------|------|----------|--------|-------|
| `id` | integer | ✅ Yes | - | Unique complaint ID |
| `title` | string | ✅ Yes | - | Complaint subject |
| `description` | string | ✅ Yes | - | Detailed description |
| `status` | string | ✅ Yes | lowercase | **MUST be lowercase:** `pending`, `resolved` |
| `type` | string | ✅ Yes | lowercase | Category: `noise`, `maintenance`, `technical`, etc. |
| `admin_reply` | string | ✅ Yes | - | Admin's response (empty string if no reply yet) |
| `created_at` | string | ✅ Yes | ISO 8601 | Timestamp of complaint creation |

#### Frontend Normalization
```dart
// From DataRepository._fetchAndCacheComplaints()
'status': (item['status'] ?? 'pending').toString().toLowerCase()
```

---

### 2.5 POST `/student/complaints` - Submit New Complaint

#### Request Format
```json
{
  "title": "Complaint Title",
  "description": "Detailed description",
  "recipient": "Room Manager",
  "is_secret": true,
  "status": "pending"
}
```

#### Request Field Requirements
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `title` | string | ✅ Yes | Complaint subject (1-200 chars) |
| `description` | string | ✅ Yes | Detailed description (min 10 chars) |
| `recipient` | string | ✅ Yes | Who the complaint is for |
| `is_secret` | boolean | ✅ Yes | Anonymous complaint flag |
| `status` | string | ✅ Yes | Always 'pending' for new complaints |

#### Expected Response
```json
{
  "success": true,
  "message": "Complaint submitted successfully",
  "data": {
    "id": 3,
    "title": "...",
    "status": "pending",
    "created_at": "2026-01-28T12:00:00"
  }
}
```

#### Error Response (Validation Failed)
```json
{
  "success": false,
  "message": "Title and description are required",
  "data": null
}
```

---

### 2.6 GET `/student/maintenance` - List of Maintenance Requests

#### Expected Response Format
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "category": "Electrical",
      "description": "Broken light bulb in room",
      "status": "pending",
      "supervisor_reply": "",
      "created_at": "2026-01-20T09:15:00"
    },
    {
      "id": 2,
      "category": "Plumbing",
      "description": "Leaking faucet",
      "status": "completed",
      "supervisor_reply": "Fixed and tested - working perfectly",
      "created_at": "2026-01-10T11:00:00"
    }
  ]
}
```

#### Critical Field Requirements
| Field | Type | Required | Format | Notes |
|-------|------|----------|--------|-------|
| `id` | integer | ✅ Yes | - | Request ID |
| `category` | string | ✅ Yes | Any | Type of maintenance |
| `description` | string | ✅ Yes | - | Details of issue |
| `status` | string | ✅ Yes | lowercase | `pending`, `in_progress`, `completed` |
| `supervisor_reply` | string | ✅ Yes | - | Supervisor's update (empty if no update) |
| `created_at` | string | ✅ Yes | ISO 8601 | Request submission time |

#### Frontend Normalization
```dart
// From DataRepository._fetchAndCacheMaintenance()
'status': (item['status'] ?? 'pending').toString().toLowerCase()
```

---

### 2.7 POST `/student/maintenance` - Submit Maintenance Request

#### Request Format
```json
{
  "category": "Plumbing",
  "description": "Leaking tap in bathroom",
  "status": "pending"
}
```

#### Expected Response
```json
{
  "success": true,
  "message": "Maintenance request submitted",
  "data": {
    "id": 3,
    "category": "Plumbing",
    "status": "pending",
    "created_at": "2026-01-28T12:00:00"
  }
}
```

---

### 2.8 GET `/student/permissions` - List of Permission Requests

#### Expected Response Format
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "type": "Pass",
      "start_date": "2026-02-01",
      "end_date": "2026-02-05",
      "reason": "Family visit",
      "status": "approved",
      "created_at": "2026-01-25T10:00:00"
    },
    {
      "id": 2,
      "type": "Outing",
      "start_date": "2026-02-10",
      "end_date": "2026-02-11",
      "reason": "Doctor's appointment",
      "status": "pending",
      "created_at": "2026-01-27T14:30:00"
    }
  ]
}
```

#### Critical Field Requirements
| Field | Type | Required | Format | Notes |
|-------|------|----------|--------|-------|
| `id` | integer | ✅ Yes | - | Permission request ID |
| `type` | string | ✅ Yes | Any | Request type: Pass, Outing, etc. |
| `start_date` | string | ✅ Yes | YYYY-MM-DD | Start date of permission |
| `end_date` | string | ✅ Yes | YYYY-MM-DD | End date of permission |
| `reason` | string | ✅ Yes | - | Reason for request |
| `status` | string | ✅ Yes | lowercase | `pending`, `approved`, `rejected` |
| `created_at` | string | ✅ Yes | ISO 8601 | Request submission time |

---

### 2.9 POST `/student/permissions` - Request Permission

#### Request Format
```json
{
  "type": "Pass",
  "start_date": "2026-02-01",
  "end_date": "2026-02-05",
  "reason": "Family visit",
  "status": "pending"
}
```

#### Request Validation
- `start_date` must be ≤ `end_date` (BACKEND MUST VALIDATE)
- Both dates must be in future (BACKEND SHOULD VALIDATE)
- Reason must be non-empty

#### Expected Response
```json
{
  "success": true,
  "message": "Permission requested successfully",
  "data": {
    "id": 3,
    "type": "Pass",
    "status": "pending",
    "start_date": "2026-02-01",
    "end_date": "2026-02-05",
    "created_at": "2026-01-28T12:00:00"
  }
}
```

---

### 2.10 GET `/student/attendance` - Attendance Records

#### Expected Response Format
```json
{
  "success": true,
  "data": [
    {
      "date": "2026-01-28",
      "status": "present"
    },
    {
      "date": "2026-01-27",
      "status": "absent"
    },
    {
      "date": "2026-01-26",
      "status": "late"
    }
  ]
}
```

#### Critical Field Requirements
| Field | Type | Required | Format | Notes |
|-------|------|----------|--------|-------|
| `date` | string | ✅ Yes | YYYY-MM-DD | Attendance date |
| `status` | string | ✅ Yes | lowercase | `present`, `absent`, `late`, `excused` |

#### Frontend Normalization
```dart
// From DataRepository._fetchAndCacheAttendance()
'status': (item['status'] ?? 'present').toString().toLowerCase()
```

---

### 2.11 GET `/student/clearance` - Clearance Status

#### Expected Response Format
```json
{
  "success": true,
  "data": {
    "id": 1,
    "student_id": "2024001",
    "status": "in_progress",
    "room_check_passed": false,
    "keys_returned": false,
    "initiated_at": "2026-01-28T10:00:00"
  }
}
```

#### Expected Response (No Active Clearance)
```json
{
  "success": true,
  "data": null
}
```

#### Critical Field Requirements
| Field | Type | Required | Format | Notes |
|-------|------|----------|--------|-------|
| `id` | integer | ✅ Yes | - | Clearance process ID |
| `student_id` | string | ✅ Yes | - | Student's ID |
| `status` | string | ✅ Yes | lowercase | `pending`, `in_progress`, `completed` |
| `room_check_passed` | boolean | ✅ Yes | 0/1 or true/false | Room inspection completed |
| `keys_returned` | boolean | ✅ Yes | 0/1 or true/false | Keys returned flag |
| `initiated_at` | string | ✅ Yes | ISO 8601 | When clearance started |

---

### 2.12 POST `/student/clearance` - Initiate Clearance

#### Request Format
```json
{
  "status": "pending",
  "initiated_at": "2026-01-28T12:00:00Z"
}
```

#### Expected Response
```json
{
  "success": true,
  "message": "Clearance process initiated",
  "data": {
    "id": 1,
    "status": "pending",
    "room_check_passed": false,
    "keys_returned": false,
    "initiated_at": "2026-01-28T12:00:00"
  }
}
```

---

### 2.13 GET `/student/announcements` - List of Announcements

#### Expected Response Format
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "Maintenance Schedule",
      "body": "Building A will have water maintenance on Feb 1st",
      "category": "general",
      "priority": "normal",
      "created_at": "2026-01-28T08:00:00"
    },
    {
      "id": 2,
      "title": "Fire Drill",
      "body": "Fire drill scheduled for next week",
      "category": "safety",
      "priority": "high",
      "created_at": "2026-01-27T15:00:00"
    }
  ]
}
```

#### Critical Field Requirements
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `id` | integer | ✅ Yes | Announcement ID |
| `title` | string | ✅ Yes | Announcement title |
| `body` | string | ✅ Yes | Announcement content |
| `category` | string | ✅ Yes | Category: general, safety, maintenance, etc. |
| `priority` | string | ✅ Yes | Priority level: normal, high, urgent |
| `created_at` | string | ✅ Yes | ISO 8601 timestamp |

---

## Part 3: Business Logic & Validation Rules

### 3.1 Activities Management

#### Rule 1: Subscription Tracking
```
WHEN: Student clicks "Subscribe" on an activity
THEN:
  1. Update is_subscribed flag to TRUE
  2. Track subscription timestamp
  3. Return success response with updated activity
  
VALIDATION:
  ✓ Student must exist and be enrolled
  ✓ Activity must exist and be active
  ✓ Prevent duplicate subscriptions (idempotent operation)
```

#### Rule 2: Activity Date Validation
```
WHEN: Creating or updating an activity
THEN:
  1. event_date must be in future (or today)
  2. event_date must be valid date format
  3. Reject if event_date is NULL
  
DATABASE CONSTRAINT:
  ALTER TABLE activities
  ADD CONSTRAINT check_event_date_not_null CHECK (event_date IS NOT NULL);
```

#### Rule 3: Image URL Standardization
```
WHEN: Storing activity image_url
THEN:
  1. Store as relative path (e.g., '/uploads/activities/event.jpg')
  2. Never store full URL in database
  3. Return NULL/empty string if no image
  4. Frontend converts to full URL using ApiService.getImageUrl()
```

---

### 3.2 Complaints Management

#### Rule 1: Status Transitions
```
ALLOWED TRANSITIONS:
  pending → resolved        ✅ Admin resolves complaint
  pending → pending        ✅ No state change (allowed, idempotent)
  resolved → resolved      ✅ No state change
  
FORBIDDEN TRANSITIONS:
  resolved → pending       ❌ Cannot re-open resolved complaint
  pending → [anything else] ❌ Only two states allowed
```

#### Rule 2: Anonymous Complaint Handling
```
WHEN: is_secret = TRUE
THEN:
  1. Do NOT store student name/ID in admin view
  2. Do NOT link complaint to student profile
  3. Use anonymous reference (e.g., "Student #unknown")
  4. Enforcement: is_secret field MUST exist in database
  
BACKEND RESPONSIBILITY:
  - Filter admin view based on is_secret flag
  - Log student ID separately (for audit trail)
  - Prevent reverse lookup from anonymous complaint to student
```

#### Rule 3: Admin Reply Tracking
```
WHEN: Admin replies to complaint
THEN:
  1. Store reply in admin_reply field
  2. Update status to resolved
  3. Log timestamp of reply
  4. Send notification to student (if not anonymous)
  
VALIDATION:
  ✓ admin_reply must be non-empty if resolving
  ✓ Only admins can set admin_reply
  ✓ Student cannot modify admin_reply
```

---

### 3.3 Maintenance Request Management

#### Rule 1: Status Workflow
```
WORKFLOW:
  pending → in_progress → completed
  
TRANSITIONS:
  ✅ pending → in_progress   (Supervisor starts work)
  ✅ in_progress → completed (Supervisor finishes)
  ✅ pending → completed     (Quick fixes, direct completion)
  ❌ completed → [any]       (Cannot revert completed status)
  
ENFORCEMENT:
  Only supervisors can transition status
  Students can only view, not modify
```

#### Rule 2: Supervisor Reply Tracking
```
WHEN: Supervisor responds to maintenance request
THEN:
  1. Store response in supervisor_reply field
  2. Add timestamp of update
  3. Include update notes/photos if available
  4. Notify student of update
  
DATABASE:
  - supervisor_reply must be VARCHAR/TEXT type
  - created_at tracks initial request
  - updated_at tracks last update
```

---

### 3.4 Permissions Request Management

#### Rule 1: Date Validation
```
CRITICAL VALIDATION (BACKEND MUST ENFORCE):
  1. start_date MUST be ≤ end_date
  2. If start_date > end_date: REJECT with error message
  3. Both dates MUST be future dates (or today for same-day pass)
  4. Prevent requesting permission in past
  
EXAMPLE REJECTION:
  Request: { start_date: "2026-02-10", end_date: "2026-02-05" }
  Response: {
    "success": false,
    "message": "End date must be greater than or equal to start date"
  }
```

#### Rule 2: Overlapping Requests
```
WHEN: Checking for overlapping permission periods
THEN:
  1. Check if student has overlapping approved permission
  2. New request start_date falls within existing permission range
  3. Action: REJECT or WARN (configurable)
  
VALIDATION QUERY:
  SELECT * FROM permissions 
  WHERE student_id = ? 
  AND status = 'approved'
  AND start_date <= ? 
  AND end_date >= ?;
```

#### Rule 3: Status Transitions
```
WORKFLOW:
  pending → approved (Admin approves)
  pending → rejected (Admin rejects)
  pending → cancelled (Student cancels)
  approved → cancelled (Student cancels before date)
  
RESTRICTIONS:
  ✓ Only admins can approve/reject
  ✓ Only student can cancel
  ✓ Cannot approve past requests
  ✓ Cannot modify rejected requests
```

---

### 3.5 Attendance Management

#### Rule 1: Daily Reset (CRITICAL)
```
REQUIREMENT:
  Attendance status must reset daily at 12:00 AM (midnight)
  
MECHANISM:
  1. Scheduled job runs every day at 00:00 (PostgreSQL cron or external scheduler)
  2. Sets today's attendance status to 'absent' for all students
  3. As students check in, status updates to 'present' or 'late'
  
IMPLEMENTATION (PostgreSQL cron extension):
  -- Install pg_cron extension
  CREATE EXTENSION IF NOT EXISTS pg_cron;
  
  -- Schedule daily reset
  SELECT cron.schedule('reset_attendance', '0 0 * * *', $$
    INSERT INTO attendance_logs (student_id, date, status)
    SELECT id, CURRENT_DATE, 'absent'
    FROM students
    ON CONFLICT DO NOTHING;
  $$);
```

#### Rule 2: Status Values
```
ALLOWED VALUES (MUST be lowercase):
  ✅ 'present' - Student checked in on time
  ✅ 'absent'  - Student did not check in
  ✅ 'late'    - Student checked in after deadline
  ✅ 'excused' - Absence is excused (doctor note, etc.)
  
DATABASE CONSTRAINT:
  ALTER TABLE attendance_logs
  ADD CONSTRAINT check_attendance_status
  CHECK (status IN ('present', 'absent', 'late', 'excused'));
```

#### Rule 3: Check-in Logic
```
WHEN: Student checks in
THEN:
  1. Get current time
  2. Compare with check-in deadline (e.g., 8:00 AM)
  3. If check-in time ≤ deadline: status = 'present'
  4. If check-in time > deadline: status = 'late'
  
CONFIGURATION:
  DEFINE: Check-in deadline (e.g., 08:00:00)
  STORE: In config table or environment variable
```

---

### 3.6 Clearance Process Management

#### Rule 1: Clearance Workflow (CRITICAL)
```
WORKFLOW:
  initiated → in_progress → completed
  
STAGES:
  1. Student initiates clearance process (status = 'pending')
  2. Room inspection conducted (room_check_passed = true/false)
  3. Keys collected (keys_returned = true/false)
  4. All checks complete → status = 'completed'
  
RULES:
  ✓ Student can only have ONE active clearance at a time
  ✓ Cannot initiate new clearance if one is active
  ✓ Cannot checkout until clearance completed
  ✓ Room check failure blocks checkout
```

#### Rule 2: Active Clearance Prevention
```
WHEN: Student tries to initiate new clearance
CHECK: Does an active clearance already exist?
  
QUERY:
  SELECT * FROM clearance_status
  WHERE student_id = ? 
  AND status IN ('pending', 'in_progress');
  
IF FOUND:
  REJECT with error: "Clearance process already in progress"
  
IF NOT FOUND:
  ALLOW new clearance process
```

#### Rule 3: Room Check Validation
```
WHEN: Room check is completed
THEN:
  1. room_check_passed field is updated (true/false)
  2. If false: Student must fix issues before completing clearance
  3. If true: One step closer to completion
  
BUSINESS RULE:
  - If room_check_passed = FALSE, status must remain 'in_progress'
  - If room_check_passed = TRUE AND keys_returned = TRUE: status = 'completed'
```

---

## Part 4: Implementation Action Plan

### 4.1 Pre-Implementation Checklist

- [ ] Backup production database
- [ ] Create development database with same schema
- [ ] Review all SQL scripts in this document
- [ ] Set up PostgreSQL environment with necessary extensions
- [ ] Plan downtime window (if required for migrations)

### 4.2 Phase 1: Database Schema Updates (PRIORITY 1 - CRITICAL)

**Estimated Time:** 2-4 hours

**Tasks:**
```sql
-- TASK 1: Fix event_date column in activities table
[ ] Rename 'date' to 'event_date' in activities table
[ ] Verify change with SELECT query
[ ] Test that frontend can read 'event_date' field
[ ] Script location: See section 1.1

-- TASK 2: Add missing columns to complaints table
[ ] Add 'is_secret' column to complaints table
[ ] Create index on is_secret for filtering
[ ] Backfill existing data with DEFAULT FALSE
[ ] Script location: See section 1.2

-- TASK 3: Add missing columns to maintenance table
[ ] Add 'supervisor_reply' column to maintenance_requests table
[ ] Create index for quick access
[ ] Script location: See section 1.3

-- TASK 4: Standardize status values
[ ] Normalize permissions.status to lowercase
[ ] Add CHECK constraint to permissions table
[ ] Normalize attendance_logs.status to lowercase
[ ] Add CHECK constraint to attendance_logs table
[ ] Script location: See sections 1.4 and 1.5

-- TASK 5: Verification
[ ] Run validation query (section 1.6)
[ ] Verify all columns exist with correct types
[ ] Verify constraints are in place
```

**Rollback Plan:**
```sql
-- If anything goes wrong, restore from backup:
RESTORE DATABASE from backup_before_schema_changes;
```

---

### 4.3 Phase 2: API Response Standardization (PRIORITY 1 - CRITICAL)

**Estimated Time:** 6-8 hours

**Endpoint Audit & Fixes Required:**

**AUDIT: GET /student/profile**
- [ ] Check if all required fields are returned (id, national_id, full_name, student_id, college, room, photo_url)
- [ ] Verify photo_url is relative path, not full URL
- [ ] Test response format matches expected JSON (section 2.1)
- [ ] Add missing fields if absent
- Action: See section 2.1

**AUDIT: GET /student/activities**
- [ ] ✅ CRITICAL: Verify API returns `date` or `event_date` field
- [ ] Check is_subscribed field present (boolean or 0/1)
- [ ] Verify image_url is relative path
- [ ] Ensure all activities have required fields
- Action: See section 2.2

**AUDIT: GET /student/complaints**
- [ ] ✅ CRITICAL: Ensure status is lowercase (pending, resolved)
- [ ] Check admin_reply field exists (empty string if no reply)
- [ ] Verify all required fields present
- [ ] Test response format
- Action: See section 2.4

**AUDIT: GET /student/maintenance**
- [ ] ✅ CRITICAL: Ensure status is lowercase
- [ ] Check supervisor_reply field exists
- [ ] Verify all required fields present
- Action: See section 2.6

**AUDIT: GET /student/permissions**
- [ ] ✅ CRITICAL: Ensure status is lowercase
- [ ] Check date fields are YYYY-MM-DD format
- [ ] Verify all required fields present
- Action: See section 2.8

**AUDIT: GET /student/attendance**
- [ ] ✅ CRITICAL: Ensure status is lowercase
- [ ] Verify date format is YYYY-MM-DD
- [ ] Check response structure
- Action: See section 2.10

**AUDIT: GET /student/clearance**
- [ ] Check room_check_passed and keys_returned are boolean
- [ ] Verify all fields present
- [ ] Test response when no active clearance (should return null data)
- Action: See section 2.11

**AUDIT: GET /student/announcements**
- [ ] Verify all fields present (id, title, body, category, priority, created_at)
- [ ] Check priority values are standardized
- Action: See section 2.13

---

### 4.4 Phase 3: Business Logic Implementation (PRIORITY 2)

**Estimated Time:** 8-12 hours

**Tasks:**

**ACTIVITY MANAGEMENT:**
- [ ] Implement subscription tracking (section 3.1)
- [ ] Add date validation for activities
- [ ] Ensure image URL standardization

**COMPLAINTS MANAGEMENT:**
- [ ] Implement status transition validation (section 3.2)
- [ ] Add is_secret handling for anonymous complaints
- [ ] Implement admin reply functionality
- [ ] Add database constraints for is_secret

**MAINTENANCE REQUESTS:**
- [ ] Implement status workflow (pending → in_progress → completed) (section 3.3)
- [ ] Ensure only supervisors can update status
- [ ] Add supervisor_reply tracking

**PERMISSIONS MANAGEMENT:**
- [ ] ✅ CRITICAL: Implement date validation (start_date ≤ end_date) (section 3.4)
- [ ] Add overlapping request detection
- [ ] Implement status transitions (section 3.4)
- [ ] Add validation for future dates

**ATTENDANCE MANAGEMENT:**
- [ ] ✅ CRITICAL: Implement daily reset at 12:00 AM (section 3.5)
- [ ] Add check-in deadline logic
- [ ] Implement status determination (present/late)
- [ ] Set up PostgreSQL cron job or external scheduler

**CLEARANCE PROCESS:**
- [ ] ✅ CRITICAL: Implement clearance workflow (section 3.6)
- [ ] Prevent duplicate active clearances
- [ ] Add room check validation
- [ ] Implement completion logic

---

### 4.5 Phase 4: Testing & Validation (PRIORITY 2)

**Estimated Time:** 6-8 hours

**Testing Checklist:**

**UNIT TESTS:**
- [ ] Test database constraints (status values, not null, etc.)
- [ ] Test date validation (permissions)
- [ ] Test clearance workflow

**INTEGRATION TESTS:**
- [ ] Test each API endpoint returns correct JSON format
- [ ] Test error scenarios (invalid input, missing fields)
- [ ] Test business logic rules (status transitions, validations)
- [ ] Test cache-first repository pattern with new endpoints

**API TESTS:**
- [ ] GET /student/profile - Check all fields present
- [ ] GET /student/activities - Verify event_date field
- [ ] POST /student/activities/{id}/subscribe - Test subscription
- [ ] GET /student/complaints - Check lowercase status
- [ ] POST /student/complaints - Test submission and validation
- [ ] GET /student/maintenance - Check lowercase status
- [ ] POST /student/maintenance - Test submission
- [ ] GET /student/permissions - Check date format and validation
- [ ] POST /student/permissions - Test date validation (start ≤ end)
- [ ] GET /student/attendance - Check daily reset, lowercase status
- [ ] GET /student/clearance - Test null response when inactive
- [ ] POST /student/clearance - Test workflow
- [ ] GET /student/announcements - Verify all fields

**FRONTEND INTEGRATION:**
- [ ] Deploy to staging environment
- [ ] Run frontend app against new API
- [ ] Verify no crashes on data loading
- [ ] Test cache-first behavior
- [ ] Test offline mode with cached data

---

### 4.6 Phase 5: Deployment (PRIORITY 3)

**Estimated Time:** 4-6 hours

**Pre-Deployment:**
- [ ] All tests pass (unit, integration, API)
- [ ] Frontend integration testing complete
- [ ] Database backups created and verified
- [ ] Rollback plan documented and tested
- [ ] Team notified of deployment window

**Deployment Steps:**
```
1. [ ] Create database snapshot/backup
2. [ ] Deploy SQL schema changes (section 1)
3. [ ] Verify schema changes applied correctly
4. [ ] Deploy API code changes
5. [ ] Run smoke tests on production endpoints
6. [ ] Deploy frontend app with new code
7. [ ] Monitor error logs for issues
8. [ ] Gather user feedback for 24 hours
```

**Post-Deployment:**
- [ ] Monitor crash logs
- [ ] Monitor API response times
- [ ] Monitor database performance
- [ ] Gather user feedback
- [ ] Schedule follow-up review

**Rollback Plan (If Issues):**
- [ ] Database: Restore from pre-deployment snapshot
- [ ] API: Rollback to previous version
- [ ] Frontend: Rollback to previous build
- [ ] Communicate with users

---

## Part 5: Technical Dependencies & Requirements

### 5.1 PostgreSQL Version Requirements

```
✅ Minimum: PostgreSQL 10
✅ Recommended: PostgreSQL 12+
✅ Features used: 
  - ENUM types (PostgreSQL 8.3+)
  - pg_cron extension (requires PostgreSQL 11+)
  - CHECK constraints (all versions)
  - JSON functions (PostgreSQL 9.3+)
```

### 5.2 Required PostgreSQL Extensions

```sql
-- Must be installed for attendance daily reset
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Verify installation
SELECT * FROM pg_extension WHERE extname = 'pg_cron';
```

### 5.3 Timezone Configuration

```
CRITICAL: All timestamps MUST use UTC (Z timezone)
Database: Set to UTC timezone
API: Return ISO 8601 format with Z (e.g., "2026-01-28T12:00:00Z")
Frontend: App converts to local time for display
```

### 5.4 Data Type Requirements

```
Field Type Mapping:

Dates:
  - date fields: DATE type (YYYY-MM-DD)
  - timestamp fields: TIMESTAMP WITH TIME ZONE (ISO 8601 string in API)
  
Booleans:
  - Database: BOOLEAN type or SMALLINT (0/1)
  - API: true/false (JSON boolean)
  - Frontend: Normalized to 0/1 internally
  
Strings:
  - Short text: VARCHAR(255)
  - Long text: TEXT
  - Status values: VARCHAR(20) with CHECK constraint
  
IDs:
  - Primary keys: INTEGER or BIGINT (SERIAL or BIGSERIAL)
  - Foreign keys: Match referenced table type
```

---

## Part 6: Migration Scripts Template

### 6.1 Complete Migration Script

```sql
-- Complete Database Schema Update for Frontend v2
-- Run with: psql -U postgres -d student_housing_db -f migration.sql
-- Date: 2026-01-28

BEGIN TRANSACTION;

-- ============================================================================
-- PHASE 1: Rename columns
-- ============================================================================

-- Fix activities table - rename date to event_date
ALTER TABLE IF EXISTS activities 
RENAME COLUMN "date" TO "event_date";

-- ============================================================================
-- PHASE 2: Add missing columns
-- ============================================================================

-- Add is_secret to complaints table
ALTER TABLE IF EXISTS complaints 
ADD COLUMN IF NOT EXISTS "is_secret" BOOLEAN DEFAULT FALSE;

-- Add supervisor_reply to maintenance_requests table
ALTER TABLE IF EXISTS maintenance_requests 
ADD COLUMN IF NOT EXISTS "supervisor_reply" TEXT DEFAULT '';

-- ============================================================================
-- PHASE 3: Normalize existing data
-- ============================================================================

-- Normalize permissions status to lowercase
UPDATE permissions SET "status" = LOWER("status") WHERE "status" IS NOT NULL;

-- Normalize attendance status to lowercase
UPDATE attendance_logs SET "status" = LOWER("status") WHERE "status" IS NOT NULL;

-- ============================================================================
-- PHASE 4: Add constraints and indexes
-- ============================================================================

-- Constraint on permissions status
ALTER TABLE permissions 
ADD CONSTRAINT IF NOT EXISTS check_permissions_status 
CHECK ("status" IN ('pending', 'approved', 'rejected', 'cancelled'));

-- Constraint on attendance status
ALTER TABLE attendance_logs 
ADD CONSTRAINT IF NOT EXISTS check_attendance_status 
CHECK ("status" IN ('present', 'absent', 'late', 'excused'));

-- Constraint on activities event_date (not null)
ALTER TABLE activities 
ADD CONSTRAINT IF NOT EXISTS check_event_date_not_null 
CHECK ("event_date" IS NOT NULL);

-- Constraint on complaints is_secret (not null)
ALTER TABLE complaints 
ALTER COLUMN "is_secret" SET NOT NULL;

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_complaints_is_secret ON complaints("is_secret");
CREATE INDEX IF NOT EXISTS idx_maintenance_supervisor_reply ON maintenance_requests("supervisor_reply");
CREATE INDEX IF NOT EXISTS idx_permissions_status ON permissions("status");
CREATE INDEX IF NOT EXISTS idx_attendance_status ON attendance_logs("status");

-- ============================================================================
-- PHASE 5: Install pg_cron for attendance reset (if not exists)
-- ============================================================================

-- Uncomment the next line if pg_cron is not installed
-- CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Schedule daily attendance reset at midnight (UTC)
-- SELECT cron.schedule('reset_daily_attendance', '0 0 * * *', $$
--   INSERT INTO attendance_logs (student_id, date, status)
--   SELECT id, CURRENT_DATE, 'absent'
--   FROM students
--   WHERE id NOT IN (
--     SELECT student_id FROM attendance_logs WHERE date = CURRENT_DATE
--   )
--   ON CONFLICT DO NOTHING;
-- $$);

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Verify schema changes
SELECT 'Activities table columns:' as check_type;
SELECT column_name, data_type FROM information_schema.columns 
WHERE table_name = 'activities' 
AND column_name IN ('id', 'title', 'event_date', 'category', 'image_url', 'is_subscribed')
ORDER BY column_name;

SELECT 'Complaints table columns:' as check_type;
SELECT column_name, data_type FROM information_schema.columns 
WHERE table_name = 'complaints' 
AND column_name IN ('id', 'title', 'is_secret', 'admin_reply', 'status')
ORDER BY column_name;

SELECT 'Maintenance table columns:' as check_type;
SELECT column_name, data_type FROM information_schema.columns 
WHERE table_name = 'maintenance_requests' 
AND column_name IN ('id', 'category', 'supervisor_reply', 'status')
ORDER BY column_name;

COMMIT;
```

---

## Summary & Key Takeaways

### Critical Issues Fixed (🔴 MUST DO)
1. **Event_Date Mapping** - Rename or map `date` → `event_date` in activities
2. **Status Lowercase** - Ensure all status values are lowercase (pending, resolved, etc.)
3. **Date Validation** - Implement start_date ≤ end_date validation in permissions
4. **Daily Reset** - Implement attendance status reset at midnight daily
5. **Clearance Workflow** - Prevent duplicate active clearances and enforce workflow

### Implementation Order
1. **First:** Database schema changes (Part 1) - 2-4 hours
2. **Second:** API response standardization (Part 2) - 6-8 hours
3. **Third:** Business logic & validation (Part 3) - 8-12 hours
4. **Fourth:** Testing & deployment (Parts 4-5) - 10-14 hours

### Success Criteria
- [ ] All database schema changes applied
- [ ] All API endpoints return correct JSON format
- [ ] All frontend tests pass without crashes
- [ ] Cache-first pattern works with new endpoints
- [ ] No data loss during migration
- [ ] Zero downtime deployment completed
- [ ] User feedback positive after 24 hours

---

**Report Status:** ✅ Complete  
**Ready for:** Backend Implementation  
**Next Step:** Schedule implementation with Backend Team

