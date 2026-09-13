// ~/.config/quickshell/Bar.qml
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

PanelWindow {
    anchors.top: true
    anchors.left: true
    anchors.right: true
    margins {
        top: 8
        left: 12
        right: 12
    }
    implicitHeight: 36
    color: "transparent"

    property color colBg: "#15803d"
    property color colAccent: "#22c55e"
    property color colAccentLight: "#4ade80"
    property color colText: "#e6ffe6"
    property string fontFamily: "JetBrainsMono Nerd Font"

    property int cpuUsage: 0
    property var lastCpuIdle: 0
    property var lastCpuTotal: 0
    property int cpuTemp: 0
    property int ramUsage: 0

    property bool colonVisible: true
    property var currentTime: new Date()

    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: { colonVisible = !colonVisible; currentTime = new Date() }
    }

    Process {
        id: cpuProc
        command: ["sh", "-c", "head -1 /proc/stat"]
        stdout: SplitParser {
            onRead: data => {
                var p = data.trim().split(/\s+/)
                var idle = parseInt(p[4]) + parseInt(p[5])
                var total = p.slice(1, 8).reduce((a, b) => a + parseInt(b), 0)
                if (lastCpuTotal > 0) cpuUsage = Math.round(100 * (1 - (idle - lastCpuIdle) / (total - lastCpuTotal)))
                lastCpuTotal = total; lastCpuIdle = idle
            }
        }
        Component.onCompleted: running = true
    }
    Timer { interval: 2000; running: true; repeat: true; onTriggered: cpuProc.running = true }

    Process {
        id: tempProc
        command: ["sh", "-c", "cat /sys/class/thermal/thermal_zone0/temp"]
        stdout: SplitParser { onRead: data => cpuTemp = Math.round(parseInt(data.trim()) / 1000) }
        Component.onCompleted: running = true
    }
    Timer { interval: 2000; running: true; repeat: true; onTriggered: tempProc.running = true }

    Process {
        id: ramProc
        command: ["sh", "-c", "free | awk '/Mem:/ {printf \"%d\", $3/$2 * 100}'"]
        stdout: SplitParser { onRead: data => ramUsage = parseInt(data.trim()) }
        Component.onCompleted: running = true
    }
    Timer { interval: 2000; running: true; repeat: true; onTriggered: ramProc.running = true }

    Rectangle {
        id: barBg
        anchors.fill: parent
        color: Qt.rgba(0.05, 0.15, 0.08, 0.55)
        radius: 30
        border.width: 1
        border.color: Qt.rgba(0.13, 0.77, 0.37, 0.5)
        layer.enabled: true
        layer.effect: MultiEffect { blurEnabled: true; blur: 0.4; blurMax: 16 }
    }
    mask: Region { item: barBg }

    Item {
        anchors.centerIn: parent
        width: clockPill.width
        height: 30

        Rectangle {
            id: clockGlow
            anchors.centerIn: parent
            width: clockPill.width + 16
            height: 34
            radius: 20
            color: colAccent
            opacity: 0.25
            layer.enabled: true
            layer.effect: MultiEffect { blurEnabled: true; blur: 1.0; blurMax: 24 }
        }

        Rectangle {
            id: clockPill
            anchors.centerIn: parent
            width: clockContent.width + 20
            height: 28
            radius: 14
            color: Qt.rgba(0.08, 0.25, 0.12, 0.6)
            border.width: 1
            border.color: colAccent
            opacity: 0.9

            Column {
                id: clockContent
                anchors.centerIn: parent
                spacing: 1

                Row {
                    id: timeRow
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 0
                    Text { text: Qt.formatDateTime(currentTime, "HH"); color: colText; font.pixelSize: 13; font.bold: true; font.family: fontFamily }
                    Text { text: ":"; color: colText; font.pixelSize: 13; font.bold: true; font.family: fontFamily; opacity: colonVisible ? 1.0 : 0.2; Behavior on opacity { NumberAnimation { duration: 200 } } }
                    Text { text: Qt.formatDateTime(currentTime, "mm"); color: colText; font.pixelSize: 13; font.bold: true; font.family: fontFamily }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatDateTime(currentTime, "ddd") + " · " + Qt.formatDateTime(currentTime, "dd MMM")
                    color: colAccentLight
                    font.pixelSize: 9
                    font.family: fontFamily
                }
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 6

        Image {
            source: Qt.resolvedUrl("./gentoo-logo.png")
            width: 18; height: 18
            sourceSize.width: 18; sourceSize.height: 18
            fillMode: Image.PreserveAspectFit
            Layout.alignment: Qt.AlignVCenter
        }

        Rectangle { width: 1; height: 14; Layout.alignment: Qt.AlignVCenter; color: "#ffffff"; opacity: 0.2 }

        Repeater {
            model: 9
            Item {
                width: 20
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignVCenter
                property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
                property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
                property bool isHovered: wsMouse.containsMouse

                Rectangle {
                    id: activeBg
                    width: 20; height: 20
                    radius: 10
                    anchors.centerIn: parent
                    color: colAccent
                    opacity: isActive ? 0.35 : (isHovered ? 0.15 : 0)
                    scale: isActive ? 1 : (isHovered ? 1.1 : 0.8)
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                }

                Rectangle {
                    id: dot
                    width: isActive ? 9 : 6
                    height: isActive ? 9 : 6
                    radius: width / 2
                    anchors.centerIn: parent
                    color: isActive ? colAccentLight : (ws ? colAccent : "#4a6b52")
                    Behavior on width { SmoothedAnimation { duration: 150 } }
                    Behavior on height { SmoothedAnimation { duration: 150 } }
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                MouseArea {
                    id: wsMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: Hyprland.dispatch('hl.dsp.focus({ workspace = "' + (index + 1) + '" })')
                }
            }
        }

        Item { Layout.fillWidth: true }

        Item {
            width: 80; height: 20; Layout.alignment: Qt.AlignVCenter
            Rectangle {
                anchors.centerIn: parent; width: 88; height: 26; radius: 16
                color: colAccent; opacity: 0.6
                layer.enabled: true
                layer.effect: MultiEffect { blurEnabled: true; blur: 1.0; blurMax: 24 }
            }
            Rectangle {
                anchors.centerIn: parent; width: 76; height: 20; radius: 14
                color: colAccent
                Text { anchors.centerIn: parent; text: "RAM " + ramUsage + "%"; color: "#0a1f0f"; font.pixelSize: 11; font.bold: true }
            }
        }

        Rectangle { width: 1; height: 14; Layout.alignment: Qt.AlignVCenter; color: "#ffffff"; opacity: 0.2 }

        Item {
            width: 80; height: 20; Layout.alignment: Qt.AlignVCenter
            Rectangle {
                anchors.centerIn: parent; width: 88; height: 26; radius: 16
                color: cpuUsage > 80 ? "#d60404" : cpuUsage > 50 ? "#faff00" : colAccent
                opacity: 0.6
                Behavior on color { ColorAnimation { duration: 500 } }
                layer.enabled: true
                layer.effect: MultiEffect { blurEnabled: true; blur: 1.0; blurMax: 24 }
            }
            Rectangle {
                anchors.centerIn: parent; width: 76; height: 20; radius: 14
                color: cpuUsage > 80 ? "#d60404" : cpuUsage > 50 ? "#faff00" : colAccentLight
                Behavior on color { ColorAnimation { duration: 500 } }
                Text { anchors.centerIn: parent; text: "CPU " + cpuUsage + "%"; color: "#0a1f0f"; font.pixelSize: 11; font.bold: true }
            }
        }

        Item {
            width: 80; height: 20; Layout.alignment: Qt.AlignVCenter
            Rectangle {
                anchors.centerIn: parent; width: 88; height: 26; radius: 16
                color: cpuTemp > 80 ? "#d60404" : cpuTemp > 60 ? "#faff00" : colAccent
                opacity: 0.6
                Behavior on color { ColorAnimation { duration: 500 } }
                layer.enabled: true
                layer.effect: MultiEffect { blurEnabled: true; blur: 1.0; blurMax: 24 }
            }
            Rectangle {
                anchors.centerIn: parent; width: 76; height: 20; radius: 14
                color: cpuTemp > 80 ? "#d60404" : cpuTemp > 60 ? "#faff00" : colAccentLight
                Behavior on color { ColorAnimation { duration: 500 } }
                Text { anchors.centerIn: parent; text: cpuTemp + "°C"; color: "#0a1f0f"; font.pixelSize: 11; font.bold: true }
            }
        }

        Rectangle { width: 1; height: 14; Layout.alignment: Qt.AlignVCenter; color: "#ffffff"; opacity: 0.2 }

        Item {
            id: volBtn
            width: 26; height: 26
            Layout.alignment: Qt.AlignVCenter
            property bool isHovered: volMouse.containsMouse

            Rectangle {
                anchors.fill: parent
                radius: 13
                color: volBtn.isHovered ? colAccentLight : colAccent
                opacity: 0.7
                Behavior on color { ColorAnimation { duration: 200 } }
            }
            Text {
                anchors.centerIn: parent
                text: "󰕾"
                font.pixelSize: 14
                color: "#0a1f0f"
                font.family: fontFamily
            }
            MouseArea {
                id: volMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: Quickshell.execDetached(["qs", "ipc", "call", "volumepopup", "toggle"])
                onWheel: (wheel) => {
                    let step = wheel.angleDelta.y > 0 ? "5%+" : "5%-"
                    Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", step])
                }
            }
        }

        Rectangle { width: 1; height: 14; Layout.alignment: Qt.AlignVCenter; color: "#ffffff"; opacity: 0.2 }

        Item {
            id: powerBtn
            width: 26; height: 26
            Layout.alignment: Qt.AlignVCenter
            property bool isHovered: powerMouse.containsMouse

            Rectangle {
                anchors.fill: parent
                radius: 13
                color: powerBtn.isHovered ? "#d60404" : colAccent
                opacity: powerBtn.isHovered ? 0.9 : 0.7
                Behavior on color { ColorAnimation { duration: 200 } }
            }
            Text {
                anchors.centerIn: parent
                text: "⏻"
                font.pixelSize: 14
                color: "#0a1f0f"
                font.family: fontFamily
            }
            MouseArea {
                id: powerMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: Quickshell.execDetached(["qs", "ipc", "call", "powermenu", "toggle"])
            }
        }
    }
}