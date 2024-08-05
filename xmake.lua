local project_name = "Project"
local target_dir = "xmake-build"
local download_cfg = "st_nucleo_f4.cfg"

set_project(project_name)
set_version("v0.2")

add_rules("mode.debug", "mode.release", "mode.releasedbg", "mode.minsizerel") 
set_defaultmode("releasedbg")

add_rules("plugin.compile_commands.autoupdate", {outputdir = ".vscode"})

toolchain("arm-none-eabi")
    set_kind("standalone")
    
    set_toolset("cc", "arm-none-eabi-gcc")
    set_toolset("as", "arm-none-eabi-gcc")
    set_toolset("ld", "arm-none-eabi-gcc")
toolchain_end()


-- basic board info
target(project_name)
    local CPU = "-mcpu=cortex-m4"
    local FPU = "-mfpu=fpv4-sp-d16"
    local FLOAT_ABI = "-mfloat-abi=hard"    
    local LDSCRIPT = "STM32F411CEUX_FLASH.ld"

    add_defines("USE_HAL_DRIVER", "STM32F411xE")
    add_cflags(CPU, "-mthumb", FPU, FLOAT_ABI, "-fdata-sections", "-ffunction-sections", {force = true})
    add_asflags(CPU, "-mthumb", FPU, FLOAT_ABI, "-fdata-sections", "-ffunction-sections", {force = true})
    add_ldflags(
        CPU, 
        "-mthumb", 
        FPU, 
        FLOAT_ABI, 
        "-specs=nano.specs", 
        "-T"..LDSCRIPT, 
        "-lm -lc -lnosys", 
        "-Wl,-Map=" .. target_dir .. "/" .. project_name .. ".map,--cref -Wl,--gc-sections", 
        "-Wl,--print-memory-usage",
        {force = true}
        )
    add_syslinks("m", "c", "nosys")
    
target_end()

-- add files
target(project_name)
    add_files(
    "Src/*.c",
    "Drivers/STM32F4xx_HAL_Driver/Src/*.c",
    "Startup/startup_stm32f411ceux.s"
    )

    add_includedirs(
    "Inc",
    "Drivers/STM32F4xx_HAL_Driver/Inc",
    "Drivers/STM32F4xx_HAL_Driver/Inc/Legacy",
    "Drivers/CMSIS/Device/ST/STM32F4xx/Include",
    "Drivers/CMSIS/Include"
    )

target_end()

-- other config
target(project_name)
    set_targetdir(target_dir)
    set_objectdir(target_dir .. "/obj")
    set_dependir(target_dir .. "/dep")
    set_kind("binary")
    set_extension(".elf")

    add_toolchains("arm-none-eabi")
    set_warnings("all")
    set_languages("c11", "cxx11")

    if is_mode("debug") then 
        set_symbols("debug")
        add_cxflags("-Og", "-gdwarf-2", {force = true})
        add_asflags("-Og", "-gdwarf-2", {force = true})
    elseif is_mode("release") then 
        set_symbols("hidden")
        set_optimize("fastest")
        set_strip("all")
    elseif is_mode("releasedbg") then 
        set_optimize("fastes")
        set_symbols("debug")
        set_strip("all")
    elseif is_mode() then 
        set_symbols("hidden")
        set_optimize("smallest")
        set_strip("all")
    end

target_end()

-- after_build(function(target)
--     import("core.project.task")
--     cprint("${bright black onwhite}********************储存空间占用情况*****************************")
--     os.exec(string.format("arm-none-eabi-objcopy -O ihex %s.elf %s.hex", target_dir .. '/' .. project_name, target_dir .. '/' .. project_name))
--     os.exec(string.format("arm-none-eabi-objcopy -O binary %s.elf %s.bin", target_dir .. '/' .. project_name, target_dir .. '/' .. project_name))
--     os.exec(string.format("arm-none-eabi-size -Ax %s.elf", target_dir .. '/' .. project_name))
--     os.exec(string.format("arm-none-eabi-size -Bd %s.elf", target_dir .. '/' .. project_name))
--     cprint("${bright black onwhite}heap-堆、stack-栈、.data-已初始化的变量全局/静态变量，bss-未初始化的data、.text-代码和常量")
-- end)

-- 自定义命令来解析内存使用报告
after_build(function (target)
    local output = os.iorunv("arm-none-eabi-size", {"-A", target:targetfile()})
    
    print("Output from arm-none-eabi-size:")
    print(output)
    
    -- 解析内存使用报告
    local function parse_memory_report(output)
        local flash_used = 0
        local ram_used = 0
        for line in output:gmatch("[^\r\n]+") do
            print(line) -- 打印每一行进行调试
            local section, size = line:match("(%S+)%s+(%d+)")
            size = tonumber(size)
            if section == ".text" or section == ".data" then
                flash_used = flash_used + size
            elseif section == ".bss" then
                ram_used = ram_used + size
            end
        end

        -- 假设RAM总容量为128 KB, FLASH总容量为512 KB
        local ram_total = 128 * 1024
        local flash_total = 512 * 1024

        print(string.format("[build] Memory region         Used Size  Region Size  %%age Used"))
        print(string.format("[build]              RAM:        %d B       %d KB      %.2f%%", ram_used, ram_total / 1024, (ram_used / ram_total) * 100))
        print(string.format("[build]            FLASH:        %d B       %d KB      %.2f%%", flash_used, flash_total / 1024, (flash_used / flash_total) * 100))
    end
    
    parse_memory_report(output)
end)

on_run(function(target)
    os.exec("openocd -f %s -c 'program ./%s/%s.elf verify reset exit'", download_cfg, target_dir, project_name)
end)