# Flutter Layout & Gesture Demo

A small Flutter app with two screens:

- **File List** — a `ListView` demonstrating `GestureDetector` (tap, long-press, tap-down/up/cancel with a press animation).
- **Profile** — a custom Instagram-style card built with **`CustomMultiChildLayout`**, which is the focus of this README.

---

## Why `CustomMultiChildLayout`?

Most Flutter layouts are built by nesting `Row`, `Column`, `Stack`, and
`Padding`. That works until you need something a `Stack` can't express
cleanly — widgets whose size *and* position both depend on each other, or
on the parent's own size, calculated in one place.

`CustomMultiChildLayout` solves that: you give it several children, each
tagged with an ID, and a single **delegate** class decides — in code —
exactly how big each child is and exactly where it goes. It's the same
mechanism `Stack`/`IndexedStack` use internally, just exposed for your own
custom arrangements.

Used here to build a profile card where:
- a cover banner spans the full width at a fixed height,
- a circular avatar overlaps the boundary between the cover and the body,
- a name label sits below the avatar,
- a stats row sits at the bottom.

A `Stack` + `Positioned` could technically do this, but every position would
be a scattered magic number. `CustomMultiChildLayout` keeps *all* of that
math in one method, next to itself, easy to reason about and easy to change.

---

## The three pieces

### 1. Slot IDs

```dart
enum ProfileSlot { cover, avatar, name, stats }
```

An identifier for each child. Any `Object` works as an ID (`String`, `int`,
an enum) — an enum is used here because it's type-safe and self-documenting.

### 2. `LayoutId` — tagging each child

```dart
CustomMultiChildLayout(
  delegate: ProfileDelegate(),
  children: [
    LayoutId(id: ProfileSlot.cover, child: /* ... */),
    LayoutId(id: ProfileSlot.avatar, child: /* ... */),
    LayoutId(id: ProfileSlot.name, child: /* ... */),
    LayoutId(id: ProfileSlot.stats, child: /* ... */),
  ],
)
```

Every child passed to `CustomMultiChildLayout` **must** be wrapped in a
`LayoutId` so the delegate can address it by ID. The order of children in
the list doesn't matter — only the ID does, and paint order follows list
order (first = painted first = bottom-most if things overlap, which is why
`cover` is listed before `avatar`).

### 3. `MultiChildLayoutDelegate` — the actual layout logic

```dart
class ProfileDelegate extends MultiChildLayoutDelegate {
  @override
  void performLayout(Size size) {
    // 1. size the child
    layoutChild(ProfileSlot.cover, BoxConstraints.tight(Size(size.width, 120)));
    // 2. place it
    positionChild(ProfileSlot.cover, Offset.zero);

    layoutChild(ProfileSlot.avatar, BoxConstraints.tight(const Size(80, 80)));
    positionChild(ProfileSlot.avatar, Offset(size.width / 2 - 40, 80));

    layoutChild(ProfileSlot.name, BoxConstraints.tight(Size(size.width, 40)));
    positionChild(ProfileSlot.name, const Offset(0, 170));

    layoutChild(ProfileSlot.stats, BoxConstraints.tight(Size(size.width, 60)));
    positionChild(ProfileSlot.stats, const Offset(0, 220));
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) => false;
}
```

`performLayout(Size size)` is called once with the size the
`CustomMultiChildLayout` itself was given by its parent (here, a fixed
`340 × 300` container). Inside it, for **every** child you must:

1. Call `layoutChild(id, constraints)` — this sizes the child and also
   *measures* it, so its resulting size is available to later calculations.
2. Call `positionChild(id, offset)` — this places the child's top-left
   corner at that offset, relative to the layout's own top-left.

**Every child listed in `children:` must get exactly one `layoutChild` +
`positionChild` call, or Flutter throws at runtime.** This is the most
common way this widget breaks in practice.

Notice the avatar's math: `size.width / 2 - 40` centers an 80-wide box
horizontally, and `80` for its `y` deliberately overlaps the bottom 40px of
the 120-tall cover — that overlap is the whole reason this needed manual
positioning instead of a plain `Column`.

`shouldRelayout` returns `false` here because nothing about this layout
ever changes at runtime — the delegate has no external state to track. If
your delegate took a constructor parameter (e.g. an avatar size the user
could change), you'd compare `oldDelegate`'s value to the new one here and
return `true` when they differ, so Flutter knows to re-run `performLayout`.

---

## Where it's used

```
ProfileScreen
  └─ Container (340×300, rounded, clipped)
       └─ CustomMultiChildLayout(delegate: ProfileDelegate())
            ├─ LayoutId(cover)  → colored banner
            ├─ LayoutId(avatar) → circular icon, overlaps cover
            ├─ LayoutId(name)   → centered text
            └─ LayoutId(stats)  → Row of StatItem (Posts / Followers / Following)
```

Open **Profile** from the app bar icon on the file list screen to see it.

---

## Project structure

Everything currently lives in a single file for simplicity:

```
lib/
  main.dart
    ├─ GestureDetectorDemoApp   — MaterialApp root
    ├─ FileListScreen           — main screen, GestureDetector demo
    ├─ FileOpenScreen           — detail screen (reached via onTap)
    ├─ ProfileScreen            — CustomMultiChildLayout demo
    ├─ ProfileDelegate          — the layout delegate described above
    └─ StatItem                 — small reusable stat widget
```

## Running it

```
flutter pub get
flutter run
```

