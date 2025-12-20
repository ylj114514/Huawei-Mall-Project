@echo off
cd /d "d:\Git\Huawei-Mall-Project"
echo 正在编译HarmonyOS项目...
powershell -Command "& .\hvigor\hvigorw.bat --mode module -p module=entry@default assembleHap --parallel"
