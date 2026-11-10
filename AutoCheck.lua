-- AutoCheck: automatic /check for the current, stable monster target.
-- Packet construction follows DSGarrett's MIT-licensed ImpossibleGauge.
_addon.name = 'AutoCheck'
_addon.author = 'A'
_addon.version = '0.1.1'
_addon.commands = {'ac', 'autocheck'}

local config = require('config')
local packets = require('packets')
require('chat')

local defaults = {
    enabled = true,
    delay_ms = 350,       -- Time a monster must remain selected before checking.
    interval = 1.0,      -- Minimum seconds between auto-check packets.
    memory = false,      -- When enabled, check each monster ID only once per zone.
}
local settings = config.load(defaults)

local checked = {}        -- Zone-wide history, used only when memory is on.
local selection_checked = false -- Each uninterrupted target selection is checked once.
local pending_id = nil    -- Only the currently selected monster can be pending.
local pending_since = 0
local last_sent = -math.huge
local last_zone = nil

local function say(message)
    windower.add_to_chat(200, '[AutoCheck] ' .. message)
end

local function clear_pending()
    pending_id = nil
    pending_since = 0
    selection_checked = false
end

local function reset_tracking()
    checked = {}
    clear_pending()
    last_sent = -math.huge
end

local function is_monster(mob)
    return mob and mob.id and mob.id > 0 and mob.index
        and mob.spawn_type == 16 and mob.valid_target
        and mob.hpp and mob.hpp > 0
end

-- The /check request is independent of the game's currently selected target.
-- Adapted from ImpossibleGauge's send_check, without its scanning queue.
local function send_check(mob)
    packets.inject(packets.new('outgoing', 0x0DD, {
        ['Target'] = mob.id,
        ['Target Index'] = mob.index,
        ['Check Type'] = 0,
    }))
end

local function show_help()
    windower.add_to_chat(0, string.color('---------- AutoCheck ----------', 140))
    windower.add_to_chat(0, string.color('AutoCheck', 167) .. '  Current-target /check only')
    local lines = {
        {'on', 'Enable automatic checks'},
        {'off', 'Disable automatic checks'},
        {'delay <milliseconds>', 'Set target settle delay (0-2000; default 350)'},
        {'interval <seconds>', 'Set minimum time between checks (1-30; default 1)'},
        {'memory on|off', 'Remember checked monster IDs until zoning (default off)'},
        {'reset', 'Clear checked monster history and pending selection'},
        {'status', 'Show current settings and target state'},
        {'restart', 'Restart this addon'},
        {'unload', 'Unload this addon'},
        {'help', 'Show this command list'},
    }
    for _, line in ipairs(lines) do
        windower.add_to_chat(0,
            string.color('//ac', 200) .. ' ' .. string.color(line[1], 207) ..
            string.color(' -> ', 200) .. line[2])
    end
end

local function show_status()
    local count = 0
    for _ in pairs(checked) do count = count + 1 end
    say(('v%s | %s | delay=%dms | interval=%.1fs | memory=%s | checked=%d | pending=%s')
        :format(_addon.version, settings.enabled and 'ON' or 'OFF',
            settings.delay_ms, settings.interval, settings.memory and 'ON' or 'OFF', count,
            pending_id and tostring(pending_id) or 'none'))
end

windower.register_event('prerender', function()
    if not settings.enabled then return end

    local info = windower.ffxi.get_info()
    if not info or not info.logged_in then
        clear_pending()
        return
    end

    -- Account for zones changing before the zone-change callback arrives.
    if info.zone ~= last_zone then
        last_zone = info.zone
        reset_tracking()
    end

    local now = os.clock()
    local target = windower.ffxi.get_mob_by_target('t')
    local id = is_monster(target) and target.id or nil

    -- A new selection starts a fresh settle timer; clearing target cancels it.
    if id ~= pending_id then
        pending_id = id
        pending_since = now
        selection_checked = false
    end

    -- Memory off: revisit a monster after targeting something else. Never spam
    -- the same uninterrupted selection, even at delay=0.
    if not id or selection_checked or (settings.memory and checked[id]) then return end
    if (now - pending_since) < settings.delay_ms / 1000 then return end
    if (now - last_sent) < settings.interval then return end

    -- Revalidate just before packet injection, preventing stale-target checks.
    local fresh = windower.ffxi.get_mob_by_target('t')
    if not is_monster(fresh) or fresh.id ~= id or fresh.index ~= target.index then
        clear_pending()
        return
    end

    -- ImpossibleGauge reports ~50y check range; avoid out-of-range packets.
    local me = windower.ffxi.get_mob_by_target('me')
    if not me or not me.x or not me.y or not me.z
        or not fresh.x or not fresh.y or not fresh.z then return end
    local dx = fresh.x - me.x
    local dy = fresh.y - me.y
    local dz = fresh.z - me.z
    if dx * dx + dy * dy + dz * dz > 50 * 50 then return end

    send_check(fresh)
    selection_checked = true
    if settings.memory then checked[id] = true end
    last_sent = now
end)

windower.register_event('zone change', function(new_zone)
    last_zone = new_zone
    reset_tracking()
end)

windower.register_event('logout', function()
    last_zone = nil
    reset_tracking()
end)

windower.register_event('addon command', function(command, argument)
    command = (command or ''):lower()
    if command == 'on' or command == 'off' then
        settings.enabled = command == 'on'
        clear_pending()
        config.save(settings)
        say(settings.enabled and 'enabled' or 'disabled')
    elseif command == 'delay' then
        local n = tonumber(argument)
        if not n or n < 0 or n > 2000 then
            say('Usage: //ac delay <0-2000 milliseconds>')
            return
        end
        settings.delay_ms = math.floor(n + 0.5)
        clear_pending()
        config.save(settings)
        say(('delay set to %dms'):format(settings.delay_ms))
    elseif command == 'interval' then
        local n = tonumber(argument)
        if not n or n < 1 or n > 30 then
            say('Usage: //ac interval <1-30 seconds>')
            return
        end
        settings.interval = n
        config.save(settings)
        say(('interval set to %.1fs'):format(n))
    elseif command == 'memory' then
        local mode = (argument or ''):lower()
        if mode ~= 'on' and mode ~= 'off' then
            say('Usage: //ac memory on|off')
            return
        end
        settings.memory = mode == 'on'
        if not settings.memory then
            -- Disabling memory should not recheck the current selection immediately.
            if pending_id and checked[pending_id] then selection_checked = true end
            checked = {}
        end
        config.save(settings)
        say(settings.memory and 'monster memory enabled' or 'monster memory disabled')
    elseif command == 'reset' then
        reset_tracking()
        say('checked-monster history cleared')
    elseif command == 'status' then
        show_status()
    elseif command == 'restart' then
        say('restarting')
        windower.send_command('lua r AutoCheck')
    elseif command == 'unload' then
        say('unloading')
        windower.send_command('lua u AutoCheck')
    else
        if command ~= '' and command ~= 'help' then say('Unknown command: ' .. command) end
        show_help()
    end
end)
