cmake_minimum_required(VERSION 3.20)

# project settings
project(DYZB-PB-01_hal C ASM)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_C_STANDARD 11)

# Include toolchain file 如果CMakePresets.json中未进行设置,此处进行导入
# include("cmake/gcc-arm-none-eabi.cmake")

# 使用 libc-nano
add_compile_options(--specs=nano.specs)

# mcu通用宏定义
add_definitions(-DUSE_HAL_DRIVER -DSTM32F103xE)

# 编译配置
if ("${CMAKE_BUILD_TYPE}" STREQUAL "Release")
    message(STATUS "Maximum optimization for speed")
    add_compile_options(-Ofast)
elseif ("${CMAKE_BUILD_TYPE}" STREQUAL "xxRel")
    message(STATUS "xx output")
    add_compile_options(-Og -g3)
    add_definitions(-DUSER_VECT_TAB_ADDRESS)
    set(LINKER_SCRIPT ${CMAKE_SOURCE_DIR}/STM32F103VETX_FLASH-boot.ld)
else ()
    message(STATUS "Minimal optimization, debug info included")
    add_compile_options(-Og -g)
endif ()

include_directories(

)

file(GLOB_RECURSE SOURCES

)

# 使用 libc-nano
add_link_options(--specs=nosys.specs)
# 关闭警告
add_link_options(-Wl,--no-warn-rwx-segments)
add_link_options(-T ${LINKER_SCRIPT})

add_executable(${PROJECT_NAME}.elf ${SOURCES} ${LINKER_SCRIPT})

set(HEX_FILE ${PROJECT_BINARY_DIR}/${PROJECT_NAME}.hex)
set(BIN_FILE ${PROJECT_BINARY_DIR}/${PROJECT_NAME}.bin)

add_custom_command(TARGET ${PROJECT_NAME}.elf POST_BUILD
        COMMAND ${CMAKE_OBJCOPY} -Oihex $<TARGET_FILE:${PROJECT_NAME}.elf> ${HEX_FILE}
        COMMAND ${CMAKE_OBJCOPY} -Obinary $<TARGET_FILE:${PROJECT_NAME}.elf> ${BIN_FILE}
        COMMENT "Building ${HEX_FILE}
Building ${BIN_FILE}")
