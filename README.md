# WiandLo — *wisdom & love*

> *“Wisdom is knowing I am nothing, Love is knowing I am everything, and between the two my life moves.”*
> — **Nisargadatta Maharaj**

**WiandLo** is a quiet place to land.

Its name is the whole point: **Wi**sdom and **Lo**ve. Not one pole or the other, but the living space *between* them, where Nisargadatta says a life moves. The app is that space, made touchable.

Most apps fight for your attention. WiandLo asks only for your presence.

[⬇ **Download the APK**](https://github.com/adrian9867/wiandlo/releases/latest)

---

## ✦ Five worlds, one practice

A single dark, breathing world of five lands. And one practice: show up, breathe, and let something grow. No streaks. No coins. No badges. Only a hand-painted world that turns a little greener every time you stay, and a voice that reminds you showing up is enough.

| World | Hue | State | Whisper |
|---|---|---|---|
| **GROUND** | soft green | ✅ live | *quiet the noise.* Transmissions and free attunement. The soil remembers every session you stay through. |
| **OPEN** | soft purple | 🔒 sealed | The world of self-inquiry. Still closes; only a hint of it waits at the edge of every screen. |
| **SEE** | sky blue | 🔒 sealed | *perception.* Slumbering. |
| **LIVE** | warm amber | 🔒 sealed | *life.* Slumbering. |
| **ROOTS** | warm terracotta | 🔒 sealed | *origins.* Slumbering. |

One door is open. That is enough to begin.

---

## ✦ Download the release

Grab the latest build, already waiting on GitHub:

[**⬇ Download WiandLo APK**](https://github.com/adrian9867/wiandlo/releases/latest)

Each release ships with its own notes, so you can read what changed before you install.

---

## ✦ Gallery

Seven moments, caught as they happened. This is what stillness looks like.

![The five worlds. Four asleep, one awake.](screenshots/01-overview-worlds.png)

![Guided, or free? The choice is yours alone.](screenshots/03-choose-mode.png)

![Transmissions, in order. Each one unlocks the next.](screenshots/04-guided-tracks.png)

![The breath core, mid-session. Nothing else matters now.](screenshots/05-audio-player.png)

![Begin attunement. The threshold you cross alone.](screenshots/06-begin-attunement.png)

![Silence, Temple, Rain... pick the world behind your eyes.](screenshots/07-sound-environments.png)

![The Daily Inquiry. Questions that return, reflections that stay.](screenshots/08-reflections.png)

The gallery grows as the worlds wake.

---

## ✦ What waits inside

### GROUND: a world that grows because you stayed
- **The living earth.** Every completed session plants more life into a hand-painted ecosystem. A `CustomPainter` draws the world live, and it climbs seven stages, from a bare seed to deep forest:

| Sessions | Stage |
|---|---|
| 0 | dormant. Bare soil, one dormant seed. |
| 1–3 | the seed cracks. Something stirs. |
| 4–7 | seedling |
| 8–14 | growing |
| 15–25 | young tree |
| 26–40 | blooming |
| 41+ | forest. Ancient roots, primordial stillness. |

- **Guided Transmissions.** Recorded sessions meant to be heard in order; each one unlocks the next. Two ship in v1.0: *01 · Come to Presence* (5 min) and *02 · Cause & Effect I* (8 min). Auto-continue, ±10s seek, and a completion screen that demands nothing.
- **Free Attunement.** Your own pace on a **4-4-6-2 breath** (in · hold · out · rest), for 5, 10, 15 or 20 minutes, wrapped in six looping soundscapes: **Silence, Temple, Night Road, Rain, Market, Forest.**
- **Showing up counts.** Leave early and nothing is counted. No growth, no ceremony, no lecture. The world only remembers the times you stayed.

### Two quiet companions (present on every screen)

Both float through the app without being summoned. They are distinct, and they never merge.

- **The Daily Inquiry.** A separate widget that drifts at the edge of every screen. A single question that rotates with the date, one new mirror each dawn: *"Who is aware of these thoughts?"*, *"What would silence say if it could speak?"*, and eight more. Open it, and a private journal waits: write what arises, save it, revisit your past reflections. Everything stays on your device. This is the OPEN world's sentinel, here early, while the world itself stays sealed.
- **Safe Harbor.** A deep-cyan orb resting on every screen. One tap, one grounding sound, wherever you are. A place to land before you decide to stay.

---

## ✦ Run it from source

**Prerequisites:** Flutter 3.x (Dart 3) plus your platform toolchain.

```bash
git clone https://github.com/adrian9867/wiandlo && cd wiandlo
flutter pub get
flutter run
flutter analyze && flutter test
```

> `google_fonts` fetches Cormorant Garamond and Inter on first run. Bundle them under `assets/` for fully offline builds.

**Audio assets** the code expects in `assets/audio/`:

| File | Used by |
|---|---|
| `G01_phase01.mp3` · `G01_phase02.mp3` | Guided tracks 01–02 |
| `temple.mp3` · `nightroad.mp3` · `rain.mp3` · `market.mp3` · `forest.mp3` | Free-mode soundscapes |
| `safe_harbor.mp3` | Safe Harbor orb. Drop in your own; until then it hums "not available yet." |

---

## ✦ The bones

| Layer | Choice |
|---|---|
| Framework | Flutter, Dart >=3.0.0 <4.0.0 |
| Audio | `just_audio`: one shared player for every sound |
| Typography | `google_fonts`: Cormorant Garamond with Inter |
| Persistence | `shared_preferences`: sessions, unlocks, reflections |
| Animation | custom `CustomPainter`s, worlds drawn live, no image assets |

```
lib/
├── main.dart
├── theme/app_theme.dart
├── screens/
│   ├── overview/overview_screen.dart        # the five worlds
│   ├── open/daily_inquiry_screen.dart       # the daily question
│   └── ground/
│       ├── ground_world_screen.dart         # the living ecosystem
│       ├── ground_session_screen.dart       # transmissions & attunement
│       ├── ground_complete_screen.dart      # you showed up
│       └── widgets/ (growth_stage · world_painter)
└── widgets/ safe_harbor · daily_inquiry_anchor
assets/        audio · images · rive (reserved for what wakes next)
screenshots/   the images above
```

**Slumbering groundwork:** `riverpod` · `go_router` · Firebase (core/auth/firestore/storage) · `hive_flutter` · `flutter_local_notifications` · `rive` are already declared, waiting for the worlds that need them.

---

## ✦ What wakes next

- [x] GROUND: transmissions, free attunement, a world that grows
- [x] The Daily Inquiry, waking ahead of its world
- [ ] OPEN, SEE, LIVE and ROOTS awaken
- [ ] The full OPEN world
- [ ] Cloud sync, progress and reflections everywhere
- [ ] A morning reminder for the Daily Inquiry
- [ ] Rive worlds, breathing with real motion
- [ ] A test suite, the quiet kind

---

*Wisdom is knowing I am nothing. Love is knowing I am everything. WiandLo is the space between, and now it is yours to enter.*