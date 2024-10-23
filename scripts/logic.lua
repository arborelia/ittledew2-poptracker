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
    if has("region-gates") then
        if region == "fields" then
            return true
        elseif region == "coast" then
            return (
                has("access-coast")
                or has("connect-fields-coast")
                or (has("access-slope") and has("connect-coast-slope"))
                or (has("access-woods") and has("connect-coast-woods"))
                or (has("access-ruins") and has("connect-coast-ruins"))
            )
        elseif region == "ruins" then
            return (
                has("access-ruins")
                or has("connect-fields-ruins")
                or (has("access-coast") and has("connect-coast-ruins"))
                or (has("access-woods") and has("connect-ruins-woods"))
                or (has("access-prairie") and has("connect-ruins-prairie"))
                or (has("access-court") and has("connect-ruins-court"))
            )
        elseif region == "woods" then
            return (
                has("access-woods")
                or has("connect-fields-woods")
                or (has("access-coast") and has("connect-coast-woods"))
                or (has("access-ruins") and has("connect-ruins-woods"))
                or (has("access-court") and has("connect-woods-court"))
            )
        elseif region == "slope" then
            return (
                has("access-slope")
                or has("connect-fields-slope")
                or (has("access-coast") and has("connect-coast-slope"))
                or (has("access-prairie") and has("connect-slope-prairie"))
            )
        elseif region == "prairie" then
            return (
                has("access-prairie")
                or has("connect-fields-prairie")
                or (has("access-ruins") and has("connect-ruins-prairie"))
                or (has("access-slope") and has("connect-slope-prairie"))
            )
        elseif region == "court" then
            return (
                (has("access-court") and (has("access-ruins") or (has("access-woods") and weapon())))
                or (has("access-ruins") and has("connect-ruins-court"))
                or (has("access-woods") and has("connect-woods-court") and weapon())
            )
        elseif region == "road" then
            return (
                (has("access-slope") and has("access-road"))
                or (has("access-slope") and has("connect-slope-road"))
            )
        end
    else  -- no region gates, everything is open
        return true
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
        if has("sword") and has("icering") and has("forcewand") then
            return keys("dream2", 3)
        elseif has("sword") and has("icering") then
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
            -- force jump across the shifting room
            has("icering") and has("wand")
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
            -- force jump across the shifting room - it's in logic!
            has("icering") and has("wand")
        ) or (
            has("dynamite") and has("icering") and realkeys("dream3", 1)
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
        return (has("stick") or has("force")) and keys("dream4", 4)
    else
        return keys("dream4", 4)
    end
end

function antigramCompletableInLogic()
    if not antigram() then
        return false
    elseif has("dreams-keep-items") then
        local crystalhit = has("force") or has("mace") or (has("stick") and has("chain"))
        return crystalhit and realkeys("dream4", 4)
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
        and (has("open-dream") or has("mace"))
    )
end

function quietus_in_logic()
    return (
        wizardryCompletableInLogic()
        and bottomlessCompletableInLogic()
        and syncopeCompletableInLogic()
        and antigramCompletableInLogic()
        and quietus()
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

function shard_req()
    if has("shard-req-12") then return 12
    elseif has("shard-req-8") then return 8
    elseif has("shard-req-4") then return 4
    else return 0
    end
end

function shard8()
    return has("shard", shard_req())
end

function shard16()
    return has("shard", 2 * shard_req())
end

function shard24()
    return has("shard", 3 * shard_req())
end

function forbidden()
    return has("forbiddenkey", 4) or has("open-tomb")
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