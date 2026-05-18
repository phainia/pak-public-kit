local MapItemBase = require("NewRoco.Modules.System.BigMap.Res.MapItemBase")
local MapItemMask = MapItemBase:Extend("MapItemMask")

function MapItemMask:Ctor(parentView, layerList, iconTemplateList)
  MapItemBase.Ctor(self, parentView, layerList, iconTemplateList)
end

function MapItemMask:Create()
end

return MapItemMask
