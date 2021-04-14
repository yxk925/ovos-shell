/*
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

import QtQuick 2.0
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import org.kde.kirigami 2.5 as Kirigami
import QtGraphicalEffects 1.0
import "quicksettings"

Item {
    id: root
    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.View

    readonly property bool horizontal: width > height

    readonly property real position: 1 - (flickable.contentY - contentHeight + Math.min(height, quickSettings.implicitHeight)) / Math.min(height, quickSettings.implicitHeight)

    readonly property real contentHeight: quickSettings.height + contentsLayout.anchors.margins * 2
    state: "closed"

    function open() {
        flickable.openRequested();
        openAnim.restart();
    }
    function close() {
        flickable.closeRequested();
        closeAnim.restart();
    }

    onWidthChanged: {
        if (state === "closed") {
            flickable.contentY = root.contentHeight;
        }
    }
    onHeightChanged: {
        if (state === "closed") {
            flickable.contentY = root.contentHeight;
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: Math.min(1, root.position) * 0.6
        visible: root.position > 0
    }

    SequentialAnimation {
        id: openAnim
        NumberAnimation {
            target: flickable
            property: "contentY"
            from: flickable.contentY
            to: 0
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
        PropertyAction {
            target: flickable
            property: "open"
            value: true
        }
    }

    SequentialAnimation {
        id: closeAnim
        NumberAnimation {
            target: flickable
            property: "contentY"
            from: flickable.contentY
            to: root.contentHeight
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
        PropertyAction {
            target: flickable
            property: "open"
            value: false
        }
    }

    SequentialAnimation {
        id: snapAnim
        NumberAnimation {
            target: flickable
            property: "contentY"
            from: flickable.contentY
            to: root.contentHeight - Math.min(root.height, quickSettings.implicitHeight + contentsLayout.anchors.margins * 2)
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
        PropertyAction {
            target: flickable
            property: "open"
            value: true
        }
    }

    Flickable {
        id: flickable
        anchors.fill: parent

        contentY: root.contentHeight
        boundsBehavior: Flickable.StopAtBounds
        contentWidth: width
        contentHeight: flickableContents.implicitHeight

        property bool open: false
        signal openRequested
        signal closeRequested

        onFlickStarted: movementStarted()
        onFlickEnded: movementEnded()
        onMovementStarted: root.state = "dragging"
        onMovementEnded: {print(open)
            if (root.position < 0.5) {print("CLOSE")
                openAnim.running = false;
                snapAnim.running = false;
                closeAnim.restart();
            } else if (open && root.position < 1) {print("SNAP")
                openAnim.running = false;
                closeAnim.running = false;
                snapAnim.restart();
            } else if (!open && root.position >= 0.5) {print("OPEN")
                closeAnim.running = false;
                snapAnim.running = false;
                openAnim.restart();
            }
        }
        MouseArea {
            id: flickableContents
            width: parent.width
            implicitHeight: contentsLayout.implicitHeight + contentsLayout.anchors.margins * 2

            ColumnLayout {
                id: contentsLayout
                spacing: 0

                anchors {
                    fill: parent
                    margins: Kirigami.Units.largeSpacing * 2
                }
                QuickSettings {
                    id: quickSettings
                    Layout.fillWidth: true
                    onDelegateClicked: root.close();
                }
                Item {
                    Layout.minimumHeight: root.height
                }
            }
        }
    }
}
