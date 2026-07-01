import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import ".."

PopupWindow {
    id: root

    property int menuWidth: 0
    property real volume: 0
    property bool muted: false
    readonly property real maxVolume: 1.5

    anchor.window: taskbar
    anchor.rect.x: menuWidth
    anchor.rect.y: 0
    anchor.edges: Edges.Top | Edges.Left
    anchor.gravity: Edges.Top | Edges.Right
    implicitWidth: 220
    implicitHeight: 140
    color: "transparent"

    function refreshVolume() {
        queryProcess.running = true;
    }

    function setVolume(fraction) {
        root.volume = Math.max(0, Math.min(root.maxVolume, fraction));
        Quickshell.execDetached(["bash", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ " + root.volume.toFixed(2)]);
    }

    function toggleMute() {
        root.muted = !root.muted;
        Quickshell.execDetached(["bash", "-c", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"]);
    }

    Process {
        id: queryProcess
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: line => {
                const match = line.match(/Volume:\s*([\d.]+)(\s*\[MUTED\])?/);
                if (match) {
                    root.volume = parseFloat(match[1]);
                    root.muted = !!match[2];
                }
            }
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
            windowTitle: "Audio"
            windowTitleIcon: ""
            windowTitleDecorationWidth: 50

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                anchors.topMargin: frame.topOffset + 18
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        Layout.fillWidth: true
                        text: "Volume"
                        font.family: fontMonaco.name
                        font.pixelSize: Config.settings.bar.fontSize
                        color: Config.colors.text
                    }
                    Text {
                        text: Math.round(root.volume * 100) + "%"
                        font.family: fontMonaco.name
                        font.pixelSize: Config.settings.bar.fontSize
                        color: Config.colors.text
                    }
                }

                Item {
                    id: sliderTrack
                    Layout.fillWidth: true
                    implicitHeight: 14

                    readonly property int thumbWidth: 10

                    // groove
                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        height: 4
                        color: Config.colors.shadow

                        Rectangle {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 1
                            color: Config.colors.outline
                        }
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 1
                            color: Config.colors.highlight
                        }
                    }

                    // thumb
                    Rectangle {
                        id: thumb
                        width: sliderTrack.thumbWidth
                        height: parent.height
                        x: (root.volume / root.maxVolume) * (sliderTrack.width - width)
                        color: Config.colors.base
                        border.width: 1
                        border.color: Config.colors.outline

                        Rectangle {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 1
                            color: Config.colors.highlight
                        }
                        Rectangle {
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            width: 1
                            color: Config.colors.highlight
                        }
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 1
                            color: Config.colors.shadow
                        }
                        Rectangle {
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                            width: 1
                            color: Config.colors.shadow
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        function moveTo(x) {
                            const travel = sliderTrack.width - sliderTrack.thumbWidth;
                            const pos = Math.max(0, Math.min(travel, x - sliderTrack.thumbWidth / 2));
                            root.setVolume(pos / travel * root.maxVolume);
                        }
                        onPressed: mouse => moveTo(mouse.x)
                        onPositionChanged: mouse => {
                            if (pressed)
                                moveTo(mouse.x);
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        Layout.fillWidth: true
                        text: "Mute"
                        font.family: fontMonaco.name
                        font.pixelSize: Config.settings.bar.fontSize
                        color: Config.colors.text
                    }

                    Rectangle {
                        id: muteTrack
                        implicitWidth: 36
                        implicitHeight: 18
                        radius: 9
                        color: root.muted ? Config.colors.accent : Config.colors.shadow
                        border.width: 1
                        border.color: Config.colors.outline

                        Rectangle {
                            width: 14
                            height: 14
                            radius: 7
                            y: 2
                            x: root.muted ? muteTrack.width - width - 2 : 2
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
                            onClicked: root.toggleMute()
                        }
                    }
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

    function openAudioMenu() {
        root.visible = true;
        root.refreshVolume();
        openAnimation.start();
    }

    function closeAudioMenu() {
        closeAnimation.start();
    }
}
