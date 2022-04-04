vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO theblackunknown/tracy
    REF 8559a2ac27c366c5150150af4aa601f1580bb2ab
    SHA512 333980f4f1aa83bd72ea1704aeb4e3a930f49d56f35627e8f09950e76ec1010f1b37f9ab0604d98b589829fb1462c3e9058f3a12f40dc4f2c4341a4b8b68dae4
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "capture"  TRACY_BUILD_CAPTURE
        "profiler" TRACY_BUILD_PROFILER
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()
vcpkg_fixup_pkgconfig()

set(tracy_tools)
if("capture" IN_LIST FEATURES)
    list(APPEND tracy_tools capture)
endif()
if("profiler" IN_LIST FEATURES)
    list(APPEND tracy_tools Tracy)
endif()

list(LENGTH tracy_tools tracy_tools_size)
if(tracy_tools_size GREATER 0)
    vcpkg_copy_tools(TOOL_NAMES ${tracy_tools} AUTO_CLEAN)
endif()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# Cleanup
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")