# GTA6-kirito_lv-ver

在 Windows 上验证 Xbox Series 游戏离线运行的兼容层项目。本仓库提供 VIctory 补丁和 RX 6800 XT 同步启动配置。游戏程序、资源包和原版 DLL 由使用者从有权使用的副本提供。

## 开发进度

| 阶段 | 实测结果 |
| --- | --- |
| Xbox2Windows 启动排查 | 补齐启动依赖，建立离线本地档案。通过玩家选择、初次设置和插画载入，后段出现 `DXGI_ERROR_DEVICE_RESET (0x887A0007)`。 |
| D3D12 描述符回收 | 实验性修改以命令列表和 GPU 栅栏管理描述符槽。回收测试与 WARP 像素测试通过，RX 6800 XT 实机仍复现重置。 |
| VIctory 对照测试 | 以 `VIctory-7900XTX` 为基础，补丁让 `VICTORY_GAME_DIR` 指向独立的资源目录。主程序和四个游戏 DLL 的导入绑定均无缺失。上游 `-Safe` 配置仍复现 GPU 重置。 |
| RX 6800 XT 同步提交 | 关闭异步提交、提前纹理上传和部分批处理后，启动测试越过载入与序章过场，到达出现“长按 LT 互动”提示的场景。约 13 分钟的观察窗口内无 GPU 重置。 |

## 当前状态

实机为 Windows 和 Radeon RX 6800 XT。已验证中文界面、序章过场和首个带互动提示的 3D 场景。该场景约 4–5 FPS，部分场景会出现黑帧或缺失绘制。后续任务、长时间稳定性和 30 FPS 解锁尚未验证。同步配置同时调整了多项开关，单个开关的影响尚未定位。

## 构建与启动

准备 Git、PowerShell、Rust stable、Visual Studio C++ Build Tools 和 Windows SDK，并让游戏程序与对应的资源目录在本机可读。以下命令从本仓库根目录运行。

```powershell
git clone https://github.com/avatarmanz/VIctory-7900XTX.git victory-upstream
git -C victory-upstream switch --detach b0cfe2ba5ff9c967a3d9beaf542b2c7c7e4ea63f
$patch = (Resolve-Path .\victory-game-dir.patch).Path
git -C victory-upstream apply --check $patch
git -C victory-upstream apply $patch
Push-Location victory-upstream
cargo +stable build --locked --profile diag -p victory --features diagnostics
Pop-Location
```

设置本机路径。`GameDir` 指向含 `MicrosoftGame.config`、游戏 DLL 和资源包的目录。若 EXE 与资源在同一目录，填该目录即可。

```powershell
$game = 'D:\MyXboxGame\game_scarlett_master.exe'
$package = 'D:\MyXboxGame\package'

# 先检查映射和导入绑定，再实际运行
.\run-victory.ps1 -VictorySource .\victory-upstream -GameExe $game -GameDir $package
.\run-victory.ps1 -VictorySource .\victory-upstream -GameExe $game -GameDir $package -Execute
```

默认开启完整 DRED 诊断。启动器将存档和缓存写入 `%LOCALAPPDATA%\GTA6-kirito_lv-ver`。可用 XInput 手柄操作。未连接手柄时，键盘前台输入可模拟手柄，WASD 移动，IJKL 控制视角，Enter 对应 A，Z 对应 LT。

## 上游与许可证

本仓库基于 VIctory 的 7900 XTX 分支。补丁和启动脚本以 [GPL-3.0](LICENSE) 发布。Xbox2Windows 实验记录保留在上面的开发进度中。 [VIctory-7900XTX](https://github.com/avatarmanz/VIctory-7900XTX) · [上游实测报告](https://github.com/avatarmanz/VIctory-7900XTX/blob/main/docs/findings.md) · [RX 6800 XT 公开反馈](https://github.com/Marvisak/VIctory/issues/63)
