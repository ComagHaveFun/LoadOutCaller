local ADDON_NAME, ns = ...

local L = ns.L or setmetatable({}, { __index = function(t, k) return k end })

local panel
local category
local widgets = {}

local function MakeSectionHeader(parent, text, anchor, yOffset)
    local fs = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    fs:SetPoint("TOPLEFT", anchor or parent, "TOPLEFT", 16, yOffset)
    fs:SetText(text)
    fs:SetTextColor(1, 0.82, 0)
    return fs
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

local function MakeLabel(parent, text, x, y)
    local fs = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    fs:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    fs:SetText(text)
    return fs
end

local function MakeEditBox(parent, width, getter, setter, yOffset, xOffset)
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

local function MakeDropdown(parent, frameName, getter, setter, yOffset)
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

local function BuildPanel()
    panel = CreateFrame("Frame", "LoadOutCallerOptionsPanel")
    panel.name = "LoadOutCaller"

    local scroll = CreateFrame("ScrollFrame", "LoadOutCallerOptionsScroll", panel, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 4, -4)
    scroll:SetPoint("BOTTOMRIGHT", -28, 4)

    local content = CreateFrame("Frame", "LoadOutCallerOptionsContent", scroll)
    content:SetSize(560, 1860)
    scroll:SetScrollChild(content)

    local title = content:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("LoadOutCaller")

    local subtitle = content:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
    subtitle:SetText(L["Announces your active talent build on instance enter and ready check."])
    subtitle:SetTextColor(0.8, 0.8, 0.8)

    widgets.enabled = MakeCheckbox(content,
        L["Addon enabled"],
        L["Master switch. When disabled, nothing happens."],
        function() return LoadOutCallerDB.enabled end,
        function(v) LoadOutCallerDB.enabled = v end,
        -64)

    local function BuildModeSection(modeKey, title, enterLabel, enterTip, startY, opts)
        opts = opts or {}
        local showReadyCheck = not opts.omitReadyCheck
        local showMatchStart = opts.showMatchStart

        MakeSectionHeader(content, title, content, startY)

        MakeCheckbox(content,
            enterLabel,
            enterTip,
            function() return LoadOutCallerDB.modes[modeKey].announceOnEnter end,
            function(v) LoadOutCallerDB.modes[modeKey].announceOnEnter = v end,
            startY - 22)

        local y = startY - 22
        if showReadyCheck then
            MakeCheckbox(content,
                L["Announce on ready check"],
                L["Triggers the announcement when a ready check is initiated."],
                function() return LoadOutCallerDB.modes[modeKey].announceOnReadyCheck end,
                function(v) LoadOutCallerDB.modes[modeKey].announceOnReadyCheck = v end,
                y - 24)
            y = y - 24
        end
        if showMatchStart then
            MakeCheckbox(content,
                L["Announce on match start countdown"],
                L["Triggers the announcement when the PvP match start countdown begins."],
                function() return LoadOutCallerDB.modes[modeKey].announceOnMatchStartCountdown end,
                function(v) LoadOutCallerDB.modes[modeKey].announceOnMatchStartCountdown = v end,
                y - 24)
            y = y - 24
        end

        MakeCheckbox(content,
            L["Always on enter (ignore skip keyword)"],
            L["When active, always announce on enter, even if the build name contains the skip keyword."],
            function() return LoadOutCallerDB.modes[modeKey].alwaysOnEnter end,
            function(v) LoadOutCallerDB.modes[modeKey].alwaysOnEnter = v end,
            y - 24)
        y = y - 24

        if showReadyCheck then
            MakeCheckbox(content,
                L["Always on ready check (ignore skip keyword)"],
                L["When active, always announce on ready check, even if the build name contains the skip keyword."],
                function() return LoadOutCallerDB.modes[modeKey].alwaysOnReadyCheck end,
                function(v) LoadOutCallerDB.modes[modeKey].alwaysOnReadyCheck = v end,
                y - 24)
            y = y - 24
        end
        if showMatchStart then
            MakeCheckbox(content,
                L["Always on match start countdown (ignore skip keyword)"],
                L["When active, always announce on the match start countdown, even if the build name contains the skip keyword."],
                function() return LoadOutCallerDB.modes[modeKey].alwaysOnMatchStartCountdown end,
                function(v) LoadOutCallerDB.modes[modeKey].alwaysOnMatchStartCountdown = v end,
                y - 24)
            y = y - 24
        end

        MakeLabel(content, L["Skip keyword:"], 24, y - 26)
        MakeEditBox(content, 180,
            function() return LoadOutCallerDB.modes[modeKey].skipKeyword end,
            function(v) LoadOutCallerDB.modes[modeKey].skipKeyword = v end,
            y - 46, 32)
    end

    BuildModeSection("dungeon",
        L["Mythic+ / Dungeons"],
        L["Announce on entering a dungeon"],
        L["Triggers the announcement when you enter a Mythic+ or 5-man dungeon."],
        -100)

    BuildModeSection("raid",
        L["Raids"],
        L["Announce on entering a raid"],
        L["Triggers the announcement when you enter a raid instance."],
        -270)

    BuildModeSection("delve",
        L["Delves"],
        L["Announce on entering a delve"],
        L["Triggers the announcement when you enter a delve."],
        -440)

    BuildModeSection("arena2v2",
        L["Arena 2v2"],
        L["Announce on entering Arena 2v2"],
        L["Triggers the announcement when you enter a 2v2 arena match (ranked or skirmish)."],
        -610, { omitReadyCheck = true, showMatchStart = true })

    BuildModeSection("arena3v3",
        L["Arena 3v3"],
        L["Announce on entering Arena 3v3"],
        L["Triggers the announcement when you enter a 3v3 arena match (ranked, skirmish, or Solo Shuffle)."],
        -780, { omitReadyCheck = true, showMatchStart = true })

    BuildModeSection("battleground",
        L["Battlegrounds"],
        L["Announce on entering a battleground"],
        L["Triggers the announcement when you enter a battleground (including Epic BGs and rated)."],
        -950, { omitReadyCheck = true, showMatchStart = true })

    local skipHint = content:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    skipHint:SetPoint("TOPLEFT", 24, -1110)
    skipHint:SetWidth(500)
    skipHint:SetJustifyH("LEFT")
    skipHint:SetText(L["Skip keyword: if your active loadout name contains this word (case-insensitive), the announcement is skipped for that mode."])
    skipHint:SetTextColor(0.7, 0.7, 0.7)

    MakeSectionHeader(content, L["Spec & Role"], content, -1154)

    widgets.warnOnRoleMismatch = MakeCheckbox(content,
        L["Warn on role mismatch"],
        L["Warns via the configured outputs (banner/chat/TTS) when your assigned group role doesn't match your current spec's natural role."],
        function() return LoadOutCallerDB.warnOnRoleMismatch end,
        function(v) LoadOutCallerDB.warnOnRoleMismatch = v end,
        -1176)

    widgets.announceOnSpecChange = MakeCheckbox(content,
        L["Announce loadout on spec change"],
        L["Fires the build announcement when you switch talent specialization (same output as ready check / instance enter)."],
        function() return LoadOutCallerDB.announceOnSpecChange end,
        function(v) LoadOutCallerDB.announceOnSpecChange = v end,
        -1200)

    MakeSectionHeader(content, L["Display"], content, -1244)

    widgets.showText = MakeCheckbox(content,
        L["Show on-screen text"],
        L["Displays the build name as large text on screen (~5s fade)."],
        function() return LoadOutCallerDB.showText end,
        function(v) LoadOutCallerDB.showText = v end,
        -1266)

    widgets.useChatMessage = MakeCheckbox(content,
        L["Post to chat"],
        L["Prints the announcement to your chat window (visible only to you)."],
        function() return LoadOutCallerDB.useChatMessage end,
        function(v) LoadOutCallerDB.useChatMessage = v end,
        -1290)

    widgets.bannerDuration = MakeSlider(content, "LoadOutCallerDurationSlider",
        L["Banner duration (seconds)"], 1, 15, 1,
        function() return LoadOutCallerDB.bannerDuration end,
        function(v) LoadOutCallerDB.bannerDuration = v end,
        -1326)

    widgets.bannerFontSize = MakeSlider(content, "LoadOutCallerFontSizeSlider",
        L["Banner font size"], 12, 64, 2,
        function() return LoadOutCallerDB.bannerFontSize end,
        function(v) LoadOutCallerDB.bannerFontSize = v end,
        -1362)

    local editHint = content:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    editHint:SetPoint("TOPLEFT", 24, -1398)
    editHint:SetWidth(500)
    editHint:SetJustifyH("LEFT")
    editHint:SetText(L["Move display frame: switch to Edit Mode (Esc -> Edit Mode). The frame will appear automatically and can be placed with the mouse."])
    editHint:SetTextColor(0.8, 0.8, 0.8)

    widgets.editModeButton = MakeButton(content,
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
        "TOPLEFT", content, "TOPLEFT", 24, -1432)

    MakeSectionHeader(content, L["Sound alert"], content, -1474)

    widgets.soundEnabled = MakeCheckbox(content,
        L["Play a sound on announcement"],
        L["Plays a sound via Blizzard's sound system. Works independently of TTS."],
        function() return LoadOutCallerDB.soundEnabled end,
        function(v) LoadOutCallerDB.soundEnabled = v end,
        -1496)

    MakeLabel(content, L["Alert sound:"], 24, -1524)

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

    local soundDD = CreateFrame("Frame", "LoadOutCallerSoundDropdown", content, "UIDropDownMenuTemplate")
    soundDD:SetPoint("TOPLEFT", content, "TOPLEFT", 12, -1542)
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

    widgets.testSoundButton = MakeButton(content,
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
        "TOPLEFT", content, "TOPLEFT", 300, -1546)

    MakeSectionHeader(content, L["Text-to-Speech (TTS)"], content, -1586)

    widgets.useTTS = MakeCheckbox(content,
        L["Use TTS"],
        L["Speaks the build name via WoW's built-in TTS."],
        function() return LoadOutCallerDB.useTTS end,
        function(v) LoadOutCallerDB.useTTS = v end,
        -1608)

    MakeLabel(content, L["TTS text template (placeholder: {build}):"], 24, -1636)
    widgets.ttsTemplate = MakeEditBox(content, 480,
        function() return LoadOutCallerDB.ttsTemplate end,
        function(v) LoadOutCallerDB.ttsTemplate = v end,
        -1656, 32)

    MakeLabel(content, L["TTS voice:"], 24, -1688)
    widgets.ttsVoice = MakeDropdown(content, "LoadOutCallerVoiceDropdown",
        function() return LoadOutCallerDB.ttsVoiceID or 0 end,
        function(v) LoadOutCallerDB.ttsVoiceID = v end,
        -1706)

    widgets.ttsVolume = MakeSlider(content, "LoadOutCallerVolumeSlider",
        L["Volume"], 0, 100, 5,
        function() return LoadOutCallerDB.ttsVolume end,
        function(v) LoadOutCallerDB.ttsVolume = v end,
        -1746)

    widgets.ttsRate = MakeSlider(content, "LoadOutCallerRateSlider",
        L["Speed"], -10, 10, 1,
        function() return LoadOutCallerDB.ttsRate end,
        function(v) LoadOutCallerDB.ttsRate = v end,
        -1782)

    widgets.testButton = MakeButton(content,
        L["Test announcement"],
        140,
        function()
            if ns.Announce then ns.Announce("test") end
        end,
        "TOPLEFT", content, "TOPLEFT", 24, -1822)
end

function ns.InitOptions()
    if panel then return end
    BuildPanel()
    category = Settings.RegisterCanvasLayoutCategory(panel, "LoadOutCaller")
    Settings.RegisterAddOnCategory(category)
    ns.optionsCategory = category
end

function ns.OpenOptions()
    if not category or not Settings or not Settings.OpenToCategory then return end
    Settings.OpenToCategory(category:GetID())
end
