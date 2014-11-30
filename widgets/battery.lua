local print = print
local io,math = io,math
local tostring,tonumber = tostring,tonumber
local color     = require( "gears.color"              )
local cairo     = require( "lgi"                      ).cairo
local gio       = require( "lgi"                      ).Gio
local wibox     = require( "wibox"                    )
local beautiful = require( "beautiful"                )

local capi = {timer=timer}

--Save config
local batConfig={batId=0,batTimeout=15}
local batStatus={state,rate,fullDesign,fullReal}

local battery_state = {
    ["Full"]        = "↯", ["Unknown"]     = "?",
    ["Charged"]     = "↯", ["Charging"]    = "⌁",
    ["Discharging"] = "",  ["Empty"] = "x"
}


local function set_value(self,value)
    self._value = value
    self:emit_signal("widget::updated")
end

local function fit(self,width,height)
    return width > (height * 1.5) and (height * 1.5) or width,height
end

local function draw(self,w,cr,width,height)
    cr:save()
    cr:set_source(color(beautiful.icon_grad or beautiful.fg_normal))
    cr:paint()
    local ratio = height / 10
    cr:set_source(color(beautiful.bg_alternate or beautiful.bg_normal))
    cr:rectangle(ratio,2*ratio,width-4*ratio,height-4*ratio)
    cr:stroke()
    cr:rectangle(width-3*ratio,height/3,1.5*ratio,height/3)
    cr:fill()
    cr:rectangle(2*ratio,3*ratio,(width-6*ratio)*(self._value or 0),height-6*ratio)
    cr:fill()
    self._tooltip.text = ((self._value or 0)*100)..'%'
    cr:set_source_rgba(1,0,0,1)
    cr:set_font_size(30)
    local extents = cr:text_extents(battery_state[batStatus.state or "Unknown"] or '*')
    cr:move_to(ratio+(width-4*ratio)/2-extents.width/2,height/2+extents.height)
    cr:show_text(battery_state[batStatus.state or "Unknown"] or '*')
    cr:restore()
end

--Parses data from acpi and return the batStatus table
local function parseAcpi()
    local Status={state,rate,fullDesign,fullReal}
    --Parse initial data
    local pipe0 = io.popen("acpi -V | grep 'Battery "..batConfig.batId.."..'| cut -d':' -f2")
    local buffer = pipe0:read("*all")
    pipe0:close()

    if #buffer == 0 then
        print("No Battery")
        Status.state="Empty"
    else
        local data=buffer:split(",")
        if #data ~= 4 then print("Acpi output parsing problem:'",buffer,"'")
        else
            Status.state=data[1]:match("%a+")
            Status.rate=string.match(data[2],"%d+")
            Status.fullDesign=string.match(data[3],"%d+ mAh"):match("%d+")
            Status.fullReal=string.match(data[4],"%d+ mAh"):match("%d+")
            --print("BatStatus:\n\tState: '"..batStatus.state.."'\n\tRate: "..batStatus.rate.."\n\tFullD:"..batStatus.fullDesign.."\n\tFullR:"..batStatus.fullReal)
        end
    end

    return Status
end

local function timeout(wdg)
    batStatus=parseAcpi()
    if batStatus.state == "Empty" then
        --AXTODO: Signal no battery and reduce rate of update 
    end
    wdg:set_value((tonumber(batStatus.rate) or 0)/100)
    wdg:emit_signal("widget::updated")
end

---args={ battery_id, update_time}
---
---     battery_id: number of the visualized battery (Default 0)
---     update_time:    w idget update time in seconds (Default 15)
local function new(args)
    --If any argument parse 'em
    if args~=nil then
        batConfig.batId = args.battery_id or batConfig.batId
        batConfig.batTimeout = args.update_time or batConfig.batTimeout
    end

    --Parse initial data
    batStatus=parseAcpi()

    local ib = wibox.widget.base.empty_widget()


    ib.set_value = set_value
    ib.fit=fit
    ib.draw = draw
    ib:set_tooltip("100%")
    local t = capi.timer({timeout=batConfig.batTimeout})
    t:connect_signal("timeout",function() timeout(ib) end)
    t:start()
    timeout(ib)
    return ib
end

return setmetatable({}, { __call = function(_, ...) return new(...) end })
-- kate: space-indent on; indent-width 2; replace-tabs on;
