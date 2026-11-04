
# 📂 Interview Task – Category Manager

A Flutter app to manage categories in a tree structure (e.g. *Electronics → Android → Samsung*). Built with clean, simple code that's easy to follow.

---

## What the app does

- Browse, add, edit, and delete categories at any depth
- Paginated list of categories (10 per page)
- Search across all categories with breadcrumb path shown
- Profile tab showing user info (name, email, phone, website, company)

---

## Project Architecture

Simple layered structure — nothing fancy:

```
lib/
├── models/      →  Data classes (Category)
├── services/    →  DbService (SQLite CRUD), ApiService (login API)
├── providers/   →  UserProvider, CategoryProvider, HomeProvider (all app state)
├── views/       →  UI screens (splash_screen.dart, login_screen.dart, home_screen.dart, category_screen.dart, profile_screen.dart)
└── main.dart    →  App entry point, Provider setup
```

The UI never touches the database directly — it always goes through `DbService` via Providers. Same for the API — `ApiService` handles the HTTP call and `UserProvider` holds the result.

---

## State Management

The entire app uses **Provider** (`ChangeNotifierProvider`) for state management, and **all UI screens are 100% `StatelessWidget`s**.

- **`UserProvider`**: Handles authentication, mock login via API, and holds current user profile data.
- **`CategoryProvider`**: Scoped per category level; manages category CRUD operations, database queries, and pagination (`currentPage`, `totalPages`, `prevPage()`, `nextPage()`, and reload after add/edit/delete).
- **`HomeProvider`**: Manages bottom navigation bar switching and full-tree category search query & results.

Every screen listens to its provider via `context.watch<T>()` or `Consumer<T>`, cleanly separating business logic and database operations from presentation.

---

## Local Database

**SQLite via `sqflite`** — chosen because:
- Categories have a parent-child relationship that fits naturally in a relational table
- Works fully offline, data persists across restarts
- Lightweight and fast for this scale

Schema:
```sql
CREATE TABLE categories (
  id        INTEGER PRIMARY KEY AUTOINCREMENT,
  name      TEXT NOT NULL,
  parent_id INTEGER  -- NULL = root category
);
```

---

## Category Hierarchy

Uses an **adjacency list** — each row stores a `parent_id` pointing to its parent (or NULL for root).

- Tapping a category pushes a new `CategoryScreen` with that item's `id` as `parentId` — the same screen reused at every level
- Deleting a category recursively deletes all its children first
- Search results show a breadcrumb path (`Electronics › Android › Samsung`) built by walking up the `parent_id` chain

---

## Search & Pagination

**Search** runs a `LIKE '%query%'` across the whole categories table — all levels, no pagination on results so nothing is hidden.

**Pagination** uses SQL `LIMIT` and `OFFSET`. Page size is 10. The total count is fetched with `COUNT(*)` so the bar shows `Page 1 / 5` and disables arrows at the edges.

---

## Running the app

```bash
flutter pub get
flutter run
```

**Demo login:**
```
Username: Bret
Email:    Sincere@april.biz
```
