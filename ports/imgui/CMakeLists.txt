cmake_minimum_required(VERSION 3.8)

project(imgui
    VERSION 1.74.0
    DESCRIPTION "Bloat-free Immediate Mode Graphical User interface for C++ with minimal dependencies."
    HOMEPAGE_URL "https://github.com/ocornut/imgui"
    LANGUAGES CXX
)

option(BUILD_SHARED_LIBS "Build shared libraries" ON)
option(INSTALL_HEADERS "Install the development headers" ON)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

set(CMAKE_DEBUG_POSTFIX d)

set(IMGUI_INCLUDES_PUBLIC
    imgui.h
    imconfig.h
)

set(IMGUI_INCLUDES_PRIVATE
    imgui_internal.h
)

set(IMGUI_SOURCES
    imgui.cpp
    imgui_demo.cpp
    imgui_draw.cpp
    imgui_widgets.cpp
)

add_library(${PROJECT_NAME}
    ${IMGUI_INCLUDES_PUBLIC}
    ${IMGUI_INCLUDES_PRIVATE}
    ${IMGUI_SOURCES}
)

if(BUILD_SHARED_LIBS AND MSVC)
    set(_IMPORT __declspec\(dllimport\))
    set(_EXPORT __declspec\(dllexport\))
    target_compile_options(${PROJECT_NAME}
        INTERFACE
            -DIMGUI_API=${_IMPORT}
        PRIVATE
            -DIMGUI_API=${_EXPORT}
    )
endif()

target_include_directories(${PROJECT_NAME}
    INTERFACE
        $<INSTALL_INTERFACE:include>
)

file(WRITE "${CMAKE_BINARY_DIR}/unofficial-imgui-config.cmake.in" [=[
    @PACKAGE_INIT@
    include("@PACKAGE_PATH_EXPORT_TARGETS@")
]=])

set(PATH_EXPORT_TARGETS "${CMAKE_INSTALL_DATADIR}/unofficial-imgui/unofficial-imgui-targets.cmake")
configure_package_config_file(
    "${CMAKE_BINARY_DIR}/unofficial-imgui-config.cmake.in"
    "${CMAKE_BINARY_DIR}/unofficial-imgui-config.cmake"
    PATH_VARS
        PATH_EXPORT_TARGETS
    INSTALL_DESTINATION ${CMAKE_INSTALL_DATADIR}/unofficial-imgui
)

write_basic_package_version_file("${CMAKE_BINARY_DIR}/unofficial-imgui-config-version.cmake"
  COMPATIBILITY AnyNewerVersion
)

install(
    FILES
        "${CMAKE_BINARY_DIR}/unofficial-imgui-config.cmake"
        "${CMAKE_BINARY_DIR}/unofficial-imgui-config-version.cmake"
    DESTINATION
        "${CMAKE_INSTALL_DATADIR}/unofficial-imgui"
)

install(TARGETS ${PROJECT_NAME}
    EXPORT unofficial-imgui-targets
    COMPONENT runtime
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}" COMPONENT bin
    LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}" COMPONENT shlib
    ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}" COMPONENT lib
)

install(EXPORT unofficial-imgui-targets
    NAMESPACE unofficial-imgui::
    DESTINATION "${CMAKE_INSTALL_DATADIR}/unofficial-imgui"
)

if(INSTALL_HEADERS)
    install(
        FILES ${IMGUI_INCLUDES_PUBLIC}
        TYPE INCLUDE
    )
endif()
