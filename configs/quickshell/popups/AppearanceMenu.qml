import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import ".."

PopupWindow {
    id: root

    property int menuWidth: 0
    property var openThemesCallback: function () {}
    property var openWallpaperCallback: function () {}
    property var openThemeSettingsCallback: function () {}
    property int activeFlyout: Config.SystemPopup.None

    readonly property int contentTop: frame.topOffset + 18
    readonly property int rowHeight: 36

    anchor.window: taskbar
    anchor.rect.x: menuWidth
    anchor.rect.y: 0
    anchor.edges: Edges.Top | Edges.Left
    anchor.gravity: Edges.Top | Edges.Right
    implicitWidth: 220
    implicitHeight: 158
    color: "transparent"

    Rectangle {
        id: frame
        opacity: 0
        anchors.fill: parent
        color: Config.colors.base
        layer.enabled: true

        property int topOffset: 20

        PopupWindowFrame {
            windowTitle: "Appearance"
            windowTitleIcon: ""
            windowTitleDecorationWidth: 55

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                anchors.topMargin: frame.topOffset + 18
                spacing: 0

                Button {
                    id: themesButton
                    Layout.fillWidth: true
                    implicitHeight: 36
                    property bool isActive: themesHover.hovered || root.activeFlyout === Config.SystemPopup.ThemePicker
                    onClicked: root.openThemesCallback()
                    background: Rectangle {
                        color: themesButton.isActive ? Config.selectionColor : "transparent"
                        border.color: "transparent"
                    }
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        spacing: 8
                        Text { font.family: iconFont.name; font.pixelSize: 20; color: themesButton.isActive ? Config.selectionTextColor : Config.colors.text; text: "" }
                        Text { font.family: fontMonaco.name; font.pixelSize: Config.settings.bar.fontSize; color: themesButton.isActive ? Config.selectionTextColor : Config.colors.text; text: "Themes" }
                    }
                    HoverHandler { id: themesHover; acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad; cursorShape: Qt.PointingHandCursor }
                }

                Button {
                    id: wallpaperButton
                    Layout.fillWidth: true
                    implicitHeight: 36
                    property bool isActive: wallpaperHover.hovered || root.activeFlyout === Config.SystemPopup.Wallpaper
                    onClicked: root.openWallpaperCallback()
                    background: Rectangle {
                        color: wallpaperButton.isActive ? Config.selectionColor : "transparent"
                        border.color: "transparent"
                    }
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        spacing: 8
                        Text { font.family: iconFont.name; font.pixelSize: 20; color: wallpaperButton.isActive ? Config.selectionTextColor : Config.colors.text; text: "" }
                        Text { font.family: fontMonaco.name; font.pixelSize: Config.settings.bar.fontSize; color: wallpaperButton.isActive ? Config.selectionTextColor : Config.colors.text; text: "Wallpaper" }
                    }
                    HoverHandler { id: wallpaperHover; acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad; cursorShape: Qt.PointingHandCursor }
                }

                Button {
                    id: settingsButton
                    Layout.fillWidth: true
                    implicitHeight: 36
                    property bool isActive: settingsHover.hovered || root.activeFlyout === Config.SystemPopup.ThemeSettings
                    onClicked: root.openThemeSettingsCallback()
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

    function openAppearanceMenu() {
        root.visible = true;
        openAnimation.start();
    }

    function closeAppearanceMenu() {
        closeAnimation.start();
    }
}
