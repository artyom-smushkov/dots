hl.monitor({
    output = "",
    mode = "highrr",
    scale = 1,
    vrr = 2,
})

hl.config({
    general = {
        gaps_in = 8,
        gaps_out = 16,
        border_size = 2,
        col = {
            active_border = "rgba(cba6f7ff)",
            inactive_border = "rgba(45475aff)",
        },
        layout = "scrolling",
        resize_on_border = true,
        allow_tearing = true,
    },
    input = {
        kb_layout = "us,ru,ua",
        kb_options = "grp:alt_space_toggle,caps:capslock",
        follow_mouse = 2,
        float_switch_override_focus = 0,
        sensitivity = 0,
        accel_profile = "flat",
        touchpad = {
            natural_scroll = false,
        },
    },
    misc = {
        mouse_move_enables_dpms = true,
        key_press_enables_dpms = false,
    },
    decoration = {
        rounding = 0,
        blur = {
            enabled = false,
        },
        shadow = {
            enabled = false,
        },
    },
    master = {
        new_status = "master",
        orientation = "center",
        new_on_top = true,
        mfact = 0.6,
        slave_count_for_center_master = 0,
    },
    dwindle = {
        force_split = 2,
        default_split_ratio = 1.2,
    },
    scrolling = {
        fullscreen_on_one_column = false,
        column_width = 0.5,
        focus_fit_method = 0,
    }
})

hl.device({
    name = "adm42-keyboards-adm42-keyboard",
    kb_layout = "us,ru,ua",
    kb_options = "grp:alt_space_toggle,caps:capslock,lv3:menu_switch,compose:paus",
    kb_variant = ",phonetic,phonetic",
})

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("GDK_BACKEND", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("XCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Dracula-cursors")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "Dracula-cursors")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("MOZ_ENABLE_WAYLAND", "1")

hl.curve("wind", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1} } })
hl.curve("winIn", { type = "bezier", points = { {0.1, 1.1}, {0.1, 1} } })
hl.curve("winOut", { type = "bezier", points = { {0.3, -0.3}, {0, 1} } })
hl.curve("liner", { type = "bezier", points = { {1, 1}, {1, 1} } })

hl.animation({ leaf = "windows", enabled = true, speed = 0.4, bezier = "wind", style = "slide" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 0.4, bezier = "winIn", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 0.4, bezier = "winOut", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 0.4, bezier = "wind", style = "slide" })
hl.animation({ leaf = "border", enabled = true, speed = 1, bezier = "liner" })
hl.animation({ leaf = "fade", enabled = true, speed = 2, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 0.4, bezier = "wind", style="slidevert" })

hl.on("hyprland.start", function()
    hl.exec_cmd("/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh,gpg")
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("/usr/libexec/xdg-desktop-portal-hyprland -r")
    hl.exec_cmd("/usr/libexec/xdg-desktop-portal-gtk -r")
    hl.exec_cmd("hyprctl setcursor Dracula-cursors 24")
    hl.exec_cmd("swww-daemon || awww-daemon")
    hl.exec_cmd("waybar")
    hl.exec_cmd("swaync")
    hl.exec_cmd("bash -c '~/.local/bin/wallsetter'")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("geary")
    hl.exec_cmd("slack --disable-gpu")
    hl.exec_cmd("flatpak run app.zen_browser.zen")
    hl.exec_cmd("lollypop")
    hl.exec_cmd("easyeffects")
    hl.exec_cmd("Telegram")
end)

hl.bind("Print", hl.dsp.exec_cmd("flatpak run be.alexandervanhee.gradia --screenshot=FULL"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("flatpak run be.alexandervanhee.gradia --screenshot=INTERACTIVE"))
hl.bind("SUPER + RETURN", hl.dsp.exec_cmd("wezterm --config-file ~/.config/wezterm/workspaces/host.lua start"))
hl.bind("SUPER + R", hl.dsp.exec_cmd("fuzzel"))
hl.bind("SUPER + E", hl.dsp.exec_cmd("nautilus"))
hl.bind("SUPER + SHIFT + C", hl.dsp.window.close())
hl.bind("SUPER + F", hl.dsp.window.fullscreen({mode = "fullscreen", action = "toggle"}))
hl.bind("SUPER + M", hl.dsp.window.fullscreen({mode = "maximized", action = "toggle"}))
hl.bind("SUPER + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + SPACE", hl.dsp.layout("swapwithmaster"))
hl.bind("SUPER + L", hl.dsp.layout("focus right"))
hl.bind("SUPER + H", hl.dsp.layout("focus left"))
hl.bind("SUPER + S", hl.dsp.layout("colresize +conf"))
hl.bind("SUPER + T", hl.dsp.layout("orientationcycle center left"))

for i = 1, 10 do
    local key = i % 10
    hl.bind("SUPER + " .. tostring(key), hl.dsp.focus({workspace = i}))
    hl.bind("SUPER + SHIFT + " .. tostring(key), hl.dsp.window.move({ workspace = i }))
end

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +5%"))

hl.window_rule({
    name = "zen-rules",
    match = { class = "zen" },
    workspace = "1 silent",
    scrolling_width = "0.667",
})

hl.window_rule({
    name = "geary-workspace-org",
    match = { class = "org.gnome.Geary" },
    workspace = "4 silent",
})

hl.window_rule({
    name = "geary-workspace",
    match = { class = "geary" },
    workspace = "4 silent",
    scrolling_width = "0.667",
})

hl.window_rule({
    name = "wezterm-workspace",
    match = { class = "org.wezfurlong.wezterm" },
    workspace = "3 silent",
})

hl.window_rule({
    name = "lm-studio-workspace",
    match = { class = "LM Studio" },
    workspace = "5 silent",
})

hl.window_rule({
    name = "spotify-workspace",
    match = { class = "Spotify" },
    workspace = "6 silent",
})

hl.window_rule({
    name = "cider-workspace",
    match = { class = "Cider" },
    workspace = "6 silent",
})

hl.window_rule({
    name = "lollypop-workspace",
    match = { class = "org.gnome.Lollypop" },
    workspace = "6 silent",
})

hl.window_rule({
    name = "easyeffects-workspace",
    match = { class = "com.github.wwmm.easyeffects" },
    workspace = "6 silent",
})

hl.window_rule({
    name = "steam-workspace",
    match = { class = "steam" },
    workspace = "7 silent",
    scrolling_width = "0.667",
})

hl.window_rule({
    name = "slack-workspace-capital",
    match = { class = "Slack" },
    workspace = "8 silent",
})

hl.window_rule({
    name = "slack-workspace",
    match = { class = "slack" },
    workspace = "8 silent",
})

hl.window_rule({
    name = "telegram-workspace",
    match = { class = "org.telegram.desktop" },
    workspace = "8 silent",
})
