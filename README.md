# Keyboard Toggle

Disable and re-enable the built-in laptop keyboard from a keybinding, for
example to type on an external keyboard resting on top of the laptop.

While the keyboard is disabled a red dot appears on the Omarchy bar; it
disappears as soon as the keyboard is back on.

- **Click the dot** to turn the keyboard back on. The disabled keyboard cannot
  press the keybinding, so this (or an external keyboard) is how you get it back.
- **Locking the screen turns the keyboard back on**, so you can always type
  your password.
- **Restarting the shell, logging out or rebooting** also leaves the keyboard on.
- Reloading the Hyprland config keeps it disabled, so the dot stays accurate.

External keyboards are never touched.

## Install

```sh
omarchy plugin add https://github.com/M1ke324/omarchy-keyboard-toggle.git --enable
```

Then add a keybinding to `~/.config/hypr/bindings.lua`:

```lua
o.bind("SUPER + CTRL + ALT + K", "Keyboard on/off", "omarchy-shell -q io.github.m1ke324.keyboard-toggle toggle")
```

## Remove

```sh
omarchy plugin remove io.github.m1ke324.keyboard-toggle
```

and delete the keybinding.

## Commands

```sh
omarchy-shell -q io.github.m1ke324.keyboard-toggle toggle   # disable / enable
omarchy-shell -q io.github.m1ke324.keyboard-toggle off      # disable
omarchy-shell -q io.github.m1ke324.keyboard-toggle on       # enable
omarchy-shell io.github.m1ke324.keyboard-toggle status      # prints enabled or disabled
```

## A different keyboard

The plugin disables `at-translated-set-2-keyboard`, the built-in keyboard on
most x86 laptops. If yours has another name, find it with:

```sh
hyprctl devices
```

and set it on the widget in `~/.config/omarchy/shell.json`:

```json
{ "id": "io.github.m1ke324.keyboard-toggle", "device": "your-keyboard-name" }
```

## Notes

- Requires Omarchy Quattro (Quickshell bar and Lua Hyprland config).
- Translations: English and Italian. Add a language by dropping a catalog in `i18n/`.

## License

MIT
