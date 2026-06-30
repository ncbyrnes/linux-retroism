import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import ".."

PopupWindow {
    id: root

    property int menuWidth: 0
    property var closeCallback: function () {}
    property var openAppLauncherCallback: function () {}
    property var openThemeMenuCallback: function () {}

    property string hostname: ""
    property string username: ""
    property int navIndex: -1
    readonly property int navCount: 5

    function activateItem(idx) {
        switch (idx) {
        case 0: root.openThemeMenuCallback(); break;
        case 1: Quickshell.execDetached(Config.settings.execCommands.files); root.closeCallback(); break;
        case 2: Quickshell.execDetached(Config.settings.execCommands.terminal); root.closeCallback(); break;
        case 3: root.openAppLauncherCallback(); break;
        case 4: root.closeCallback(); break;
        }
    }

    anchor.window: taskbar
    anchor.rect.x: menuWidth
    anchor.rect.y: parentWindow.implicitHeight
    implicitWidth: 300
    implicitHeight: 340
    color: "transparent"

    Process {
        command: ["hostname"]
        running: true
        stdout: SplitParser { onRead: line => root.hostname = line }
    }

    Process {
        command: ["whoami"]
        running: true
        stdout: SplitParser { onRead: line => root.username = line }
    }

    Timer {
        id: focusTimer
        interval: 50
        onTriggered: keyInput.forceActiveFocus()
    }

    Rectangle {
        id: frame
        opacity: 0
        anchors.fill: parent
        color: Config.colors.base
        layer.enabled: true

        property int topOffset: 20

        PopupWindowFrame {
            windowTitle: root.hostname
            windowTitleIcon: ""
            windowTitleDecorationWidth: 70

            Item {
                anchors.fill: parent
                anchors.margins: 8
                anchors.topMargin: frame.topOffset + 18

                TextInput {
                    id: keyInput
                    focus: true
                    opacity: 0
                    width: 1; height: 1

                    Keys.onDownPressed:  root.navIndex = (root.navIndex + 1) % root.navCount
                    Keys.onUpPressed:    root.navIndex = (root.navIndex + root.navCount - 1) % root.navCount
                    Keys.onReturnPressed: if (root.navIndex >= 0) root.activateItem(root.navIndex)
                    Keys.onEscapePressed: root.closeCallback()
                }

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    ColumnLayout {
                        Layout.preferredWidth: root.implicitWidth * 0.33
                        Layout.maximumWidth: root.implicitWidth * 0.33
                        Layout.fillHeight: true
                        spacing: 4

                        Image {
                            Layout.fillWidth: true
                            Layout.preferredHeight: width
                            fillMode: Image.PreserveAspectFit
                            sourceSize.width: 80
                            sourceSize.height: 80
                            source: Config.settings.systemProfileImageSource

                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                                border.color: Config.colors.outline
                                border.width: 1
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: root.username
                            color: Config.colors.text
                            font.family: fontMonaco.name
                            font.pixelSize: Config.settings.bar.fontSize
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        }

                        Item { Layout.fillHeight: true }
                    }

                    Rectangle {
                        Layout.preferredWidth: 1
                        Layout.fillHeight: true
                        color: Config.colors.outline
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 0

                        Button {
                            Layout.fillWidth: true
                            implicitHeight: 36
                            onClicked: root.openThemeMenuCallback()
                            background: Rectangle {
                                color: (appearanceHover.hovered || root.navIndex === 0) ? Config.colors.highlight : "transparent"
                                border.color: "transparent"
                            }
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                spacing: 8
                                Text { font.family: iconFont.name; font.pixelSize: 20; color: Config.colors.text; text: "\ue3ae" }
                                Text { font.family: fontMonaco.name; font.pixelSize: Config.settings.bar.fontSize; color: Config.colors.text; text: "Appearance" }
                            }
                            HoverHandler { id: appearanceHover; acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad; cursorShape: Qt.PointingHandCursor }
                        }

                        Button {
                            Layout.fillWidth: true
                            implicitHeight: 36
                            onClicked: { Quickshell.execDetached(Config.settings.execCommands.files); root.closeCallback() }
                            background: Rectangle {
                                color: (filesHover.hovered || root.navIndex === 1) ? Config.colors.highlight : "transparent"
                                border.color: "transparent"
                            }
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                spacing: 8
                                Text { font.family: iconFont.name; font.pixelSize: 20; color: Config.colors.text; text: "\ue2c7" }
                                Text { font.family: fontMonaco.name; font.pixelSize: Config.settings.bar.fontSize; color: Config.colors.text; text: "Files" }
                            }
                            HoverHandler { id: filesHover; acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad; cursorShape: Qt.PointingHandCursor }
                        }

                        Button {
                            Layout.fillWidth: true
                            implicitHeight: 36
                            onClicked: { Quickshell.execDetached(Config.settings.execCommands.terminal); root.closeCallback() }
                            background: Rectangle {
                                color: (terminalHover.hovered || root.navIndex === 2) ? Config.colors.highlight : "transparent"
                                border.color: "transparent"
                            }
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                spacing: 8
                                Text { font.family: iconFont.name; font.pixelSize: 20; color: Config.colors.text; text: "\ueb8e" }
                                Text { font.family: fontMonaco.name; font.pixelSize: Config.settings.bar.fontSize; color: Config.colors.text; text: "Terminal" }
                            }
                            HoverHandler { id: terminalHover; acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad; cursorShape: Qt.PointingHandCursor }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: Config.colors.outline
                            Layout.leftMargin: 4
                            Layout.rightMargin: 4
                        }

                        Button {
                            Layout.fillWidth: true
                            implicitHeight: 36
                            onClicked: root.openAppLauncherCallback()
                            background: Rectangle {
                                color: (programsHover.hovered || root.navIndex === 3) ? Config.colors.highlight : "transparent"
                                border.color: "transparent"
                            }
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                spacing: 8
                                Text { font.family: iconFont.name; font.pixelSize: 20; color: Config.colors.text; text: "\ue8b6" }
                                Text { font.family: fontMonaco.name; font.pixelSize: Config.settings.bar.fontSize; color: Config.colors.text; text: "Programs" }
                            }
                            HoverHandler { id: programsHover; acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad; cursorShape: Qt.PointingHandCursor }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: Config.colors.outline
                            Layout.leftMargin: 4
                            Layout.rightMargin: 4
                        }

                        Button {
                            Layout.fillWidth: true
                            implicitHeight: 36
                            onClicked: root.closeCallback()
                            background: Rectangle {
                                color: (shutdownHover.hovered || root.navIndex === 4) ? Config.colors.highlight : "transparent"
                                border.color: "transparent"
                            }
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                spacing: 8
                                Text { font.family: iconFont.name; font.pixelSize: 20; color: Config.colors.text; text: "\uf418" }
                                Text { font.family: fontMonaco.name; font.pixelSize: Config.settings.bar.fontSize; color: Config.colors.text; text: "Shut Down" }
                            }
                            HoverHandler { id: shutdownHover; acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad; cursorShape: Qt.PointingHandCursor }
                        }

                        Item { Layout.fillHeight: true }
                    }
                }
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

    function openStartMenu() {
        root.visible = true;
        root.navIndex = -1;
        focusTimer.start();
        openAnimation.start();
    }

    function closeStartMenu() {
        closeAnimation.start();
    }
}
