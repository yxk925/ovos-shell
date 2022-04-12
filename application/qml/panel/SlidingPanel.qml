import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import org.kde.kirigami 2.5 as Kirigami
import QtQuick.Layouts 1.12
import "quicksettings"


Item {
    id: pullControlRoot
    width: parent.width
    height: parent.height
    property alias position: pullControlRoot.menuPosition
    property bool menuOpen: false
    property bool menuClosed: true
    property bool menuDragging: false
    property int menuDragDirection
    property real menuPosition: 0.0
    property real dragPositionTopToBottom: 0.0
    property real dragPositionBottomToTop: 0.0
    property alias menuHeight: pullDownRoot.height

    function close() {
        closeAnimationTpBt.restart();
    }

    Connections {
        target: mouseSwipeArea
        onCustomDragReleased: {
            if(pullControlRoot.menuDragDirection == 1){
                if(pullControlRoot.menuPosition >= 0.1) {
                    snapAnimationTpBt.restart()
                } else if(pullControlRoot.menuPosition < 0.1){
                    closeAnimationTpBt.restart()
                }
            }
            if(pullControlRoot.menuDragDirection == 2){
                if(pullControlRoot.menuPosition > 0.6) {
                    snapAnimationTpBt.restart()
                } else if (pullControlRoot.menuPosition <= 0.6){
                    closeAnimationTpBt.restart()
                }
            }
        }
    }

    SequentialAnimation {
        id: closeAnimationTpBt
        NumberAnimation {
            target: pullControlRoot
            property: "menuPosition"
            from: pullControlRoot.menuPosition
            to: 0.0
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }

    SequentialAnimation {
        id: snapAnimationTpBt
        NumberAnimation {
            target: pullControlRoot
            property: "menuPosition"
            from: pullControlRoot.menuPosition
            to: 1.0
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }

    function calculate_menu_position(dragPosition, direction) {
        if (direction == "TopToBottom") {
            menuPosition = Math.round(Math.max(0.0, Math.min(1.0, dragPosition * 2.0 - 1.0)) * 100.0) / 100.0
            if(dragPosition < 0.5 && dragPosition > 0.2) {
                menuPosition = dragPosition
            }
            pullControlRoot.menuDragDirection = 1
        }
        if (direction == "BottomToTop") {
            menuPosition = Math.round(Math.max(0.0, Math.min(1.0, 1.0 - dragPosition * 2.0)) * 100.0) / 100.0
            pullControlRoot.menuDragDirection = 2
        }
    }

    function calculate_mainContents_y(){
        if (pullControlRoot.menuDragDirection == 1) {
            mainContents.y = -pullControlRoot.height + pullControlRoot.menuPosition * pullControlRoot.height
        }
        if (pullControlRoot.menuDragDirection == 2) {
            mainContents.y = -pullControlRoot.height + pullControlRoot.menuPosition * pullControlRoot.height
        }
    }

    onDragPositionTopToBottomChanged: {
        calculate_menu_position(dragPositionTopToBottom, "TopToBottom")
    }

    onDragPositionBottomToTopChanged: {
        calculate_menu_position(dragPositionBottomToTop, "BottomToTop")
    }

    onMenuPositionChanged: {
        if (menuPosition < 0) {
            menuPosition = 0
        }

        if (menuPosition == 0.0) {
            menuClosed = true
            menuOpen = false
            menuDragging = false
        } else if (menuPosition == 1.0) {
            menuClosed = false
            menuOpen = true
            menuDragging = false
        } else {
            menuClosed = false
            menuOpen = false
            menuDragging = true
        }

        calculate_mainContents_y()
    }

    Control {
        id: pullDownRoot
        anchors.top: parent.top
        width: pullControlRoot.width
        height: pullControlRoot.height * menuPosition

        background: Rectangle {
            color: "black"
            opacity: pullDownRoot.menuPosition < 0.6 ? Math.min(1, pullDownRoot.menuPosition) * 0.2 : Math.min(1, pullDownRoot.menuPosition) * 0.6
            visible: pullDownRoot.menuPosition > 0
            height: pullDownRoot.menuPosition < 0.6 ? quickSettings.implicitHeight : parent.height
        }
        
        Item {
            id: mainContents
            width: parent.width
            height: pullControlRoot.height
            y: -pullControlRoot.height

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
                    onDelegateClicked: {
                        pullControlRoot.close()
                    }
                }
                Item {
                    Layout.fillHeight: true
                }
            }
        }
    }
}
