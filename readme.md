vscode 中开发 stm32 HAL 项目配置

## 依赖工具
- [clangd](https://github.com/clangd/clangd/releases/tag/18.1.3)
- [STM32CubeCLT](https://www.st.com/en/development-tools/stm32cubeclt.html)
- [openOCD](https://github.com/openocd-org/openocd/releases/tag/v0.12.0)

其中 STM32CubeCLT 基本上包含了所有开发 stm32 所需的工具
```txt
=  STM32Cube Command Line Tools                                                       =
=  -- This is a help to show the location of CubeCLT component STM32   -------------  =
=======================================================================================
=                                                                                     =
  STM32CubeTargetRepo = D:\ST\STM32CubeCLT_1.15.1\STM32target-mcu
  STM32CubeSVDRepo    = D:\ST\STM32CubeCLT_1.15.1\STMicroelectronics_CMSIS_SVD
  GNUToolsForSTM32    = D:\ST\STM32CubeCLT_1.15.1\GNU-tools-for-STM32\bin
  STLinkGDBServer     = D:\ST\STM32CubeCLT_1.15.1\STLink-gdb-server\bin
  STM32CubeProgrammer = D:\ST\STM32CubeCLT_1.15.1\STM32CubeProgrammer\bin
  CMake               = D:\ST\STM32CubeCLT_1.15.1\CMake\bin
  Ninja               = D:\ST\STM32CubeCLT_1.15.1\Ninja\bin
```
将需要的工具添加到环境变量中，方便使用。

结合最新版本的 stm32cubemx 生成 cmake 工程，可快速进行项目开发。