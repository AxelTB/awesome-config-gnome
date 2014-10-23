
-- Gears
local gears  = require( "gears"       )
local cairo  = require( "lgi"         ).cairo
local color  = require( "gears.color" )
local glib   = require( "lgi"         ).GLib
local config = require( "forgotten"   )
local utils  = require( "utils"       )
require("retrograde")

-- Awful
local awful      = require( "awful"       )
awful.rules      = require( "awful.rules" )
local wibox      = require( "wibox"       )
local tyrannical = require( "tyrannical"  )
require("awful.autofocus")

-- Shortcuts
require( "tyrannical.shortcut" )
require( "repetitive"          )

-- Theme handling library
local beautiful = require( "beautiful" )
local blind     = require( "blind"     )

-- Widgets
local menubar      = require( "menubar"                    )
local customButton = require( "customButton"               )
local customMenu   = require( "customMenu"                 )
local drawer       = require( "drawer"                     )
local widgets      = require( "widgets"                    )
local radical      = require( "radical"                    )
local rad_task     = require( "radical.impl.tasklist"      )
local rad_taglist  = require( "radical.impl.taglist"       )
local collision    = require( "collision"                  )
local alttab       = require( "radical.impl.alttab"        )
local rad_client   = require( "radical.impl.common.client" )
local rad_tag      = require( "radical.impl.common.tag"    )


-- Data sources
local naughty       = require( "naughty"                  )
local notifications = require( "extern.notifications"     )
local vicious       = require( "extern.vicious"           )
-- local wirefu     = require( "wirefu.demo.notification" )

-- Hardware
local wacky = require("wacky")

require("runOnce")
--local rad_client = require("radical.impl.common.client")

-- utils.profile.start()
-- debug.sethook(utils.profile.trace, "crl", 1)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end
-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}
vicious.cache( vicious.widgets.net )
vicious.cache( vicious.widgets.fs  )
vicious.cache( vicious.widgets.dio )
vicious.cache( vicious.widgets.cpu )
vicious.cache( vicious.widgets.mem )
vicious.cache( vicious.widgets.dio )

-- Various configuration options
config.showTitleBar  = false
config.themeName     = "arrow"
config.noNotifyPopup = true
config.useListPrefix = true
config.deviceOnDesk  = true
config.desktopIcon   = true
config.advTermTB     = true
config.scriptPath    = awful.util.getdir("config") .. "/Scripts/"
config.scr           = {
    pri         = 1,
    sec         = 3,
    music       = 4,
    irc         = 2,
    media       = 5,
}


-- Load the theme
config.load()
config.themePath = awful.util.getdir("config") .. "/blind/" .. config.themeName .. "/"
config.iconPath  = config.themePath       .. "Icon/"

beautiful.init(config.themePath                .. "/themeSciFi.lua")

local titlebars_enabled = beautiful.titlebar_enabled == nil and true or beautiful.titlebar_enabled

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
-- beautiful.init(awful.util.getdir("config").."/blind/arrow/themeSciFi.lua")

-- This is used later as the default terminal and editor to run.
terminal = "urxvtc"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
-- Allow personal.lua file to overload some settingsS
require('personal')
-- Table of layouts to cover with awful.layout.inc, order matters.

local layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
--     awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
local layouts_all =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
--     awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}

-- Add Collision shortcuts
collision()

movetagL,movetagR = {}, {}

dofile(awful.util.getdir("config") .. "/baseRule.lua")

-- Create the "Show Desktop" icon
local desktopPix             = customButton.showDesktop ( nil                                )

-- Create the clock
local clock                  = drawer.dateInfo          ( nil                                )
clock.bg                     = beautiful.bg_alternate

-- Create the volume box
local soundWidget            = drawer.soundInfo         ( 300                                )

-- Create the net manager
local netinfo                = drawer.netInfo           ( 300                                )

-- Create the memory manager
local meminfo                = drawer.memInfo           ( 300                                )

-- Create the cpu manager
local cpuinfo                = drawer.cpuInfo           ( 300                                )

-- Create the laucher dock
local lauchDock              = widgets.dock             ( nil , {position="left",default_cats={"Tools","Development","Network","Player"}})

-- Create the laucher dock
local endArrow               = blind.common.drawing.get_beg_arrow_wdg2({bg_color=beautiful.icon_grad })
-- Create the laucher dock
local endArrow_alt           = blind.common.drawing.get_beg_arrow_wdg2({bg_color=beautiful.bg_alternate})
local endArrow_alt2i         = cairo.ImageSurface(cairo.Format.ARGB32, beautiful.default_height/2+2, beautiful.default_height)
local cr = cairo.Context(endArrow_alt2i)
cr:set_source_surface(blind.common.drawing.get_beg_arrow2({bg_color=beautiful.bg_alternate}))
cr:paint()
cr:set_source(color(beautiful.icon_grad or beautiful.fg_normal))
cr:set_line_width(1.5)
cr:move_to(0,-2)
cr:line_to(beautiful.default_height/2,beautiful.default_height/2)
cr:line_to(0,beautiful.default_height+2)
cr:stroke()
local endArrow_alt2 = wibox.widget.imagebox()
endArrow_alt2:set_image(endArrow_alt2i)

-- Create battery
local bat = widgets.battery()

-- Create notifications history
local notif = notifications()

-- Create keyboard layout manager
local keyboard = widgets.keyboard()

-- Imitate the Gnome 2 menubar
local bar_menu,bar_menu_w = radical.bar{item_style=radical.item.style.arrow_prefix,fg=beautiful.fg_normal,fg_focus=beautiful.menu_fg_normal,disable_submenu_icon=true}

local app_menu = nil
bar_menu:add_item {text="Apps",icon=gears.color.apply_mask(beautiful.awesome_icon,beautiful.button_bg_normal or beautiful.bg_normal),tooltip="Application menu",sub_menu = function()
    if not app_menu then
        app_menu = customMenu.appmenu({filter = true, showfilter = true, y = screen[1].geometry.height - 18, x = offset, 
            autodiscard = true,has_decoration=false,x=0,filtersubmenu=true,maxvisible=20,style=radical.style.classic,item_style=radical.item.style.classic,
            show_filter=true},{maxvisible=20,style=radical.style.classic,item_style=radical.item.style.classic})
        end
    return app_menu
end}
bar_menu:add_item {text="Places",
    icon=gears.color.apply_mask(config.iconPath .. "tags/home.png",
    beautiful.button_bg_normal or beautiful.bg_normal),tooltip="Folder shortcuts",sub_menu = customMenu.places.get_menu}
bar_menu:add_item {text="Launch",
    icon=gears.color.apply_mask(config.iconPath .. "gearA.png", beautiful.button_bg_normal or beautiful.bg_normal),
    tooltip="Execute a command", sub_menu = customMenu.launcher.get_menu}

bar_menu_w.__draw = bar_menu_w.draw

local arr = blind.common.drawing.get_end_arrow2({bg_color= beautiful.icon_grad or beautiful.fg_normal})
bar_menu_w.draw = function(self,w, cr, w2, height)
    bar_menu_w.__draw(self,w, cr, w2, height)
    cr:set_source_surface(arr,w2-height/2,0)
    cr:paint()
end

-- End arrow
local endArrowR = wibox.widget.imagebox()

local endArrowR2i         = cairo.ImageSurface(cairo.Format.ARGB32, beautiful.default_height/2+2, beautiful.default_height)
local cr = cairo.Context(endArrowR2i)
cr:set_source_surface(blind.common.drawing.get_beg_arrow2({bg_color=beautiful.bg_alternate ,direction="left"}),2,0)
cr:paint()
cr:set_source(color(beautiful.icon_grad or beautiful.fg_normal))
cr:set_line_width(1.5)
cr:move_to(beautiful.default_height/2+2,-2)
cr:line_to(2,beautiful.default_height/2)
cr:line_to(beautiful.default_height/2+2,beautiful.default_height+2)
cr:stroke()

endArrowR:set_image(endArrowR2i)
local endArrowR2 = wibox.widget.imagebox()
endArrowR2:set_image(blind.common.drawing.get_beg_arrow2({bg_color=beautiful.bg_alternate ,direction="left"}),2,0)

rad_taglist.taglist_watch_name_changes = true

-- Create the addTag icon (depend on shifty rule)
local addTag                 = customButton.addTag                      ( nil )

-- Create the addTag icon (depend on shifty rule)
local lockTag                 = {}

-- Create the keyboard layout switcher, feel free to add your contry and push it to master

-- local keyboardSwitcherWidget = widgets.keyboardSwitcher ( nil                                )

-- Load the desktop "conky" widget
-- widgets.desktopMonitor(screen.count() == 1 and 1 or 2)

--Some spacers with dirrent text
spacer5 = widgets.spacer({text = " ",width=5})
local spacer_img = blind.common.drawing.separator_widget()

local arr_last_tag = blind.common.drawing.get_end_arrow2({ bg_color=beautiful.bg_alternate })
local cr = cairo.Context(arr_last_tag)
cr:set_source(color(beautiful.icon_grad or beautiful.fg_normal))
cr:set_line_width(1.5)
cr:move_to(0,-2)
cr:line_to(beautiful.default_height/2,beautiful.default_height/2)
cr:line_to(0,beautiful.default_height+2)
cr:stroke()
local arr_last_tag_w = wibox.widget.base.make_widget()
arr_last_tag_w.fit=function(s,w,h)
    return 0,h
end
-- Use negative offset
arr_last_tag_w.draw = function(self, w, cr, width, height)
    cr:save()
    cr:reset_clip()
    cr:set_source_surface(arr_last_tag,-beautiful.default_height/2-1,0)
    cr:paint()
    cr:restore()
end

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

local prev_menu,prev_item = nil

beautiful.on_tag_hover = customMenu.taghover

alttab.default_icon   = config.iconPath .. "tags/other.png"
alttab.titlebar_path  = config.themePath.. "Icon/titlebar/"

-- Create a wibox for each screen and add it
wibox_top   = {}
wibox_bot   = {}
mypromptbox = {}
mytaglist   = {}
layoutmenu  = {}
delTag      = {}

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create a taglist widget

    -- Create the delTag button
    delTag[s]     = customButton.delTag   ( s                                               )
    lockTag[s]    = customButton.lockTag                      ( s )

    -- Create the button to move a tag the next screen
    movetagL[s]   = customButton.tagmover(s,{ direction = "left",  icon = config.iconPath .. "tags/screen_left.png"  })
    movetagR[s]   = customButton.tagmover(s,{ direction = "right", icon = config.iconPath .. "tags/screen_right.png" })

    -- Create the layout menu for this screen
    layoutmenu[s] = customMenu.layoutmenu ( s,layouts_all                                   )

    -- Create the wibox
    wibox_top[s] = awful.wibox({ position = "top"   , ontop=false,screen = s,height=beautiful.default_height , bg = beautiful.bg_wibar or beautiful.bg_normal })
    wibox_bot[s] = awful.wibox({ position = "bottom", ontop=false,screen = s,height=beautiful.default_height , bg = beautiful.bg_wibar or beautiful.bg_normal })

    local endArrow2 = wibox.widget.imagebox()
    endArrow2:set_image(blind.common.drawing.get_beg_arrow2({bg_color=beautiful.icon_grad,direction="left"}))


    -- Top Wibox
    wibox_top[s]:set_widgets {
        { --Left
            rad_taglist(s)._internal.margin, --Taglist
            { -- Tag control buttons
                {
                    {
                        arr_last_tag_w,
                        addTag        ,
                        delTag     [s],
                        lockTag    [s],
                        movetagL   [s],
                        movetagR   [s],
                        layoutmenu [s],
                        layout = wibox.layout.fixed.horizontal
                    },
                    layout = wibox.layout.margin(nil,1,4,0,0)
                },
                layout = wibox.widget.background(nil,beautiful.bg_alternate)
            }, --Buttons
            endArrow_alt2           , --Separator
            layout = wibox.layout.fixed.horizontal
        },
        nil, --Center
        (s == config.scr.pri or s == config.scr.sec) and { -- Right, first screen only
            endArrowR,
            { -- The background
                { -- The widgets
                    spacer5    ,
                    cpuinfo    ,
                    spacer_img ,
                    meminfo    ,
                    spacer_img ,
                    netinfo    ,
                    spacer_img ,
                    soundWidget,
                    spacer_img ,
                    clock      ,
                },
                layout = wibox.widget.background(nil,beautiful.bg_alternate)
            },
            layout = wibox.layout.fixed.horizontal
        } or nil,
        layout = wibox.layout.align.horizontal
    }

    -- Bottom Wibox
    wibox_bot[s]:set_widgets {
        { --Left
            bar_menu_w     ,
            mypromptbox[s] ,
            desktopPix     ,
            runbg          ,
            endArrow       ,
            layout = wibox.layout.fixed.horizontal,
        },
        rad_task(s or 1)._internal.margin, --Center
        {
            endArrow2                                ,
            { -- Right
                {
                    keyboard                         ,
                    notif                            ,
                    bat                              ,
                    s == 1 and wibox.widget.systray(),
                },
                layout = wibox.widget.background(nil,beautiful.icon_grad or beautiful.fg_normal),
            },
        },
        layout = wibox.layout.align.horizontal
    }

end
-- }}}

-- Add the drives list on the desktop
if config.deviceOnDesk == true then
--   widgets.devices()
end
if config.desktopIcon == true then
--     for i=1,20 do
--         widgets.desktopIcon()
--     end
end

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ "Mod1"            }, "space",  widgets.keyboard.quickswitchmenu),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function() wacky.select_rect(10) end),
    awful.key({ modkey, "Shift"   }, "w", function() wacky.focussed_client(10) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab"   , function () alttab.altTab()          end ),
    awful.key({ modkey, "Shift"   }, "Tab"   , function () alttab.altTabBack()      end ),
    awful.key({ "Mod1",           }, "Tab"   , function () alttab.altTab({auto_release=true})          end ),
    awful.key({ "Mod1", "Shift"   }, "Tab"   , function () alttab.altTabBack({auto_release=true})      end ),
    awful.key({ modkey, "Control" }, "Tab"   , function () customButton.lockTag.show_menu()      end ),

    -- Standard program
    awful.key({         "Control" }, "Escape", function () awful.util.spawn("xkill")    end ),
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal)   end ),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () customMenu.layoutmenu.centered_menu(layouts) end),
    awful.key({ modkey, "Shift"   }, "space", function () customMenu.layoutmenu.centered_menu(layouts,true) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),
    awful.key({ "Control", "Mod1" }, "#143",  awful.tag.viewnext),
    awful.key({ "Control", "Mod1" }, "#136",  awful.tag.viewprev),
    --220 143 209

    --Switch screen
    --              MODIFIERS         KEY                        ACTION                               
    awful.key({                   }, "#179"  , function () utils.mouseManager.switchTo(3)       end ),
    awful.key({                   }, "#175"  , function () utils.mouseManager.switchTo(4)       end ),
    awful.key({                   }, "#176"  , function () utils.mouseManager.switchTo(5)       end ),
    awful.key({                   }, "#178"  , function () utils.mouseManager.switchTo(1)       end ),
    awful.key({                   }, "#177"  , function () utils.mouseManager.switchTo(2)       end ),

    -- Prompt
    awful.key({ modkey },            "r",
              function ()
                  awful.prompt.run({ prompt = "Run: ", hooks = {
                      {{         },"Return",function(command)
                          local result = awful.util.spawn(command)
                          mypromptbox[mouse.screen].widget:set_text(type(result) == "string" and result or "")
                          return true
                      end},
                      {{"Mod1"   },"Return",function(command)
                          local result = awful.util.spawn(command,{intrusive=true})
                          mypromptbox[mouse.screen].widget:set_text(type(result) == "string" and result or "")
                          return true
                      end},
                      {{"Shift"  },"Return",function(command)
                          local result = awful.util.spawn(command,{intrusive=true,ontop=true,floating=true})
                          mypromptbox[mouse.screen].widget:set_text(type(result) == "string" and result or "")
                          return true
                      end}
                  }},
                  mypromptbox[mouse.screen].widget,
                  function (com)
                          local result = awful.util.spawn(com)
                          if type(result) == "string" then
                              mypromptbox[mouse.screen].widget:set_text(result)
                          end
                          return true
                  end, awful.completion.shell,
                  awful.util.getdir("cache") .. "/history")
              end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end),

    --Custom
    awful.key({ modkey,"Control" }, "p", function() 
        utils.profile.start()
        debug.sethook(utils.profile.trace, "crl", 1)
    end),
    awful.key({ modkey,"Control","Shift" }, "p", function() 
        debug.sethook()
        utils.profile.stop(_G)
    end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
--     awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "y",      function (c) collision.resize.display(c,true) end),
    awful.key({ modkey,           }, "m",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 10 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      local tag = awful.tag.gettags(client.focus.screen)[i]
                      if client.focus and tag then
                          awful.client.movetotag(tag)
                     end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      local tag = awful.tag.gettags(client.focus.screen)[i]
                      if client.focus and tag then
                          awful.client.toggletag(tag)
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "Conky" },
      properties = { border_width = 0,
                     border_color = beautiful.border_normal,} },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    --Fix some wierd reload bugs
    if c.size_hints.user_size and startup then
        c:geometry({width = c.size_hints.user_size.width,height = c.size_hints.user_size.height, x = c:geometry().x})
    end
    if c.size_hints.max_height and c.size_hints.max_height < screen[c.screen].geometry.height/2 then
        awful.client.setslave(c)
    end
    if not c.size_hints.user_position and not c.size_hints.program_position then
        awful.placement.no_overlap(c)
        awful.placement.no_offscreen(c)
    end

    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then

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
                    layout = wibox.widget.background(nil,beautiful.bg_alternate)
                },
                endArrow_alt,
            },
            title, -- Center
            { --Right
                endArrowR2,
                {
                    right_layout,
                    layout = wibox.widget.background(nil,beautiful.bg_alternate)
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
end)


client.connect_signal("tagged",function(c)
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        local tb = awful.titlebar(c,{size=beautiful.titlebar_height or 16})
        if tb and tb.title_wdg then
            local underlays = {}
            for k,v in ipairs(c:tags()) do
                underlays[#underlays+1] = v.name
            end
            tb.title_wdg:set_underlay(underlays,{style=radical.widgets.underlay.draw_arrow,alpha=1,color="#0C2853"})
        end
    end
end)

client.connect_signal("focus", function(c) 
    local tb = c:titlebar_top()
    if tb and tb.title_wdg then
        tb.title_wdg.data.image = beautiful.taglist_bg_image_selected
    end
    if not c.class == "URxvt" then
        c.border_color = beautiful.border_focus
    end
end)
client.connect_signal("unfocus", function(c)
    local tb = c:titlebar_top()
    if tb and tb.title_wdg then
        tb.title_wdg.data.image = beautiful.tasklist_bg_image_selected or beautiful.taglist_bg_image_used
    end
    if not c.class == "URxvt" then
        c.border_color = beautiful.border_normal
    end
end)

-- When setting a client as "slave", use the first available slot instead of the last
awful.client._setslave = awful.client.setslave
function awful.client.setslave(c)
    local t = awful.tag.selected(c.screen)
    local nmaster = awful.tag.getnmaster(t) or 1
    local cls = awful.client.tiled(c.screen) or client.get(c.screen)
    local index = awful.util.table.hasitem(cls,c)
    if index and index <= nmaster and #cls > nmaster then
        c:swap(cls[nmaster+1])
    else
        awful.client._setslave(c)
    end
end

-- }}}
-- debug.sethook()
-- utils.profile.stop(_G)
-- widgets.radialSelect.radial_client_select()
--print("start")
--utils.fd_async.exec_command_async("/tmp/test.sh"):connect_signal("request::completed",function(content)
--    print("content",content)
--end)

-- utils.fd_async.download_text_async("http://www.google.com"):connect_signal("request::completed",function(content)
--     print("c2",content)
-- end)
-- print("HONORING",awesome.honor_ewmh_desktop,awesome.font_height,awesome.font)
-- awesome.honor_ewmh_desktop = false
-- client.add_signal("property::shape_bounding")
-- drawable.add_signal("property::shape_bounding")


-- print("test")
-- glib.idle_add(glib.PRIORITY_DEFAULT_IDLE, function() print("foo") end)
-- print("test2")


require("radical.impl.tasklist.extensions").add("Running time",function(client)
    local w = wibox.widget.base.make_widget()
    w.fit = function(_,w,h)
        return radical.widgets.underlay.fit("foo",{bg="#ff0000"}),h
    end
    w.draw = function(self, w, cr, width, height)
        cr:set_source_surface(radical.widgets.underlay.draw("foo",{bg=beautiful.fg_normal,height=beautiful.default_height}))
        cr:paint()
    end
    return w
end)

require("radical.impl.tasklist.extensions").add("Machine",function(client)
    local w = wibox.widget.base.make_widget()
    w.fit = function(_,w,h)
        return radical.widgets.underlay.fit(client.machine,{bg="#ff0000"}),h
    end
    w.draw = function(self, w, cr, width, height)
        cr:set_source_surface(radical.widgets.underlay.draw(client.machine,{bg=beautiful.fg_normal,height=beautiful.default_height}))
        cr:paint()
    end
    return w
end)
require("radical.impl.taglist.extensions").add("Count",function(client)
    local w = wibox.widget.base.make_widget()
    w.fit = function(_,w,h)
        return radical.widgets.underlay.fit("12",{bg="#ff0000"}),h
    end
    w.draw = function(self, w, cr, width, height)
        cr:set_source_surface(radical.widgets.underlay.draw("12",{bg=beautiful.fg_normal,height=beautiful.default_height}))
        cr:paint()
    end
    return w
end)


-- client.connect_signal("request::urgent", function(c,urgent)
--     if c ~= client.focus then
--         c.urgent = urgent
--     end
-- end)


print("START",awful.tag.selected(1))

-- local function gen_cls(c,results)
--     local ret = setmetatable({},{__index = function(t,i)
-- --         print ("REQ"..i)
--         local ret = c[i]
--         if type(ret) == "function" then
--             if i == "geometry" then
--                 return function(self,...)
--                  if #{...} > 0 then
--                     results[c] = ({...})[1]
--                  end
--                  return c:geometry()
--                 end
--             else
--                 return function(self,...) return ret(c,...) end
--             end
--         end
--         return ret
--     end})
--     
--     return ret
-- end
-- 
-- glib.idle_add(glib.PRIORITY_DEFAULT_IDLE, function()
--     local cls,results = {},setmetatable({},{__mode="k"})
--     for k,v in ipairs (awful.tag.selected(1):clients()) do
--         cls[#cls+1] = gen_cls(v,results)
--     end
-- 
--     local param =  {
--         tag = awful.tag.selected(1),
--         screen = 1,
--         clients = cls,
--         workarea = screen[1].workarea
--     }
--     awful.layout.suit.tile.left.arrange(param)
--     
--     print("DONE")
--     for c,geom in pairs(results) do
--         print(geom.x,geom.y,geom.width,geom.height)
--     end
-- end)

-- print("monitor")
-- utils.fd_async.file.watch("/home/lepagee/foobar"):connect_signal("file::changed",function(path1,path2)
--     print("file changed",path1,path2)
-- end):connect_signal("file::created",function(path1,path2)
--     print("file created",path1,path2)
-- end):connect_signal("file::deleted",function(path1,path2)
--     print("file deleted",path1,path2)
-- end)

-- utils.fd_async.network.load("http://www.gnu.org/licenses/old-licenses/gpl-2.0.html"):connect_signal("request::completed",function(content)
--     print("ICI",content)
-- end)

-- utils.fd_async.file.copy("/tmp/foo","/tmp/bar")

-- local m = require("lgi").Gtk.MessageDialog(nil,nil,nil,nil,"foobar")
-- m:run()

-- Hack to have rounded naughty popups
local wmt = getmetatable(wibox)
local wibox_constructor = wmt.__call
-- setmetatable(wibox,{__call = function()
--     print("foobar")
-- end})

local function resize_naughty(w)
    local height,width = w.height,w.width
    local shape = cairo.ImageSurface(cairo.Format.ARGB32, width, height)
    local cr = cairo.Context(shape)
    cr:set_source_rgba(1,1,1,1)
    cr:paint()
    cr:move_to(height/2,height)
    cr:arc(height/2,height/2,height/2,math.pi/2,3*(math.pi/2))
    cr:arc(width-height/2,height/2,height/2,3*(math.pi/2),math.pi/2)
    cr:close_path()
    cr:set_source_rgba(0,0,0,1)
    cr:fill()
    w.x = screen[1].geometry.width/2-width/2
    w.shape_bounding = shape._native
    w:set_bg(cairo.Pattern.create_for_surface(shape))
end

-- The trick here is to replace the wibox metatable to hijack the constructor
-- ... so evil!
local fake_naughty_box = {__call=function(...)
    local w = wibox_constructor(...)
    w:connect_signal("property::width",resize_naughty)
    w:connect_signal("property::height",resize_naughty)
    return w
end}
naughty._notify = naughty.notify
naughty.notify = function(...)
    setmetatable(wibox,fake_naughty_box)
    local ret = naughty._notify(...)
    print("LA",ret.box)
    setmetatable(wibox,wmt)
    return ret
end
