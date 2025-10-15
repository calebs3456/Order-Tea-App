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

