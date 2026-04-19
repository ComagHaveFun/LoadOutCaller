local ADDON_NAME, ns = ...
if GetLocale() ~= "deDE" then return end
local L = ns.L

L["Announces your active talent build on instance enter and ready check."] = "Sagt den aktiven Talent-Build beim Betreten einer Instanz oder bei einem Ready-Check an."

-- General
L["Addon enabled"] = "Addon aktiviert"
L["Master switch. When disabled, nothing happens."] = "Haupt-Schalter. Wenn deaktiviert, passiert nichts."

-- Triggers
L["Triggers"] = "Ausl\195\182ser"
L["Announce on instance enter (5-man dungeon or raid)"] = "Bei Instanz-Eintritt ansagen (5er-Dungeon oder Raid)"
L["Triggers the announcement when you enter a dungeon or raid instance."] = "L\195\182st die Ansage aus, wenn du eine Dungeon- oder Raid-Instanz betrittst."
L["Announce on ready check"] = "Bei Ready-Check ansagen"
L["Triggers the announcement when a ready check is initiated in a dungeon/raid."] = "L\195\182st die Ansage aus, wenn in Dungeon/Raid ein Ready-Check gestartet wird."
L["Always on instance enter (ignore skip keyword)"] = "Immer bei Instanz-Eintritt (ignoriert Skip-Keyword)"
L["When active, always announce on instance enter, even if the build name contains the skip keyword."] = "Wenn aktiv, wird bei Instanz-Eintritt immer angesagt, auch wenn der Build-Name das Skip-Keyword enth\195\164lt."
L["Always on ready check (ignore skip keyword)"] = "Immer bei Ready-Check (ignoriert Skip-Keyword)"
L["When active, always announce on ready check, even if the build name contains the skip keyword."] = "Wenn aktiv, wird bei jedem Ready-Check angesagt, auch wenn der Build-Name das Skip-Keyword enth\195\164lt."

-- Skip keywords
L["Skip keywords (case-insensitive)"] = "Skip-Keywords (gro\195\159-/kleinschreibungsunabh\195\164ngig)"
L["If the active build name contains this keyword, the announcement is skipped."] = "Wenn der aktive Build-Name dieses Wort enth\195\164lt, wird die Ansage geschluckt."
L["5-man dungeons:"] = "5er-Instanzen:"
L["Raids:"] = "Raids:"

-- Display
L["Display"] = "Anzeige"
L["Show on-screen text"] = "On-Screen-Text anzeigen"
L["Displays the build name as large text on screen (~5s fade)."] = "Zeigt den Build-Namen als gro\195\159en Text auf dem Bildschirm (~5s Fade)."
L["Post to chat"] = "In den Chat schreiben"
L["Prints the announcement to your chat window (visible only to you)."] = "Gibt die Ansage in deinem Chat-Fenster aus (nur f\195\188r dich sichtbar)."
L["Banner duration (seconds)"] = "Banner-Dauer (Sekunden)"
L["Banner font size"] = "Banner-Schriftgr\195\182\195\159e"
L["Sound alert"] = "Sound-Alarm"
L["Play a sound on announcement"] = "Sound bei Ansage abspielen"
L["Plays a sound via Blizzard's sound system. Works independently of TTS."] = "Spielt einen Sound \195\188ber Blizzards Sound-System ab. Funktioniert unabh\195\164ngig von TTS."
L["Alert sound:"] = "Alarm-Sound:"
L["Test sound"] = "Sound testen"

-- Per-mode triggers
L["Mythic+ / Dungeons"] = "Mythic+ / Dungeons"
L["Raids"] = "Raids"
L["Delves"] = "Delves"
L["Announce on entering a dungeon"] = "Beim Betreten eines Dungeons ansagen"
L["Announce on entering a raid"] = "Beim Betreten eines Raids ansagen"
L["Announce on entering a delve"] = "Beim Betreten einer Delve ansagen"
L["Triggers the announcement when you enter a Mythic+ or 5-man dungeon."] = "L\195\182st die Ansage aus, wenn du einen Mythic+ oder 5er-Dungeon betrittst."
L["Triggers the announcement when you enter a raid instance."] = "L\195\182st die Ansage aus, wenn du einen Raid betrittst."
L["Triggers the announcement when you enter a delve."] = "L\195\182st die Ansage aus, wenn du eine Delve betrittst."
L["Triggers the announcement when a ready check is initiated."] = "L\195\182st die Ansage aus, wenn ein Ready-Check gestartet wird."
L["Always on enter (ignore skip keyword)"] = "Immer beim Betreten (Skip-Keyword ignorieren)"
L["When active, always announce on enter, even if the build name contains the skip keyword."] = "Wenn aktiv, wird beim Betreten immer angesagt, auch wenn der Build-Name das Skip-Keyword enth\195\164lt."
L["Skip keyword:"] = "Skip-Keyword:"
L["Skip keyword: if your active loadout name contains this word (case-insensitive), the announcement is skipped for that mode."] = "Skip-Keyword: Wenn dein aktiver Loadout-Name dieses Wort enth\195\164lt (unabh\195\164ngig von Gro\195\159-/Kleinschreibung), wird die Ansage f\195\188r diesen Modus geschluckt."
L["Reset"] = "Zur\195\188cksetzen"
L["Reset to default"] = "Auf Standard zur\195\188cksetzen"
L["General"] = "Allgemein"
L["Sound"] = "Sound"
L["Display & Frame"] = "Anzeige & Frame"

-- PvP modes
L["Arena 2v2"] = "Arena 2v2"
L["Arena 3v3"] = "Arena 3v3"
L["Battlegrounds"] = "Schlachtfelder"
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
L["Move display frame: switch to Edit Mode (Esc -> Edit Mode). The frame will appear automatically and can be placed with the mouse."] = "Anzeige-Frame verschieben: In den Bearbeitungsmodus wechseln (Esc -> Bearbeitungsmodus). Der Frame erscheint dann automatisch und kann mit der Maus platziert werden."
L["Open Edit Mode"] = "Bearbeitungsmodus \195\182ffnen"

-- TTS
L["Text-to-Speech (TTS)"] = "Text-to-Speech (TTS)"
L["Use TTS"] = "TTS verwenden"
L["Speaks the build name via WoW's built-in TTS."] = "Spricht den Build-Namen \195\188ber die eingebaute WoW-TTS aus."
L["TTS text template (placeholder: {loadoutname}):"] = "TTS-Text-Template (Platzhalter: {loadoutname}):"
L["TTS voice:"] = "TTS-Stimme:"
L["Volume"] = "Lautst\195\164rke"
L["Speed"] = "Geschwindigkeit"
L["Test announcement"] = "Test-Ansage"
L["TTS API not available (C_VoiceChat.SpeakText missing)."] = "TTS-API nicht verf\195\188gbar (C_VoiceChat.SpeakText fehlt)."
L["TTS test sent: {details}"] = "TTS-Test gesendet: {details}"
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
