import QtQuick
import qs.Commons as Commons
import qs.Ui

// A dot on the bar, shown only while the built-in keyboard is disabled.
// Clicking it turns the keyboard back on.
BarWidget {
  id: root

  readonly property string pluginId: "io.github.m1ke324.keyboard-toggle"
  moduleName: pluginId

  readonly property var service: bar && bar.shell ? bar.shell.serviceFor(pluginId) : null
  readonly property bool keyboardOff: service ? service.disabled : false

  Commons.Translations { id: strings; directory: Qt.resolvedUrl("i18n") }

  function syncDevice() {
    if (!service) return
    var device = settings && settings.device ? String(settings.device) : ""
    service.device = device !== "" ? device : service.defaultDevice
  }

  onServiceChanged: syncDevice()
  onSettingsChanged: syncDevice()

  visible: keyboardOff
  implicitWidth: keyboardOff ? button.implicitWidth : 0
  implicitHeight: button.implicitHeight

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "●"
    active: true
    tooltipText: strings.t("bar.tooltip")
    onPressed: function(b) { if (root.service) root.service.enable() }
  }
}
