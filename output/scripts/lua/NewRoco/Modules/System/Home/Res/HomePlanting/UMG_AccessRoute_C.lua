local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_AccessRoute_C = Base:Extend("UMG_AccessRoute_C")

function UMG_AccessRoute_C:OnConstruct()
  self.uiData = {}
end

function UMG_AccessRoute_C:OnDestruct()
  self.uiData = {}
end

function UMG_AccessRoute_C:OnSkipClick()
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_AccessRoute_C:OnSkipClick")
  _G.DataModelMgr.PlayerDataModel:SetIsTraceByBag(true)
  if self.uiData.text then
    if self.uiData.text == "ActivityModuleCmd.OpenMainPanel" then
      _G.NRCModuleManager:DoCmd(self.uiData.text, self.uiData.param2)
    elseif self.uiData.text == "BigMapModuleCmd.OnTraceBossByEggItemId" then
      _G.NRCModuleManager:DoCmd(self.uiData.text, LuaText.jump_to_error_tips, self.uiData.param1[1])
    elseif self.uiData.text == "ShopModuleCmd.OpenMainPanel" then
      _G.NRCModuleManager:DoCmd(self.uiData.text, self.uiData.param1[1])
    elseif self.uiData.text == "BigMapModuleCmd.SendZoneNpcTraceQueryReq" then
      _G.NRCModuleManager:DoCmd(self.uiData.text, self.uiData.param1)
    elseif self.uiData.text == "HomeModuleCmd.OpenSeedCraftPanel" or self.uiData.text == "HomeModuleCmd.OpenSeedBagPanel" then
      _G.NRCModuleManager:DoCmd(self.uiData.text, self.uiData.param1[1])
    else
      _G.NRCModuleManager:DoCmd(self.uiData.text, LuaText.jump_to_error_tips)
    end
  end
  _G.DataModelMgr.PlayerDataModel:SetIsTraceByBag(false)
end

function UMG_AccessRoute_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self.index = index
  self:updateItemInfo(_data)
end

function UMG_AccessRoute_C:updateItemInfo(_data)
  if _data.acquire_way_text == nil then
    self.SourceBtn1:SetVisibility(UE4.ESlateVisibility.Hidden)
  else
    if _data.text then
      self.SeedSynthesisBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.SeedSynthesisBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self.SyntheticSeedText:SetText(_data.acquire_way_text)
  end
end

function UMG_AccessRoute_C:OnItemSelected(_bSelected)
  if _bSelected and self.uiData.text then
    self:OnSkipClick()
  end
end

function UMG_AccessRoute_C:OnDeactive()
end

return UMG_AccessRoute_C
