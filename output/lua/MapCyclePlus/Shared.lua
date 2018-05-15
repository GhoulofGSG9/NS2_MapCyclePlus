local function LoadHeightmap()

    -- Load height map
    gHeightMap = HeightMap()
    local heightmapFilename = string.format("maps/overviews/%s.hmp", Shared.GetMapName())

    if not gHeightMap:Load(heightmapFilename) then
        Shared.Message("Couldn't load height map " .. heightmapFilename)
        gHeightMap = nil
    end

end

function GetHeightmap()
    if not gHeightMap then

        gMaskMapName = false
        LoadHeightmap()
        gMaskMapName = true
    end

    return gHeightMap
end