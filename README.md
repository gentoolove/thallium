# thallium

A minimal, green-themed Hyprland desktop for a 2011 Apple iMac (iMac12,2), running Gentoo Linux with OpenRC — no systemd.

## Hardware

- Apple iMac 12,2 (Mid 2011)
- CPU: Intel Core i5-2400 (Sandy Bridge)
- GPU: AMD Radeon HD 6970M/6990M (Blackcomb, TeraScale 2 / VLIW4 — pre-GCN, `radeon` kernel driver, no Vulkan support) + Intel HD 3000 (integrated)
- Display: built-in 27" panel, 2560x1440 @ 60Hz (`eDP-1`)

## Stack

| Component        | Choice                          |
|-------------------|----------------------------------|
| Distro            | Gentoo Linux                    |
| Init system        | OpenRC (no systemd)             |
| Compositor         | Hyprland 0.56.2 (Lua config)     |
| Bar / shell        | Quickshell (QML)                |
| Terminal           | Kitty                           |
| Launcher           | Fuzzel                          |
| Notifications      | Mako                            |
| Wallpaper          | Hyprpaper                       |
| Audio              | PipeWire + WirePlumber (manually launched, no systemd user services) |

## Layout

```
~/.config/hypr/
  hyprland.lua        # main compositor config (Lua syntax, Hyprland 0.55+)
  hyprpaper.conf       # wallpaper daemon config

~/.config/quickshell/
  shell.qml            # entry point — wires up Bar, PowerMenu, VolumePopup
  Bar.qml              # top bar: workspaces, RAM/CPU/temp pills, clock, volume, power
  PowerMenu.qml        # popup: shutdown / reboot / logout / lock
  VolumePopup.qml       # popup: volume slider + mute

~/.config/kitty/
  kitty.conf

~/.config/fuzzel/
  fuzzel.ini
```

## Known hardware limitation: no compositor blur/transparency

The Radeon HD 6970M's DRM primary plane scans out in `XRGB8888` (opaque, no alpha channel) — confirmed via `hyprctl monitors`. This means **no window transparency or compositor blur is physically possible** on this GPU under Hyprland, regardless of `decoration.blur` settings. Attempts to fix via `AQ_NO_MODIFIERS` and explicit `bitdepth` in the monitor config did not change this.

As a workaround, the bar/popups use `QtQuick.Effects.MultiEffect` for a "glow" effect on their own semi-transparent shapes — this works, since it's client-side rendering rather than backdrop blur, but it does **not** blur what's behind the window.

## Key bindings

| Bind                         | Action                     |
|------------------------------|----------------------------|
| `SUPER + Return`              | Open Kitty                 |
| `SUPER + Space`                | Open Fuzzel                |
| `SUPER + Q`                    | Close active window         |
| `SUPER + =` / `SUPER + -`      | Volume up / down            |
| `SUPER + M`                    | Mute toggle                 |
| `SUPER + SHIFT + =` / `-`      | Brightness up / down (`brightnessctl`) |

## GPU / driver notes

- `VIDEO_CARDS="radeon"` in `/etc/portage/make.conf` (not `amdgpu` — unsupported for TeraScale)
- `amdgpu` kernel module blacklisted to avoid probe conflicts with `radeon`
- `AQ_DRM_DEVICES` / `AQ_NO_MODIFIERS` used to pin the discrete GPU explicitly (avoid `by-path` symlinks — Aquamarine splits `AQ_DRM_DEVICES` on `:`, which collides with PCI address formatting)

## Autostart

PipeWire, WirePlumber, Mako, Hyprpaper, and Quickshell are all launched manually from `hyprland.lua`'s `hl.on("hyprland.start", ...)` block, since OpenRC does not start user-level audio/session services automatically.

## License

GPL-3.0
