# RentEasy Flutter rules

- Flutter 3.x, Dart 3 null safety, Material 3 (ThemeData with colorScheme.fromSeed), Provider for state.
- The Figma wireframes are low-fidelity: use them for information, layout and flow only. Choose a clean, consistent Material 3 look yourself
- Widgets: small, reusable, const constructors, no business logic inside widgets.
- Folders: TMA3084-SpringTech-RentEasy/src/frontend/lib/widgets, TMA3084-SpringTech-RentEasy/src/frontend/lib/screens, TMA3084-SpringTech-RentEasy/src/frontend/lib/models (use mock data first).
- Accessibility: tap targets at least 48x48, good text contrast, works on small and large phones.
- Every new widget needs a widget test in test/.

## Code requirements

- Maintain a clean, readable, maintainable, consistent code style.

## Widgets

- Widgets are small, reusable, with const constructors and no business logic inside.
- Before building any UI piece, check what already exists: first the widgets in src/frontend/lib/widgets, then Flutter's built-in Material 3 widgets (AppBar, NavigationBar, SearchBar, SegmentedButton, Card, etc.). Reuse or extend an existing widget (for example, add an optional parameter) instead of duplicating code.
- Create a new widget whenever it is needed, even if it is not in docs/widget-inventory.md (the inventory is a guide, not a limit). Create one when a UI piece is used in 2 or more places, or when a screen's build method becomes long.
- One widget per file, file names in snake_case.
- Every new widget needs a widget test in src/frontend/test/.
- At the end of each reply, list which widgets you reused and which you created.
- If docs/widget-inventory.md exists, add each new widget to it.
