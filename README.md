# 📂 Interview Task – Simple Category Manager

Welcome! 🎉

This little Flutter app is meant to show off a clean, easy‑to‑understand code base that you can pick up in a few minutes. It lets you manage categories (think *Electronics → Android → Samsung*) – add, view, search and delete them – all on your phone or emulator.

---

## What the app does

- **Home screen** – a friendly greeting, a search bar, and a paginated list of top‑level categories.
- **Add Category** – a bright *Add Category* button replaces the old *Manage* button. Tap it, type a name, and boom – the new category appears.
- **Add Sub‑category** – on the category detail page you get a floating `+` button that works the same way, but attaches the new item under the selected parent.
- **Search** – start typing and you instantly see *all* matching results (no pagination for search, so you never miss anything).
- **Delete** – swipe left or hit the trash icon to remove a category and everything beneath it.
- **Profile tab** – a quick view of the logged‑in user’s name, email and username.

That’s it – a tiny, self‑contained app that demonstrates good UI patterns without any backend.

---

## Why we chose the tools we did

### Provider for state management
- **Lightweight:** No ceremony, just a couple of `ChangeNotifier`s.
- **Flutter‑first:** It’s part of the official ecosystem, well‑documented and works everywhere.
- **Perfect fit:** Our state is simple – current page, search query, and a refresh trigger. Provider handles that with almost no boilerplate.

### SQLite (via `sqflite`) for local storage
- **Relational data:** Categories have a parent‑child relationship – SQLite lets us query that efficiently.
- **Offline‑first:** The app works even when you have no internet, which is great for interview demos.
- **Tiny footprint:** For a project this size the database is only a few kilobytes; no server needed.

---

## Project layout (at a glance)
```
/lib
├─ models/            # `Category` data class
├─ services/          # `DbService` – all the SQLite CRUD helpers
├─ views/             # UI screens (`home_screen.dart`, `category_page.dart`)
├─ main.dart          # App entry, Provider setup
└─ utils/ (optional) # small helper functions

pubspec.yaml          # dependencies (provider, sqflite, path)
README.md             # you are reading it now!
```

---

## Getting the app up and running

1. **Make sure you have Flutter** installed (stable channel) and an emulator or device ready.
2. **Grab the packages** – this step needs internet:
   ```bash
   flutter pub get
   ```
3. **Launch the app**:
   ```bash
   flutter run
   ```
   The app will start on the Home screen. Try adding a category, searching, deleting, and switching to the Profile tab.

---

## Demo login details (hard‑coded mock payload)
When the app starts you’ll see a *Login* screen that expects a username and an email. Use the values below – they’ll also appear on the Profile tab after you “log in”.

```json
{
  "username": "Bret",
  "email": "Sincere@april.biz"
}
```

