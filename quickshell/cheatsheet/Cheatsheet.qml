import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

FloatingWindow {
    id: root

    property var scheme: ({})

    visible: false
    color: "transparent"

    function show() {
        visible = true;
    }

    function hide() {
        visible = false;
    }

    // Keybind categories
    readonly property var keybinds: [
        {
            category: "Apps",
            binds: [
                { key: "Super + T", action: "Terminal" },
                { key: "Super + W", action: "Browser" },
                { key: "Super + C", action: "Code Editor" },
                { key: "Super + E", action: "File Explorer" },
                { key: "Super + G", action: "GitHub Desktop" }
            ]
        },
        {
            category: "Windows",
            binds: [
                { key: "Super + Q", action: "Close Window" },
                { key: "Super + F", action: "Fullscreen" },
                { key: "Super + Alt + F", action: "Bordered Fullscreen" },
                { key: "Super + Alt + Space", action: "Toggle Floating" },
                { key: "Super + P", action: "Pin Window" },
                { key: "Super + Arrow", action: "Move Focus" },
                { key: "Super + Shift + Arrow", action: "Move Window" },
                { key: "Super + Z + Drag", action: "Move Window" },
                { key: "Super + X + Drag", action: "Resize Window" },
                { key: "Super + -/=", action: "Resize Split" }
            ]
        },
        {
            category: "Workspaces",
            binds: [
                { key: "Super + 1-0", action: "Go to Workspace" },
                { key: "Super + Alt + 1-0", action: "Move to Workspace" },
                { key: "Ctrl + Super + Left/Right", action: "Prev/Next Workspace" },
                { key: "Super + S", action: "Toggle Special WS" },
                { key: "Super + Scroll", action: "Switch Workspace" }
            ]
        },
        {
            category: "Special Workspaces",
            binds: [
                { key: "Ctrl + Shift + Esc", action: "System Monitor" },
                { key: "Super + M", action: "Music" },
                { key: "Super + D", action: "Communication" },
                { key: "Super + R", action: "Todo" }
            ]
        },
        {
            category: "Groups",
            binds: [
                { key: "Super + ,", action: "Toggle Group" },
                { key: "Super + U", action: "Ungroup" },
                { key: "Alt + Tab", action: "Cycle Group Next" },
                { key: "Shift + Alt + Tab", action: "Cycle Group Prev" }
            ]
        },
        {
            category: "Utilities",
            binds: [
                { key: "Print", action: "Screenshot (Full)" },
                { key: "Super + Shift + S", action: "Screenshot (Region)" },
                { key: "Super + Alt + R", action: "Record Screen" },
                { key: "Super + Shift + C", action: "Color Picker" },
                { key: "Super + V", action: "Clipboard History" },
                { key: "Super + .", action: "Emoji Picker" }
            ]
        },
        {
            category: "System",
            binds: [
                { key: "Super", action: "Launcher" },
                { key: "Super + L", action: "Lock Screen" },
                { key: "Super + Shift + L", action: "Sleep" },
                { key: "Ctrl + Alt + Del", action: "Session Menu" },
                { key: "Super + K", action: "Show Panels" },
                { key: "Super + B", action: "Wallpaper Picker" }
            ]
        },
        {
            category: "Media",
            binds: [
                { key: "Ctrl + Super + Space", action: "Play/Pause" },
                { key: "Ctrl + Super + =/-", action: "Next/Prev Track" },
                { key: "XF86Audio*", action: "Volume/Media Keys" },
                { key: "Super + Shift + M", action: "Mute" }
            ]
        }
    ]

    Rectangle {
        width: 1200
        height: 700
        anchors.centerIn: parent
        color: scheme.surfaceContainer || "#201f23"
        radius: 16
        border.width: 1
        border.color: scheme.outline || "#918f9a"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Text {
                    text: "Keyboard Shortcuts"
                    color: scheme.onSurface || "#e5e1e7"
                    font.pixelSize: 26
                    font.weight: Font.Bold
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    width: closeText.width + 16
                    height: 28
                    radius: 6
                    color: closeArea.containsMouse ? (scheme.surfaceContainerHighest || "#353438") : "transparent"

                    Text {
                        id: closeText
                        anchors.centerIn: parent
                        text: "ESC to close"
                        color: scheme.onSurfaceVariant || "#c8c5d1"
                        font.pixelSize: 14
                    }

                    MouseArea {
                        id: closeArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.hide()
                    }
                }
            }

            // Grid of categories
            GridLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                columns: 4
                rows: 2
                rowSpacing: 20
                columnSpacing: 20

                Repeater {
                    model: keybinds

                    Rectangle {
                        required property var modelData
                        required property int index

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: 1
                        color: scheme.surfaceContainerLow || "#1c1b1f"
                        radius: 12

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8

                            Text {
                                text: modelData.category
                                color: scheme.primary || "#c2c1ff"
                                font.pixelSize: 15
                                font.weight: Font.Bold
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: 4

                                Repeater {
                                    model: modelData.binds

                                    RowLayout {
                                        required property var modelData

                                        Layout.fillWidth: true
                                        spacing: 8

                                        Text {
                                            text: modelData.key
                                            color: scheme.secondary || "#c7c4dc"
                                            font.pixelSize: 12
                                            font.family: "monospace"
                                            Layout.preferredWidth: 140
                                        }

                                        Text {
                                            text: modelData.action
                                            color: scheme.onSurfaceVariant || "#c8c5d1"
                                            font.pixelSize: 12
                                            wrapMode: Text.WordWrap
                                            Layout.fillWidth: true
                                        }
                                    }
                                }

                                Item { Layout.fillHeight: true }
                            }
                        }
                    }
                }
            }
        }
    }

    // Close on Escape
    Shortcut {
        sequence: "Escape"
        onActivated: root.hide()
    }
}
