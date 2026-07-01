import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import ".."

PopupWindow {
    id: root

    property int menuWidth: 0
    property string screenName: ""
    property string wallpaperDir: "/home/nichole/Pictures/wallpaper"
    property var wallpapers: []

    anchor.window: taskbar
    anchor.rect.x: menuWidth
    anchor.rect.y: 0
    anchor.edges: Edges.Top | Edges.Left
    anchor.gravity: Edges.Top | Edges.Right
    implicitWidth: 280
    implicitHeight: 300
    color: "transparent"

    Process {
        id: scanProcess
        command: ["bash", "-c", "find '" + root.wallpaperDir + "' -maxdepth 1 -type f \\( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \\) | sort"]
        stdout: SplitParser {
            onRead: line => root.wallpapers = root.wallpapers.concat([line])
        }
    }

    Rectangle {
        id: frame
        opacity: 0
        anchors.fill: parent
        color: Config.colors.base
        layer.enabled: true

        property int topOffset: 20

        PopupWindowFrame {
            windowTitle: "Wallpaper"
            windowTitleIcon: ""
            windowTitleDecorationWidth: 60

            GridView {
                anchors.fill: parent
                anchors.margins: 8
                anchors.topMargin: frame.topOffset + 18
                clip: true

                cellWidth: 84
                cellHeight: 84
                model: root.wallpapers

                delegate: Item {
                    width: 84
                    height: 84

                    Button {
                        anchors.fill: parent
                        anchors.margins: 4
                        opacity: thumbHover.hovered ? 0.8 : 1

                        onClicked: {
                            Quickshell.execDetached(["bash", "-c", "hyprctl hyprpaper preload '" + modelData + "' && hyprctl hyprpaper wallpaper '" + root.screenName + "," + modelData + "'"]);
                        }

                        background: Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            border.width: 1
                            border.color: Config.colors.outline
                        }

                        Image {
                            anchors.fill: parent
                            anchors.margins: 1
                            source: "file://" + modelData
                            fillMode: Image.PreserveAspectCrop
                            sourceSize.width: 76
                            sourceSize.height: 76
                            clip: true
                        }

                        HoverHandler {
                            id: thumbHover
                            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                            cursorShape: Qt.PointingHandCursor
                        }
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

    function openWallpaperMenu() {
        root.visible = true;
        root.wallpapers = [];
        scanProcess.running = true;
        openAnimation.start();
    }

    function closeWallpaperMenu() {
        closeAnimation.start();
    }
}
