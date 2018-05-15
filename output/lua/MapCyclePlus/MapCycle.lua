local startsWith = StringStartsWith

local prefixMap
local gameModeMap

local tempFileName = "mapPrefix.json"

function Server.GetMapNameWithIndex(index, mapCycle)
    local mapCycle = mapCycle or MapCycle_GetMapCycle()
    local name = mapCycle.maps[index]
    local mode

    if type(name) == "table" then
        name = name.map
        mode = name.gamemode
    end

    return name, mode
end

function Server.GetNumMaps()
    local mapCycle = MapCycle_GetMapCycle()
    return #mapCycle.maps
end

local mapName
local oldGetMapName = Shared.GetMapName
function Server.GetMapName(index)
    if index then return Server.GetMapNameWithIndex(index) end

    if not mapName then
        mapName = oldGetMapName()

        local temp = LoadConfigFile(tempFileName, {}, false)
        if temp[2] then
            mapName = string.gsub(mapName, temp[2], temp[1])
        end
    end

    return mapName
end
Shared.GetMapName = Server.GetMapName

local oldMapCycle_GetMapIsInCycle = MapCycle_GetMapIsInCycle
function MapCycle_GetMapIsInCycle(mapName)
    if not gameModeMap then
        return oldMapCycle_GetMapIsInCycle(mapName)
    end

    return gameModeMap[mapName] ~= nil
end

local oldStartWorld = Server.StartWorld
function Server.StartWorld(mods, mapName)
    local settings = gameModeMap and gameModeMap[mapName]
    local temp = {}
    Log "Server.StartWorld"
    Log("%s", settings)
    if settings then
        if settings.replace then
            mapName = string.gsub(mapName, settings.prefix, settings.replace)
            temp = {settings.prefix, settings.replace }
            Print(mapName)
        end

        local mapMods = settings.mods
        table.addtable(mapMods, mods)
    end

    SaveConfigFile(tempFileName, temp)

    oldStartWorld(mods, mapName)

end

do
    local function buildPrefixMap(mapCycle)
        if not mapCycle or not mapCycle.gamemodes or type(mapCycle.gamemodes) ~= "table" then
            return
        end

        prefixMap = {
            _prefixes = {}
        }

        for name, settings in pairs(mapCycle.gamemodes) do
            local mods = settings.mods
            prefixMap[name] = settings
            if settings.mapPrefixes then
                for i = 1, #settings.mapPrefixes do
                    local prefixTable = settings.mapPrefixes[i]
                    local prefix = prefixTable[1]
                    local replace = prefixTable[2]

                    prefixMap[prefix] = settings
                    prefixMap[prefix].prefix = prefix
                    prefixMap[prefix].replace = replace
                    table.insert(prefixMap._prefixes, prefix)
                end
            end
        end

        table.sort(prefixMap._prefixes)
    end

    local function buildGameModeMap(mapCycle)
        local maps = mapCycle.maps

        if not prefixMap then return end

        gameModeMap = {}

        for i = 1, #maps do
            local name, mode = Server.GetMapNameWithIndex(i, mapCycle)

            if mode and prefixMap[mode] then
                gameModeMap[name] = prefixMap[mode]
            else
                for i = #prefixMap._prefixes, 1, -1 do
                    local prefix = prefixMap._prefixes[i]

                    if startsWith(name, prefix) then
                        gameModeMap[name] = prefixMap[prefix]
                        break
                    end
                end

                gameModeMap[name] = gameModeMap[name] or false
            end
        end
    end

    local mapCycle = MapCycle_GetMapCycle()
    buildPrefixMap(mapCycle)
    buildGameModeMap(mapCycle)
end