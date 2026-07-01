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
            property int currentSubPopup: Config.SystemPopup.None
            property int currentFlyout: Config.SystemPopup.None

            PanelWindow {
                id: taskbar
                screen: root.modelData
                WlrLayershell.layer: WlrLayer.Bottom
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

                anchors {
                    bottom: true
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
                        tBorderwidth: 1
                        bBorderwidth: 10
                        borderColor: Config.colors.shadow
                    }
                    NewBorder {
                        commonBorderWidth: 4
                        commonBorder: false
                        lBorderwidth: 10
                        rBorderwidth: 10
                        tBorderwidth: 10
                        bBorderwidth: 1
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
                    activeSubPopup: root.currentSubPopup
                    closeCallback: taskbar.closeAllPopups
                    openAppLauncherCallback: () => {
                        if (root.currentSubPopup == Config.SystemPopup.AppLauncher) {
                            appLauncher.closeAppLauncher();
                            root.currentSubPopup = Config.SystemPopup.None;
                            return;
                        }
                        taskbar.closeSubPopups();
                        appLauncher.openAppLauncher();
                        root.currentSubPopup = Config.SystemPopup.AppLauncher;
                    }
                    openThemeMenuCallback: () => {
                        if (root.currentSubPopup == Config.SystemPopup.Appearance) {
                            appearanceMenu.closeAppearanceMenu();
                            root.currentSubPopup = Config.SystemPopup.None;
                            return;
                        }
                        taskbar.closeSubPopups();
                        appearanceMenu.openAppearanceMenu();
                        root.currentSubPopup = Config.SystemPopup.Appearance;
                    }
                    openShutdownMenuCallback: () => {
                        if (root.currentSubPopup == Config.SystemPopup.Shutdown) {
                            shutdownMenu.closeShutdownMenu();
                            root.currentSubPopup = Config.SystemPopup.None;
                            return;
                        }
                        taskbar.closeSubPopups();
                        shutdownMenu.openShutdownMenu();
                        root.currentSubPopup = Config.SystemPopup.Shutdown;
                    }
                    openSystemSettingsMenuCallback: () => {
                        if (root.currentSubPopup == Config.SystemPopup.SystemSettings) {
                            systemSettingsMenu.closeSystemSettingsMenu();
                            root.currentSubPopup = Config.SystemPopup.None;
                            return;
                        }
                        taskbar.closeSubPopups();
                        systemSettingsMenu.openSystemSettingsMenu();
                        root.currentSubPopup = Config.SystemPopup.SystemSettings;
                    }
                    openNetworkMenuCallback: () => {
                        if (root.currentSubPopup == Config.SystemPopup.Network) {
                            networkMenu.closeNetworkMenu();
                            root.currentSubPopup = Config.SystemPopup.None;
                            return;
                        }
                        taskbar.closeSubPopups();
                        networkMenu.openNetworkMenu();
                        root.currentSubPopup = Config.SystemPopup.Network;
                    }
                    openAudioMenuCallback: () => {
                        if (root.currentSubPopup == Config.SystemPopup.Audio) {
                            audioMenu.closeAudioMenu();
                            root.currentSubPopup = Config.SystemPopup.None;
                            return;
                        }
                        taskbar.closeSubPopups();
                        audioMenu.openAudioMenu();
                        root.currentSubPopup = Config.SystemPopup.Audio;
                    }
                }
                Popups.AppearanceMenu {
                    id: appearanceMenu
                    menuWidth: startMenu.implicitWidth + 4
                    activeFlyout: root.currentFlyout
                    anchor.rect.y: -(startMenu.implicitHeight - (startMenu.contentTop + 4 * startMenu.rowHeight) - appearanceMenu.implicitHeight)
                    openThemesCallback: () => taskbar.openAppearanceFlyout(Config.SystemPopup.ThemePicker)
                    openWallpaperCallback: () => taskbar.openAppearanceFlyout(Config.SystemPopup.Wallpaper)
                    openThemeSettingsCallback: () => taskbar.openAppearanceFlyout(Config.SystemPopup.ThemeSettings)
                }
                Popups.ThemeMenu {
                    id: themeMenu
                    menuWidth: startMenu.implicitWidth + appearanceMenu.implicitWidth + 4
                    anchor.rect.y: 0
                }
                Popups.WallpaperMenu {
                    id: wallpaperMenu
                    menuWidth: startMenu.implicitWidth + appearanceMenu.implicitWidth + 4
                    screenName: root.modelData.name
                    anchor.rect.y: 0
                }
                Popups.ThemeSettingsMenu {
                    id: themeSettingsMenu
                    menuWidth: startMenu.implicitWidth + appearanceMenu.implicitWidth + 4
                    anchor.rect.y: 0
                }
                Popups.AppLauncher {
                    id: appLauncher
                    closeCallback: taskbar.closeAllPopups
                    menuWidth: startMenu.implicitWidth + 4
                    popupWidth: 280
                    screenHeight: modelData.height
                    anchor.rect.y: 0
                }
                Popups.ShutdownMenu {
                    id: shutdownMenu
                    closeAllCallback: taskbar.closeAllPopups
                    menuWidth: startMenu.implicitWidth + 4
                    anchor.rect.y: 0
                }
                Popups.SystemSettingsMenu {
                    id: systemSettingsMenu
                    menuWidth: startMenu.implicitWidth + 4
                    anchor.rect.y: 0
                }
                Popups.NetworkMenu {
                    id: networkMenu
                    menuWidth: startMenu.implicitWidth + 4
                    anchor.rect.y: 0
                }
                Popups.AudioMenu {
                    id: audioMenu
                    menuWidth: startMenu.implicitWidth + 4
                    anchor.rect.y: 0
                }
                function closeAppearanceFlyout(flyout) {
                    switch (flyout) {
                    case Config.SystemPopup.ThemePicker:
                        themeMenu.closeThemeMenu();
                        break;
                    case Config.SystemPopup.Wallpaper:
                        wallpaperMenu.closeWallpaperMenu();
                        break;
                    case Config.SystemPopup.ThemeSettings:
                        themeSettingsMenu.closeThemeSettingsMenu();
                        break;
                    }
                }
                function openAppearanceFlyout(flyout) {
                    if (root.currentFlyout == flyout) {
                        taskbar.closeAppearanceFlyout(flyout);
                        root.currentFlyout = Config.SystemPopup.None;
                        return;
                    }
                    taskbar.closeAppearanceFlyout(root.currentFlyout);
                    switch (flyout) {
                    case Config.SystemPopup.ThemePicker:
                        themeMenu.openThemeMenu();
                        break;
                    case Config.SystemPopup.Wallpaper:
                        wallpaperMenu.openWallpaperMenu();
                        break;
                    case Config.SystemPopup.ThemeSettings:
                        themeSettingsMenu.openThemeSettingsMenu();
                        break;
                    }
                    root.currentFlyout = flyout;
                }
                function closeSubPopups() {
                    taskbar.closeAppearanceFlyout(root.currentFlyout);
                    root.currentFlyout = Config.SystemPopup.None;

                    switch (root.currentSubPopup) {
                    case Config.SystemPopup.Appearance:
                        appearanceMenu.closeAppearanceMenu();
                        break;
                    case Config.SystemPopup.AppLauncher:
                        appLauncher.closeAppLauncher();
                        break;
                    case Config.SystemPopup.Shutdown:
                        shutdownMenu.closeShutdownMenu();
                        break;
                    case Config.SystemPopup.SystemSettings:
                        systemSettingsMenu.closeSystemSettingsMenu();
                        break;
                    case Config.SystemPopup.Network:
                        networkMenu.closeNetworkMenu();
                        break;
                    case Config.SystemPopup.Audio:
                        audioMenu.closeAudioMenu();
                        break;
                    }
                    root.currentSubPopup = Config.SystemPopup.None;
                }
                function closeAllPopups() {
                    taskbar.closeSubPopups();

                    if (root.currentPopup == Config.SystemPopup.Startmenu) {
                        startMenu.closeStartMenu();
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

                visible: root.currentPopup != Config.SystemPopup.None || root.currentSubPopup != Config.SystemPopup.None || root.currentFlyout != Config.SystemPopup.None

                exclusionMode: ExclusionMode.Ignore

                MouseArea {
                    id: popupArea
                    width: Screen.width
                    height: Screen.height
                    visible: root.currentPopup != Config.SystemPopup.None || root.currentSubPopup != Config.SystemPopup.None || root.currentFlyout != Config.SystemPopup.None
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
