local ADDON_NAME, ns = ...

ns.ADDON_NAME = ADDON_NAME
ns.L = ns.L or setmetatable({}, { __index = function(t, k) return k end })
local L = ns.L

ns.MODE_ORDER = { "dungeon", "raid", "delve", "arena2v2", "arena3v3", "battleground", "openworld_warmode", "openworld_nowarmode" }

ns.defaults = {
    enabled = true,
    modes = {
        dungeon = {
            announceOnEnter = true,
            announceOnReadyCheck = true,
            announceOnInvite = true,
            alwaysOnEnter = false,
            alwaysOnReadyCheck = false,
            alwaysOnInvite = false,
            skipKeyword = "M+",
        },
        raid = {
            announceOnEnter = true,
            announceOnReadyCheck = true,
            announceOnInvite = true,
            alwaysOnEnter = false,
            alwaysOnReadyCheck = false,
            alwaysOnInvite = false,
            skipKeyword = "Raid",
        },
        delve = {
            announceOnEnter = true,
            announceOnReadyCheck = true,
            alwaysOnEnter = false,
            alwaysOnReadyCheck = false,
            skipKeyword = "Delves",
        },
        arena2v2 = {
            announceOnEnter = true,
            announceOnReadyCheck = false,
            announceOnMatchStartCountdown = true,
            announceOnInvite = true,
            alwaysOnEnter = false,
            alwaysOnReadyCheck = false,
            alwaysOnMatchStartCountdown = false,
            alwaysOnInvite = false,
            skipKeyword = "2v2",
        },
        arena3v3 = {
            announceOnEnter = true,
            announceOnReadyCheck = false,
            announceOnMatchStartCountdown = true,
            announceOnInvite = true,
            alwaysOnEnter = false,
            alwaysOnReadyCheck = false,
            alwaysOnMatchStartCountdown = false,
            alwaysOnInvite = false,
            skipKeyword = "3v3",
        },
        battleground = {
            announceOnEnter = true,
            announceOnReadyCheck = false,
            announceOnMatchStartCountdown = true,
            announceOnInvite = true,
            alwaysOnEnter = false,
            alwaysOnReadyCheck = false,
            alwaysOnMatchStartCountdown = false,
            alwaysOnInvite = false,
            skipKeyword = "BG",
        },
        openworld_warmode = {
            announceOnEnter = false,
            alwaysOnEnter = false,
            skipKeyword = "Warmode",
        },
        openworld_nowarmode = {
            announceOnEnter = false,
            alwaysOnEnter = false,
            skipKeyword = "Open World",
        },
    },
    showText = true,
    useChatMessage = true,
    useTTS = true,
    warnOnRoleMismatch = true,
    announceOnSpecChange = true,
    ttsTemplate = L["Current loadout: {loadoutname}"],
    ttsVoiceID = 0,
    ttsVolume = 100,
    ttsRate = 0,
    bannerDuration = 5,
    bannerFontSize = 32,
    bannerColor = { r = 1, g = 0.82, b = 0 },
    chatColor = { r = 1, g = 0.82, b = 0 },
    framePos = { point = "TOP", x = 0, y = -180 },
    frameLocked = true,
    soundEnabled = false,
    soundID = 8959,
    soundPath = nil,
    debug = false,
}

ns.PRESET_SOUNDS = {
    { key = "ready_check",   label = "Ready Check",        id = 8959 },
    { key = "raid_warning",  label = "Raid Warning",       id = 8960 },
    { key = "alarm_clock",   label = "Alarm Clock",        id = 567482 },
    { key = "boss_whisper",  label = "Boss Whisper Alert", id = 37666 },
    { key = "auction_open",  label = "Auction Hammer",     id = 857 },
    { key = "level_up",      label = "Level Up",           id = 888 },
    { key = "quest_accept",  label = "Quest Accepted",     id = 878 },
    { key = "map_ping",      label = "Map Ping",           id = 3337 },
}

function ns.GetSharedMediaSounds()
    local list = {}
    if not LibStub then return list end
    local ok, lsm = pcall(LibStub, "LibSharedMedia-3.0", true)
    if not ok or not lsm or not lsm.List then return list end
    local names = lsm:List("sound") or {}
    for _, name in ipairs(names) do
        local path = lsm.Fetch and lsm:Fetch("sound", name, true) or nil
        if path then
            table.insert(list, { key = "lsm:" .. name, label = "[LSM] " .. name, path = path })
        end
    end
    return list
end

local function MergeDefaults(dst, src)
    for k, v in pairs(src) do
        if dst[k] == nil then
            if type(v) == "table" then
                dst[k] = {}
                MergeDefaults(dst[k], v)
            else
                dst[k] = v
            end
        elseif type(v) == "table" and type(dst[k]) == "table" then
            MergeDefaults(dst[k], v)
        end
    end
end

local INSTANCE_TYPE_TO_MODE = {
    party    = "dungeon",
    raid     = "raid",
    scenario = "delve",
    pvp      = "battleground",
}

local function IsWarMode()
    if C_PvP and C_PvP.IsWarModeDesired then
        local ok, v = pcall(C_PvP.IsWarModeDesired)
        if ok then return v and true or false end
    end
    return false
end

local function GetModeKey(instanceType, maxPlayers)
    if instanceType == "arena" then
        return maxPlayers == 4 and "arena2v2" or "arena3v3"
    end
    local mapped = INSTANCE_TYPE_TO_MODE[instanceType]
    if mapped then return mapped end
    if instanceType == "none" then
        return IsWarMode() and "openworld_warmode" or "openworld_nowarmode"
    end
    return nil
end
ns.GetModeKey = GetModeKey

local function Print(msg, r, g, b)
    local prefix = "|cff3FC7EBLoadOutCaller|r: "
    if not DEFAULT_CHAT_FRAME then return end
    if r and g and b then
        local hex = string.format("|cff%02x%02x%02x",
            math.floor(r * 255), math.floor(g * 255), math.floor(b * 255))
        DEFAULT_CHAT_FRAME:AddMessage(prefix .. hex .. tostring(msg) .. "|r")
    else
        DEFAULT_CHAT_FRAME:AddMessage(prefix .. tostring(msg))
    end
end
ns.Print = Print

local function GetConfigName(configID)
    if not configID or not C_Traits or not C_Traits.GetConfigInfo then return end
    local info = C_Traits.GetConfigInfo(configID)
    if info and info.name and info.name ~= "" then
        return info.name
    end
end

local function GetActiveBuildName()
    if not C_ClassTalents then
        return L["No active build"], false
    end

    local specID
    if PlayerUtil and PlayerUtil.GetCurrentSpecID then
        local ok, id = pcall(PlayerUtil.GetCurrentSpecID)
        if ok then specID = id end
    end
    if not specID then
        local idx = GetSpecialization and GetSpecialization() or nil
        if idx and GetSpecializationInfo then
            specID = GetSpecializationInfo(idx)
        end
    end

    if specID and C_ClassTalents.GetLastSelectedSavedConfigID then
        local savedID = C_ClassTalents.GetLastSelectedSavedConfigID(specID)
        if savedID and savedID ~= 0 then
            local name = GetConfigName(savedID)
            if name then return name, true end
        end
    end
    if C_ClassTalents.GetActiveConfigID then
        local name = GetConfigName(C_ClassTalents.GetActiveConfigID())
        if name then return name .. L[" (default)"], false end
    end
    return L["No active build"], false
end
ns.GetActiveBuildName = GetActiveBuildName

local displayFrame

local function SaveFramePos(frame)
    local point, _, _, x, y = frame:GetPoint()
    if point then
        LoadOutCallerDB.framePos = { point = point, x = x or 0, y = y or 0 }
    end
end

local function CreateDisplayFrame()
    local f = CreateFrame("Frame", "LoadOutCallerDisplayFrame", UIParent)
    f:SetSize(560, 64)
    f:SetFrameStrata("HIGH")
    f:SetMovable(true)
    f:SetClampedToScreen(true)
    f:EnableMouse(false)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(self)
        if self:IsMovable() and self:IsMouseEnabled() then
            self:StartMoving()
        end
    end)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SaveFramePos(self)
    end)

    local bg = f:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0, 0, 0, 0.4)
    bg:Hide()
    f.bg = bg

    local border = CreateFrame("Frame", nil, f, "TooltipBackdropTemplate")
    border:SetAllPoints()
    border:Hide()
    f.border = border

    local text = f:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    text:SetPoint("CENTER")
    text:SetJustifyH("CENTER")
    text:SetJustifyV("MIDDLE")
    text:SetTextColor(1, 0.82, 0)
    text:SetText("")
    f.text = text

    local pos = LoadOutCallerDB.framePos or ns.defaults.framePos
    f:ClearAllPoints()
    f:SetPoint(pos.point or "TOP", UIParent, pos.point or "TOP", pos.x or 0, pos.y or -180)

    f:Hide()
    return f
end

local function GetDisplayFrame()
    if not displayFrame then
        displayFrame = CreateDisplayFrame()
    end
    return displayFrame
end
ns.GetDisplayFrame = GetDisplayFrame

local function ApplyFontSize(f)
    local size = LoadOutCallerDB.bannerFontSize or ns.defaults.bannerFontSize
    local path, _, flags = f.text:GetFont()
    if path then
        f.text:SetFont(path, size, flags or "")
    end
end

local hideTimer
local function ShowAnnouncement(text)
    local f = GetDisplayFrame()
    ApplyFontSize(f)
    local color = LoadOutCallerDB.bannerColor or ns.defaults.bannerColor
    f.text:SetTextColor(color.r, color.g, color.b)
    f.text:SetText(text)
    f:SetAlpha(1)
    f:Show()
    if hideTimer then
        hideTimer:Cancel()
        hideTimer = nil
    end
    if not LoadOutCallerDB.frameLocked then
        return
    end
    local total = LoadOutCallerDB.bannerDuration or ns.defaults.bannerDuration
    if total < 1 then total = 1 end
    local fadeDur = math.min(1.2, total * 0.25)
    local visibleDur = math.max(0, total - fadeDur)
    hideTimer = C_Timer.NewTimer(visibleDur, function()
        UIFrameFadeOut(f, fadeDur, 1, 0)
        C_Timer.After(fadeDur + 0.1, function()
            if f:GetAlpha() <= 0.05 then f:Hide() end
        end)
    end)
end

local function SetFrameLocked(locked)
    LoadOutCallerDB.frameLocked = locked and true or false
    local f = GetDisplayFrame()
    if LoadOutCallerDB.frameLocked then
        f:EnableMouse(false)
        f.bg:Hide()
        f.border:Hide()
        f:Hide()
    else
        f:EnableMouse(true)
        f.bg:Show()
        f.border:Show()
        f.text:SetText(L["|cffffff00LoadOutCaller|r - drag to move"])
        f:SetAlpha(1)
        f:Show()
    end
end
ns.SetFrameLocked = SetFrameLocked

local editModeHooked = false
local function HookEditMode()
    if editModeHooked then return end
    if not EditModeManagerFrame then return end
    editModeHooked = true
    if EditModeManagerFrame.EnterEditMode then
        hooksecurefunc(EditModeManagerFrame, "EnterEditMode", function()
            SetFrameLocked(false)
        end)
    end
    if EditModeManagerFrame.ExitEditMode then
        hooksecurefunc(EditModeManagerFrame, "ExitEditMode", function()
            SetFrameLocked(true)
        end)
    end
end
ns.HookEditMode = HookEditMode

local function PlayAlertSound()
    if not LoadOutCallerDB.soundEnabled then return end
    local path = LoadOutCallerDB.soundPath
    if path and path ~= "" then
        pcall(PlaySoundFile, path, "Master")
        return
    end
    local id = LoadOutCallerDB.soundID
    if id and id > 0 then
        pcall(PlaySound, id, "Master")
    end
end
ns.PlayAlertSound = PlayAlertSound

local function SpeakTTS(text, verbose)
    if not (C_VoiceChat and C_VoiceChat.SpeakText) then
        if verbose then
            Print(L["TTS API not available (C_VoiceChat.SpeakText missing)."])
        end
        return false
    end
    local voiceID = LoadOutCallerDB.ttsVoiceID or 0
    local rate = LoadOutCallerDB.ttsRate or 0
    local volume = LoadOutCallerDB.ttsVolume or 100

    -- Patch 12.0.0: signature is (voiceID, text, rate, volume, overlap)
    local ok, err = pcall(C_VoiceChat.SpeakText, voiceID, text, rate, volume, false)
    if not ok and verbose then
        Print(L["TTS error: {details}"]:gsub("{details}", tostring(err)))
    end
    return ok
end
ns.SpeakTTS = SpeakTTS

local function FormatTemplate(template, buildName)
    template = template or "{loadoutname}"
    local safe = (buildName or ""):gsub("%%", "%%%%")
    local out = template:gsub("{loadoutname}", safe)
    return out
end

local function LocalizedRoleName(role)
    if role == "TANK" then return _G.TANK or "Tank" end
    if role == "HEALER" then return _G.HEALER or "Healer" end
    if role == "DAMAGER" then return _G.DAMAGER or (_G.DPS or "Damage") end
    return role or ""
end

local function GetSpecRole()
    if not GetSpecialization then return nil end
    local idx = GetSpecialization()
    if not idx then return nil end
    if not GetSpecializationInfo then return nil end
    local _, _, _, _, role = GetSpecializationInfo(idx)
    return role
end

local function GetAssignedRole()
    if not UnitGroupRolesAssigned then return nil end
    local role = UnitGroupRolesAssigned("player")
    if not role or role == "NONE" then return nil end
    return role
end

local function GetRoleMismatchMessage()
    if not LoadOutCallerDB.warnOnRoleMismatch then return nil end
    local assigned = GetAssignedRole()
    if not assigned then return nil end
    local spec = GetSpecRole()
    if not spec then return nil end
    if assigned == spec then return nil end
    local template = L["Role mismatch: assigned {assigned}, spec is {spec}"]
    local msg = template
        :gsub("{assigned}", (LocalizedRoleName(assigned):gsub("%%", "%%%%")))
        :gsub("{spec}", (LocalizedRoleName(spec):gsub("%%", "%%%%")))
    return msg
end
ns.GetRoleMismatchMessage = GetRoleMismatchMessage

local function EmitMessage(msg)
    if not msg or msg == "" then return end
    if LoadOutCallerDB.showText then ShowAnnouncement(msg) end
    if LoadOutCallerDB.useChatMessage then
        local c = LoadOutCallerDB.chatColor or ns.defaults.chatColor
        Print(msg, c.r, c.g, c.b)
    end
    if LoadOutCallerDB.useTTS then SpeakTTS(msg) end
    PlayAlertSound()
end
ns.EmitMessage = EmitMessage

local FORCE_FLAGS = {
    enter      = "alwaysOnEnter",
    readycheck = "alwaysOnReadyCheck",
    matchstart = "alwaysOnMatchStartCountdown",
    invite     = "alwaysOnInvite",
}

local INSTANCE_REASONS = {
    enter      = true,
    readycheck = true,
    matchstart = true,
    invite     = true,
}

local function ShouldSkip(reason, mode, buildName)
    if reason == "test" then return false end
    -- Instance-triggered announcements only apply inside a tracked mode.
    -- If we scheduled an announce but the player has already left the BG/arena/dungeon
    -- by the time it fires, mode is nil and we must skip.
    if not mode then
        return INSTANCE_REASONS[reason] == true
    end

    local keyword = mode.skipKeyword
    if not keyword or keyword == "" then return false end

    local forceFlag = FORCE_FLAGS[reason]
    if forceFlag and mode[forceFlag] then return false end

    return buildName:lower():find(keyword:lower(), 1, true) ~= nil
end

local ANNOUNCE_COOLDOWN = 5
local BUILD_NAME_MAX_RETRIES = 3
local BUILD_NAME_RETRY_DELAY = 2
local lastAnnounceTime = 0

local function Announce(reason, retryCount, overrideModeKey)
    if not LoadOutCallerDB.enabled and reason ~= "test" then return end

    if reason ~= "test" then
        local now = GetTime()
        if now - lastAnnounceTime < ANNOUNCE_COOLDOWN then return end
    end

    local buildName, isSaved = GetActiveBuildName()

    -- After /reload the talent API can briefly return the default-spec build
    -- before GetLastSelectedSavedConfigID is populated. Retry a few times.
    if not isSaved and reason ~= "test" then
        retryCount = retryCount or 0
        if retryCount < BUILD_NAME_MAX_RETRIES then
            C_Timer.After(BUILD_NAME_RETRY_DELAY, function() Announce(reason, retryCount + 1, overrideModeKey) end)
            return
        end
    end

    local modeKey = overrideModeKey
    if not modeKey then
        local _, instanceType, _, _, maxPlayers = GetInstanceInfo()
        modeKey = GetModeKey(instanceType, maxPlayers)
    end
    local mode = modeKey and LoadOutCallerDB.modes and LoadOutCallerDB.modes[modeKey] or nil

    local skipped = ShouldSkip(reason, mode, buildName)
    if LoadOutCallerDB.debug then
        Print(string.format("[debug] reason=%s instType=%s maxP=%s mode=%s keyword=%s build=%q isSaved=%s -> skipped=%s",
            tostring(reason), tostring(instanceType), tostring(maxPlayers), tostring(modeKey),
            tostring(mode and mode.skipKeyword), tostring(buildName), tostring(isSaved), tostring(skipped)))
    end
    if skipped then
        return
    end

    local msg = FormatTemplate(LoadOutCallerDB.ttsTemplate, buildName)
    local roleWarn = GetRoleMismatchMessage()
    if roleWarn then
        msg = msg .. ". " .. roleWarn
    end

    if reason ~= "test" then
        lastAnnounceTime = GetTime()
    end
    EmitMessage(msg)
end
ns.Announce = Announce

local function TestTTS()
    local buildName = GetActiveBuildName()
    local msg = FormatTemplate(LoadOutCallerDB.ttsTemplate, buildName)
    return SpeakTTS(msg, true)
end
ns.TestTTS = TestTTS

local lastRoleMismatchState
local function HandleRoleChanged(changedName)
    if not LoadOutCallerDB.enabled then return end
    if not LoadOutCallerDB.warnOnRoleMismatch then return end
    if changedName and changedName ~= UnitName("player") then return end
    local mismatchMsg = GetRoleMismatchMessage()
    local state = mismatchMsg and "mismatch" or "match"
    if state == "match" then
        lastRoleMismatchState = state
        return
    end
    if state == lastRoleMismatchState then return end
    lastRoleMismatchState = state
    EmitMessage(mismatchMsg)
end

local lastKnownSpec
local function HandleSpecializationChanged(unit)
    if unit and unit ~= "player" then return end
    if not LoadOutCallerDB.enabled then return end
    if not LoadOutCallerDB.announceOnSpecChange then return end

    -- WoW fires PLAYER_SPECIALIZATION_CHANGED on instance enter/exit (e.g. arenas)
    -- even when the spec didn't actually change. Only announce on a real change.
    local currentSpec = GetSpecialization and GetSpecialization() or nil
    if currentSpec == lastKnownSpec then return end
    lastKnownSpec = currentSpec

    C_Timer.After(0.3, function() Announce("specchange") end)
end

local lastKnownLoadoutName
local function HandleTraitConfigUpdated(configID)
    if LoadOutCallerDB.debug then
        Print(string.format("[debug] TRAIT_CONFIG_UPDATED fired configID=%s enabled=%s announceOnSpecChange=%s",
            tostring(configID), tostring(LoadOutCallerDB.enabled), tostring(LoadOutCallerDB.announceOnSpecChange)))
    end
    if not LoadOutCallerDB.enabled then return end
    if not LoadOutCallerDB.announceOnSpecChange then return end

    -- TRAIT_CONFIG_UPDATED fires on commit, on load-saved-config, and spuriously
    -- on instance transitions. On fire, GetLastSelectedSavedConfigID often still
    -- reports the previous loadout - delay the name lookup so the game has a
    -- chance to update the active saved config pointer. Dedup by name.
    C_Timer.After(0.3, function()
        local currentName = GetActiveBuildName()
        if LoadOutCallerDB.debug then
            Print(string.format("[debug] TRAIT_CONFIG_UPDATED resolved current=%q last=%q",
                tostring(currentName), tostring(lastKnownLoadoutName)))
        end
        if currentName == lastKnownLoadoutName then return end
        lastKnownLoadoutName = currentName
        Announce("loadoutchange")
    end)
end

local lastLfgProposalKey
local function HandleLFGProposalShow()
    if not LoadOutCallerDB.enabled then return end
    if not GetLFGProposal then return end
    local proposalExists, id, _, subtypeID = GetLFGProposal()
    if not proposalExists then return end

    -- subtypeID: 1=Dungeon, 2=Heroic Dungeon, 3=Raid (LFR), 5=Flex Raid.
    -- M+ is premade and never fires LFG_PROPOSAL_SHOW.
    local modeKey
    if subtypeID == 1 or subtypeID == 2 then
        modeKey = "dungeon"
    elseif subtypeID == 3 or subtypeID == 5 then
        modeKey = "raid"
    end
    if not modeKey then return end

    local key = modeKey .. ":" .. tostring(id)
    if lastLfgProposalKey == key then return end
    lastLfgProposalKey = key

    local mode = LoadOutCallerDB.modes and LoadOutCallerDB.modes[modeKey]
    if not mode or not mode.announceOnInvite then return end
    Announce("invite", nil, modeKey)
end

local lastInvitedQueueKey
local function HandleBattlefieldStatus(index)
    if not LoadOutCallerDB.enabled then return end
    if not GetBattlefieldStatus then return end

    local function process(i)
        -- Retail signature (post-Patch 5.2.0):
        -- status, mapName, teamSize, registeredMatch, suspendedQueue, queueType, gameType, role, asGroup, shortDescription, longDescription, isSoloQueue
        local status, mapName, teamSize, _, _, queueType = GetBattlefieldStatus(i)
        if status ~= "confirm" then return end

        local qt = queueType and tostring(queueType):upper() or ""
        local modeKey
        if qt:find("ARENA") then
            -- queueType can be "ARENA" (rated) or "ARENASKIRMISH" (unrated, always 3v3).
            if teamSize == 2 then
                modeKey = "arena2v2"
            else
                modeKey = "arena3v3"
            end
        else
            modeKey = "battleground"
        end

        if LoadOutCallerDB.debug then
            Print(string.format("[debug] BF idx=%s status=%s map=%s teamSize=%s queueType=%s -> mode=%s",
                tostring(i), tostring(status), tostring(mapName), tostring(teamSize), tostring(queueType), tostring(modeKey)))
        end

        local key = modeKey .. ":" .. tostring(mapName) .. ":" .. tostring(queueType)
        if lastInvitedQueueKey == key then return end
        lastInvitedQueueKey = key

        local mode = LoadOutCallerDB.modes and LoadOutCallerDB.modes[modeKey]
        if not mode or not mode.announceOnInvite then return end
        Announce("invite", nil, modeKey)
    end

    if index then
        process(index)
    elseif GetMaxBattlefieldID then
        for i = 1, GetMaxBattlefieldID() do
            process(i)
        end
    end
end

local PVP_BEGIN_TIMER = (Enum and Enum.StartTimerType and Enum.StartTimerType.PvPBeginTimer) or 1

local matchStartRecheckTimer
local function HandleStartTimer(timerType, timeSeconds, totalTime)
    if LoadOutCallerDB.debug then
        Print(string.format("[debug] START_TIMER timerType=%s timeSeconds=%s totalTime=%s PVP_BEGIN_TIMER=%s",
            tostring(timerType), tostring(timeSeconds), tostring(totalTime), tostring(PVP_BEGIN_TIMER)))
    end
    if timerType ~= PVP_BEGIN_TIMER then return end
    if not LoadOutCallerDB.enabled then return end
    local _, instanceType, _, _, maxPlayers = GetInstanceInfo()
    local modeKey = GetModeKey(instanceType, maxPlayers)
    if not modeKey then return end
    local mode = LoadOutCallerDB.modes and LoadOutCallerDB.modes[modeKey]
    if not mode or not mode.announceOnMatchStartCountdown then return end

    Announce("matchstart")

    -- Last-chance re-check ~8s before the gates open. Catches the case where
    -- the player swaps loadout mid-countdown: the initial announce was skipped
    -- (build matched), they swap to a wrong build, and the normal dedup would
    -- keep us silent until the match starts. Fresh timer per START_TIMER
    -- fire - if START_TIMER re-fires with a refreshed countdown, the latest
    -- timeSeconds wins.
    if matchStartRecheckTimer then
        matchStartRecheckTimer:Cancel()
        matchStartRecheckTimer = nil
    end
    local secs = tonumber(timeSeconds) or 0
    local delay = secs - 8
    if delay > 0 then
        matchStartRecheckTimer = C_Timer.NewTimer(delay, function()
            matchStartRecheckTimer = nil
            if LoadOutCallerDB.debug then
                Print("[debug] matchstart last-chance re-check")
            end
            Announce("matchstart")
        end)
    end
end

local lastAnnouncedInstanceID
local function HandleEnteringWorld(isInitialLogin, isReloadingUi)
    local _, instanceType, _, _, maxPlayers, _, _, instanceID = GetInstanceInfo()
    local modeKey = GetModeKey(instanceType, maxPlayers)
    if not modeKey then
        lastAnnouncedInstanceID = nil
        return
    end

    -- Always update the last-seen instance ID, even when the mode's
    -- announceOnEnter is off. Otherwise the ID stays stuck on the previous
    -- instance and re-entering it triggers the dedup wrongly.
    local isSameInstance = (lastAnnouncedInstanceID == instanceID)
    lastAnnouncedInstanceID = instanceID

    local mode = LoadOutCallerDB.modes and LoadOutCallerDB.modes[modeKey]
    if not mode or not mode.announceOnEnter then return end
    if isSameInstance then return end

    C_Timer.After(0.5, function() Announce("enter") end)
end

local function HandleReadyCheck()
    local _, instanceType, _, _, maxPlayers = GetInstanceInfo()
    local modeKey = GetModeKey(instanceType, maxPlayers)
    if not modeKey then return end
    local mode = LoadOutCallerDB.modes and LoadOutCallerDB.modes[modeKey]
    if not mode or not mode.announceOnReadyCheck then return end
    Announce("readycheck")
end

local function HandleSlash(msg)
    msg = (msg or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
    if msg == "test" then
        Announce("test")
    elseif msg == "lock" then
        SetFrameLocked(true)
        Print(L["Display frame locked."])
    elseif msg == "unlock" then
        SetFrameLocked(false)
        Print(L["Display frame unlocked - drag to move, /lc lock to lock."])
    elseif msg == "help" or msg == "?" then
        Print(L["Commands: /lc (options), /lc test, /lc lock, /lc unlock"])
    else
        if ns.OpenOptions then
            ns.OpenOptions()
        else
            Print(L["Options not yet initialized - please /reload."])
        end
    end
end

local function HandleAddonLoaded(addonName)
    if addonName ~= ADDON_NAME then return end
    LoadOutCallerDB = LoadOutCallerDB or {}
    MergeDefaults(LoadOutCallerDB, ns.defaults)
    if ns.InitOptions then ns.InitOptions() end
end

local function HandlePlayerLogin()
    SLASH_LOADOUTCALLER1 = "/lc"
    SLASH_LOADOUTCALLER2 = "/loadoutcaller"
    SlashCmdList["LOADOUTCALLER"] = HandleSlash
    HookEditMode()
    lastKnownSpec = GetSpecialization and GetSpecialization() or nil
    lastKnownLoadoutName = GetActiveBuildName()
end

local EVENT_HANDLERS = {
    ADDON_LOADED                  = HandleAddonLoaded,
    PLAYER_LOGIN                  = HandlePlayerLogin,
    PLAYER_ENTERING_WORLD         = HandleEnteringWorld,
    READY_CHECK                   = HandleReadyCheck,
    PLAYER_SPECIALIZATION_CHANGED = HandleSpecializationChanged,
    TRAIT_CONFIG_UPDATED          = HandleTraitConfigUpdated,
    ROLE_CHANGED_INFORM           = HandleRoleChanged,
    START_TIMER                   = HandleStartTimer,
    UPDATE_BATTLEFIELD_STATUS     = HandleBattlefieldStatus,
    LFG_PROPOSAL_SHOW             = HandleLFGProposalShow,
}

local bootstrap = CreateFrame("Frame")
for event in pairs(EVENT_HANDLERS) do
    bootstrap:RegisterEvent(event)
end
bootstrap:SetScript("OnEvent", function(_, event, arg1, arg2, arg3)
    local handler = EVENT_HANDLERS[event]
    if handler then handler(arg1, arg2, arg3) end
end)
