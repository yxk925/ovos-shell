

foreach(component IN ITEMS Core Qml Widgets Gui Network WebView Sql DBus Quick)  # Extend with other Qt modules
    if(TARGET Qt5::${component})
        add_library(Qt::${component} ALIAS Qt5::${component})
    endif()
endforeach()