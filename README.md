# 📌 Flutter Task Manager

A scalable Flutter Task Management Application built using modern architecture principles and best practices. The app integrates Firebase Authentication, Cloud Firestore, and a RESTful API with a robust offline-first caching strategy for seamless performance.

## 🔑 Key Highlights

### 🔐 Secure Authentication
Email & Password login with persistent sessions, validation, and user-friendly error handling.

###👤 User Profile Management
Profile data stored in Firestore (users/{userId}) with theme preference (Dark/Light mode) auto-applied on launch.

### 📋 Task Management Module

REST API integration with pagination (skip & limit)

Infinite scroll & pull-to-refresh

Search, filter (All / Completed / Pending)

Sort by Due Date, Priority, Created Date

Add / Update / Delete with optimistic UI

### 📡 Offline-First Architecture
Local caching using Hive/SQLite, automatic sync when online, and offline banner indicator.

### 🧠 State Management
Implemented using Riverpod / Bloc
Clean separation of concerns (No business logic in UI)
Proper loading and structured error states

### ⚠️ Structured Error Modeling
AppException, NetworkException, ServerException, CacheException, AuthException

### 🎨 UI & Experience

Material 3 design system

Responsive layout with proper spacing

Clean, modern UX

Empty state handling

No overflow issues

 
