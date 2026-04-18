# LoadOutCaller

**Never pull a boss with your questing build again.**

LoadOutCaller announces your currently selected talent loadout the moment you enter a Mythic+ (M+) dungeon, a raid, a Delve, an arena, or a battleground - when a ready check starts, when the PvP match-start countdown begins, or when you switch specialization. It also warns you if your assigned group role doesn't match your spec. The loadout name is spoken out loud via WoW's built-in text-to-speech, written to chat, and shown as large text on your screen - so you notice *before* the pull that you're still on the wrong build.

## Features

- **Six independent modes**: Mythic+ / Dungeons, Raids, Delves, Arena 2v2, Arena 3v3, and Battlegrounds - each with its own triggers and skip keyword. PvE modes (dungeon/raid/delve) support both instance-enter and ready-check triggers; PvP modes support instance-enter and **match-start countdown** (fires when the arena/BG gates-open countdown begins). Arena 3v3 covers rated, skirmish, **and** Solo Shuffle (all 6-player brackets); Arena 2v2 covers rated and skirmish.
- **Spec / role safety net**: warns when your assigned group role (Tank/Healer/Damage) doesn't match your current spec's natural role (e.g. signed up as Tank but currently in Frost DK). Also announces your loadout on spec switch, re-applying the skip-keyword logic.
- **Four output channels**: on-screen banner, chat message, spoken TTS, and a short sound alert - each independently toggleable.
- **Customizable banner**: configurable display duration (1-15s) and font size (12-64pt), repositionable via Blizzard's Edit Mode.
- **Sound alerts**: curated Blizzard sound presets (Ready Check, Raid Warning, Alarm Clock, …). If [LibSharedMedia-3.0](https://www.curseforge.com/wow/addons/libsharedmedia-3-0) is installed, its sounds are offered too - but it's **not** a dependency.
- **Smart skip**: if your active loadout already contains a keyword (e.g. `M+` in dungeons, `Raid` in raids, `Delves` in delves), the announcement is silently skipped for that mode. Keywords are fully configurable and case-insensitive.
- **Per-trigger "always announce"** flags per mode if you want the reminder unconditionally (e.g. on every raid ready check).
- **Draggable display frame** integrated with Blizzard's **Edit Mode** - no clunky lock/unlock commands needed, just Esc -> Edit Mode.
- **Fully configurable TTS**: voice, volume, speed, and a custom message template with a `{build}` placeholder.
- **In-game options panel** under Esc -> Options -> AddOns (no chat-command config).
- **11 locales**: English, German, French, Spanish (ES+MX), Italian, Portuguese (BR), Russian, Korean, Simplified + Traditional Chinese.

## Installation

### CurseForge

Install via the CurseForge app or download from the addon's CurseForge page and extract into:

```
World of Warcraft\_retail_\Interface\AddOns\
```

### Manual

1. Download the zip.
2. Extract so that `LoadOutCaller\LoadOutCaller.toc` ends up in `World of Warcraft\_retail_\Interface\AddOns\LoadOutCaller\`.
3. Restart WoW (or `/reload` if already running) and enable *LoadOutCaller* in the AddOns list.

## Usage

### Slash commands

| Command | Effect |
|---|---|
| `/lc` or `/loadoutcaller` | Open the options panel |
| `/lc test` | Trigger a test announcement using your current loadout |
| `/lc lock` / `/lc unlock` | Fallback to lock/unlock the display frame without Edit Mode |
| `/lc help` | List commands |

### Moving the on-screen banner

Press **Esc -> Edit Mode**. The banner appears automatically, drag it wherever you want, exit Edit Mode - position is saved. (You can also open Edit Mode directly from the options panel with the *Open Edit Mode* button.)

### Options

The panel lives at **Esc -> Options -> AddOns -> LoadOutCaller**. Settings:

- **Addon enabled** - master switch.
- **Per-mode sections** - six independent blocks:
  - **PvE** (Mythic+ / Dungeons, Raids, Delves): *Announce on entering*, *Announce on ready check*, *Always on enter*, *Always on ready check*, *Skip keyword* (defaults `M+`, `Raid`, `Delves`).
  - **PvP** (Arena 2v2, Arena 3v3, Battlegrounds): *Announce on entering*, *Announce on match start countdown*, *Always on enter*, *Always on match start countdown*, *Skip keyword* (default `PvP`).
  - *Skip keyword* logic: if your active loadout name contains the keyword (case-insensitive), the announcement for that mode is skipped - unless the matching *Always on …* flag is set.
- **Spec & Role**:
  - *Warn on role mismatch* - compares `UnitGroupRolesAssigned("player")` with your spec's role; warns if they differ.
  - *Announce loadout on spec change* - fires the full build announcement (plus role check) when you switch specialization.
- **Show on-screen text** - toggle the banner.
- **Banner duration / font size** - tune the banner's on-screen time and text size.
- **Post to chat** - prints the announcement to your local chat window (visible only to you).
- **Play a sound on announcement** - enables a short audio alert. Pick from Blizzard presets or LibSharedMedia sounds (if installed).
- **Use TTS** - toggle voice output.
- **TTS template** - custom message, `{build}` is replaced with your loadout name. Default: *"Current build: {build}"* (localized).
- **TTS voice / volume / speed** - standard TTS parameters.
- **Test announcement** - fires a manual announcement to preview your settings.

## How the per-mode skip keyword works

Example: you name your M+ loadout `"Fury M+"` and your raid loadouts `"Fury Council"`, `"Fury ST"`, etc.

- **Mythic+ dungeon, `"Fury M+"` active** -> *silent* (name contains `M+`, clearly the right build).
- **Mythic+ dungeon, `"Fury Council"` active** -> *announced* (name doesn't contain `M+`, so you probably forgot to switch).
- **Raid boss ready check, loadout = `"Fury Council"` for that fight**:
  - With *Always on ready check* **off**: *silent* (name doesn't contain `Raid`, but maybe that's fine - you still won't get a nudge).
  - With *Always on ready check* **on**: *announced every time* (recommended if you use a per-boss loadout naming scheme, so you hear the loadout name before every pull regardless of skip keyword).

Use per-mode `Always on …` toggles to customize the behavior per context.

## Requirements

- World of Warcraft Retail, The War Within / Midnight (Interface `120001`).
- TTS works out of the box using Blizzard's built-in voice engine; no external dependencies.

## Languages

| Locale | Status |
|---|---|
| enUS / enGB | base |
| deDE | native |
| frFR | translated |
| esES / esMX | translated |
| itIT | translated |
| ptBR | translated |
| ruRU | translated |
| koKR | translated |
| zhCN | translated |
| zhTW | translated |

Translations for non-English locales were done with reasonable care but have not been reviewed by native speakers for every language. Native-speaker corrections welcome - strings live in `Locales/<locale>.lua`, keyed by their English original.

## License

MIT

## Credits

Author: Comag-Malfurion (Have Fun)
 