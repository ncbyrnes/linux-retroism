import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import Quickshell.Wayland
import ".."
import "../utils" as Utils

PopupWindow {
    id: root

    property int menuWidth: 0
    property int popupWidth: 280
    property int screenHeight: 0
    property var currentApps: []
    property var closeCallback: function () {}

    anchor.window: taskbar
    anchor.rect.x: menuWidth
    anchor.rect.y: 0
    anchor.edges: Edges.Top | Edges.Left
    anchor.gravity: Edges.Top | Edges.Right
    implicitWidth: popupWidth
    implicitHeight: 300
    color: "transparent"

    Rectangle {
        id: frame
        opacity: 0
        anchors.fill: parent
        color: Config.colors.base
        layer.enabled: true

        property int topOffset: 20

        PopupWindowFrame {
            windowTitle: "Programs"
            windowTitleIcon: ""
            windowTitleDecorationWidth: 80
            Item {
                id: content
                anchors.fill: parent
                anchors.margins: 8
                anchors.topMargin: frame.topOffset + 12
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 36
                        color: Config.colors.highlight
                        border.color: Config.colors.outline
                        border.width: 1
                        clip: true
                        TextField {
                            id: searchInput
                            width: parent.width
                            anchors.centerIn: parent
                            text: ""
                            font.pixelSize: 14
                            font.family: fontMonaco.name
                            color: Config.colors.text
                            selectionColor: Config.selectionColor
                            padding: 2
                            selectByMouse: true
                            cursorVisible: false
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            focus: true

                            background: Rectangle { color: "transparent" }

                            Keys.onEscapePressed: root.closeCallback()

                            Component.onCompleted: searchInput.forceActiveFocus()

                            onAccepted: {
                                if (root.currentApps.length == 1) {
                                    root.currentApps[0].execute();
                                    root.closeCallback();
                                }
                            }
                            onTextChanged: {
                                root.currentApps = Utils.AppSearch.fuzzyQuery(searchInput.text);
                            }
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"
                        border.color: Config.colors.outline
                        border.width: 1
                        clip: true

                        ListView {
                            id: appsView
                            model: root.currentApps
                            anchors.fill: parent
                            anchors.margins: 6
                            anchors.bottomMargin: 1
                            flickableDirection: Flickable.VerticalFlick
                            boundsBehavior: Flickable.DragOverBounds
                            maximumFlickVelocity: 3500
                            clip: true
                            spacing: 4

                            delegate: Item {
                                width: parent.width
                                height: 32
                                Button {
                                    width: parent.width
                                    height: 32
                                    opacity: mouse.hovered ? 0.75 : 1
                                    background: Rectangle {
                                        anchors.fill: parent
                                        color: parent.pressed ? Config.colors.shadow : Config.colors.highlight
                                        border.width: 1
                                    }
                                    onReleased: {
                                        modelData.execute();
                                        root.closeCallback();
                                    }
                                    Text {
                                        anchors.fill: parent
                                        leftPadding: 8
                                        verticalAlignment: Text.AlignVCenter
                                        font.family: fontMonaco.name
                                        font.pixelSize: Config.settings.bar.fontSize
                                        color: Config.colors.text
                                        text: modelData.name
                                    }
                                    HoverHandler {
                                        id: mouse
                                        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                                        cursorShape: Qt.PointingHandCursor
                                    }
                                }
                            }

                            ScrollIndicator.vertical: ScrollIndicator {
                                active: appsView.moving
                            }
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

    function openAppLauncher() {
        root.visible = true;
        root.currentApps = Utils.AppSearch.fuzzyQuery("A");
        searchInput.text = "";
        openAnimation.start();
    }

    function closeAppLauncher() {
        closeAnimation.start();
    }
}
