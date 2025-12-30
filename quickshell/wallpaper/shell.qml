import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

ShellRoot {
    id: root

    // Color scheme loaded from Caelestia state
    property var scheme: ({})
    property bool schemeLoaded: false

    // Monitor resolution
    property int monitorWidth: 2880
    property int monitorHeight: 1800

    // State directory path - use Environment for reliable paths
    readonly property string homeDir: Quickshell.env("HOME")
    readonly property string stateDir: (Quickshell.env("XDG_STATE_HOME") || homeDir + "/.local/state") + "/caelestia"

    Component.onCompleted: {
        loadScheme();
        detectMonitorResolution();
        // Show picker immediately on launch
        showTimer.start();
    }

    // Small delay to ensure everything is loaded
    Timer {
        id: showTimer
        interval: 100
        onTriggered: wallpaperPicker.show()
    }

    function loadScheme() {
        schemeLoader.running = true;
    }

    function detectMonitorResolution() {
        // Use Hyprland to get monitor info
        var monitors = Hyprland.monitors;
        if (monitors && monitors.values && monitors.values.length > 0) {
            var monitor = monitors.values[0];
            if (monitor.width && monitor.height) {
                monitorWidth = monitor.width;
                monitorHeight = monitor.height;
            }
        }
    }

    // Scheme data from stdout
    property string schemeData: ""

    // Load color scheme from Caelestia state file
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
                        // Convert hex colors to proper format
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
            error: "#ffb4ab",
            errorContainer: "#93000a",
            onErrorContainer: "#ffdad6"
        };
        schemeLoaded = true;
    }

    // Wallpaper picker window
    WallpaperPicker {
        id: wallpaperPicker
        scheme: root.scheme
        monitorWidth: root.monitorWidth
        monitorHeight: root.monitorHeight
        homeDir: root.homeDir

        onVisibleChanged: {
            // Exit quickshell when picker is closed
            if (!visible) {
                Qt.quit();
            }
        }
    }
}
