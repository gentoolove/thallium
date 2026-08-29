-- ~/.config/hypr/hyprland.lua
-------------------------------
-- BASE LOOK
-------------------------------
hl.config({
general = {
  gaps_in = 4,
  gaps_out = 8,
  border_size = 2,
  ["col.active_border"]   = "rgba(22c55eee)",   
  ["col.inactive_border"] = "rgba(15803d66)",
  layout = "dwindle",
},

  decoration = {
  rounding = 8,
  blur = { enabled = false },
},
})

-------------------------------
-- AUTOSTART
-------------------------------
hl.on("hyprland.start", function()
  hl.exec_cmd("mako")
  hl.exec_cmd("hyprpaper")
  hl.exec_cmd("qs")    
end)


-------------------------------
-- BINDS
-------------------------------
local mainMod = "SUPER"

hl.bind(mainMod .. "+Space",  hl.dsp.exec_cmd("fuzzel"))
hl.bind(mainMod .. "+Return", hl.dsp.exec_cmd("kitty"))    -- SUPER+Enter -> Kitty
hl.bind(mainMod .. "+Q",      hl.dsp.window.close())
