// ~/.config/quickshell/PowerMenu.qml
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: powerMenu
    visible: false
    implicitWidth: 260
    implicitHeight: 220
    color: "transparent"

    anchors { top: true; right: true }
    margins { top: 50; right: 20 }

    property color colBg: "#0f1a12"
    property color colAccent: "#22c55e"
    property string fontFamily: "JetBrainsMono Nerd Font"

    IpcHandler {
        target: "powermenu"
        function toggle() { powerMenu.visible = !powerMenu.visible }
    }

    Rectangle {
        anchors.fill: parent
        radius: 18
        color: colBg
        border.width: 1
        border.color: Qt.rgba(0.13, 0.77, 0.37, 0.4)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            Repeater {
                model: [
                    { label: "Shut down", icon: "󰐥", cmd: "sudo shutdown now" },
                    { label: "Reboot",    icon: "󰜉", cmd: "sudo reboot" },
                    { label: "Log out",   icon: "󰗽", cmd: "hyprctl dispatch exit" },
                    { label: "Lock",      icon: "󰌾", cmd: "hyprlock" }
                ]
                delegate: Rectangle {
                    Layout.fillWidth: true
                    height: 42
                    radius: 10
                    property bool isHovered: itemMouse.containsMouse
                    color: isHovered ? Qt.rgba(0.13, 0.77, 0.37, 0.25) : "transparent"

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        spacing: 10
                        Text { text: modelData.icon; color: colAccent; font.pixelSize: 16; font.family: fontFamily }
                        Text { text: modelData.label; color: "#e6ffe6"; font.pixelSize: 13; font.family: fontFamily }
                    }

                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            Quickshell.execDetached(["bash", "-c", modelData.cmd])
                            powerMenu.visible = false
                        }
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: powerMenu.visible = false
    }
}