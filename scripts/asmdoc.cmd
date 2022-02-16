cd api
setlocal enabledelayedexpansion enableextensions
set LIST=
for %%x in (..\basic\modules\*.asm) do set LIST=!LIST! %%x
set LIST=%LIST:~1%
perl asmdoc.pl -author -version ..\basic\basic.inc %LIST%
