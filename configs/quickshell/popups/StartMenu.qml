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
    property var openShutdownMenuCallback: function () {}
    property var openSystemSettingsMenuCallback: function () {}
    property var openNetworkMenuCallback: function () {}
    property var openAudioMenuCallback: function () {}

    property string hostname: ""
    property string username: ""
    property int navIndex: -1
    readonly property int navCount: 8
    property int activeSubPopup: Config.SystemPopup.None

    readonly property int contentTop: frame.topOffset + 18
    readonly property int rowHeight: 36

    function activateItem(idx) {
        switch (idx) {
        case 0: root.openAppLauncherCallback(); break;
        case 1: Quickshell.execDetached(Config.settings.execCommands.files); root.closeCallback(); break;
        case 2: Quickshell.execDetached(Config.settings.execCommands.terminal); root.closeCallback(); break;
        case 3: root.openSystemSettingsMenuCallback(); break;
        case 4: root.openThemeMenuCallback(); break;
        case 5: root.openNetworkMenuCallback(); break;
        case 6: root.openAudioMenuCallback(); break;
        case 7: root.openShutdownMenuCallback(); break;
        }
    }

    anchor.window: taskbar
    anchor.rect.x: menuWidth
    anchor.rect.y: 0
    anchor.edges: Edges.Top | Edges.Left
    anchor.gravity: Edges.Top | Edges.Right
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
                            id: programsButton
                            Layout.fillWidth: true
                            implicitHeight: 36
                            property bool isActive: programsHover.hovered || root.navIndex === 0 || root.activeSubPopup === Config.SystemPopup.AppLauncher
                            onClicked: root.openAppLauncherCallback()
                            background: Rectangle {
                                color: programsButton.isActive ? Config.selectionColor : "transparent"
                                border.color: "transparent"
                            }
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                spacing: 8
                                Text { font.family: iconFont.name; font.pixelSize: 20; color: programsButton.isActive ? Config.selectionTextColor : Config.colors.text; text: "\ue8b6" }
                                Text { font.family: fontMonaco.name; font.pixelSize: Config.settings.bar.fontSize; color: programsButton.isActive ? Config.selectionTextColor : Config.colors.text; text: "Programs" }
                            }
                            HoverHandler { id: programsHover; acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad; cursorShape: Qt.PointingHandCursor }
                        }

                        Button {
                            id: filesButton
                            Layout.fillWidth: true
                            implicitHeight: 36
                            property bool isActive: filesHover.hovered || root.navIndex === 1
                            onClicked: { Quickshell.execDetached(Config.settings.execCommands.files); root.closeCallback() }
                            background: Rectangle {
                                color: filesButton.isActive ? Config.selectionColor : "transparent"
                                border.color: "transparent"
                            }
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                spacing: 8
                                Text { font.family: iconFont.name; font.pixelSize: 20; color: filesButton.isActive ? Config.selectionTextColor : Config.colors.text; text: "\ue2c7" }
                                Text { font.family: fontMonaco.name; font.pixelSize: Config.settings.bar.fontSize; color: filesButton.isActive ? Config.selectionTextColor : Config.colors.text; text: "Files" }
                            }
                            HoverHandler { id: filesHover; acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad; cursorShape: Qt.PointingHandCursor }
                        }

                        Button {
                            id: terminalButton
                            Layout.fillWidth: true
                            implicitHeight: 36
                            property bool isActive: terminalHover.hovered || root.navIndex === 2
                            onClicked: { Quickshell.execDetached(Config.settings.execCommands.terminal); root.closeCallback() }
                            background: Rectangle {
                                color: terminalButton.isActive ? Config.selectionColor : "transparent"
                                border.color: "transparent"
                            }
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                spacing: 8
                                Text { font.family: iconFont.name; font.pixelSize: 20; color: terminalButton.isActive ? Config.selectionTextColor : Config.colors.text; text: "\ueb8e" }
                                Text { font.family: fontMonaco.name; font.pixelSize: Config.settings.bar.fontSize; color: terminalButton.isActive ? Config.selectionTextColor : Config.colors.text; text: "Terminal" }
                            }
                            HoverHandler { id: terminalHover; acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad; cursorShape: Qt.PointingHandCursor }
                        }

                        Button {
                            id: settingsButton
                            Layout.fillWidth: true
                            implicitHeight: 36
                            property bool isActive: settingsHover.hovered || root.navIndex === 3 || root.activeSubPopup === Config.SystemPopup.SystemSettings
                            onClicked: root.openSystemSettingsMenuCallback()
                            background: Rectangle {
                                color: settingsButton.isActive ? Config.selectionColor : "transparent"
                                border.color: "transparent"
                            }
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                spacing: 8
                                Text { font.family: iconFont.name; font.pixelSize: 20; color: settingsButton.isActive ? Config.selectionTextColor : Config.colors.text; text: "" }
                                Text { font.family: fontMonaco.name; font.pixelSize: Config.settings.bar.fontSize; color: settingsButton.isActive ? Config.selectionTextColor : Config.colors.text; text: "Settings" }
                            }
                            HoverHandler { id: settingsHover; acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad; cursorShape: Qt.PointingHandCursor }
                        }

                        Button {
                            id: appearanceButton
                            Layout.fillWidth: true
                            implicitHeight: 36
                            property bool isActive: appearanceHover.hovered || root.navIndex === 4 || root.activeSubPopup === Config.SystemPopup.Appearance
                            onClicked: root.openThemeMenuCallback()
                            background: Rectangle {
                                color: appearanceButton.isActive ? Config.selectionColor : "transparent"
                                border.color: "transparent"
                            }
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                spacing: 8
                                Text { font.family: iconFont.name; font.pixelSize: 20; color: appearanceButton.isActive ? Config.selectionTextColor : Config.colors.text; text: "\ue3ae" }
                                Text { font.family: fontMonaco.name; font.pixelSize: Config.settings.bar.fontSize; color: appearanceButton.isActive ? Config.selectionTextColor : Config.colors.text; text: "Appearance" }
                            }
                            HoverHandler { id: appearanceHover; acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad; cursorShape: Qt.PointingHandCursor }
                        }

                        Button {
                            id: networkButton
                            Layout.fillWidth: true
                            implicitHeight: 36
                            property bool isActive: networkHover.hovered || root.navIndex === 5 || root.activeSubPopup === Config.SystemPopup.Network
                            onClicked: root.openNetworkMenuCallback()
                            background: Rectangle {
                                color: networkButton.isActive ? Config.selectionColor : "transparent"
                                border.color: "transparent"
                            }
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                spacing: 8
                                Text { font.family: iconFont.name; font.pixelSize: 20; color: networkButton.isActive ? Config.selectionTextColor : Config.colors.text; text: "" }
                                Text { font.family: fontMonaco.name; font.pixelSize: Config.settings.bar.fontSize; color: networkButton.isActive ? Config.selectionTextColor : Config.colors.text; text: "Network" }
                            }
                            HoverHandler { id: networkHover; acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad; cursorShape: Qt.PointingHandCursor }
                        }

                        Button {
                            id: audioButton
                            Layout.fillWidth: true
                            implicitHeight: 36
                            property bool isActive: audioHover.hovered || root.navIndex === 6 || root.activeSubPopup === Config.SystemPopup.Audio
                            onClicked: root.openAudioMenuCallback()
                            background: Rectangle {
                                color: audioButton.isActive ? Config.selectionColor : "transparent"
                                border.color: "transparent"
                            }
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                spacing: 8
                                Text { font.family: iconFont.name; font.pixelSize: 20; color: audioButton.isActive ? Config.selectionTextColor : Config.colors.text; text: "" }
                                Text { font.family: fontMonaco.name; font.pixelSize: Config.settings.bar.fontSize; color: audioButton.isActive ? Config.selectionTextColor : Config.colors.text; text: "Audio" }
                            }
                            HoverHandler { id: audioHover; acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad; cursorShape: Qt.PointingHandCursor }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: Config.colors.outline
                            Layout.leftMargin: 4
                            Layout.rightMargin: 4
                        }

                        Button {
                            id: shutdownButton
                            Layout.fillWidth: true
                            implicitHeight: 36
                            property bool isActive: shutdownHover.hovered || root.navIndex === 7 || root.activeSubPopup === Config.SystemPopup.Shutdown
                            onClicked: root.openShutdownMenuCallback()
                            background: Rectangle {
                                color: shutdownButton.isActive ? Config.selectionColor : "transparent"
                                border.color: "transparent"
                            }
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                spacing: 8
                                Text { font.family: iconFont.name; font.pixelSize: 20; color: shutdownButton.isActive ? Config.selectionTextColor : Config.colors.text; text: "\uf418" }
                                Text { font.family: fontMonaco.name; font.pixelSize: Config.settings.bar.fontSize; color: shutdownButton.isActive ? Config.selectionTextColor : Config.colors.text; text: "Shut Down" }
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
