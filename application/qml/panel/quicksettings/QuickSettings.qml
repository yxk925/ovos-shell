/*
 * Copyright 2020 Aditya Mehra <Aix.m@outlook.com>
 * Copyright 2018 by Marco Martin <mart@kde.org>
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

import QtQuick 2.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.5 as Kirigami

GridLayout {
    id: root

    signal delegateClicked
    property bool horizontalMode: false
    columns: 1
    rowSpacing: Kirigami.Units.largeSpacing
    columnSpacing: Kirigami.Units.largeSpacing
    property int delegateSize: horizontalMode ? Kirigami.Units.iconSizes.large : Kirigami.Units.iconSizes.small
    ColumnLayout {
        id: buttonsLayout
        Layout.fillWidth: true
        Layout.minimumWidth: 0
        spacing: Kirigami.Units.largeSpacing * 2

        BrightnessSlider {
            Layout.fillWidth: true
        }
        VolumeSlider {
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            HomeDelegate {
                Layout.minimumWidth: delegateSize
                leftPadding: horizontalMode ? Kirigami.Units.largeSpacing : Kirigami.Units.smallSpacing
                rightPadding: horizontalMode ? Kirigami.Units.largeSpacing : Kirigami.Units.smallSpacing
            }
            //WirelessDelegate {}
            Delegate {
                Layout.minimumWidth: delegateSize
                iconSource: "qrc://icons/screen-rotate"
                //text: "Rotate"
                leftPadding: horizontalMode ? Kirigami.Units.largeSpacing : Kirigami.Units.smallSpacing
                rightPadding: horizontalMode ? Kirigami.Units.largeSpacing : Kirigami.Units.smallSpacing
                onClicked: {
                    if (applicationSettings.rotation === "CW") {
                        applicationSettings.rotation = "NORMAL";
                    } else if (applicationSettings.rotation === "NORMAL") {
                        applicationSettings.rotation = "CCW";
                    } else if (applicationSettings.rotation === "CCW") {
                        applicationSettings.rotation = "UD";
                    } else {
                        //if (applicationSettings.rotation === "UD") {
                        applicationSettings.rotation = "CW";
                    }
                    print(applicationSettings.rotation)
                }
            }
            MuteDelegate {
                Layout.minimumWidth: delegateSize
                leftPadding: horizontalMode ? Kirigami.Units.largeSpacing : Kirigami.Units.smallSpacing
                rightPadding: horizontalMode ? Kirigami.Units.largeSpacing : Kirigami.Units.smallSpacing
            }
            AdditionalSettingsDelegate {
                Layout.minimumWidth: delegateSize
                leftPadding: horizontalMode ? Kirigami.Units.largeSpacing : Kirigami.Units.smallSpacing
                rightPadding: horizontalMode ? Kirigami.Units.largeSpacing : Kirigami.Units.smallSpacing
            }
            RebootDelegate {
                Layout.minimumWidth: delegateSize
                leftPadding: horizontalMode ? Kirigami.Units.largeSpacing : Kirigami.Units.smallSpacing
                rightPadding: horizontalMode ? Kirigami.Units.largeSpacing : Kirigami.Units.smallSpacing
            }
            ShutdownDelegate {
                Layout.minimumWidth: delegateSize
                leftPadding: horizontalMode ? Kirigami.Units.largeSpacing : Kirigami.Units.smallSpacing
                rightPadding: horizontalMode ? Kirigami.Units.largeSpacing : Kirigami.Units.smallSpacing
            }
        }
    }
}
