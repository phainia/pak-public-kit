local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PVP_ValueNumber_ListItem_C = Base:Extend("UMG_PVP_ValueNumber_ListItem_C")

function UMG_PVP_ValueNumber_ListItem_C:OnConstruct()
  self.DropOut.btnLevelUp.OnClicked:Add(self, self.HandleKickOffButtonClick)
end

function UMG_PVP_ValueNumber_ListItem_C:OnDestruct()
  self.DropOut.btnLevelUp.OnClicked:Remove(self, self.HandleKickOffButtonClick)
end

function UMG_PVP_ValueNumber_ListItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.ObserverName:SetText(self.data.name)
  local path = "Texture2D'/Game/NewRoco/Modules/System/Common/Icon/HeadIcon/"
  local headIconFullPath
  if self.data.icon > 0 then
    local cardIconConf = _G.DataConfigManager:GetCardIconConf(self.data.icon)
    if cardIconConf then
      local headIconRelativePath = cardIconConf.icon_resource_path
      headIconFullPath = string.format("%s%s.%s'", path, headIconRelativePath, headIconRelativePath)
    end
  end
  if headIconFullPath then
    self.HeadPortrait:SetPath(headIconFullPath)
  end
end

function UMG_PVP_ValueNumber_ListItem_C:OnItemSelected(_bSelected)
end

function UMG_PVP_ValueNumber_ListItem_C:OnDeactive()
  self.data = nil
end

function UMG_PVP_ValueNumber_ListItem_C:HandleKickOffButtonClick()
  if self.data.OnKickOffCallback then
    if self.data.OnKickOffCallbackOwner then
      self.data.OnKickOffCallback(self.data.OnKickOffCallbackOwner, self)
    else
      self.data.OnKickOffCallback(self)
    end
  end
end

return UMG_PVP_ValueNumber_ListItem_C
