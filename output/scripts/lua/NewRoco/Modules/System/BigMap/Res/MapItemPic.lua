local MapItemBase = require("NewRoco.Modules.System.BigMap.Res.MapItemBase")
local MapItemPic = MapItemBase:Extend("MapItemPic")
MapItemPic.ItemData = {}

function MapItemPic:Ctor(parentView, layerList, iconTemplateList)
  MapItemBase.Ctor(self, parentView, layerList, iconTemplateList)
end

function MapItemPic:Create(itemData)
  local sceneResId = itemData.sceneResId
  local pieceNum = itemData.pieceNum
  local imageWidget, assetPath
  do
    local assetDir = "/Game/NewRoco/Modules/System/BigMap/Raw/Texture/Maps/"
    local assetDir_PC = "/Game/NewRoco/Modules/System/BigMap/Raw/Texture/Maps_PC/"
    if RocoEnv.PLATFORM_WINDOWS then
      local assetPath_PC = string.format("%s%d/%02d.%02d", assetDir_PC, sceneResId or 10003, pieceNum, pieceNum)
      if UE4.UNRCStatics.ResolveObjectSafe and UE4.UNRCStatics.ResolveObjectSafe(assetPath_PC) then
        assetPath = assetPath_PC
      end
    end
    assetPath = assetPath or string.format("%s%d/%02d.%02d", assetDir, sceneResId or 10003, pieceNum, pieceNum)
  end
  imageWidget:SetPath(assetPath)
end

function MapItemPic:Refresh(pieceNum)
end

function MapItemPic:Destroy()
end

return MapItemPic
