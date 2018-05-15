gMaskMapName = true -- switch to check if the mapname should be mask or not

ModLoader.SetupFileHook("lua/MapCycle.lua", "lua/MapCyclePlus/MapCycle.lua", "post")
ModLoader.SetupFileHook("lua/NetworkMessages.lua", "lua/MapCyclePlus/NetworkMessages.lua", "post")
ModLoader.SetupFileHook("lua/GUIMinimap.lua", "lua/MapCyclePlus/GUIMinimap.lua", "post")