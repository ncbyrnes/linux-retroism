import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import ".."

PopupWindow {
    id: root

    property int menuWidth: 0

    anchor.window: taskbar
    anchor.rect.x: menuWidth
    anchor.rect.y: 0
    anchor.edges: Edges.Top | Edges.Left
    anchor.gravity: Edges.Top | Edges.Right
    implicitWidth: 220
    implicitHeight: 100
    color: "transparent"

    Rectangle {
        id: frame
        opacity: 0
        anchors.fill: parent
        color: Config.colors.base
        layer.enabled: true

        property int topOffset: 20

        PopupWindowFrame {
            windowTitle: "Settings"
            windowTitleIcon: ""
            windowTitleDecorationWidth: 55

            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                anchors.topMargin: frame.topOffset + 18
                spacing: 8

                Text {
                    Layout.fillWidth: true
                    text: "Blue Selection Box"
                    font.family: fontMonaco.name
                    font.pixelSize: Config.settings.bar.fontSize
                    color: Config.colors.text
                    wrapMode: Text.WordWrap
                }

                Rectangle {
                    id: track
                    implicitWidth: 36
                    implicitHeight: 18
                    radius: 9
                    color: Config.settings.blueSelectionBox ? "#000080" : Config.colors.shadow
                    border.width: 1
                    border.color: Config.colors.outline

                    Rectangle {
                        width: 14
                        height: 14
                        radius: 7
                        y: 2
                        x: Config.settings.blueSelectionBox ? track.width - width - 2 : 2
                        color: Config.colors.base
                        border.width: 1
                        border.color: Config.colors.outline

                        Behavior on x {
                            NumberAnimation { duration: 100 }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Config.settings.blueSelectionBox = !Config.settings.blueSelectionBox
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

    function openThemeSettingsMenu() {
        root.visible = true;
        openAnimation.start();
    }

    function closeThemeSettingsMenu() {
        closeAnimation.start();
    }
}
