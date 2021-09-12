
# NOTE src/utilities.cmake:76 force x64 by defining BIT64=1
vcpkg_fail_port_install(
    ON_ARCH
        x86
)

if(VCPKG_TARGET_IS_WINDOWS)
    # NOTE: Static library required on windows, it seems some shared library does not export symbol which prevents a .lib to be generated
    # LINK : fatal error LNK1181: cannot open input file '..\..\Release\lib\LLVMDemangle.lib' [C:\devel\vcpkg\buildtrees\mdl\x64-windows-rel\src\mdl\jit\llvm\dist\lib\Support\LLVMSupport.vcxproj]

    vcpkg_check_linkage(
        ONLY_STATIC_LIBRARY
    )

    if((NOT VCPKG_BUILD_TYPE) OR (NOT VCPKG_BUILD_TYPE STREQUAL "release"))
        message(STATUS "Note: ${PORT} only supports release build (FreeImage dependency does not compile with /MTd nor /MDd).")
        set(VCPKG_BUILD_TYPE release)
    endif()
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NVIDIA/MDL-SDK
    REF d51e97f0019642f0cb1dfb7b67a4edaac2058f92
    SHA512 585a58cd2f1dcf9c8e72dcfef57db8808b9ca4427e6914df3fee6f295d977b7f771531c3c275d54be3ec6c64fc1acfe7c7a4f6608bcf0831e11df6d9d5632ca3
    HEAD_REF master
    PATCHES
        001-freeimage-from-vcpkg.patch
        002-clang-7.0.x-and-above.patch
        003-install-rules.patch
        004-freeimage-disable-faxg3.patch
        005-missing-std-includes.patch
        006-missing-link-windows-crypt-libraries.patch
        007-guard-nonexisting-targets.patch
        008-disable-plugins.patch
)

set(_MVSC_CRT_LINKAGE_OPTION)
if(VCPKG_CRT_LINKAGE STREQUAL "static")
    set(_MVSC_CRT_LINKAGE_OPTION -DMDL_MSVC_DYNAMIC_RUNTIME_EXAMPLES:BOOL=OFF)
elseif(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
    set(_MVSC_CRT_LINKAGE_OPTION -DMDL_MSVC_DYNAMIC_RUNTIME_EXAMPLES:BOOL=ON)
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_find_acquire_program(PYTHON3)
    set(PATH_PYTHON ${PYTHON3})
else()
    # FIXME Python 3.6.9 is provided, but mdl requires 3.7 or 2.7
    vcpkg_find_acquire_program(PYTHON2)
    set(PATH_PYTHON ${PYTHON2})
endif()

vcpkg_find_acquire_program(CLANG)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DMDL_ENABLE_CUDA_EXAMPLES:BOOL=OFF
        -DMDL_ENABLE_OPENGL_EXAMPLES:BOOL=OFF
        -DMDL_ENABLE_QT_EXAMPLES:BOOL=OFF
        -DMDL_ENABLE_D3D12_EXAMPLES:BOOL=OFF
        -DMDL_ENABLE_OPTIX7_EXAMPLES:BOOL=OFF
        -DMDL_ENABLE_MATERIALX:BOOL=OFF

        -DMDL_BUILD_SDK_EXAMPLES:BOOL=OFF
        -DMDL_BUILD_CORE_EXAMPLES:BOOL=OFF
        -DMDL_BUILD_ARNOLD_PLUGIN:BOOL=OFF
        
        -DMDL_INSTALL_PLUGINS:BOOL=OFF

        -Dclang_PATH:PATH=${CLANG}
        -Dpython_PATH:PATH=${PATH_PYTHON}

        -DCMAKE_CXX_STANDARD:STRING=11
        -DCMAKE_CXX_EXTENSIONS:STRING=ON

        ${_MVSC_CRT_LINKAGE_OPTION}
    OPTIONS_DEBUG
        -DMDL_INSTALL_HEADERS:BOOL=OFF
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_copy_tools(
    TOOL_NAMES i18n mdlc mdlm
    AUTO_CLEAN
)

vcpkg_fixup_cmake_targets()

file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
