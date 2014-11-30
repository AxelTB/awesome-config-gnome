local wibox     = require( "wibox"                   )
local awful     = require( "awful"                   )
local rad_tag   = require( "radical.impl.common.tag" )
local beautiful = require( "beautiful"               )
local radical   = require( "radical"                 )
local rad_task  = require( "radical.impl.tasklist"   )
local chopped   = require( "chopped"                 )
local collision = require( "collision"               )

local endArrowR2,endArrow_alt

local function new(c)
    if not endArrowR2 then
        endArrowR2      = chopped.get_separator {
            weight      = chopped.weight.FULL                       ,
            direction   = chopped.direction.LEFT                    ,
            sep_color   = nil                                       ,
            left_color  = nil                                       ,
            right_color = beautiful.bar_bg_alternate or beautiful.bg_alternate                    ,
        }

        endArrow_alt    = chopped.get_separator {
            weight      = chopped.weight.FULL                       ,
            direction   = chopped.direction.RIGHT                   ,
            sep_color   = nil                                       ,
            left_color  = beautiful.bar_bg_alternate or beautiful.bg_alternate                    ,
            right_color = nil                                       ,
        }
    end

    -- Create a resize handle
    local resize_handle = wibox.widget.imagebox()
    resize_handle:set_image(beautiful.titlebar_resize)
    resize_handle:buttons( awful.util.table.join(
        awful.button({ }, 1, function(geometry)
            collision._resize.mouse_resize(c)
        end))
    )

    local tag_selector = wibox.widget.imagebox()
    tag_selector:set_image(beautiful.titlebar_tag)
    tag_selector:buttons( awful.util.table.join(

        awful.button({ }, 1, function(geometry)

            local m,tag_item = rad_tag({checkable=true,
            button1 = function(i,m)
                awful.client.toggletag(i._tag,c)
                i.checked = not i.checked
            end})
            for k,t in ipairs(c:tags()) do
                if tag_item[t] then
                    tag_item[t].checked = true
                end
            end
            m.parent_geometry = geometry
            m.visible = true
        end))
    )

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    local labels = {"Floating","Maximize","Sticky","On Top","Close"}
    for k,v in ipairs({awful.titlebar.widget.floatingbutton(c) , awful.titlebar.widget.maximizedbutton(c), awful.titlebar.widget.stickybutton(c),
        awful.titlebar.widget.ontopbutton(c), awful.titlebar.widget.closebutton(c)}) do
        right_layout:add(v)
        radical.tooltip(v,labels[k],{})
    end

    -- The title goes in the middle
    local buttons = awful.util.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
    )

    local title = awful.titlebar.widget.titlewidget(c)

    title.draw = function(self,w, cr, width, height)
        local i = rad_task.item(c)
        if i and i.widget then
            local w2,h2 = i.widget:fit(width,height)
            cr:save()
            cr:reset_clip()
            cr:translate((width-w2)/2, 0)
            i.widget.draw(i.widget,w, cr, w2, height)
            cr:restore()
        end
    end


    -- Now bring it all together
    local layout = wibox.layout.align.horizontal()
    if layout.set_expand then
        layout:set_expand("inside")
    else
        title.fit = function(self,w,h)
            return w,h
        end
    end

    local tb = awful.titlebar(c,{size=beautiful.titlebar_height or 16})

    -- Setup titlebar widgets
    tb:set_widgets {
        { --Left
            {
                {
                    resize_handle,
                    tag_selector ,
                },
                layout = wibox.widget.background(nil,beautiful.bar_bg_alternate or beautiful.bg_alternate)
            },
            endArrow_alt,
        },
        title, -- Center
        { --Right
            endArrowR2,
            {
                right_layout,
                layout = wibox.widget.background(nil,beautiful.bar_bg_alternate or beautiful.bg_alternate)
            }
        },
        layout = layout
    }

    tb.title_wdg = title
    title:buttons(buttons)
    local underlays = {}
    for k,v in ipairs(c:tags()) do
        underlays[#underlays+1] = v.name
    end
    title:set_underlay(underlays,{style=radical.widgets.underlay.draw_arrow,alpha=1,color="#0C2853"})
end

return setmetatable({}, { __call = function(_, ...) return new(...) end })