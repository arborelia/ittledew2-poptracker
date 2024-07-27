function has(item, amount)
    local count = Tracker:ProviderCountForCode(item)
    if not amount then
        return count > 0
    else
        amount = tonumber(amount)
        return count >= amount
    end
end

function dream()
    return has("raftpiece") or has("open-dream")
end

function dreamchange()
    return not has("dreams-keep-items")
end

function wizardry()
    return has("open-dream") or (has("raftpiece") and has("forcewand"))
end

function bottomless()
    return has("open-dream") or (has("raftpiece") and has("icering"))
end

function syncope()
    return has("open-dream") or (has("raftpiece") and has("dynamite"))
end

function antigram()
    return has("open-dream") or (has("raftpiece") and has("sword") and has("chain"))
end

function quietus()
    if has("open-dream") then
        return keys("dream2", 4) and keys("dream4", 4)
    elseif has("raftpiece") and has("firemace") and has("forcewand") and has("sword") and has("icering") and has("chain") then
        return keys("dream2", 2) and keys("dream4", 4)
    else
        return false
    end
end

function quietus_in_logic()
    if has("open-dream") then
        return keys("dream2", 4) and keys("dream4", 4)
    elseif has("raftpiece") and has("firemace") and has("forcewand") and has("sword") and has("icering") and has("chain") and has("roll") then
        return realkeys("dream2", 4) and realkeys("dream4", 4)
    else
        return false
    end
end


function weapon()
    return has("stick") or has("forcewand") or has("icering") or has("dynamite")
end

function openchest()
    return weapon() or (has("roll-chests") and has("roll"))
end

function puzzledmg()
    return has("efcs") or has("fakeefcs") or has("dynamite", 4)
end

function nondynamite()
    return has("stick") or has("forcewand") or has("icering")
end

function nonforce()
    return has("stick") or has("dynamite") or has("icering")
end

function projectile()
    return has("firemace") or has("forcewand")
end

function keys(dungeon, amount)
    local npicks = Tracker:ProviderCountForCode("lockpick")
    local nkeys = Tracker:ProviderCountForCode("key-" .. dungeon)
    if has("keyrings") then nkeys = nkeys * 10 end
    return has("keysey") or npicks + nkeys >= tonumber(amount)
end

function realkeys(dungeon, amount)
    local nkeys = Tracker:ProviderCountForCode("key-" .. dungeon)
    if has("keyrings") then nkeys = nkeys * 10 end
    return has("keysey") or nkeys >= tonumber(amount)
end

function library()
    return has("open-library") or has("raftpiece", 7)
end

function shard8()
    return has("shard", 8)
end

function shard16()
    return has("shard", 16)
end

function shard24()
    return has("shard", 24)
end

function forbidden()
    return has("forbiddenkey", 4)
end

-- leaving room for glitch logic
function can_phase_itemless()
    return false
end

function can_phase_itemless_difficult()
    return false
end

function can_phase_ice()
    return false
end

function can_phase_dynamite()
    return false
end