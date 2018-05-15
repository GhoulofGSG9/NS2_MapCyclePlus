local oldInitialize = GUIMinimap.Initialize
function GUIMinimap:Initialize()
    gMaskMapName = false

    oldInitialize(self)

    gMaskMapName = true
end
