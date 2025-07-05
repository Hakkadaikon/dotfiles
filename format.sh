#!/bin/bash

# luaformatter
# https://github.com/Koihik/LuaFormatter?tab=readme-ov-file
find home/.config -type f -name "*.lua" -print0 | xargs -0 stylua
