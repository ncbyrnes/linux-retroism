import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import ".."

PopupWindow {
    id: root

    property int menuWidth: 0
    property var closeAllCallback: function () {}

    anchor.window: taskbar
    anchor.rect.x: menuWidth
    anchor.rect.y: 0
    anchor.edges: Edges.Top | Edges.Left
    anchor.gravity: Edges.Top | Edges.Right
    implicitWidth: 220
    implicitHeight: 196
    color: "transparent"

    Rectangle {
        id: frame
        opacity: 0
        anchors.fill: parent
        color: Config.colors.base
        layer.enabled: true

        property int topOffset: 20

        PopupWindowFrame {
            windowTitle: "Shut Down"
            windowTitleIcon: ""
            windowTitleDecorationWidth: 50

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                anchors.topMargin: frame.topOffset + 18
                spacing: 0

                Button {
                    id: shutdownButton
                    Layout.fillWidth: true
                    implicitHeight: 36
                    property bool isActive: shutdownHover.hovered
                    onClicked: {
                        Quickshell.execDetached(["bash", "-c", "systemctl poweroff"]);
                        root.closeAllCallback();
                    }
                    background: Rectangle {
                        color: shutdownButton.isActive ? Config.selectionColor : "transparent"
                        border.color: "transparent"
                    }
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        spacing: 8
                        Text { font.family: iconFont.name; font.pixelSize: 20; color: shutdownButton.isActive ? Config.selectionTextColor : Config.colors.text; text: "" }
                        Text { font.family: fontMonaco.name; font.pixelSize: Config.settings.bar.fontSize; color: shutdownButton.isActive ? Config.selectionTextColor : Config.colors.text; text: "Shut Down" }
                    }
                    HoverHandler { id: shutdownHover; acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad; cursorShape: Qt.PointingHandCursor }
                }

                Button {
                    id: restartButton
                    Layout.fillWidth: true
                    implicitHeight: 36
                    property bool isActive: restartHover.hovered
                    onClicked: {
                        Quickshell.execDetached(["bash", "-c", "systemctl reboot"]);
                        root.closeAllCallback();
                    }
                    background: Rectangle {
                        color: restartButton.isActive ? Config.selectionColor : "transparent"
                        border.color: "transparent"
                    }
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        spacing: 8
                        Text { font.family: iconFont.name; font.pixelSize: 20; color: restartButton.isActive ? Config.selectionTextColor : Config.colors.text; text: "" }
                        Text { font.family: fontMonaco.name; font.pixelSize: Config.settings.bar.fontSize; color: restartButton.isActive ? Config.selectionTextColor : Config.colors.text; text: "Restart" }
                    }
                    HoverHandler { id: restartHover; acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad; cursorShape: Qt.PointingHandCursor }
                }

                Button {
                    id: logoutButton
                    Layout.fillWidth: true
                    implicitHeight: 36
                    property bool isActive: logoutHover.hovered
                    onClicked: {
                        Quickshell.execDetached(["bash", "-c", "hyprctl dispatch exit"]);
                        root.closeAllCallback();
                    }
                    background: Rectangle {
                        color: logoutButton.isActive ? Config.selectionColor : "transparent"
                        border.color: "transparent"
                    }
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        spacing: 8
                        Text { font.family: iconFont.name; font.pixelSize: 20; color: logoutButton.isActive ? Config.selectionTextColor : Config.colors.text; text: "" }
                        Text { font.family: fontMonaco.name; font.pixelSize: Config.settings.bar.fontSize; color: logoutButton.isActive ? Config.selectionTextColor : Config.colors.text; text: "Log Out" }
                    }
                    HoverHandler { id: logoutHover; acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad; cursorShape: Qt.PointingHandCursor }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Config.colors.outline
                    Layout.leftMargin: 4
                    Layout.rightMargin: 4
                }

                Button {
                    id: cancelButton
                    Layout.fillWidth: true
                    implicitHeight: 36
                    property bool isActive: cancelHover.hovered
                    onClicked: root.closeShutdownMenu()
                    background: Rectangle {
                        color: cancelButton.isActive ? Config.selectionColor : "transparent"
                        border.color: "transparent"
                    }
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        spacing: 8
                        Text { font.family: iconFont.name; font.pixelSize: 20; color: cancelButton.isActive ? Config.selectionTextColor : Config.colors.text; text: "" }
                        Text { font.family: fontMonaco.name; font.pixelSize: Config.settings.bar.fontSize; color: cancelButton.isActive ? Config.selectionTextColor : Config.colors.text; text: "Cancel" }
                    }
                    HoverHandler { id: cancelHover; acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad; cursorShape: Qt.PointingHandCursor }
                }

                Item { Layout.fillHeight: true }
            }
        }

        OpacityAnimator {
            id: openAnimation
            target: frame
            from: 0
            to: 1
            duration: 140
            easing.type: Easing.OutCubic
        }
        OpacityAnimator {
            id: closeAnimation
            target: frame
            from: 1
            to: 0
            duration: 80
            easing.type: Easing.InOutQuad
            onFinished: root.visible = false
        }
    }

    function openShutdownMenu() {
        root.visible = true;
        openAnimation.start();
    }

    function closeShutdownMenu() {
        closeAnimation.start();
    }
}
