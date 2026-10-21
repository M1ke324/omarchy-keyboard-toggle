import QtQuick
import Quickshell.Io
import Quickshell.Hyprland
import qs.Commons as Commons

// Holds whether the built-in keyboard is disabled, once for the whole shell,
// so every monitor's bar widget and the IPC commands share the same state.
Item {
  id: root

  property var shell: null

  readonly property string pluginId: "io.github.m1ke324.keyboard-toggle"
  readonly property string defaultDevice: "at-translated-set-2-keyboard"
  readonly property string glyph: "\u{f030c}"

  // The bar widget sets this from its "device" setting.
  property string device: defaultDevice
  property bool disabled: false

  Commons.Translations { id: strings; directory: Qt.resolvedUrl("i18n") }

  // The device name reaches Hyprland as a quoted Lua string built in bash from
  // argv, never interpolated into the command line.
  function apply(enabled) {
    applyProc.command = ["bash", "-c",
      "name=${1//\\\\/\\\\\\\\}; name=${name//\\\"/\\\\\\\"}; "
        + "hyprctl eval \"hl.device({ name = \\\"$name\\\", enabled = $2 })\" >/dev/null",
      "keyboard-toggle", root.device, enabled ? "true" : "false"]
    applyProc.running = true
  }

  function osd(message) {
    osdProc.command = ["omarchy-osd", "-i", "keyboard", "-m", message]
    osdProc.running = true
  }

  function enable() {
    if (!disabled) return
    disabled = false
    apply(true)
    osd(strings.t("osd.enabled"))
  }

  function disable() {
    if (disabled) return
    disabled = true
    apply(false)
    osd(strings.t("osd.disabled"))
  }

  function toggle() {
    if (disabled) enable()
    else disable()
  }

  // A shell restart forgets the state, so start from a working keyboard
  // rather than leave one disabled with no dot to click.
  Component.onCompleted: apply(true)

  // Reloading the Hyprland config drops the runtime device rule and turns the
  // keyboard back on: disable it again so it keeps matching the dot.
  Connections {
    target: Hyprland
    function onRawEvent(event) {
      if (event.name === "configreloaded" && root.disabled) root.apply(false)
    }
  }

  // The lock screen needs the keyboard for the password, so turn it back on
  // as soon as the session locks.
  Timer {
    interval: 1000
    running: root.disabled
    repeat: true
    onTriggered: if (!lockProc.running) lockProc.running = true
  }

  Process {
    id: lockProc
    command: ["omarchy-shell", "lock", "isLocked"]
    stdout: StdioCollector {
      onStreamFinished: if (text.trim() === "true") root.enable()
    }
  }

  Process { id: applyProc }
  Process { id: osdProc }

  // omarchy-shell -q io.github.m1ke324.keyboard-toggle toggle
  // omarchy-shell -q io.github.m1ke324.keyboard-toggle on
  // omarchy-shell -q io.github.m1ke324.keyboard-toggle off
  // omarchy-shell -q io.github.m1ke324.keyboard-toggle status
  IpcHandler {
    target: root.pluginId

    function toggle(): void { root.toggle() }
    function on(): void { root.enable() }
    function off(): void { root.disable() }
    function status(): string { return root.disabled ? "disabled" : "enabled" }
  }
}
