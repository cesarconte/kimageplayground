add_library(kimageplayground_core STATIC
    playgroundcontroller.cpp
    playgroundcontroller.h
)

target_include_directories(kimageplayground_core PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

target_link_libraries(kimageplayground_core PUBLIC
    Qt6::Core
    Qt6::Gui
    Qt6::Widgets
    Qt6::Network
)

add_executable(kimageplayground
    main.cpp
    resources.qrc
)

target_link_libraries(kimageplayground PRIVATE
    kimageplayground_core
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    KF6::CoreAddons
    KF6::I18n
)

install(TARGETS kimageplayground DESTINATION ${KDE_INSTALL_BINDIR})
install(FILES org.cesar.kimageplayground.desktop DESTINATION ${KDE_INSTALL_APPDIR})
