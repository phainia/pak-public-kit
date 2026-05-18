local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local MusicCollectionModuleEvent = require("NewRoco.Modules.System.MusicCollection.MusicCollectionModuleEvent")
local UMG_SetOptions_C = Base:Extend("UMG_SetOptions_C")

function UMG_SetOptions_C:OnConstruct()
end

function UMG_SetOptions_C:OnDestruct()
end

function UMG_SetOptions_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self.index = index
  self:SetInfo()
end

function UMG_SetOptions_C:SetInfo()
  local MusicApplyListConf = _G.DataConfigManager:GetMusicApplyListConf(self.uiData.id)
  if self.uiData.IsSet then
    self.check:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.check:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.checkIcon:SetPath(MusicApplyListConf.list_icon_path)
  self.SortText:SetText(MusicApplyListConf.list_name)
end

function UMG_SetOptions_C:OnItemSelected(_bSelected)
  if _bSelected then
    self:StopAllAnimations()
    self:PlayAnimation(self.Press)
    _G.NRCModuleManager:GetModule("MusicCollectionModule"):DispatchEvent(MusicCollectionModuleEvent.SetMusicOption, self.uiData.id)
  else
    self:StopAllAnimations()
    self:PlayAnimation(self.Cancel)
  end
end

function UMG_SetOptions_C:OnDeactive()
end

return UMG_SetOptions_C
