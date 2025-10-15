# 🧭 Order Tea — Community Task Manager

[![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org)
[![Vapor](https://img.shields.io/badge/Framework-Vapor-blue.svg)](https://vapor.codes)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Web-lightgrey.svg)]()
[![Database](https://img.shields.io/badge/Database-MySQL-4479A1.svg)](https://www.mysql.com/)
[![License](https://img.shields.io/badge/License-Educational-green.svg)]()

---

### 💡 Recruiter TL;DR  
> **Solo-developed full-stack project (Swift + Vapor + MySQL + iOS)** built for my A-Level NEA.  
> Designed a community task-management app with a **custom scheduling algorithm**, full CRUD operations, **hashed authentication**, and simulated notifications — all built and tested end-to-end.  
> Demonstrates **software architecture, backend design, and app development** skills relevant to software engineering internships.

---

## 📘 Overview
A lightweight, privacy-conscious task manager for **community, family, and non-commercial groups**.  
Includes a **Swift/Vapor backend**, **web UI**, and **iOS app** for creating groups, assigning tasks/subtasks, scheduling by priority, and simulated reminders.  
Originally developed as an **A-Level NEA coursework project**.

---

## 🎯 Why this exists
Coordinating chores or community projects across multiple people can be messy — who does what, by when, and what matters most?  
**Order Tea** focuses on **clarity and simplicity**, allowing mixed-ability users to collaborate without paywalls or complexity.  
- Website → overview & schedule view  
- iOS App → quick task updates & management 

---

## 🔑 Key Features
- **Groups & Roles** – organisers assign; auxiliaries complete (families, clubs, DofE teams, etc.)  
- **Tasks + Subtasks** – full CRUD on both web and iOS; subtasks aggregate into progress tracking 
- **Scheduling Algorithm** – weighted priority using normalised factors (End Date, Start Date, Assigned Priority, Progress, Access Level) with reorderable weighting :contentReference[oaicite:4]{index=4}  
- **Auth & Sessions** – salted + hashed passwords, persistent login sessions 
- **Simulated Notifications** – JSON payloads written to file every 30 min to mimic APNs delivery 
- **Accessible UI** – consistent design & contrast for inclusive usability

---

## 🧰 Tech Stack
| Layer | Technology | Purpose |
|-------|-------------|----------|
| **Backend** | Swift + [Vapor](https://vapor.codes) | REST API + HTML (Leaf) + DB integration 
| **Web** | HTML / CSS / JavaScript (via Leaf) | Interface for management 
| **iOS** | Swift (UIKit) | Task + Group management, factor control
| **Database** | MySQL | Persistent data storage 

---

## 🗄️ Data Model (MySQL)

```sql
CREATE DATABASE courseworkVapor;

CREATE TABLE users(
  "username" varchar(255), "password" varchar(255), "userID" varchar(255)
);

CREATE TABLE groupSets(
  "GroupID" varchar(255), "UserID" varchar(255), "AccessLevel" int
);

CREATE TABLE groupNames(
  "GroupID" varchar(255), "GroupName" varchar(255)
);

CREATE TABLE tasks(
  "Title" varchar(255), "Description" varchar(255),
  "AssignedFrom" varchar(255), "AssignedTo" varchar(255),
  "AccessLevel" int, "EndDate" datetime, "AssignedPriority" int,
  "TaskID" varchar(255), "GroupID" varchar(255), "SubtaskNumber" int,
  "StartDate" datetime, "Complete" bool
);
```
## ⚙️ Scheduling Algorithm

Each task’s priority is determined by a **weighted combination** of configurable factors.  
Each factor is first **normalised** to a common 0–1 range, and then combined using **geometrically decaying weights** — meaning earlier factors in the list have a stronger influence.

**User-configurable factors:**
- **End Date** – time remaining until due  
- **Start Date** – time since task began  
- **Assigned Priority** – user-defined importance  
- **Progress** – proportion of subtasks completed  
- **Access Level** – reflects the authority of the assigner or assignee  

**Computation:**
1. Normalise all selected factors.  
2. Apply user-specified order of importance.  
3. Use geometric decay (e.g., weight = 0.7ⁿ for factor *n*) to emphasise earlier factors.  
4. Multiply and sum to produce a single priority score.  
5. Sort all tasks by this score using a **merge sort algorithm (O(n log n))** for efficiency.

---

## 🔔 Notifications

The backend implements **polling every 30 minutes** to simulate real-time notifications.  
When the current time matches a task’s reminder time:

1. A JSON payload resembling an **Apple Push Notification (APNs)** message is generated.  
2. Instead of sending it through APNs, the payload is written to a local file for demonstration purposes.  
3. This approach ensures the logic of notification timing is tested even without a developer account.

Example JSON payload:
```json
{
  "aps": {
    "alert": {
      "title": "Task Reminder",
      "body": "‘Submit Report’ is due in 30 minutes."
    },
    "sound": "default"
  }
}
```
## 🌐 API Examples

The backend exposes a simple RESTful API implemented using **Swift + Vapor**.  
All routes return structured **JSON** responses, and the iOS app communicates via `URLSession` with form-encoded or JSON bodies.

---

### 🧾 **Task Routes**

| Endpoint | Method | Description |
|-----------|---------|-------------|
| `/taskAPI/create` | **POST** | Create a new task. Used by the iOS client. Accepts form-encoded data including title, description, due date, and group ID. |
| `/taskAPI/list` | **GET** | Retrieve all tasks for a specific user or group. Returns an array of task objects with metadata and scheduling info. |
| `/taskAPI/update` | **POST** | Update task details (e.g. progress, priority, or completion status). |
| `/taskAPI/delete` | **DELETE** | Remove a specific task by its `TaskID`. Requires authentication. |
| `/taskAPI/factors` | **POST** | Update or reorder factor weightings used in the scheduling algorithm. |

---

### 👥 **User Routes**

| Endpoint | Method | Description |
|-----------|---------|-------------|
| `/userAPI/register` | **POST** | Register a new user. Passwords are salted and hashed before being stored. |
| `/userAPI/login` | **POST** | Authenticate a user and create a session token. Returns basic user info and session ID. |
| `/userAPI/logout` | **POST** | End the user’s current session securely. |

---

### 👪 **Group Routes**

| Endpoint | Method | Description |
|-----------|---------|-------------|
| `/groupAPI/create` | **POST** | Create a new group with a unique ID and name. |
| `/groupAPI/join` | **POST** | Join an existing group using a group code. |
| `/groupAPI/members` | **GET** | List all members and access levels within a group. |
| `/groupAPI/leave` | **DELETE** | Leave a specific group and remove membership mapping. |

---

### 📦 **Response Example**

**Successful task creation (`/taskAPI/create`):**
```json
{
  "status": "success",
  "taskID": "task_492b3a",
  "message": "Task created successfully."
}
```

## 🔒 Security

Security and privacy were key design considerations throughout development.  
The system implements multiple layers of protection to ensure safe data handling.

### 🧠 Key Measures
- **Hashed & Salted Passwords**  
  User passwords are never stored in plaintext. Each password is salted and hashed using **SHA-256** through Apple’s `CommonCrypto` framework before being saved to the database.

- **Session Tokens**  
  Upon login, a unique session token is generated and stored locally for the user’s session duration.  
  This prevents repeated credential entry and ensures requests are authenticated securely.

- **Minimal Data Exposure**  
  Each API route validates the user’s access level against their group membership to prevent unauthorised data access.

- **Input Validation & Sanitisation**  
  Both server and client validate user inputs to guard against injection attacks and malformed requests.

- **Local-only Authentication Flow**  
  The app avoids third-party dependencies and networked credential sharing, keeping user data confined to the system’s database.

---

## 🧪 Testing & Feedback

A mix of **unit**, **integration**, and **user testing** was performed to validate system reliability and usability.

### ✅ Functional Testing
| Area | Description | Result |
|------|--------------|--------|
| **CRUD Operations** | Verified on both web and iOS for users, groups, and tasks. | ✅ Passed |
| **Scheduling Algorithm** | Tested across different factor weights and orders for consistent task ranking. | ✅ Passed |
| **Login Sessions** | Ensured correct persistence and expiry handling for user sessions. | ✅ Passed |
| **Error Handling** | Confirmed graceful fallback for invalid inputs or missing data. | ✅ Passed |

### 💬 User Feedback
Real users were invited to interact with the application in a small pilot test. Key takeaways:
- The **interface was intuitive** and simple to navigate.  
- The **task organisation system felt logical** and easy to follow.  
- Users appreciated the clean visual structure and **clear progress feedback**.  
- Requested features included more frequent notifications and task comment threads.

### 🔍 Manual Testing Summary
- All major routes and features were tested under typical use conditions.  
- iOS app behaviour was validated on simulator and physical device.  
- Browser-based interactions confirmed cross-platform compatibility on macOS and Windows.

---

## 📱 iOS Views

The iOS app was designed for clarity and responsiveness, reflecting the web interface’s logic while optimising for mobile use.

| View | Description |
|------|--------------|
| **`LoginView`** | Manages user authentication and session creation with validation feedback. |
| **`GroupView`** | Displays all groups a user belongs to and provides creation/join options. |
| **`TaskView`** | Core workspace where users create, edit, and manage tasks and subtasks. |
| **`ChangeFactorsView`** | Enables users to reorder and adjust factor weights in the scheduling algorithm. |
| **`CreateGroupView`** | Allows creation of new collaborative groups and management of member roles. |
| **`ProfileView`** *(optional feature)* | Displays user info, session status, and basic app settings. |

### 🧭 Navigation Flow
1. **LoginView → GroupView** – user selects or creates a group  
2. **GroupView → TaskView** – view or manage tasks  
3. **TaskView → ChangeFactorsView** – modify scheduling preferences  
4. **Global Access** – ability to return to group overview or logout from any screen

The UI prioritises **speed, simplicity, and user feedback**, ensuring that core actions (task creation, editing, or completion) require no more than three taps.

---

## 📄 License

**Educational / Portfolio Use Only**

This project was developed as part of an **A-Level NEA Coursework** submission and is intended for **learning, demonstration, and personal portfolio purposes**.  
You are welcome to:
- Fork or clone the repository for **educational exploration**.  
- Reference code snippets for **non-commercial learning or interviews**.  
- Use the project as an example of **Swift/Vapor full-stack architecture**.

Please **do not redistribute or use commercially** without explicit permission from the author.

---

### ⭐ Acknowledgements

Thanks for visiting and exploring *Order Tea* ☕  
Built with curiosity, patience, and too much caffeine.

---
