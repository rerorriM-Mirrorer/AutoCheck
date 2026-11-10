-- Mocked Windower regression for the published v0.1.1 candidate.
-- This is NOT a real Windower or FFXI client test.
local events, writes, injected = {}, {}, {}
local now, zone, active = 0, 100, nil
local settings
local function monster(id)
    return {id=id, index=id % 100, spawn_type=16, valid_target=true,
            hpp=100, x=1, y=2, z=3}
end
local me = {id=1, x=0, y=0, z=0}
local function eq(actual, expected, label)
    assert(actual == expected,
        (label or 'assert') .. ': expected ' .. tostring(expected) ..
        ', got ' .. tostring(actual))
end
local function tick(t)
    now = t
    if events.prerender then events.prerender() end
end
local function cmd(a,b)
    events['addon command'](a,b)
end
_addon = {}
os.clock = function() return now end
string.color = function(s) return s end
windower = {
    register_event=function(name,fn) events[name]=fn end,
    add_to_chat=function(_,s) writes[#writes+1]=s end,
    send_command=function(_) end,
    ffxi={
        get_info=function() return {logged_in=true,zone=zone} end,
        get_mob_by_target=function(tag) return tag=='me' and me or active end,
    },
}
package.preload.config = function()
    return {
        load=function(defaults) settings=defaults return settings end,
        save=function() end,
    }
end
package.preload.packets = function()
    return {
        new=function(_,id,fields) return {id=id,fields=fields} end,
        inject=function(packet) injected[#injected+1]=packet end,
    }
end
package.preload.chat = function() return {} end
dofile('AutoCheck.lua')
eq(settings.memory,false,'memory defaults OFF')
active = monster(101)
tick(0); tick(.36)
eq(#injected,1,'initial check')
eq(injected[1].id,0x0DD,'check packet ID')
eq(injected[1].fields['Target'],101,'check target')
tick(.8); tick(1.4)
eq(#injected,1,'no repeated continuous-selection check')
active = monster(102)
tick(1.5); tick(2)
eq(#injected,2,'new monster')
active = monster(101)
tick(2.1); tick(2.6)
eq(#injected,2,'global throttle')
tick(3.1)
eq(#injected,3,'revisit with memory OFF')
cmd('memory','on')
eq(settings.memory,true,'memory ON')
active = monster(103)
tick(4); tick(4.4)
eq(#injected,4,'memory ON first selection')
active = monster(104)
tick(4.5); tick(5.5)
eq(#injected,5,'memory ON second monster')
active = monster(103)
tick(5.6); tick(6.8)
eq(#injected,5,'memory ON prevents revisits')
cmd('memory','off')
eq(settings.memory,false,'memory OFF again')
tick(7)
eq(#injected,5,'no immediate duplicate on mode change')
active = nil; tick(7.1)
active = monster(103); tick(7.2); tick(8)
eq(#injected,6,'OFF permits next target selection')
cmd('delay','0')
eq(settings.delay_ms,0,'zero delay')
active = monster(105); tick(9.1)
eq(#injected,7,'zero-delay check')
tick(9.2); tick(10.2)
eq(#injected,7,'zero-delay hold does not spam')
print('AutoCheck v0.1.1: PASS (mocked packet/selection/memory/timing)')
