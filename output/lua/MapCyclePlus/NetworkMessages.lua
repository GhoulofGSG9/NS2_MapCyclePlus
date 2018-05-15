local kMapNameMessage =
{
    mapName = "string (128)",
}

Shared.RegisterNetworkMessage("MapCycle_MapName", kMapNameMessage)

if Server then
    local function OnClientConnect(client)
        Server.SendNetworkMessage(client, "MapCycle_MapName", { mapName = Server.GetMapName() }, true)
    end
    Event.Hook("ClientConnect", OnClientConnect)
end

if Client then
    local mapName
    local maskedMapName
    local oldGetMapName = Shared.GetMapName
    function Shared.GetMapName()
        mapName = mapName or oldGetMapName()
        if not gMaskMapName then return mapName end

        return maskedMapName or mapName
    end

    local function OnMessageMapName(message)
        maskedMapName = message.mapName
    end
    Client.HookNetworkMessage("MapCycle_MapName", OnMessageMapName)
end