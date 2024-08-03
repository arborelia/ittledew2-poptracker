function has(item, amount)
    local count = Tracker:ProviderCountForCode(item)
    if not amount then
        return count > 0
    else
        amount = tonumber(amount)
        return count >= amount
    end
end

function access(region)
    -- todo: add option
    if region == "court" then
        return has("access-court") and (has("access-ruins") or has("access-woods"))
    elseif region == "road" then
        return has("access-road") and has("access-slope")
    else
        return has("access-" .. region)
    end
end

function dream()
    return has("raftpiece")
end

function dreamchange()
    return not has("dreams-keep-items")
end

function wizardry()
    return dream() and (has("open-dream") or has("forcewand"))
end

function wizardryCompletable()
    return wizardry() and (
        dreamchange() or 
        (has("dreams-keep-items") and has("stick") and has("wand"))
    )
end

function wizardryCompletableInLogic()
    return wizardryCompletable()
end

function bottomless()
    return dream() and (has("open-dream") or has("icering"))
end

function bottomlessCompletable()
    if not bottomless() then
        return false
    elseif has("dreams-keep-items") then
        if has("sword") and has("icering") then
            return keys("dream2", 2)
        elseif has("stick") and has("icering") then
            return keys("dream2", 4)
        else
            return false
        end
    else
        return keys("dream2", 4)
    end
end

function bottomlessCompletableInLogic()
    if not bottomless() then
        return false
    elseif has("dreams-keep-items") then
        return has("icering") and has("roll") and has("stick") and realkeys("dream2", 4)
    else
        return realkeys("dream2", 4)
    end
end

function syncope()
    return dream() and (has("open-dream") or has("dynamite"))
end

function syncopeCompletable()
    if not syncope() then
        return false
    elseif has("dreams-keep-items") then
        return (
            has("dynamite") and has("icering") and has("wand")
        ) or (
            has("dynamite")
            and (has("icering") or has("wand"))
            and keys("dream3", 1)
        ) or (
            has("dynamite") and nondynamite() and keys("dream3", 3)
        )
    else
        return keys("dream3", 3)
    end
end

function syncopeCompletableInLogic()
    if not syncope() then
        return false
    elseif has("dreams-keep-items") then
        return (
            has("dynamite") and has("icering") and has("wand")
        ) or (
            has("dynamite") and nondynamite() and realkeys("dream3", 3)
        )
    else
        return realkeys("dream3", 3)
    end
end

function antigram()
    return dream() and (has("open-dream") or (has("sword") and has("chain")))
end

function antigramCompletable()
    if not antigram() then
        return false
    elseif has("dreams-keep-items") then
        return weapon() and keys("dream4", 4)
    else
        return keys("dream4", 4)
    end
end

function antigramCompletableInLogic()
    if not antigram() then
        return false
    elseif has("dreams-keep-items") then
        return weapon() and has("roll") and realkeys("dream4", 4)
    else
        return realkeys("dream4", 4)
    end
end

function quietus()
    return (
        wizardryCompletable()
        and bottomlessCompletable()
        and syncopeCompletable()
        and antigramCompletable()
    )
end

function quietus_in_logic()
    return (
        wizardryCompletableInLogic()
        and bottomlessCompletableInLogic()
        and syncopeCompletableInLogic()
        and antigramCompletableInLogic()
    )
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