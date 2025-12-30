import QtQuick

Rectangle {
    id: root

    property var scheme: ({})
    property alias source: image.source
    property bool loading: image.status === Image.Loading
    property bool error: image.status === Image.Error
    property bool fetching: false

    color: scheme.surfaceContainerLow || "#1c1b1f"
    radius: 12
    clip: true

    Image {
        id: image
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false

        opacity: status === Image.Ready ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }
    }

    // Loading spinner
    Item {
        anchors.centerIn: parent
        visible: root.loading || root.fetching
        width: 48
        height: 48

        Rectangle {
            id: spinner
            anchors.centerIn: parent
            width: 40
            height: 40
            radius: 20
            color: "transparent"
            border.width: 3
            border.color: scheme.primary || "#c2c1ff"

            // Spinning arc effect
            Rectangle {
                width: 40
                height: 40
                radius: 20
                color: "transparent"
                border.width: 3
                border.color: scheme.surfaceContainerLow || "#1c1b1f"
                anchors.centerIn: parent

                // Mask to create arc
                Rectangle {
                    width: 20
                    height: 40
                    color: scheme.surfaceContainerLow || "#1c1b1f"
                    anchors.right: parent.right
                }
            }

            RotationAnimator {
                target: spinner
                from: 0
                to: 360
                duration: 1000
                loops: Animation.Infinite
                running: root.loading || root.fetching
            }
        }

        Text {
            anchors.top: spinner.bottom
            anchors.topMargin: 12
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.fetching ? "Fetching..." : "Loading..."
            color: scheme.onSurfaceVariant || "#c8c5d1"
            font.pixelSize: 12
        }
    }

    // Error state
    Column {
        anchors.centerIn: parent
        visible: root.error && !root.fetching
        spacing: 8

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "!"
            color: scheme.error || "#ffb4ab"
            font.pixelSize: 32
            font.weight: Font.Bold
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Failed to load image"
            color: scheme.error || "#ffb4ab"
            font.pixelSize: 14
        }
    }

    // Placeholder when no source
    Text {
        anchors.centerIn: parent
        visible: image.source == "" && !root.loading && !root.error && !root.fetching
        text: "Click 'Random' to fetch an image"
        color: scheme.onSurfaceVariant || "#c8c5d1"
        font.pixelSize: 14
    }
}
