import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

import "../popups" as Popups
import ".."

Scope {
    // Taskbar variants, we have one taskber per screen.
    Variants {
        model: Quickshell.screens
        Item {
            id: root
            required property var modelData
            property int currentPopup: Config.SystemPopup.None

            PanelWindow {
                id: taskbar
                screen: root.modelData
                WlrLayershell.layer: WlrLayer.Bottom
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

                anchors {
                    top: true
                    left: true
                    right: true
                }
                implicitHeight: 35

                /*=== Taskbar Background (colors & shading) ===*/
                color: Config.colors.base
                Item {
                    id: taskbarBackground
                    anchors.fill: parent
                    NewBorder {
                        commonBorderWidth: 4
                        commonBorder: false
                        lBorderwidth: 10
                        rBorderwidth: 1
                        tBorderwidth: 10
                        bBorderwidth: 1
                        borderColor: Config.colors.shadow
                    }
                    NewBorder {
                        commonBorderWidth: 4
                        commonBorder: false
                        lBorderwidth: 10
                        rBorderwidth: 10
                        tBorderwidth: 1
                        bBorderwidth: 10
                        borderColor: Config.colors.highlight
                    }

                    Rectangle {
                        id: barBackground
                        anchors {
                            fill: parent
                            margins: 0
                        }
                        color: "transparent"
                        radius: 0
                        border.width: 1
                        border.color: Config.colors.outline
                    }
                }
                /*=== ===================================== ===*/


                /*=== StartMenu & Other popup Stuff ===*/
                Popups.StartMenu {
                    id: startMenu
                    menuWidth: 0
                    closeCallback: taskbar.closeAllPopups
                    openAppLauncherCallback: () => {
                        startMenu.closeStartMenu();
                        root.currentPopup = Config.SystemPopup.None;
                        appLauncher.openAppLauncher();
                        root.currentPopup = Config.SystemPopup.AppLauncher;
                    }
                    openThemeMenuCallback: () => {
                        startMenu.closeStartMenu();
                        root.currentPopup = Config.SystemPopup.None;
                        themeMenu.openThemeMenu();
                        root.currentPopup = Config.SystemPopup.ThemePicker;
                    }
                }
                Popups.ThemeMenu {
                    id: themeMenu
                    menuWidth: 0
                }
                Popups.AppLauncher {
                    id: appLauncher
                    closeCallback: taskbar.closeAllPopups
                    menuWidth: 0
                    popupWidth: 280
                    screenHeight: modelData.height
                }
                function closeAllPopups() {
                    switch (root.currentPopup) {
                    case Config.SystemPopup.Startmenu:
                        startMenu.closeStartMenu();
                        break;
                    case Config.SystemPopup.ThemePicker:
                        themeMenu.closeThemeMenu();
                        break;
                    case Config.SystemPopup.AppLauncher:
                        appLauncher.closeAppLauncher();
                        break;
                    }
                    root.currentPopup = Config.SystemPopup.None;
                }

                Button {
                    id: appLauncherButton
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 11
                    implicitHeight: 24
                    implicitWidth: 46

                    onClicked: {
                        if (root.currentPopup == Config.SystemPopup.None) {
                            startMenu.openStartMenu();
                            root.currentPopup = Config.SystemPopup.Startmenu;
                        } else {
                            taskbar.closeAllPopups();
                            root.currentPopup = Config.SystemPopup.None;
                        }
                    }

                    background: Rectangle {
                        color: root.currentPopup == Config.SystemPopup.Startmenu ? Config.colors.shadow : "transparent"
                        border.width: 1
                        border.color: Config.colors.outline
                    }

                    Text {
                        anchors.centerIn: parent
                        font.family: fontMonaco.name
                        font.pixelSize: Config.settings.bar.fontSize
                        text: "Start"
                        color: Config.colors.outline
                    }

                    HoverHandler { cursorShape: Qt.PointingHandCursor }
                }
                Scope {
                    id: startMenuIpc
                    property string screenName: taskbar.screen.name
                    IpcHandler {
                        target: "startMenu_" + startMenuIpc.screenName
                        function toggleStartMenu() {
                            if (root.currentPopup == Config.SystemPopup.None) {
                                startMenu.openStartMenu();
                                root.currentPopup = Config.SystemPopup.Startmenu;
                            } else {
                                taskbar.closeAllPopups();
                                root.currentPopup = Config.SystemPopup.None;
                            }
                        }
                    }
                }

                /*=== ============================= ===*/

                /*=== System Tray & Background for it ===*/
                Item {
                    id: test
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    height: parent.height - 8
                    width: sysTray.width + 18
                    Rectangle {
                        id: background
                        anchors.fill: test

                        anchors.bottomMargin: -2
                        color: "transparent"
                        Rectangle {
                            anchors.fill: background
                            border.width: 0
                            color: Config.colors.shadow
                        }
                        Rectangle {
                            anchors.fill: background
                            color: "transparent"
                            border.width: 1
                            z: -5
                            anchors.margins: -1
                            anchors.bottomMargin: 1
                        }
                    }
                    SysTray {
                        id: sysTray
                    }
                }
                /*=== =============================== ===*/
            }

            /*=== POPUP CLOSING PANEL ===*/
            // This panel is strictly for detecting clicks
            // outside of popups in order to close them.
            PanelWindow {
                id: overlay
                screen: root.modelData
                color: "transparent"

                implicitHeight: screen.height

                // Better UX to not have it close on hotbar press? idk. TODO: Figure this out
                //implicitHeight: screen.height - taskbar.implicitHeight

                anchors {
                    bottom: true
                    left: true
                    right: true
                }

                visible: root.currentPopup != Config.SystemPopup.None ? true : false

                exclusionMode: ExclusionMode.Ignore

                MouseArea {
                    id: popupArea
                    width: Screen.width
                    height: Screen.height
                    visible: root.currentPopup != Config.SystemPopup.None ? true : false
                    onClicked: {
                        taskbar.closeAllPopups();
                    }
                }
            }
            /*=== =================== ===*/
        }
    }

    enum SystemPopups {
        Startmenu,
        ThemePicker,
        None
    }
}
