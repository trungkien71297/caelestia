import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

ShellRoot {
    id: root

    property var scheme: ({})
    property bool schemeLoaded: false

    readonly property string homeDir: Quickshell.env("HOME")
    readonly property string stateDir: (Quickshell.env("XDG_STATE_HOME") || homeDir + "/.local/state") + "/caelestia"

    Component.onCompleted: {
        loadScheme();
        showTimer.start();
    }

    Timer {
        id: showTimer
        interval: 100
        onTriggered: cheatsheet.show()
    }

    function loadScheme() {
        schemeLoader.running = true;
    }

    property string schemeData: ""

    Process {
        id: schemeLoader

        command: ["cat", stateDir + "/scheme.json"]

        stdout: SplitParser {
            onRead: data => {
                schemeData = data;
            }
        }

        onExited: function(code, status) {
            if (code === 0 && schemeData) {
                try {
                    var data = JSON.parse(schemeData);
                    if (data.colours) {
                        var colours = {};
                        for (var key in data.colours) {
                            var hex = data.colours[key];
                            if (hex && hex.length === 6) {
                                colours[key] = "#" + hex;
                            } else {
                                colours[key] = hex;
                            }
                        }
                        scheme = colours;
                        schemeLoaded = true;
                    }
                } catch (e) {
                    console.error("Failed to parse scheme:", e);
                    useDefaultScheme();
                }
                schemeData = "";
            } else {
                useDefaultScheme();
            }
        }
    }

    function useDefaultScheme() {
        scheme = {
            background: "#131317",
            onBackground: "#e5e1e7",
            surface: "#131317",
            surfaceContainer: "#201f23",
            surfaceContainerLow: "#1c1b1f",
            surfaceContainerHigh: "#2a292e",
            surfaceContainerHighest: "#353438",
            onSurface: "#e5e1e7",
            onSurfaceVariant: "#c8c5d1",
            outline: "#918f9a",
            primary: "#c2c1ff",
            onPrimary: "#2a2a60",
            primaryContainer: "#7171ac",
            onPrimaryContainer: "#ffffff",
            secondary: "#c7c4dc",
            secondaryContainer: "#46455a"
        };
        schemeLoaded = true;
    }

    Cheatsheet {
        id: cheatsheet
        scheme: root.scheme

        onVisibleChanged: {
            if (!visible) {
                Qt.quit();
            }
        }
    }
}
