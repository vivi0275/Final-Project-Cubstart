# Nursy — Healthcare Task Management for iOS

**Nursy** (Xcode project name: *Cubstart*) is a native iOS application built with Swift and SwiftUI that helps hospital teams manage nursing tasks, patients, and medical protocols. It supports two distinct user roles — **Nurse** and **Management/Doctor** — with a full offline-first architecture and optional real-time cloud synchronisation via Firebase Firestore.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Technology Stack](#technology-stack)
- [Architecture](#architecture)
- [Data Models](#data-models)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Firebase Setup (optional)](#firebase-setup-optional)
- [Running the App](#running-the-app)
- [Project Structure](#project-structure)
- [Sample Data](#sample-data)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

Hospital nurses and doctors deal with dozens of tasks every shift. Nursy brings them together in a single app:

- Nurses can view, complete, and create tasks (including by voice), track their schedule on a calendar, and monitor their own performance on a dashboard.
- Doctors and head nurses can assign tasks, validate completed work, manage the patient roster, and visualise team workload at a glance.
- All data is stored locally with SwiftData, and can optionally be synchronised in real time across devices through Firebase Firestore.

---

## Features

### Nurse Profile

| Feature | Description |
|---------|-------------|
| **Task List** | View all assigned tasks with filtering by category, priority, and status |
| **Task Completion** | Mark tasks as done, add completion notes and timestamps |
| **Voice Task Creation** | Dictate a new task hands-free using native iOS speech recognition |
| **Calendar View** | See tasks scheduled by date; manage them directly from the calendar |
| **Dashboard** | Charts and KPIs for completion rates, category breakdown, and priority distribution with Day / Week / Month / Year filters |

### Management / Doctor Profile

| Feature | Description |
|---------|-------------|
| **Timeline Dashboard** | Real-time overview of every task across the full lifecycle |
| **Task Validation** | Approve completed tasks and leave doctor notes |
| **Task Creation & Assignment** | Create tasks, set priorities and deadlines, assign to specific nurses |
| **Patient Management** | Add patients, update status, view all associated tasks |
| **Team Workload** | Inspect per-nurse metrics: total tasks, completion rate, overdue alerts |
| **Medical Protocols** | Apply protocol templates to generate a set of tasks in one action |

### Cross-Cutting Features

- **Offline-first** — the app is fully functional without a network connection; SwiftData stores all data locally.
- **Real-time cloud sync** — when Firebase is configured, tasks synchronise across devices using Firestore listeners with timestamp-based conflict resolution.
- **Graceful degradation** — if `GoogleService-Info.plist` is absent, the app silently falls back to local-only mode.
- **Role-based routing** — `RootView` → `ProfileSelectionView` → role-specific tab bar, with no shared state between profiles.

---

## Technology Stack

| Layer | Technology |
|-------|-----------|
| Language | Swift 5.9+ |
| UI framework | SwiftUI (iOS 15+) |
| Local persistence | SwiftData (SQLite) |
| Reactive bindings | Combine |
| Charts | Swift Charts |
| Voice input | AVFoundation + Speech framework |
| Cloud database | Firebase Firestore |
| Firebase SDK | Firebase Core, Firebase Firestore |
| Build system | Xcode 15+ |
| Scripting | Bash |
| Editor integration | VS Code / Cursor with custom tasks |

---

## Architecture

The project follows a **service-oriented MVVM-lite** pattern:

```
ProfileSelectionView
        │
        ▼ (role selection)
  MainTabView  ──────────────────────────────────────────┐
    (Nurse)                                        (Doctor)
       │                                               │
  ┌────┴────┐                               ┌──────────┴─────────┐
  │ Tasks   │ CalendarView   DashboardView  │ Timeline  Patients │ Team
  │ (CRUD)  │                               │ Dashboard           │
  └────┬────┘                               └──────────┬─────────┘
       │                                               │
       └──────────────┬────────────────────────────────┘
                      │
             ┌────────┴────────┐
             │  SwiftData      │  ← local persistence
             │  (NursingTask,  │
             │   Patient,      │
             │   MedicalProtocol)
             └────────┬────────┘
                      │ TaskSyncService (bi-directional)
             ┌────────┴────────┐
             │  Firestore      │  ← cloud (optional)
             └─────────────────┘
```

### Key Services

| Service | Responsibility |
|---------|---------------|
| `FirebaseManager` | Firebase SDK initialisation |
| `FirestoreService` | Firestore CRUD and real-time listeners |
| `TaskSyncService` | Bi-directional sync between SwiftData and Firestore, conflict resolution |
| `SpeechRecognitionManager` | Microphone access, live speech-to-text transcription |
| `TaskParser` | Converts natural-language input into structured `NursingTask` objects |

---

## Data Models

### NursingTask

```swift
@Model class NursingTask {
    var id: UUID
    var title: String
    var taskDescription: String
    var isCompleted: Bool
    var priority: TaskPriority          // .urgent | .important | .normal
    var category: TaskCategory          // .patientCare | .medication | .documentation | …
    var patientId: String?
    var dueTime: Date?
    var createdAt: Date
    var completedAt: Date?
    var assignedTo: String?             // Staff ID, e.g. "N-001"
    var assignedBy: String?             // Doctor ID
    var assignedAt: Date?
    var completedByStaffId: String?
    var completedNotes: String?
    var validatedByDoctor: Bool
    var validatedAt: Date?
    var doctorNotes: String?
}
```

**Task lifecycle:** `Pending → In Progress → Completed → Validated`

**Categories:** Patient Care · Medication · Documentation · Rounds · Emergency · Training · Administrative · Team Meeting

### Patient

```swift
@Model class Patient {
    var id: UUID
    var patientId: String               // e.g. "P-001"
    var name: String
    var roomNumber: String?
    var diagnosis: String?
    var admissionDate: Date
    var status: PatientStatus           // .critical | .serious | .stable | .recovering | .discharged
    var notes: String
    var assignedDoctor: String?
}
```

### MedicalProtocol

```swift
@Model class MedicalProtocol {
    var id: UUID
    var name: String
    var protocolDescription: String
    var category: ProtocolCategory      // .postOp | .preOp | .emergency | .routine | .specialized | .monitoring
    var estimatedDuration: TimeInterval
    var taskTemplateIds: [String]
    var isActive: Bool
    var createdAt: Date
    var usageCount: Int
}
```

### StaffMember

```swift
struct StaffMember: Codable {
    var id: UUID
    var staffId: String                 // e.g. "N-001"
    var name: String
    var role: StaffRole                 // .rn | .lpn | .na | .headNurse
    var department: String
    var shift: ShiftType                // .day | .evening | .night
    var isActive: Bool
}
```

---

## Getting Started

### Prerequisites

- **macOS** with **Xcode 15 or later** installed
- **iOS 15+** simulator or physical iPhone
- **Git**
- *(Optional)* A Firebase project for cloud synchronisation

### Installation

```bash
git clone https://github.com/vivi0275/Nursy.git
cd Nursy
open Cubstart.xcodeproj
```

Xcode will resolve Swift Package dependencies (Firebase) automatically on first open.

### Firebase Setup (optional)

Cloud sync is entirely optional. To enable it:

1. Go to the [Firebase Console](https://console.firebase.google.com) and create a new project.
2. Add an iOS app using your app's Bundle ID.
3. Download the generated `GoogleService-Info.plist`.
4. Drag the file into the `Cubstart/` folder in Xcode. Make sure **Copy items if needed** is checked.
5. Verify the file appears in the Xcode project navigator.
6. Firebase will configure itself automatically on the next launch.

> **Without Firebase:** The app runs entirely offline. Data is persisted in SwiftData only; no cloud sync takes place.

For full details, see [`FIREBASE_SETUP.md`](FIREBASE_SETUP.md).

---

## Running the App

### Xcode (recommended)

1. Open `Cubstart.xcodeproj` in Xcode.
2. Select a simulator or connected iPhone from the scheme picker.
3. Press **⌘ R** (or **Product → Run**).

### VS Code / Cursor shortcuts

| Shortcut | Action |
|----------|--------|
| `⌘ ⇧ R` | Launch in iPhone Simulator |
| `⌘ ⇧ D` | Deploy to connected iPhone |
| `⌘ ⇧ P` → type task name | Run any custom task from the palette |

### Shell scripts

```bash
# Launch in Simulator
./scripts/run-ios-simulator.sh

# Deploy to a connected iPhone
./scripts/run-ios-device.sh

# Automated Firebase package setup
./scripts/add-firebase-package.sh

# Device diagnostics
./scripts/diagnostic-iphone.sh
./scripts/find-device-info.sh
```

### Local database

SwiftData stores the SQLite database at:

```
~/Library/Application\ Support/Cubstart.sqlite
```

The database is created automatically on first launch; no migration steps are needed.

---

## Project Structure

```
Nursy/
├── Cubstart/                          # App source code
│   ├── Models/
│   │   ├── PatientModel.swift
│   │   ├── TaskModel.swift
│   │   ├── StaffMember.swift
│   │   └── MedicalProtocol.swift
│   ├── Services/
│   │   ├── FirebaseManager.swift
│   │   ├── FirestoreService.swift
│   │   ├── TaskSyncService.swift
│   │   ├── SpeechRecognitionManager.swift
│   │   └── TaskParser.swift
│   └── Views/
│       ├── RootView.swift
│       ├── ProfileSelectionView.swift
│       ├── MainTabView.swift
│       ├── Nurse/
│       │   ├── ContentView.swift      # Task list & filtering
│       │   ├── CalendarView.swift
│       │   ├── DashboardView.swift
│       │   ├── AddTaskView.swift
│       │   ├── VoiceTaskView.swift
│       │   └── TaskRowView.swift
│       ├── Doctor/
│       │   ├── DoctorTimelineDashboard.swift
│       │   ├── DoctorPatientsView.swift
│       │   ├── DoctorTeamView.swift
│       │   ├── DoctorCreateTaskView.swift
│       │   └── DoctorValidationView.swift
│       └── Common/
│           ├── PatientDetailView.swift
│           ├── AddPatientView.swift
│           ├── StaffDetailView.swift
│           ├── TaskCompletionView.swift
│           ├── ProtocolsView.swift
│           ├── SettingsView.swift
│           └── QuickActionsView.swift
├── CubstartTests/                     # Unit tests
├── CubstartUITests/                   # UI tests
├── scripts/                           # Build & deployment automation
├── Cubstart.xcodeproj/                # Xcode project
├── FIREBASE_SETUP.md                  # Firebase configuration guide
└── README.md                          # This file
```

---

## Sample Data

When running in `DEBUG` mode, the app auto-populates the following sample data:

**Patients**

| ID | Name | Status | Diagnosis |
|----|------|--------|-----------|
| P-001 | John Smith | Stable | Post-operative recovery |
| P-002 | Maria Garcia | Serious | Pneumonia |
| P-003 | Robert Johnson | Critical | Cardiac monitoring |
| P-004 | Emily Davis | Stable | Diabetes management |
| P-005 | Michael Brown | Recovering | Fracture repair |

**Staff** — 8 pre-populated members with roles (RN, LPN, NA, Head Nurse), departments, and shifts (Day / Evening / Night).

**Medical Protocols** — 6 protocol templates: Post-Op, Pre-Op, Emergency, Routine, Specialized, Monitoring.

---

## Contributing

1. Fork the repository and create a feature branch: `git checkout -b feature/my-feature`
2. Commit your changes: `git commit -m "Add my feature"`
3. Push the branch: `git push origin feature/my-feature`
4. Open a pull request describing your changes.

Please ensure your code builds without warnings and passes the existing test suite (`CubstartTests` and `CubstartUITests`) before submitting.

---

## License

This project is provided for educational and development purposes. See the repository for any applicable license information.
