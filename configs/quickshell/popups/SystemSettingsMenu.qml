import Quickshell
import QtQuick
import QtQuick.Layouts
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
    implicitHeight: 90
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

            Item {
                anchors.fill: parent
                anchors.margins: 8
                anchors.topMargin: frame.topOffset + 18

                Text {
                    anchors.centerIn: parent
                    text: "Coming soon"
                    font.family: fontMonaco.name
                    font.pixelSize: Config.settings.bar.fontSize
                    color: Config.colors.text
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

    function openSystemSettingsMenu() {
        root.visible = true;
        openAnimation.start();
    }

    function closeSystemSettingsMenu() {
        closeAnimation.start();
    }
}
