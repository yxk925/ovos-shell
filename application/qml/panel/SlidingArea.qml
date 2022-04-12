import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import org.kde.kirigami 2.5 as Kirigami
import QtQuick.Layouts 1.12

MouseArea {
    id: mouseArea
    width: parent.width
    height: slidingPanel.menuHeight == 0 ?  parent.height * 0.1 : slidingPanel.menuHeight
    propagateComposedEvents: true
    property real prevX: 0
    property real prevY: 0
    property real velocityX: 0.0
    property real velocityY: 0.0
    property int startX: 0
    property int startY: 0
    property bool tracing: false

    signal customDragReleased()

    onClicked: {
        mouse.accepted = false;
    }

    onPressed: {
        startX = mouse.x
        startY = mouse.y
        prevX = mouse.x
        prevY = mouse.y
        velocityX = 0
        velocityY = 0
        tracing = true
    }

    onReleased: {
        customDragReleased()
        velocityX = 0
        velocityY = 0
        tracing = false
    }

    onPositionChanged: {
        if ( !tracing ) return
        var currVelX = (mouse.x-prevX)
        var currVelY = (mouse.y-prevY)

        velocityX = (velocityX + currVelX)/2.0;
        velocityY = (velocityY + currVelY)/2.0;

        prevX = mouse.x
        prevY = mouse.y

        if ( mouse.y > startY && velocityY > 1) {
            slidingPanel.dragPositionTopToBottom = (mouse.y - startY) / parent.height
        }

        if(slidingPanel.menuPosition > 0.5){
            if ( mouse.y < startY && velocityY < -2) {
                slidingPanel.dragPositionBottomToTop = (startY - mouse.y) / parent.height
            }
        }
    }
}