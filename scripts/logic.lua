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

function quietus()
    if has("raftpiece") and has("firemace") and has("forcewand") and has("sword") and has("icering") and has("chain") then
        return keys("dream2", 2) and keys("dream4", 4)
    else
        return false
    end
end

function quietus_in_logic()
    if has("raftpiece") and has("firemace") and has("forcewand") and has("sword") and has("icering") and has("chain") then
        return realkeys("dream2", 4) and realkeys("dream4", 4)
    else
        return false
    end
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