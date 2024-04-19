SatarkusPortals = CreateFrame("Frame")

SatarkusPortals.matchWords = {
    { "wtb", "portal",  "to",     "undercity" },
    { "wtb", "portal",  "uc" },
    { "wtb", "uc",      "portal" },
    { "wtb", "port",    "uc" },
    { "wtb", "portal",  "to",     "stonrad" },
    { "wtb", "portal",  "ston" },
    { "wtb", "stonard", "portal" },
    { "wtb", "port",    "stonard" },
    { "wtb", "uc",      "port" },
    { "wtb", "portal",  "to",     "orgrimmar" },
    { "wtb", "portal",  "og" },
    { "wtb", "og",      "portal" },
    { "wtb", "port",    "og" },
    { "wtb", "og",      "port" },
    { "wtb", "portal",  "to",     "thunder",  "bluff" },
    { "wtb", "portal",  "tb" },
    { "wtb", "tb",      "portal" },
    { "wtb", "port",    "tb" },
    { "wtb", "tb",      "port" },
    { "wtb", "portal",  "to",     "dalaran" },
    { "wtb", "portal",  "dala" },
    { "wtb", "dala",    "portal" },
    { "wtb", "dalaran", "portal" },
    { "wtb", "port",    "dala" },
    { "wtb", "dala",    "port" },
    { "wtb", "port",    "dalaran" },
    { "wtb", "dalaran", "port" },
    { "wtb", "mage",    "portal" },
    { "wtb", "portal" },
    { "wtb", "port",    "to",     "uc" },
    { "wtb", "port",    "to",     "og" },
    { "wtb", "uc",  "summon" },
    { "wtb", "og",  "summon" }
}

SatarkusPortals.portals = {
    ["stormwind"] = 10059,
    ["orgrimmar"] = 11417,
    ["ironforge"] = 11416,
    ["undercity"] = 11418,
    ["darnassus"] = 11419,
    ["thunderbluff"] = 11420
}

SatarkusPortals.lastInvitations = {}

SatarkusPortals.timerActive = false;

function SatarkusPortals:Print(...)
    print("[SatarkusPortals] " .. ...)
end

function SatarkusPortals:Boot()
    self:SetScript("OnEvent", function(self, event, ...)
        self[event](self, ...)
    end)
    self:RegisterEvent("ADDON_LOADED")
end

function SatarkusPortals:ADDON_LOADED(name)
    if name == "SatarkusPortals" then
        self:OnBoot()
    end
end

function SatarkusPortals:RegisterSlashCommand()
    SLASH_SATARKUSPORTALS1 = "/sap"
    SLASH_SATARKUSPORTALS2 = "/satarkusportals"
    SlashCmdList["SATARKUSPORTALS"] = function(msg)
        local _, _, command, args = string.find(msg, "%s?(%w+)%s?(.*)")
        if command then
            self:OnSlashCommand(command, args)
        end
    end
    self:Print("Satarkus Portals type /ps on, /ps off for enable/disable the addon.")
end

function SatarkusPortals:OnSlashCommand(command, args)
    command = string.lower(command)
    if command == "on" then
        self:On()
    elseif command == "off" then
        self:Off()
    else
        self:Print("Unknown command.")
    end
end

function SatarkusPortals:On()
    self:RegisterEvent("CHAT_MSG_SAY")
    self:RegisterEvent("CHAT_MSG_YELL")
    self:RegisterEvent("CHAT_MSG_WHISPER")
    self:RegisterEvent("CHAT_MSG_CHANNEL")
    self:RegisterEvent("GROUP_ROSTER_UPDATE")
    self:RegisterEvent("RAID_ROSTER_UPDATE")
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    self:StartTimer();
    SetRaidTarget("player", 6)

    self:Print("Looking for portal buyers ...")
end

function SatarkusPortals:Off()
    self:UnregisterEvents()
    SetRaidTarget("player", 0)
    self:StopTimer();
    self:Print("All done. Time for breakfast.")
end

function SatarkusPortals:UnregisterEvents()
    self:UnregisterEvent("CHAT_MSG_SAY")
    self:UnregisterEvent("CHAT_MSG_YELL")
    self:UnregisterEvent("CHAT_MSG_WHISPER")
    self:UnregisterEvent("CHAT_MSG_CHANNEL")
    self:UnregisterEvent("GROUP_ROSTER_UPDATE")
    self:UnregisterEvent("RAID_ROSTER_UPDATE")
    self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
end

function SatarkusPortals:OnBoot()
    self:RegisterSlashCommand()
    self:Print("Satarkus Portals is Loaded.")
end

function SatarkusPortals:CHAT_MSG_CHANNEL(...)
    self:OnChat(...)
end

function SatarkusPortals:CHAT_MSG_SAY(...)
    self:OnChat(...)
end

function SatarkusPortals:CHAT_MSG_YELL(...)
    self:OnChat(...)
end

function SatarkusPortals:CHAT_MSG_WHISPER(...)
    self:OnChat(...)
end

function SatarkusPortals:GROUP_ROSTER_UPDATE(...)
    self:GroupChanged()
end

function SatarkusPortals:RAID_ROSTER_UPDATE(...)
    self:GroupChanged()
end

function SatarkusPortals:UNIT_SPELLCAST_SUCCEEDED(...)
    self:OnSpellCastSuccess(...)
end

function SatarkusPortals:WantsPortal(playerName, guid, message)
    if playerName == UnitName("player") then
        return false
    end
    local _, playerClass = GetPlayerInfoByGUID(guid)
    if playerClass == "MAGE" then
        --return false
    end

    return self:MatchWordToDestination(string.lower(message))
end

function SatarkusPortals:MatchWordToDestination(text)
    text = text:lower()
    for _, combination in ipairs(self.matchWords) do
        local allKeywordsFound = true
        for _, keyword in ipairs(combination) do
            keyword = keyword:lower()
            if not text:match("%S*" .. keyword .. "%S*") then
                allKeywordsFound = false
                break
            end
        end
        if allKeywordsFound then
            return true
        end
    end
    return false
end

-- Función auxiliar para verificar si un elemento está en una tabla
function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

function SatarkusPortals:IsUnitInGroup(unit)
    local raidID = UnitInRaid(unit)
    if raidID then
        local name, _, _, _, _, _, _, online = GetRaidRosterInfo(raidID)
        return online or (IsInGroup(unit) and name)
    end
    return false
end

function SatarkusPortals:ArrayHas(item, array)
    for index, value in pairs(array) do
        if value == item then
            return true
        end
    end
    return false
end

function SatarkusPortals:OnChat(text, playerName, _, _, shortPlayerName, _, _, _, _, _, _, guid)
    if self:WantsPortal(shortPlayerName, guid, text) then
        self:Print("Portal from [" .. text .. "]")
        if self:IsUnitInGroup(playerName) then
            local message =
            "It appears you're in a group. Extend me an invitation, and I shall craft the portal you seek!"
            SendChatMessage(message, "WHISPER", nil, playerName)
        else
            if self:TryToInvitePlayer(playerName) then
                self:CustomWellcomeChat(playerName, shortPlayerName)
            end
        end
    else
    end
end

function SatarkusPortals:GroupChanged()
    SetRaidTarget("player", 6)
    SetRaidTarget("party1", 3)
end

function SatarkusPortals:CustomWellcomeChat(playerName, shortPlayerName)
    local frases = {
        "Ahoy there, %s! You asked for a portal. In which grand city does your heart yearn to venture forth? Speak now, and let the magic of the portals whisk you away to your chosen destination!",
        "Greetings, %s! You asked for a portal. Tell me, which grand city beckons you today?",
        "Welcome, %s, You asked for a portal. Choose your destination, and let the journey begin!",
        "Ahoy, matey %s! You asked for a portal. Which city be callin' yer name today?",
        "Greetings, %s! You asked for a portal. Which city shall we uncover the mysteries of?",
        "Hail, brave traveler %s! You asked for a portal. Which city shall we discover today?",
        "Ahoy there, fearless %s! You asked for a portal. Choose your destiny, and let us set sail!",
        "Greetings, wanderer %s! You asked for a portal. Where shall we uncover the mysteries next?",
        "Hello, %s! You asked for a portal. Tell me, where does your sense of adventure guide you?",
        "Greetings, seeker of thrills %s! You asked for a portal. Which city shall be our playground?",
        "Ahoy there, %s! You asked for a portal. Where shall the winds of destiny carry us today?",
    }

    local fraseAleatoria = frases[math.random(#frases)]
    local mensaje = string.format(fraseAleatoria, shortPlayerName)
    SendChatMessage(mensaje, "WHISPER", nil, playerName)
end

function SatarkusPortals:CustomSellingChat()
    local messages = {
        "WTS OG/UC PORTAL for 1G, interested? /w for details. Join the Horde's journey, where water and food are freely given!",
        "WTS OG/UC PORTAL for 1G, /w for info. In the Horde, even sustenance is shared - enjoy free water and food!",
        "WTS OG/UC PORTAL for 1G, seeking buyers. /w for inquiries. Brave the unknown with the Horde's provision of free water and food!",
        "WTS OG/UC PORTAL for 1G, message for details. /w. Discover secrets with us, sustained by the Horde's free water and food!",
        "WTS OG/UC PORTAL for 1G, anyone keen? /w for info. Let the Horde guide you, where even water and food are freely provided!",
        "WTS OG/UC PORTAL for 1G, /w for inquiries. Journey with the Horde, fortified by the generosity of free water and food!",
        "WTS OG/UC PORTAL for 1G, /w if interested. Arm yourself, knowing the Horde provides even free water and food!",
        "WTS OG/UC PORTAL for 1G, /w to buy. Join the Horde's ranks, where even water and food are freely shared!",
        "WTS OG/UC PORTAL for 1G, drop me a message. /w. Venture forth with the Horde, where free water and food await!",
        "WTS OG/UC PORTAL for 1G, /w for purchase details. Let the Horde sustain you with free water and food on this adventure!",
        "WTS OG/UC PORTAL for 1G, interested? /w for details. Join the Horde's quest, where water and food are freely given!",
        "WTS OG/UC PORTAL for 1G, /w for info. In the Horde, even sustenance is shared - enjoy free water and food!",
        "WTS OG/UC PORTAL for 1G, seeking buyers. /w for inquiries. Brave the unknown with the Horde's provision of free water and food!",
        "WTS OG/UC PORTAL for 1G, message for details. /w. Discover secrets with us, sustained by the Horde's free water and food!",
        "WTS OG/UC PORTAL for 1G, anyone keen? /w for info. Let the Horde guide you, where even water and food are freely provided!",
        "WTS OG/UC PORTAL for 1G, /w for inquiries. Journey with the Horde, fortified by the generosity of free water and food!",
        "WTS OG/UC PORTAL for 1G, /w if interested. Arm yourself, knowing the Horde provides even free water and food!",
        "WTS OG/UC PORTAL for 1G, /w to buy. Join the Horde's ranks, where even water and food are freely shared!",
        "WTS OG/UC PORTAL for 1G, drop me a message. /w. Venture forth with the Horde, where free water and food await!",
        "WTS OG/UC PORTAL for 1G, /w for purchase details. Let the Horde sustain you with free water and food on this adventure!"
    }

    local randomChannel = math.random(1)
    local randomMessage = messages[math.random(#messages)];
    if randomChannel == 1 then
        SendChatMessage(randomMessage, "YELL")
        SendChatMessage(randomMessage, "CHANNEL", nil, "2")
    else
        SendChatMessage(randomMessage, "YELL")
        SendChatMessage(randomMessage, "CHANNEL", nil, "1")
    end
end

function SatarkusPortals:OnSpellCastSuccess(event, unit, spellName, spellID)
    if unit == "player" then
        if SatarkusPortals:IsPortalSpell(spellID) then
            self:Print("Se ha lanzado un portal: " .. spellName)
        end
    end
end

function SatarkusPortals:IsPortalSpell(spellID)
    for _, id in pairs(self.portals) do
        if spellID == id then
            return true
        end
    end
    return false
end

function SatarkusPortals:StartTimer()
    SatarkusPortals:SetScript("OnUpdate", function(self, elapsed)
        self.timer = (self.timer or 0) + elapsed
        if self.timer >= 60 then
            SatarkusPortals:CustomSellingChat()
            self.timer = 0
        end
    end)
end

-- Función para desactivar el temporizador
function SatarkusPortals:StopTimer()
    SatarkusPortals:SetScript("OnUpdate", nil)
end

function SatarkusPortals:TryToInvitePlayer(playerName)
    if self:CanInvite(playerName) then
        InviteUnit(playerName)
        self.lastInvitations[playerName] = GetServerTime()
        return true
    else
        self:Print("Ya se ha invitado a " .. playerName .. " en los últimos 15 minutos.")
        return false
    end
end

function SatarkusPortals:CanInvite(playerName)
    local lastInviteTime = self.lastInvitations[playerName]
    if lastInviteTime == nil then
        return true
    end
    -- Verificar si han pasado 15 minutos desde la última invitación
    local currentTime = GetServerTime()
    local elapsedTime = currentTime - lastInviteTime
    return elapsedTime >= (15 * 60) -- 15 minutos en segundos
end

SatarkusPortals:Boot()
