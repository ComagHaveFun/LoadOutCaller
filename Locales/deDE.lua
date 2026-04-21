local ADDON_NAME, ns = ...
if GetLocale() ~= "deDE" then return end
local L = ns.L

L["Announces your active talent build on instance enter and ready check."] = "Sagt den aktiven Talent-Build beim Betreten einer Instanz oder bei einem Ready-Check an."

-- General
L["Addon enabled"] = "Addon aktiviert"
L["Master switch. When disabled, nothing happens."] = "Haupt-Schalter. Wenn deaktiviert, passiert nichts."

-- PvP match start
L["PvP match start"] = "PvP-Matchstart"
L["Last-chance re-check (seconds before match start)"] = "Letzter Check (Sekunden vor Match-Beginn)"
L["Schedules an extra loadout check this many seconds before the PvP match gates open - last chance to warn you if you swapped to the wrong build mid-countdown."] = "Plant eine zusätzliche Loadout-Prüfung diese Anzahl Sekunden vor dem Match-Beginn - letzte Chance, dich zu warnen falls du mitten im Countdown den falschen Build eingestellt hast."

-- Troubleshooting
L["Troubleshooting"] = "Fehlersuche"
L["Debug mode"] = "Debug-Modus"
L["Prints verbose diagnostic messages to chat (mode detection, battlefield status, skip decisions). Off by default - enable only when reporting a bug."] = "Gibt ausf\195\188hrliche Diagnose-Meldungen im Chat aus (Modus-Erkennung, Battlefield-Status, Skip-Entscheidungen). Standardm\195\164\195\159ig aus - nur zum Melden eines Bugs aktivieren."
L["Print debug snapshot"] = "Debug-Snapshot ausgeben"
L["Prints a one-off diagnostic to chat regardless of the debug toggle: ITL detection, active loadout name, current mode, and all relevant settings. Useful for reporting a bug without waiting for a trigger."] = "Gibt einmalig eine Diagnose in den Chat aus (unabhängig vom Debug-Toggle): ITL-Erkennung, aktueller Loadout-Name, aktueller Modus und alle relevanten Einstellungen. Nützlich zum Melden eines Bugs, ohne auf einen Trigger warten zu müssen."

-- Triggers
L["Announce on ready check"] = "Bei Ready-Check ansagen"
L["Always on ready check (ignore skip keyword)"] = "Immer bei Ready-Check (ignoriert Skip-Keyword)"
L["When active, always announce on ready check, even if the build name contains the skip keyword."] = "Wenn aktiv, wird bei jedem Ready-Check angesagt, auch wenn der Build-Name das Skip-Keyword enth\195\164lt."

-- Skip keywords

-- Display
L["Show on-screen text"] = "On-Screen-Text anzeigen"
L["Displays the build name as large text on screen (~5s fade)."] = "Zeigt den Build-Namen als gro\195\159en Text auf dem Bildschirm (~5s Fade)."
L["Post to chat"] = "In den Chat schreiben"
L["Prints the announcement to your chat window (visible only to you)."] = "Gibt die Ansage in deinem Chat-Fenster aus (nur f\195\188r dich sichtbar)."
L["Banner duration (seconds)"] = "Banner-Dauer (Sekunden)"
L["Banner font size"] = "Banner-Schriftgr\195\182\195\159e"
L["Play a sound on announcement"] = "Sound bei Ansage abspielen"
L["Plays a sound via Blizzard's sound system. Works independently of TTS."] = "Spielt einen Sound \195\188ber Blizzards Sound-System ab. Funktioniert unabh\195\164ngig von TTS."
L["Alert sound:"] = "Alarm-Sound:"
L["Test sound"] = "Sound testen"

-- Per-mode triggers
L["Mythic+ / Dungeons"] = "Mythic+ / Dungeons"
L["Raids"] = "Schlachtz\195\188ge"
L["Delves"] = "Tiefen"
L["Announce on entering a dungeon"] = "Beim Betreten eines Dungeons ansagen"
L["Announce on entering a raid"] = "Beim Betreten eines Schlachtzugs ansagen"
L["Announce on entering a delve"] = "Beim Betreten einer Tiefe ansagen"
L["Triggers the announcement when you enter a Mythic+ or 5-man dungeon."] = "L\195\182st die Ansage aus, wenn du einen Mythic+ oder 5er-Dungeon betrittst."
L["Triggers the announcement when you enter a raid instance."] = "L\195\182st die Ansage aus, wenn du einen Schlachtzug betrittst."
L["Triggers the announcement when you enter a delve."] = "L\195\182st die Ansage aus, wenn du eine Tiefe betrittst."
L["Triggers the announcement when a ready check is initiated."] = "L\195\182st die Ansage aus, wenn ein Ready-Check gestartet wird."
L["Always on enter (ignore skip keyword)"] = "Immer beim Betreten (Skip-Keyword ignorieren)"
L["When active, always announce on enter, even if the build name contains the skip keyword."] = "Wenn aktiv, wird beim Betreten immer angesagt, auch wenn der Build-Name das Skip-Keyword enth\195\164lt."
L["Skip keyword:"] = "Skip-Keyword:"
L["Skip keyword: if your active loadout name contains this word (case-insensitive), the announcement is skipped for that mode."] = "Skip-Keyword: Wenn dein aktiver Loadout-Name dieses Wort enth\195\164lt (unabh\195\164ngig von Gro\195\159-/Kleinschreibung), wird die Ansage f\195\188r diesen Modus geschluckt."
L["Reset to default"] = "Auf Standard zur\195\188cksetzen"
L["Sound"] = "Sound"
L["Display & Frame"] = "Anzeige & Frame"

-- PvP modes
L["Arena 2v2"] = "Arena 2v2"
L["Arena 3v3"] = "Arena 3v3"
L["Battlegrounds"] = "Schlachtfelder"

-- Open World modes
L["Open World (War Mode on)"] = "Open World (Kriegsmodus an)"
L["Open World (War Mode off)"] = "Open World (Kriegsmodus aus)"
L["Announce on entering open world"] = "Beim Betreten der Open World ansagen"
L["Triggers the announcement when you zone into the open world with War Mode enabled. Off by default - enable it if you use a dedicated War Mode build."] = "L\195\182st die Ansage aus, wenn du in die Open World mit aktiviertem Kriegsmodus wechselst. Standardm\195\164\195\159ig aus - aktiviere es, wenn du einen eigenen Kriegsmodus-Build nutzt."
L["Triggers the announcement when you zone into the open world with War Mode disabled (questing, dailies, world content). Off by default."] = "L\195\182st die Ansage aus, wenn du in die Open World mit deaktiviertem Kriegsmodus wechselst (Quests, Dailies, Welt-Inhalte). Standardm\195\164\195\159ig aus."
L["Announce on entering Arena 2v2"] = "Beim Betreten einer Arena 2v2 ansagen"
L["Announce on entering Arena 3v3"] = "Beim Betreten einer Arena 3v3 ansagen"
L["Announce on entering a battleground"] = "Beim Betreten eines Schlachtfelds ansagen"
L["Triggers the announcement when you enter a 2v2 arena match (ranked or skirmish)."] = "L\195\182st die Ansage aus, wenn du ein 2v2-Arenamatch betrittst (gewertet oder Skirmish)."
L["Triggers the announcement when you enter a 3v3 arena match (ranked, skirmish, or Solo Shuffle)."] = "L\195\182st die Ansage aus, wenn du ein 3v3-Arenamatch betrittst (gewertet, Skirmish oder Solo Shuffle)."
L["Triggers the announcement when you enter a battleground (including Epic BGs and rated)."] = "L\195\182st die Ansage aus, wenn du ein Schlachtfeld betrittst (inkl. Epic-BGs und gewertet)."

-- Spec & Role
L["Spec & Role"] = "Spec & Rolle"
L["Warn on role mismatch"] = "Bei Rollen-Mismatch warnen"
L["Warns via the configured outputs (banner/chat/TTS) when your assigned group role doesn't match your current spec's natural role."] = "Warnt \195\188ber die konfigurierten Ausgaben (Banner/Chat/TTS), wenn deine zugewiesene Gruppenrolle nicht zur nat\195\188rlichen Rolle deiner Spec passt."
L["Announce loadout on spec change"] = "Bei Spec-Wechsel ansagen"
L["Fires the build announcement when you switch talent specialization (same output as ready check / instance enter)."] = "L\195\182st die Build-Ansage aus, wenn du die Talent-Spezialisierung wechselst (gleiche Ausgabe wie Ready-Check / Instanz-Eintritt)."
L["Role mismatch: assigned {assigned}, spec is {spec}"] = "Rollen-Mismatch: zugewiesen {assigned}, Spec ist {spec}"

-- PvP match start countdown
L["Announce on match start countdown"] = "Bei Match-Start-Countdown ansagen"
L["Triggers the announcement when the PvP match start countdown begins."] = "L\195\182st die Ansage aus, wenn der PvP-Match-Start-Countdown beginnt."
L["Always on match start countdown (ignore skip keyword)"] = "Immer bei Match-Start-Countdown (Skip-Keyword ignorieren)"
L["When active, always announce on the match start countdown, even if the build name contains the skip keyword."] = "Wenn aktiv, wird beim Match-Start-Countdown immer angesagt, auch wenn der Build-Name das Skip-Keyword enth\195\164lt."

-- PvP queue invite
L["Announce on queue invite (PvP queue popped)"] = "Bei Queue-Pop ansagen (PvP-Einladung)"
L["Triggers the announcement when the PvP queue pops and the 'Enter Battle' dialog appears - the earliest moment to switch builds."] = "L\195\182st die Ansage aus, sobald die PvP-Queue plopp und der 'Beitreten'-Dialog erscheint - der fr\195\188heste Zeitpunkt, den Build noch zu wechseln."
L["Always on queue invite (ignore skip keyword)"] = "Immer bei Queue-Pop (Skip-Keyword ignorieren)"
L["When active, always announce on queue invite, even if the build name contains the skip keyword."] = "Wenn aktiv, wird beim Queue-Pop immer angesagt, auch wenn der Build-Name das Skip-Keyword enth\195\164lt."

-- PvE queue invite (LFG / LFR)
L["Announce on Dungeon Finder invite"] = "Bei Dungeonsuche-Einladung ansagen"
L["Triggers the announcement when the Dungeon Finder pops a 'Ready to enter' dialog (random / heroic dungeon). Premade groups and M+ don't fire this."] = "L\195\182st die Ansage aus, wenn die Dungeonsuche einen 'Bereit zum Betreten'-Dialog \195\182ffnet (Zufalls-/heroischer Dungeon). Premade-Gruppen und Mythic+ feuern dieses Event nicht."
L["Announce on Raid Finder invite"] = "Bei Schlachtzugssuche-Einladung ansagen"
L["Triggers the announcement when the Raid Finder (LFR) or Flex Raid pops a 'Ready to enter' dialog. Premade groups don't fire this."] = "L\195\182st die Ansage aus, wenn die Schlachtzugssuche (LFR) oder Flex-Raid einen 'Bereit zum Betreten'-Dialog \195\182ffnet. Premade-Gruppen feuern dieses Event nicht."
L["Move display frame: switch to Edit Mode (Esc -> Edit Mode). The frame will appear automatically and can be placed with the mouse."] = "Anzeige-Frame verschieben: In den Bearbeitungsmodus wechseln (Esc -> Bearbeitungsmodus). Der Frame erscheint dann automatisch und kann mit der Maus platziert werden."
L["Open Edit Mode"] = "Bearbeitungsmodus \195\182ffnen"

-- TTS
L["Text-to-Speech (TTS)"] = "Text-to-Speech (TTS)"
L["Use TTS"] = "TTS verwenden"
L["Speaks the build name via WoW's built-in TTS."] = "Spricht den Build-Namen \195\188ber die eingebaute WoW-TTS aus."
L["Message template (placeholder: {loadoutname}):"] = "Nachrichten-Template (Platzhalter: {loadoutname}):"
L["The spoken text uses the message template configured under 'Display & Frame'."] = "Der gesprochene Text nutzt das Nachrichten-Template aus 'Anzeige & Frame'."
L["On-screen text color"] = "Farbe des On-Screen-Texts"
L["Pick the color of the on-screen banner text."] = "W\195\164hle die Farbe des On-Screen-Banner-Texts."
L["Chat text color"] = "Farbe des Chat-Texts"
L["Pick the color of the chat-message text (the |cff3FC7EBLoadOutCaller|r prefix stays addon-blue)."] = "W\195\164hle die Farbe des Chat-Nachrichten-Texts (das |cff3FC7EBLoadOutCaller|r-Pr\195\164fix bleibt Addon-Blau)."
L["TTS voice:"] = "TTS-Stimme:"
L["Volume"] = "Lautst\195\164rke"
L["Speed"] = "Geschwindigkeit"
L["Test announcement"] = "Test-Ansage"
L["TTS API not available (C_VoiceChat.SpeakText missing)."] = "TTS-API nicht verf\195\188gbar (C_VoiceChat.SpeakText fehlt)."
L["TTS error: {details}"] = "TTS-Fehler: {details}"

-- Runtime strings
L["Current loadout: {loadoutname}"] = "Aktuelles Loadout: {loadoutname}"
L["No active build"] = "Kein aktiver Build"
L[" (default)"] = " (Standard)"
L["|cffffff00LoadOutCaller|r - drag to move"] = "|cffffff00LoadOutCaller|r - ziehen zum Verschieben"

-- Slash command feedback
L["Display frame locked."] = "Anzeige-Frame fixiert."
L["Display frame unlocked - drag to move, /lc lock to lock."] = "Anzeige-Frame entsperrt - ziehen zum Verschieben, /lc lock zum Fixieren."
L["Commands: /lc (options), /lc test, /lc lock, /lc unlock"] = "Befehle: /lc (Optionen), /lc test, /lc lock, /lc unlock"
L["Options not yet initialized - please /reload."] = "Optionen noch nicht initialisiert - bitte /reload."
