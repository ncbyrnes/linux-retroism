import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import ".."

PopupWindow {
    id: root

    property int menuWidth: 0
    property var networks: []
    property string connectingSsid: ""
    property string statusText: ""

    anchor.window: taskbar
    anchor.rect.x: menuWidth
    anchor.rect.y: 0
    anchor.edges: Edges.Top | Edges.Left
    anchor.gravity: Edges.Top | Edges.Right
    implicitWidth: 280
    implicitHeight: 300
    color: "transparent"

    property var _scanBuffer: []

    Process {
        id: scanProcess
        command: ["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "device", "wifi", "list"]
        stdout: SplitParser {
            onRead: line => root._scanBuffer.push(line)
        }
        onExited: {
            const bySsid = {};
            for (const line of root._scanBuffer) {
                const parts = line.split(":");
                if (parts.length < 4)
                    continue;
                const inUse = parts[0] === "*";
                const ssid = parts[1];
                const signal = parseInt(parts[2], 10) || 0;
                const security = parts[3];
                if (!ssid)
                    continue;
                if (!bySsid[ssid] || bySsid[ssid].signal < signal || inUse) {
                    bySsid[ssid] = { ssid, signal, secured: security !== "", inUse };
                }
            }
            root.networks = Object.values(bySsid).sort((a, b) => b.signal - a.signal);
            root._scanBuffer = [];
        }
    }

    Process {
        id: connectProcess
        onExited: exitCode => {
            root.statusText = exitCode === 0 ? "Connected" : "Failed to connect";
            root.connectingSsid = "";
            root.rescan();
        }
    }

    function rescan() {
        root.statusText = "";
        root._scanBuffer = [];
        scanProcess.running = true;
    }

    function connectTo(ssid, password) {
        root.statusText = "Connecting…";
        connectProcess.command = password ? ["nmcli", "device", "wifi", "connect", ssid, "password", password] : ["nmcli", "device", "wifi", "connect", ssid];
        connectProcess.running = true;
    }

    Rectangle {
        id: frame
        opacity: 0
        anchors.fill: parent
        color: Config.colors.base
        layer.enabled: true

        property int topOffset: 20

        PopupWindowFrame {
            windowTitle: "Network"
            windowTitleIcon: ""
            windowTitleDecorationWidth: 50

            Item {
                anchors.fill: parent
                anchors.margins: 8
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                anchors.topMargin: frame.topOffset + 18
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    visible: root.connectingSsid === ""
                    spacing: 4

                    Text {
                        Layout.fillWidth: true
                        text: root.statusText
                        visible: root.statusText !== ""
                        font.family: fontMonaco.name
                        font.pixelSize: Config.settings.bar.fontSize
                        color: Config.colors.text
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"
                        border.color: Config.colors.outline
                        border.width: 1
                        clip: true

                        ListView {
                            id: networksView
                            model: root.networks
                            anchors.fill: parent
                            anchors.margins: 6
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
                                    background: Rectangle {
                                        anchors.fill: parent
                                        color: modelData.inUse ? Config.selectionColor : (netHover.hovered ? Config.colors.shadow : Config.colors.highlight)
                                        border.width: 1
                                    }
                                    onReleased: {
                                        if (modelData.inUse)
                                            return;
                                        if (modelData.secured)
                                            root.connectingSsid = modelData.ssid;
                                        else
                                            root.connectTo(modelData.ssid, "");
                                    }
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 8
                                        anchors.rightMargin: 8
                                        spacing: 6
                                        Text {
                                            Layout.fillWidth: true
                                            font.family: fontMonaco.name
                                            font.pixelSize: Config.settings.bar.fontSize
                                            color: modelData.inUse ? Config.selectionTextColor : Config.colors.text
                                            text: modelData.ssid
                                            elide: Text.ElideRight
                                        }
                                        Text {
                                            font.family: iconFont.name
                                            font.pixelSize: 16
                                            color: modelData.inUse ? Config.selectionTextColor : Config.colors.text
                                            text: modelData.secured ? "" : ""
                                        }
                                        Text {
                                            font.family: fontMonaco.name
                                            font.pixelSize: Config.settings.bar.fontSize
                                            color: modelData.inUse ? Config.selectionTextColor : Config.colors.text
                                            text: modelData.signal + "%"
                                        }
                                    }
                                    HoverHandler {
                                        id: netHover
                                        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                                        cursorShape: Qt.PointingHandCursor
                                    }
                                }
                            }

                            ScrollIndicator.vertical: ScrollIndicator {
                                active: networksView.moving
                            }
                        }
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    visible: root.connectingSsid !== ""
                    spacing: 8

                    Text {
                        Layout.fillWidth: true
                        text: "Connect to \"" + root.connectingSsid + "\""
                        wrapMode: Text.WordWrap
                        font.family: fontMonaco.name
                        font.pixelSize: Config.settings.bar.fontSize
                        color: Config.colors.text
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 32
                        color: Config.colors.highlight
                        border.color: Config.colors.outline
                        border.width: 1
                        clip: true

                        TextField {
                            id: passwordInput
                            anchors.fill: parent
                            echoMode: TextInput.Password
                            font.pixelSize: 14
                            font.family: fontMonaco.name
                            color: Config.colors.text
                            selectionColor: Config.selectionColor
                            padding: 6
                            selectByMouse: true
                            verticalAlignment: Text.AlignVCenter
                            background: Rectangle { color: "transparent" }

                            Keys.onEscapePressed: {
                                root.connectingSsid = "";
                                passwordInput.text = "";
                            }
                            onAccepted: {
                                root.connectTo(root.connectingSsid, passwordInput.text);
                                passwordInput.text = "";
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Button {
                            Layout.fillWidth: true
                            implicitHeight: 28
                            background: Rectangle { color: Config.colors.highlight; border.width: 1; border.color: Config.colors.outline }
                            onClicked: {
                                root.connectTo(root.connectingSsid, passwordInput.text);
                                passwordInput.text = "";
                            }
                            Text { anchors.centerIn: parent; text: "Connect"; font.family: fontMonaco.name; font.pixelSize: Config.settings.bar.fontSize; color: Config.colors.text }
                        }
                        Button {
                            Layout.fillWidth: true
                            implicitHeight: 28
                            background: Rectangle { color: Config.colors.highlight; border.width: 1; border.color: Config.colors.outline }
                            onClicked: {
                                root.connectingSsid = "";
                                passwordInput.text = "";
                            }
                            Text { anchors.centerIn: parent; text: "Cancel"; font.family: fontMonaco.name; font.pixelSize: Config.settings.bar.fontSize; color: Config.colors.text }
                        }
                    }

                    Item { Layout.fillHeight: true }
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

    function openNetworkMenu() {
        root.visible = true;
        root.connectingSsid = "";
        root.rescan();
        openAnimation.start();
    }

    function closeNetworkMenu() {
        closeAnimation.start();
    }
}
