-- Love2D configuration for Pile-Up Poker
-- Optimised for Samsung S22 Ultra (1440x3088, portrait)

function love.conf(t)
    t.identity          = "PileUpPoker"
    t.version           = "11.4"
    t.console           = false

    t.window.title      = "Pile-Up Poker"
    -- Desktop preview window at ~50 % of virtual resolution
    t.window.width      = 540
    t.window.height     = 1170
    t.window.resizable  = true
    t.window.minwidth   = 270
    t.window.minheight  = 585
    t.window.fullscreen = false
    t.window.vsync      = 1
    t.window.highdpi    = true   -- enable high-DPI on retina / high-density screens

    -- Disable unused modules (improves startup time on Android)
    t.modules.joystick  = false
    t.modules.physics   = false
    t.modules.video     = false
    t.modules.thread    = false
end
