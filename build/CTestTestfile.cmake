# CMake generated Testfile for 
# Source directory: /home/diau/git/mycroft/mycroft-embedded-shell
# Build directory: /home/diau/git/mycroft/mycroft-embedded-shell/build
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(appstreamtest "/usr/bin/cmake" "-DAPPSTREAMCLI=/usr/bin/appstreamcli" "-DINSTALL_FILES=/home/diau/git/mycroft/mycroft-embedded-shell/build/install_manifest.txt" "-P" "/opt/kde5/share/ECM/kde-modules/appstreamtest.cmake")
subdirs("application")
