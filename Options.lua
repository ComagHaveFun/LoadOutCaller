local ADDON_NAME, ns = ...

local L = ns.L or setmetatable({}, { __index = function(t, k) return k end })

local rootCategory
local widgets = {}

local SKIP_KEYWORD_TOOLTIP = L["Skip keyword: if your active loadout name contains this word (case-insensitive), the announcement is skipped for that mode."]

local function MakeSectionHeader(parent, text, yOffset)
    local fs = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    fs:SetPoint("TOPLEFT", parent, "TOPLEFT", 16, yOffset)
    fs:SetText(text)
    fs:SetTextColor(1, 0.82, 0)
    return fs
end

local function ApplyTooltip(frame, label, tooltip)
    if not tooltip then return end
    frame:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        if label then
            GameTooltip:SetText(label, 1, 1, 1)
            GameTooltip:AddLine(tooltip, nil, nil, nil, true)
        else
            GameTooltip:SetText(tooltip, 1, 1, 1, 1, true)
        end
        GameTooltip:Show()
    end)
    frame:HookScript("OnLeave", function() GameTooltip:Hide() end)
end

local function MakeCheckbox(parent, label, tooltip, getter, setter, yOffset)
    local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    cb:SetSize(24, 24)
    cb:SetPoint("TOPLEFT", parent, "TOPLEFT", 24, yOffset)

    local labelFS = cb:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    labelFS:SetPoint("LEFT", cb, "RIGHT", 4, 1)
    labelFS:SetText(label)
    labelFS:SetJustifyH("LEFT")
    cb.labelFS = labelFS

    if tooltip then
        cb:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(label, 1, 1, 1)
            GameTooltip:AddLine(tooltip, nil, nil, nil, true)
            GameTooltip:Show()
        end)
        cb:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end

    cb:SetScript("OnShow", function(self) self:SetChecked(getter() and true or false) end)
    cb:SetScript("OnClick", function(self) setter(self:GetChecked() and true or false) end)
    return cb
end

local function MakeLabel(parent, text, x, y, tooltip)
    local fs = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    fs:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    fs:SetText(text)
    if tooltip then
        local hover = CreateFrame("Frame", nil, parent)
        hover:SetPoint("TOPLEFT", fs, "TOPLEFT", -2, 2)
        hover:SetPoint("BOTTOMRIGHT", fs, "BOTTOMRIGHT", 2, -2)
        hover:EnableMouse(true)
        ApplyTooltip(hover, text, tooltip)
    end
    return fs
end

local function MakeEditBox(parent, width, getter, setter, yOffset, xOffset, tooltipLabel, tooltipText)
    local eb = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    eb:SetAutoFocus(false)
    eb:SetSize(width, 22)
    eb:SetPoint("TOPLEFT", parent, "TOPLEFT", xOffset or 24, yOffset)
    eb:SetFontObject("ChatFontNormal")
    eb:SetScript("OnShow", function(self) self:SetText(getter() or "") end)
    local commit = function(self)
        setter(self:GetText() or "")
        self:ClearFocus()
    end
    eb:SetScript("OnEnterPressed", commit)
    eb:SetScript("OnEscapePressed", function(self) self:SetText(getter() or "") self:ClearFocus() end)
    eb:SetScript("OnEditFocusLost", function(self) setter(self:GetText() or "") end)
    eb.Refresh = function(self) self:SetText(getter() or "") end
    if tooltipText then
        ApplyTooltip(eb, tooltipLabel, tooltipText)
    end
    return eb
end

local function MakeSlider(parent, frameName, label, minV, maxV, step, getter, setter, yOffset)
    local s = CreateFrame("Slider", frameName, parent, "OptionsSliderTemplate")
    s:SetPoint("TOPLEFT", parent, "TOPLEFT", 24, yOffset)
    s:SetWidth(240)
    s:SetMinMaxValues(minV, maxV)
    s:SetValueStep(step)
    s:SetObeyStepOnDrag(true)
    local lowFS = _G[frameName .. "Low"]
    local highFS = _G[frameName .. "High"]
    local textFS = _G[frameName .. "Text"]
    if lowFS then lowFS:SetText(tostring(minV)) end
    if highFS then highFS:SetText(tostring(maxV)) end
    if textFS then textFS:SetText(label) end
    s:SetScript("OnShow", function(self)
        self:SetValue(getter() or minV)
        if textFS then textFS:SetText(label .. ": " .. tostring(math.floor((getter() or minV) + 0.5))) end
    end)
    s:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value / step + 0.5) * step
        setter(value)
        if textFS then textFS:SetText(label .. ": " .. tostring(value)) end
    end)
    return s
end

local function MakeButton(parent, label, width, onClick, point, relativeTo, relPoint, x, y)
    local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    b:SetSize(width or 140, 24)
    b:SetText(label)
    b:SetPoint(point or "TOPLEFT", relativeTo or parent, relPoint or "TOPLEFT", x or 24, y or 0)
    b:SetScript("OnClick", onClick)
    return b
end

local function ShowColorPicker(r, g, b, callback)
    if not ColorPickerFrame then return end
    local function apply()
        local nr, ng, nb = ColorPickerFrame:GetColorRGB()
        callback(nr, ng, nb)
    end
    if ColorPickerFrame.SetupColorPickerAndShow then
        ColorPickerFrame:SetupColorPickerAndShow({
            r = r, g = g, b = b,
            swatchFunc = apply,
            cancelFunc = function(prev)
                if prev then callback(prev.r, prev.g, prev.b) end
            end,
        })
    else
        ColorPickerFrame.func = apply
        ColorPickerFrame.cancelFunc = function(prev)
            if prev then callback(prev.r, prev.g, prev.b) end
        end
        ColorPickerFrame.previousValues = { r = r, g = g, b = b }
        ColorPickerFrame:SetColorRGB(r, g, b)
        ShowUIPanel(ColorPickerFrame)
    end
end

local function MakeColorSwatch(parent, label, tooltip, getColor, setColor, yOffset)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(20, 20)
    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 24, yOffset)

    local border = btn:CreateTexture(nil, "BACKGROUND")
    border:SetPoint("TOPLEFT", -1, 1)
    border:SetPoint("BOTTOMRIGHT", 1, -1)
    border:SetColorTexture(0.4, 0.4, 0.4, 1)

    local swatch = btn:CreateTexture(nil, "OVERLAY")
    swatch:SetAllPoints()

    local function refresh()
        local r, g, b = getColor()
        swatch:SetColorTexture(r, g, b)
    end

    local labelFS = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    labelFS:SetPoint("LEFT", btn, "RIGHT", 8, 0)
    labelFS:SetText(label)

    btn:SetScript("OnClick", function()
        local r, g, b = getColor()
        ShowColorPicker(r, g, b, function(nr, ng, nb)
            setColor(nr, ng, nb)
            refresh()
        end)
    end)
    btn:SetScript("OnShow", refresh)
    ApplyTooltip(btn, label, tooltip)
    btn.Refresh = refresh
    return btn
end

local function GetVoiceList()
    local list = {}
    if C_VoiceChat and C_VoiceChat.GetTtsVoices then
        local ok, voices = pcall(C_VoiceChat.GetTtsVoices)
        if ok and type(voices) == "table" then
            for _, v in ipairs(voices) do
                table.insert(list, { voiceID = v.voiceID, name = v.name or ("Voice " .. tostring(v.voiceID)) })
            end
        end
    end
    if #list == 0 then
        table.insert(list, { voiceID = 0, name = "Default (0)" })
    end
    return list
end

local function MakeVoiceDropdown(parent, frameName, getter, setter, yOffset)
    local dd = CreateFrame("Frame", frameName, parent, "UIDropDownMenuTemplate")
    dd:SetPoint("TOPLEFT", parent, "TOPLEFT", 12, yOffset)
    UIDropDownMenu_SetWidth(dd, 260)

    local function Refresh()
        local currentID = getter()
        local voices = GetVoiceList()
        local currentLabel
        for _, v in ipairs(voices) do
            if v.voiceID == currentID then currentLabel = v.name break end
        end
        UIDropDownMenu_SetText(dd, currentLabel or ("Voice " .. tostring(currentID)))
    end

    UIDropDownMenu_Initialize(dd, function(self, level)
        local voices = GetVoiceList()
        local currentID = getter()
        for _, v in ipairs(voices) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = v.name
            info.value = v.voiceID
            info.checked = (v.voiceID == currentID)
            info.func = function(item)
                setter(item.value)
                UIDropDownMenu_SetSelectedValue(dd, item.value)
                Refresh()
                CloseDropDownMenus()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    dd:SetScript("OnShow", Refresh)
    return dd
end

local function NewSubPanel(name)
    local f = CreateFrame("Frame")
    f.name = name
    f:Hide()
    return f
end

local function AddPanelTitle(panel, text, subtitle)
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText(text)
    if subtitle then
        local sub = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        sub:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
        sub:SetText(subtitle)
        sub:SetTextColor(0.8, 0.8, 0.8)
    end
end

local function BuildModePanel(modeKey, title, enterLabel, enterTip, opts)
    opts = opts or {}
    local panel = NewSubPanel(title)

    AddPanelTitle(panel, title, enterTip)

    local y = -64

    MakeCheckbox(panel,
        enterLabel,
        enterTip,
        function() return LoadOutCallerDB.modes[modeKey].announceOnEnter end,
        function(v) LoadOutCallerDB.modes[modeKey].announceOnEnter = v end,
        y)
    y = y - 24

    if not opts.omitReadyCheck then
        MakeCheckbox(panel,
            L["Announce on ready check"],
            L["Triggers the announcement when a ready check is initiated."],
            function() return LoadOutCallerDB.modes[modeKey].announceOnReadyCheck end,
            function(v) LoadOutCallerDB.modes[modeKey].announceOnReadyCheck = v end,
            y)
        y = y - 24
    end

    if opts.showMatchStart then
        MakeCheckbox(panel,
            L["Announce on match start countdown"],
            L["Triggers the announcement when the PvP match start countdown begins."],
            function() return LoadOutCallerDB.modes[modeKey].announceOnMatchStartCountdown end,
            function(v) LoadOutCallerDB.modes[modeKey].announceOnMatchStartCountdown = v end,
            y)
        y = y - 24
    end

    if opts.showInvite then
        MakeCheckbox(panel,
            opts.inviteLabel or L["Announce on queue invite (PvP queue popped)"],
            opts.inviteTip or L["Triggers the announcement when the PvP queue pops and the 'Enter Battle' dialog appears - the earliest moment to switch builds."],
            function() return LoadOutCallerDB.modes[modeKey].announceOnInvite end,
            function(v) LoadOutCallerDB.modes[modeKey].announceOnInvite = v end,
            y)
        y = y - 24
    end

    y = y - 8

    MakeCheckbox(panel,
        L["Always on enter (ignore skip keyword)"],
        L["When active, always announce on enter, even if the build name contains the skip keyword."],
        function() return LoadOutCallerDB.modes[modeKey].alwaysOnEnter end,
        function(v) LoadOutCallerDB.modes[modeKey].alwaysOnEnter = v end,
        y)
    y = y - 24

    if not opts.omitReadyCheck then
        MakeCheckbox(panel,
            L["Always on ready check (ignore skip keyword)"],
            L["When active, always announce on ready check, even if the build name contains the skip keyword."],
            function() return LoadOutCallerDB.modes[modeKey].alwaysOnReadyCheck end,
            function(v) LoadOutCallerDB.modes[modeKey].alwaysOnReadyCheck = v end,
            y)
        y = y - 24
    end

    if opts.showMatchStart then
        MakeCheckbox(panel,
            L["Always on match start countdown (ignore skip keyword)"],
            L["When active, always announce on the match start countdown, even if the build name contains the skip keyword."],
            function() return LoadOutCallerDB.modes[modeKey].alwaysOnMatchStartCountdown end,
            function(v) LoadOutCallerDB.modes[modeKey].alwaysOnMatchStartCountdown = v end,
            y)
        y = y - 24
    end

    if opts.showInvite then
        MakeCheckbox(panel,
            L["Always on queue invite (ignore skip keyword)"],
            L["When active, always announce on queue invite, even if the build name contains the skip keyword."],
            function() return LoadOutCallerDB.modes[modeKey].alwaysOnInvite end,
            function(v) LoadOutCallerDB.modes[modeKey].alwaysOnInvite = v end,
            y)
        y = y - 24
    end

    y = y - 16

    MakeLabel(panel, L["Skip keyword:"], 24, y, SKIP_KEYWORD_TOOLTIP)
    y = y - 22

    local eb = MakeEditBox(panel, 180,
        function() return LoadOutCallerDB.modes[modeKey].skipKeyword end,
        function(v) LoadOutCallerDB.modes[modeKey].skipKeyword = v end,
        y, 32, L["Skip keyword:"], SKIP_KEYWORD_TOOLTIP)

    MakeButton(panel, L["Reset to default"], 140,
        function()
            LoadOutCallerDB.modes[modeKey].skipKeyword = ns.defaults.modes[modeKey].skipKeyword
            if eb.Refresh then eb:Refresh() end
        end,
        "TOPLEFT", panel, "TOPLEFT", 224, y)

    local hint = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    hint:SetPoint("TOPLEFT", 24, y - 32)
    hint:SetWidth(500)
    hint:SetJustifyH("LEFT")
    hint:SetText(SKIP_KEYWORD_TOOLTIP)
    hint:SetTextColor(0.7, 0.7, 0.7)

    return panel
end

local function BuildRootPanel()
    local panel = CreateFrame("Frame", "LoadOutCallerOptionsPanel")
    panel.name = "LoadOutCaller"

    AddPanelTitle(panel, "LoadOutCaller", L["Announces your active talent build on instance enter and ready check."])

    widgets.enabled = MakeCheckbox(panel,
        L["Addon enabled"],
        L["Master switch. When disabled, nothing happens."],
        function() return LoadOutCallerDB.enabled end,
        function(v) LoadOutCallerDB.enabled = v end,
        -64)

    MakeSectionHeader(panel, L["Spec & Role"], -100)

    widgets.warnOnRoleMismatch = MakeCheckbox(panel,
        L["Warn on role mismatch"],
        L["Warns via the configured outputs (banner/chat/TTS) when your assigned group role doesn't match your current spec's natural role."],
        function() return LoadOutCallerDB.warnOnRoleMismatch end,
        function(v) LoadOutCallerDB.warnOnRoleMismatch = v end,
        -124)

    widgets.announceOnSpecChange = MakeCheckbox(panel,
        L["Announce loadout on spec change"],
        L["Fires the build announcement when you switch talent specialization (same output as ready check / instance enter)."],
        function() return LoadOutCallerDB.announceOnSpecChange end,
        function(v) LoadOutCallerDB.announceOnSpecChange = v end,
        -148)

    MakeSectionHeader(panel, L["PvP match start"], -184)

    widgets.matchStartRecheckSeconds = MakeSlider(panel, "LoadOutCallerMatchStartRecheckSlider",
        L["Last-chance re-check (seconds before match start)"], 5, 60, 1,
        function() return LoadOutCallerDB.matchStartRecheckSeconds end,
        function(v) LoadOutCallerDB.matchStartRecheckSeconds = v end,
        -210)

    local recheckHint = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    recheckHint:SetPoint("TOPLEFT", 24, -250)
    recheckHint:SetWidth(500)
    recheckHint:SetJustifyH("LEFT")
    recheckHint:SetText(L["Schedules an extra loadout check this many seconds before the PvP match gates open - last chance to warn you if you swapped to the wrong build mid-countdown."])
    recheckHint:SetTextColor(0.7, 0.7, 0.7)

    MakeSectionHeader(panel, L["Troubleshooting"], -288)

    widgets.debug = MakeCheckbox(panel,
        L["Debug mode"],
        L["Prints verbose diagnostic messages to chat (mode detection, battlefield status, skip decisions). Off by default - enable only when reporting a bug."],
        function() return LoadOutCallerDB.debug end,
        function(v) LoadOutCallerDB.debug = v end,
        -312)

    widgets.debugSnapshotButton = MakeButton(panel,
        L["Print debug snapshot"], 200,
        function() if ns.PrintDebugSnapshot then ns.PrintDebugSnapshot() end end,
        "TOPLEFT", panel, "TOPLEFT", 24, -344)

    local snapshotHint = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    snapshotHint:SetPoint("TOPLEFT", 24, -372)
    snapshotHint:SetWidth(500)
    snapshotHint:SetJustifyH("LEFT")
    snapshotHint:SetText(L["Prints a one-off diagnostic to chat regardless of the debug toggle: ITL detection, active loadout name, current mode, and all relevant settings. Useful for reporting a bug without waiting for a trigger."])
    snapshotHint:SetTextColor(0.7, 0.7, 0.7)

    return panel
end

local function BuildDisplayPanel()
    local panel = NewSubPanel(L["Display & Frame"])
    AddPanelTitle(panel, L["Display & Frame"])

    MakeLabel(panel, L["Message template (placeholder: {loadoutname}):"], 24, -64)
    widgets.ttsTemplate = MakeEditBox(panel, 460,
        function() return LoadOutCallerDB.ttsTemplate end,
        function(v) LoadOutCallerDB.ttsTemplate = v end,
        -84, 32)

    MakeButton(panel, L["Reset to default"], 140,
        function()
            LoadOutCallerDB.ttsTemplate = ns.defaults.ttsTemplate
            if widgets.ttsTemplate and widgets.ttsTemplate.Refresh then
                widgets.ttsTemplate:Refresh()
            end
        end,
        "TOPLEFT", panel, "TOPLEFT", 504, -84)

    widgets.showText = MakeCheckbox(panel,
        L["Show on-screen text"],
        L["Displays the build name as large text on screen (~5s fade)."],
        function() return LoadOutCallerDB.showText end,
        function(v) LoadOutCallerDB.showText = v end,
        -120)

    widgets.useChatMessage = MakeCheckbox(panel,
        L["Post to chat"],
        L["Prints the announcement to your chat window (visible only to you)."],
        function() return LoadOutCallerDB.useChatMessage end,
        function(v) LoadOutCallerDB.useChatMessage = v end,
        -144)

    widgets.bannerDuration = MakeSlider(panel, "LoadOutCallerDurationSlider",
        L["Banner duration (seconds)"], 1, 15, 1,
        function() return LoadOutCallerDB.bannerDuration end,
        function(v) LoadOutCallerDB.bannerDuration = v end,
        -184)

    widgets.bannerFontSize = MakeSlider(panel, "LoadOutCallerFontSizeSlider",
        L["Banner font size"], 12, 64, 2,
        function() return LoadOutCallerDB.bannerFontSize end,
        function(v) LoadOutCallerDB.bannerFontSize = v end,
        -224)

    widgets.bannerColor = MakeColorSwatch(panel,
        L["On-screen text color"],
        L["Pick the color of the on-screen banner text."],
        function()
            local c = LoadOutCallerDB.bannerColor or ns.defaults.bannerColor
            return c.r, c.g, c.b
        end,
        function(r, g, b)
            LoadOutCallerDB.bannerColor = { r = r, g = g, b = b }
        end,
        -260)

    widgets.chatColor = MakeColorSwatch(panel,
        L["Chat text color"],
        L["Pick the color of the chat-message text (the |cff3FC7EBLoadOutCaller|r prefix stays addon-blue)."],
        function()
            local c = LoadOutCallerDB.chatColor or ns.defaults.chatColor
            return c.r, c.g, c.b
        end,
        function(r, g, b)
            LoadOutCallerDB.chatColor = { r = r, g = g, b = b }
        end,
        -288)

    local editHint = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    editHint:SetPoint("TOPLEFT", 24, -324)
    editHint:SetWidth(500)
    editHint:SetJustifyH("LEFT")
    editHint:SetText(L["Move display frame: switch to Edit Mode (Esc -> Edit Mode). The frame will appear automatically and can be placed with the mouse."])
    editHint:SetTextColor(0.8, 0.8, 0.8)

    widgets.editModeButton = MakeButton(panel,
        L["Open Edit Mode"],
        200,
        function()
            if SettingsPanel and SettingsPanel:IsShown() then
                HideUIPanel(SettingsPanel)
            end
            if EditModeManagerFrame and ShowUIPanel then
                ShowUIPanel(EditModeManagerFrame)
            elseif EditModeManagerFrame then
                EditModeManagerFrame:Show()
            end
        end,
        "TOPLEFT", panel, "TOPLEFT", 24, -360)

    return panel
end

local function GetSoundList()
    local list = {}
    local presets = ns.PRESET_SOUNDS or {}
    for _, p in ipairs(presets) do
        table.insert(list, { key = p.key, label = p.label, id = p.id })
    end
    if ns.GetSharedMediaSounds then
        local lsm = ns.GetSharedMediaSounds()
        for _, s in ipairs(lsm) do
            table.insert(list, s)
        end
    end
    return list
end

local function SoundGetter()
    return LoadOutCallerDB.soundPath or LoadOutCallerDB.soundID or 0
end

local function SoundSetter(entry)
    if entry.path then
        LoadOutCallerDB.soundPath = entry.path
        LoadOutCallerDB.soundID = nil
    else
        LoadOutCallerDB.soundPath = nil
        LoadOutCallerDB.soundID = entry.id
    end
end

local function BuildSoundPanel()
    local panel = NewSubPanel(L["Sound"])
    AddPanelTitle(panel, L["Sound"])

    widgets.soundEnabled = MakeCheckbox(panel,
        L["Play a sound on announcement"],
        L["Plays a sound via Blizzard's sound system. Works independently of TTS."],
        function() return LoadOutCallerDB.soundEnabled end,
        function(v) LoadOutCallerDB.soundEnabled = v end,
        -64)

    MakeLabel(panel, L["Alert sound:"], 24, -96)

    local soundDD = CreateFrame("Frame", "LoadOutCallerSoundDropdown", panel, "UIDropDownMenuTemplate")
    soundDD:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -114)
    UIDropDownMenu_SetWidth(soundDD, 260)

    local function SoundDDRefresh()
        local current = SoundGetter()
        local list = GetSoundList()
        local label
        for _, e in ipairs(list) do
            if (e.path and e.path == current) or (not e.path and e.id == current) then
                label = e.label
                break
            end
        end
        UIDropDownMenu_SetText(soundDD, label or ("Sound #" .. tostring(current)))
    end

    UIDropDownMenu_Initialize(soundDD, function(self, level)
        local list = GetSoundList()
        local current = SoundGetter()
        for _, entry in ipairs(list) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = entry.label
            info.checked = (entry.path and entry.path == current) or (not entry.path and entry.id == current)
            info.func = function()
                SoundSetter(entry)
                SoundDDRefresh()
                CloseDropDownMenus()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    soundDD:SetScript("OnShow", SoundDDRefresh)
    widgets.soundDropdown = soundDD

    widgets.testSoundButton = MakeButton(panel,
        L["Test sound"],
        120,
        function()
            if ns.PlayAlertSound then
                local wasEnabled = LoadOutCallerDB.soundEnabled
                LoadOutCallerDB.soundEnabled = true
                ns.PlayAlertSound()
                LoadOutCallerDB.soundEnabled = wasEnabled
            end
        end,
        "TOPLEFT", panel, "TOPLEFT", 300, -118)

    return panel
end

local function BuildTTSPanel()
    local panel = NewSubPanel(L["Text-to-Speech (TTS)"])
    AddPanelTitle(panel, L["Text-to-Speech (TTS)"])

    widgets.useTTS = MakeCheckbox(panel,
        L["Use TTS"],
        L["Speaks the build name via WoW's built-in TTS."],
        function() return LoadOutCallerDB.useTTS end,
        function(v) LoadOutCallerDB.useTTS = v end,
        -64)

    local templateHint = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    templateHint:SetPoint("TOPLEFT", 24, -96)
    templateHint:SetWidth(500)
    templateHint:SetJustifyH("LEFT")
    templateHint:SetText(L["The spoken text uses the message template configured under 'Display & Frame'."])
    templateHint:SetTextColor(0.7, 0.7, 0.7)

    MakeLabel(panel, L["TTS voice:"], 24, -128)
    widgets.ttsVoice = MakeVoiceDropdown(panel, "LoadOutCallerVoiceDropdown",
        function() return LoadOutCallerDB.ttsVoiceID or 0 end,
        function(v) LoadOutCallerDB.ttsVoiceID = v end,
        -146)

    widgets.ttsVolume = MakeSlider(panel, "LoadOutCallerVolumeSlider",
        L["Volume"], 0, 100, 5,
        function() return LoadOutCallerDB.ttsVolume end,
        function(v) LoadOutCallerDB.ttsVolume = v end,
        -190)

    widgets.ttsRate = MakeSlider(panel, "LoadOutCallerRateSlider",
        L["Speed"], -10, 10, 1,
        function() return LoadOutCallerDB.ttsRate end,
        function(v) LoadOutCallerDB.ttsRate = v end,
        -230)

    widgets.testButton = MakeButton(panel,
        L["Test announcement"],
        200,
        function()
            if ns.TestTTS then
                ns.TestTTS()
            elseif ns.Announce then
                ns.Announce("test")
            end
        end,
        "TOPLEFT", panel, "TOPLEFT", 24, -274)

    return panel
end

local MODE_PANEL_DEFS = {
    {
        modeKey = "dungeon",
        title = L["Mythic+ / Dungeons"],
        enterLabel = L["Announce on entering a dungeon"],
        enterTip = L["Triggers the announcement when you enter a Mythic+ or 5-man dungeon."],
        opts = { showInvite = true, inviteLabel = L["Announce on Dungeon Finder invite"], inviteTip = L["Triggers the announcement when the Dungeon Finder pops a 'Ready to enter' dialog (random / heroic dungeon). Premade groups and M+ don't fire this."] },
    },
    {
        modeKey = "raid",
        title = L["Raids"],
        enterLabel = L["Announce on entering a raid"],
        enterTip = L["Triggers the announcement when you enter a raid instance."],
        opts = { showInvite = true, inviteLabel = L["Announce on Raid Finder invite"], inviteTip = L["Triggers the announcement when the Raid Finder (LFR) or Flex Raid pops a 'Ready to enter' dialog. Premade groups don't fire this."] },
    },
    {
        modeKey = "delve",
        title = L["Delves"],
        enterLabel = L["Announce on entering a delve"],
        enterTip = L["Triggers the announcement when you enter a delve."],
        opts = nil,
    },
    {
        modeKey = "arena2v2",
        title = L["Arena 2v2"],
        enterLabel = L["Announce on entering Arena 2v2"],
        enterTip = L["Triggers the announcement when you enter a 2v2 arena match (ranked or skirmish)."],
        opts = { omitReadyCheck = true, showMatchStart = true, showInvite = true },
    },
    {
        modeKey = "arena3v3",
        title = L["Arena 3v3"],
        enterLabel = L["Announce on entering Arena 3v3"],
        enterTip = L["Triggers the announcement when you enter a 3v3 arena match (ranked, skirmish, or Solo Shuffle)."],
        opts = { omitReadyCheck = true, showMatchStart = true, showInvite = true },
    },
    {
        modeKey = "battleground",
        title = L["Battlegrounds"],
        enterLabel = L["Announce on entering a battleground"],
        enterTip = L["Triggers the announcement when you enter a battleground (including Epic BGs and rated)."],
        opts = { omitReadyCheck = true, showMatchStart = true, showInvite = true },
    },
    {
        modeKey = "openworld_warmode",
        title = L["Open World (War Mode on)"],
        enterLabel = L["Announce on entering open world"],
        enterTip = L["Triggers the announcement when you zone into the open world with War Mode enabled. Off by default - enable it if you use a dedicated War Mode build."],
        opts = { omitReadyCheck = true },
    },
    {
        modeKey = "openworld_nowarmode",
        title = L["Open World (War Mode off)"],
        enterLabel = L["Announce on entering open world"],
        enterTip = L["Triggers the announcement when you zone into the open world with War Mode disabled (questing, dailies, world content). Off by default."],
        opts = { omitReadyCheck = true },
    },
}

local function RegisterSubcategory(panel)
    local sub = Settings.RegisterCanvasLayoutSubcategory(rootCategory, panel, panel.name)
    return sub
end

function ns.InitOptions()
    if rootCategory then return end

    local rootPanel = BuildRootPanel()
    rootCategory = Settings.RegisterCanvasLayoutCategory(rootPanel, "LoadOutCaller")
    Settings.RegisterAddOnCategory(rootCategory)

    for _, def in ipairs(MODE_PANEL_DEFS) do
        local subPanel = BuildModePanel(def.modeKey, def.title, def.enterLabel, def.enterTip, def.opts)
        RegisterSubcategory(subPanel)
    end

    RegisterSubcategory(BuildDisplayPanel())
    RegisterSubcategory(BuildSoundPanel())
    RegisterSubcategory(BuildTTSPanel())

    ns.optionsCategory = rootCategory
end

function ns.OpenOptions()
    if not rootCategory or not Settings or not Settings.OpenToCategory then return end
    Settings.OpenToCategory(rootCategory:GetID())
end
