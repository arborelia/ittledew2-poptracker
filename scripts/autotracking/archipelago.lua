ScriptHost:LoadScript("scripts/autotracking/item_mapping.lua")
ScriptHost:LoadScript("scripts/autotracking/location_mapping.lua")

CUR_INDEX = -1
SLOT_DATA = nil
HOSTED = {}
REGION_CODES = {"coast", "ruins", "woods", "slope", "prairie", "court", "road"}

local positionKey = ""
local levelNameKey = ""

local dungeonNames = {
    PillowFort = true,
    SandCastle = true,
    ArtExhibit = true,
    TrashCave = true,
    FloodedBasement = true,
    PotassiumMine = true,
    BoilingGrave = true,
    GrandLibrary = true,
    SunkenLabyrinth = true,
    MachineFortress = true,
    DarkHypostyle = true,
    TombOfSimulacrum = true,
}

local dreamWorldNames = {
    DreamWorld = true,
    DreamForce = true, -- Wizardry Lab
    DreamDynamite = true, -- Syncope
    DreamIce = true, -- Bottomless Tower
    DreamFireChain = true, -- Antigram
    DreamAll = true, -- Quietus
}

local function levelNameToTabName(levelName)
    if dungeonNames[levelName] then
        return "Dungeons"
    elseif dreamWorldNames[levelName] then
        return "Dream World"
    else
        return "Overworld"
    end
end

-- from https://stackoverflow.com/questions/9168058/how-to-dump-a-table-to-console
-- dumps a table in a readable string
function dump_table(o, depth)
    if depth == nil then
        depth = 0
    end
    if type(o) == 'table' then
        local tabs = ('\t'):rep(depth)
        local tabs2 = ('\t'):rep(depth + 1)
        local s = '{\n'
        for k, v in pairs(o) do
            if type(k) ~= 'number' then
                k = '"' .. k .. '"'
            end
            s = s .. tabs2 .. '[' .. k .. '] = ' .. dump_table(v, depth + 1) .. ',\n'
        end
        return s .. tabs .. '}'
    else
        return tostring(o)
    end
end

local function onRetrieved(key, value)
    if key == levelNameKey then
        local levelName = value
        local tabName = levelNameToTabName(levelName)

        Tracker:UiHint("ActivateTab", tabName)
    end
end

local function onSetReply(key, value, _old)
    onRetrieved(key, value)
end

function onClear(slot_data)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onClear, slot_data:\n%s", dump_table(slot_data)))
    end
    SLOT_DATA = slot_data
    CUR_INDEX = -1
    -- reset locations
    for _, v in pairs(LOCATION_MAPPING) do
        if v[1] then
            if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: clearing location %s", v[1]))
            end
            local obj = Tracker:FindObjectForCode(v[1])
            if obj then
                if v[1]:sub(1, 1) == "@" then
                    obj.AvailableChestCount = obj.ChestCount
                else
                    obj.Active = false
                end
            elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: could not find object for code %s", v[1]))
            end
        end
    end
    -- reset items
    for _, v in pairs(ITEM_MAPPING) do
        if v[1] and v[2] then
            if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: clearing item %s of type %s", v[1], v[2]))
            end
            local obj = Tracker:FindObjectForCode(v[1])
            if obj then
                if v[2] == "toggle" then
                    obj.Active = false
                elseif v[2] == "progressive" then
                    obj.CurrentStage = 0
                    obj.Active = false
                elseif v[2] == "consumable" then
                    obj.AcquiredCount = 0
                elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                    print(string.format("onClear: unknown item type %s for code %s", v[2], v[1]))
                end
            elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: could not find object for code %s", v[1]))
            end
        end
    end

    if slot_data.key_settings then
        Tracker:FindObjectForCode("key-settings").CurrentStage = slot_data.key_settings
    end

    if slot_data.shard_settings then
        Tracker:FindObjectForCode("shard-settings").CurrentStage = slot_data.shard_settings
    end

    if slot_data.roll_opens_chests then
        Tracker:FindObjectForCode("roll-chests").Active = (slot_data.roll_opens_chests == 1)
    end

    if slot_data.open_d8 then
        Tracker:FindObjectForCode("open-library").Active = (slot_data.open_d8 == 1)
    end

    if slot_data.open_dreamworld then
        Tracker:FindObjectForCode("open-dream").Active = (slot_data.open_dreamworld == 1)
    end

    if slot_data.open_s4 then
        Tracker:FindObjectForCode("open-tomb").Active = (slot_data.open_s4 == 1)
    end

    if slot_data.dream_dungeons_do_not_change_items then
        Tracker:FindObjectForCode("dreams-keep-items").Active = (slot_data.dream_dungeons_do_not_change_items == 1)
    end

    if slot_data.start_with_all_warps then
        Tracker:FindObjectForCode("start-warps").Active = (slot_data.start_with_all_warps == 1)
    end

    if slot_data.include_portal_worlds then
        Tracker:FindObjectForCode("include-portal-worlds").Active = (slot_data.include_portal_worlds == 1)
    end

    if slot_data.include_secret_dungeons then
        Tracker:FindObjectForCode("include-secret-dungeons").Active = (slot_data.include_secret_dungeons == 1)
    end

    if slot_data.include_dream_dungeons then
        Tracker:FindObjectForCode("include-dream-dungeons").Active = (slot_data.include_dream_dungeons == 1)
    end

    if slot_data.include_super_secrets then
        Tracker:FindObjectForCode("include-super-secrets").Active = (slot_data.include_super_secrets == 1)
    end

    positionKey = "id2.pos." .. Archipelago.PlayerNumber
    levelNameKey = "id2.levelName." .. Archipelago.PlayerNumber

    local keys = {
        positionKey,
        levelNameKey
    }

    Archipelago:SetNotify(keys)
    Archipelago:Get(keys)
end

-- called when an item gets collected
function onItem(index, item_id, item_name, player_number)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onItem: %s, %s, %s, %s, %s", index, item_id, item_name, player_number, CUR_INDEX))
    end
    if not AUTOTRACKER_ENABLE_ITEM_TRACKING then
        return
    end
    if index <= CUR_INDEX then
        return
    end
    local is_local = player_number == Archipelago.PlayerNumber
    CUR_INDEX = index;
    local v = ITEM_MAPPING[item_id]
    if not v then
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("onItem: could not find item mapping for id %s", item_id))
        end
        return
    end
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onItem: code: %s, type %s", v[1], v[2]))
    end
    if not v[1] then
        return
    end
    local obj = Tracker:FindObjectForCode(v[1])
    if obj then
        if v[2] == "toggle" then
            obj.Active = true
        elseif v[2] == "propagate" then
            obj.Active = true
            for code in REGION_CODES do
                local region = Tracker:FindObjectForCode("access-" .. code)
                region.Active = access(code)
            end
        elseif v[2] == "progressive" then
            if obj.Active then
                obj.CurrentStage = obj.CurrentStage + 1
            else
                obj.Active = true
            end
        elseif v[2] == "consumable" then
            obj.AcquiredCount = obj.AcquiredCount + obj.Increment
        elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("onItem: unknown item type %s for code %s", v[2], v[1]))
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onItem: could not find object for code %s", v[1]))
    end
end

-- called when a location gets cleared
function onLocation(location_id, location_name)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onLocation: %s, %s", location_id, location_name))
    end
    if not AUTOTRACKER_ENABLE_LOCATION_TRACKING then
        return
    end
    local v = LOCATION_MAPPING[location_id]
    if not v and AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onLocation: could not find location mapping for id %s", location_id))
    end
    if not v[1] then
        return
    end
    local obj = Tracker:FindObjectForCode(v[1])
    if obj then
        if v[1]:sub(1, 1) == "@" then
            obj.AvailableChestCount = obj.AvailableChestCount - 1
        else
            obj.Active = true
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onLocation: could not find object for code %s", v[1]))
    end
end

-- called when a locations is scouted
function onScout(location_id, location_name, item_id, item_name, item_player)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onScout: %s, %s, %s, %s, %s", location_id, location_name, item_id, item_name,
            item_player))
    end
end

-- called when a bounce message is received 
function onBounce(json)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onBounce: %s", dump_table(json)))
    end
    -- your code goes here
end

-- add AP callbacks
-- un-/comment as needed
Archipelago:AddClearHandler("clear handler", onClear)
if AUTOTRACKER_ENABLE_ITEM_TRACKING then
    Archipelago:AddItemHandler("item handler", onItem)
end
if AUTOTRACKER_ENABLE_LOCATION_TRACKING then
    Archipelago:AddLocationHandler("location handler", onLocation)
end
Archipelago:AddRetrievedHandler("retrieved handler", onRetrieved)
Archipelago:AddSetReplyHandler("set reply handler", onSetReply)
-- Archipelago:AddScoutHandler("scout handler", onScout)
-- Archipelago:AddBouncedHandler("bounce handler", onBounce)
