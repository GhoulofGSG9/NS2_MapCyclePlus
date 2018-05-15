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

    local oldGetMapName = Shared.GetMapName
    function Shared.GetMapName()
        return mapName or oldGetMapName()
    end

    local function OnMessageMapName(message)
        mapName = message.mapName
    end
    Client.HookNetworkMessage("MapCycle_MapName", OnMessageMapName)
end