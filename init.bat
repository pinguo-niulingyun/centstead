@echo off

set UserConfigPath=config

mkdir %UserConfigPath%

copy /-y stubs\config.yaml "%UserConfigPath%\\config.yaml"
copy /-y stubs\after.sh "%UserConfigPath%\\after.sh"
copy /-y stubs\aliases "%UserConfigPath%\\aliases"

set UserConfigPath=
echo Box initialized!