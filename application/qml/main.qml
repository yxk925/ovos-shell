/*
 * Copyright 2020 Aditya Mehra <Aix.m@outlook.com>
 * Copyright 2018 by Marco Martin <mart@kde.org>
 * Copyright 2018 David Edmundson <davidedmundson@kde.org>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.9
import QtGraphicalEffects 1.0
import org.kde.kirigami 2.9 as Kirigami
import QtQuick.Window 2.2
import Mycroft 1.0 as Mycroft
import QtQuick.Controls.Material 2.0
import "./panel" as Panel
import "./osd" as Osd
import OVOSPlugin 1.0 as OVOSPlugin

Kirigami.AbstractApplicationWindow {
    id: root
    visible: true
    visibility: "Maximized"
    flags: Qt.FramelessWindowHint
    property var controllerStatus: Mycroft.MycroftController.status
    property bool platformEGLFS: true
    property bool slidingPanelShouldOpen: false

    function showShutDownDialog() {
        slidingPanel.close()
        shutdownOptions.open()
    }

    onControllerStatusChanged: {
        serviceWatcher.queryGuiServiceIsAlive();
        serviceWatcher.querySkillServiceIsAlive();
    }

    Component.onCompleted: {
        var platform = environmentSummary.readVariable("QT_QPA_PLATFORM")
        if (platform == "eglfs") {
            platformEGLFS = true
        }
        Kirigami.Units.longDuration = 100;
        Kirigami.Units.shortDuration = 100;
        palette.mid = OVOSPlugin.Configuration.secondaryColor
        palette.dark = Qt.darker(OVOSPlugin.Configuration.secondaryColor, 1.2)
    }

    Connections {
        target: OVOSPlugin.Configuration
        onSchemeChanged: {
          contentsRect.visible = false
          contentsRect.visible = true
          palette.mid = OVOSPlugin.Configuration.secondaryColor
          palette.dark = Qt.darker(OVOSPlugin.Configuration.secondaryColor, 1.2)
        }
    }

    Connections {
        target: resetOperations
        onResetOperationsStarted: {
            contentsRect.visible = false
            contentsRect.enabled = false
            factoryResetUI.visible = true
            factoryResetUI.enabled = true
        }
        onResetOperationsFinished: {
            var platform = environmentSummary.readVariable("QT_QPA_PLATFORM")
            if (platform == "eglfs") {
                resetOperations.runRestartDevice()
            }
        }
    }

    Connections {
        target: Mycroft.MycroftController
        onIntentRecevied: {
            if (type == "ovos.shell.exec.factory.reset") {
                var script_to_run_path = data.script
                resetOperations.runResetOperations(script_to_run_path)
            }
            if (type == "ovos.shell.oauth.start.authentication") {
                oauthLoader.url = data.url
                oauthLoader.needsCredentials = data.needs_credentials
                oauthLoader.skillID = data.skill_id
                oauthLoader.appID = data.app_id
                oauthLoader.open()
            }
            if (type == "ovos.shell.oauth.display.qr.code") {
                oauthQrCodeLoader.skillID = data.skill_id
                oauthQrCodeLoader.appID = data.app_id
                oauthQrCodeLoader.qrCodePath = "file://" + data.qr
                oauthQrCodeLoader.open()
            }
            if (type == "ovos.display.screenshot.get") {
                var folderpath = data.folderpath
                var filepath = folderpath + "/" + "screen-" +  Qt.formatDateTime(new Date(), "hhmmss-ddMMyy") + ".png"
                mainView.grabToImage(function(result) {
                    result.saveToFile(filepath);
                });
                Mycroft.MycroftController.sendRequest("ovos.display.screenshot.get.response", {"result": filepath});
            }
            if (type == "ovos.shell.get.menuLabels.status") {
                Mycroft.MycroftController.sendRequest("ovos.shell.get.menuLabels.status.response", {"enabled": applicationSettings.menuLabels});
            }
            if (type == "ovos.shell.set.menuLabels") {
                applicationSettings.menuLabels = data.enabled
                Mycroft.MycroftController.sendRequest("ovos.shell.get.menuLabels.status.response", {"enabled": applicationSettings.menuLabels});
            }
        }
    }

    ShutdownOptions {
        id: shutdownOptions
    }

    Loader {
        anchors.fill: parent
        source: "KdeConnect.qml"
        z: 1200
    }

    FactoryResetUI {
        id: factoryResetUI
        visible: false
        enabled: false
    }

    Timer {
        interval: 20000
        running: Mycroft.GlobalSettings.autoConnect && Mycroft.MycroftController.status != Mycroft.MycroftController.Open
        triggeredOnStart: true
        onTriggered: {
            console.log("Trying to connect to Mycroft");
            Mycroft.MycroftController.start();
            slidingPanel.close();
            OVOSPlugin.Configuration.updateSchemeList();
        }
    }

    Rectangle {
        id: contentsRect
        color: "black"
        anchors.centerIn: parent
        rotation: {
            switch (applicationSettings.rotation) {
                case "CW":
                    return 90;
                case "CCW":
                    return -90;
                case "UD":
                    return 180;
                case "NORMAL":
                default:
                    return 0;
            }
        }
        width: rotation === 90 || rotation == -90 ? parent.height : parent.width
        height: rotation === 90 || rotation == -90 ? parent.width : parent.height

        Loader {
            width: parent.width
            height: parent.height
            source: "Keyboard.qml"
            z: 1000
        }

        Image {
            source: "background.png"
            fillMode: Image.PreserveAspectFit
            anchors.fill: parent
            opacity: !mainView.currentItem && serviceWatcher.guiServiceAlive
            Behavior on opacity {
                OpacityAnimator {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InQuad
                }
            }
        }

        ServiceWatcher {
            id: serviceWatcher
            anchors.fill: parent
        }

        StatusIndicator {
            id: si
            enabled: serviceWatcher.guiServiceAlive
            visible: serviceWatcher.guiServiceAlive
            anchors {
                top: parent.top
                right: parent.right
                margins: Kirigami.Units.largeSpacing
            }
            z: 998
        }


        Item {
            anchors.fill: parent
            visible: slidingPanel.position < 0.05
            enabled: slidingPanel.position < 0.05
            z: 10

            Osd.VolumeOSD {
                id: volumeOSD
                width: parent.width - Kirigami.Units.gridUnit
                height: Kirigami.Units.gridUnit * 3
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: Mycroft.Units.gridUnit * 2
                anchors.bottom: parent.bottom
                anchors.bottomMargin: parent.height * 0.25
                refSlidingPanel: slidingPanel.position
                horizontalMode: root.width > root.height ? 1 : 0
            }
        }

        Flickable {
            id: pullDownMenuFlickableArea
            anchors.fill: parent
            boundsBehavior: Flickable.DragAndOvershootBounds
            flickableDirection: Flickable.VerticalFlick

            rebound: Transition {
                SequentialAnimation {
                    NumberAnimation {
                        properties: "x,y"
                        duration: Kirigami.Units.longDuration * 3
                        easing.type: Easing.InOutCubic
                    }

                    ScriptAction {
                        script: {
                            if(slidingPanelShouldOpen) {
                                slidingPanel.open()
                                slidingPanelShouldOpen = false
                            }
                        }
                    }
                }
            }

            onContentYChanged: {
                if (contentY < 0 && contentY < -height * 0.15) {
                    if(!slidingPanel.menuOpen) {
                        slidingPanelShouldOpen = true
                    }
                }
            }

            onMovementEnded: {
                pullDownMenuFlickableArea.returnToBounds()
            }

            Mycroft.SkillView {
                id: mainView
                Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
                width: contentsRect.width
                height: contentsRect.height
                z: 2

                Rectangle {
                    anchors.bottom: parent.top
                    width: parent.width
                    height: pullDownMenuFlickableArea.moving && slidingPanelShouldOpen ? contentsRect.height : 0
                    visible: pullDownMenuFlickableArea.moving && (pullDownMenuFlickableArea.contentY < -height * 0.15) ? 1 : 0
                    enabled: pullDownMenuFlickableArea.moving && (pullDownMenuFlickableArea.contentY < -height * 0.15) ? 1 : 0

                    gradient: Gradient {
                        GradientStop { position: 0.8; color: "black"}
                        GradientStop { position: 0.995; color: Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.4) }
                        GradientStop { position: 1.0; color: Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.1)}
                    }

                    onVisibleChanged: {
                        if(visible && (pullDownMenuFlickableArea.contentY < -height * 0.15)){
                            Mycroft.SoundEffects.playClickedSound("qrc:/sounds/flicked.wav")
                        }
                    }
                }

                ListenerAnimation {
                    id: listenerAnimator
                    anchors.fill: parent
                }

                NotificationsSystem {
                    id: notificationManager
                }
            }
        }

        FastBlur {
            anchors.fill: mainView
            source: mainView
            radius: 50
            visible: slidingPanel.position > 0.5 || shutdownOptions.opened ? 1 : 0
            opacity: slidingPanel.position > 0.5 || shutdownOptions.opened ? 1 : 0
            z: 4
        }

        Panel.SlidingPanel {
            id: slidingPanel
            width: parent.width
            height: parent.height
            verticalMode: contentsRect.height > contentsRect.width ? 1 : 0
            z: 5
        }

        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: (1 - applicationSettings.fakeBrightness) * 0.85
            z: 6
        }
    }
}
