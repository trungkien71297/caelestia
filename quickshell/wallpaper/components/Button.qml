import QtQuick

Rectangle {
    id: root

    property var scheme: ({})
    property alias text: label.text
    property alias textColor: label.color
    property alias iconSource: icon.source
    property bool enabled: true
    property bool primary: false

    signal clicked()

    width: row.width + 24
    height: 36
    radius: 8
    color: {
        if (!enabled) return scheme.surfaceContainerHigh || "#2a292e";
        if (mouseArea.containsPress) return primary ? (scheme.primaryContainer || "#7171ac") : (scheme.surfaceContainerHighest || "#353438");
        if (mouseArea.containsMouse) return primary ? Qt.lighter(scheme.primary || "#c2c1ff", 1.1) : (scheme.surfaceContainerHigh || "#2a292e");
        return primary ? (scheme.primary || "#c2c1ff") : (scheme.surfaceContainer || "#201f23");
    }

    border.width: primary ? 0 : 1
    border.color: scheme.outline || "#918f9a"

    Behavior on color {
        ColorAnimation { duration: 150 }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 8

        Image {
            id: icon
            visible: source != ""
            width: 18
            height: 18
            anchors.verticalCenter: parent.verticalCenter
            sourceSize.width: 18
            sourceSize.height: 18
        }

        Text {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            color: {
                if (!root.enabled) return scheme.onSurfaceVariant || "#c8c5d1";
                return primary ? (scheme.onPrimary || "#2a2a60") : (scheme.onSurface || "#e5e1e7");
            }
            font.pixelSize: 14
            font.weight: Font.Medium
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: root.enabled
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

        onClicked: {
            if (root.enabled) root.clicked();
        }
    }
}
