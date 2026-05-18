local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_DailySurvey_ItemIcon_C = Base:Extend("UMG_DailySurvey_ItemIcon_C")

function UMG_DailySurvey_ItemIcon_C:OnConstruct()
end

function UMG_DailySurvey_ItemIcon_C:OnDestruct()
end

function UMG_DailySurvey_ItemIcon_C:OnItemUpdate(_data, datalist, index)
  self.isSpecial = _G.NRCModuleManager:DoCmd(_G.MagicManualModuleCmd.IsGetDailyTaskSpecial)
  self.eggShowId = _G.DataConfigManager:GetDailyGlobalConfig(8).numList[1]
  self.eggShowNum = _G.DataConfigManager:GetDailyGlobalConfig(8).numList[2]
  self.data = _data
  local IconPath, BgQuality
  if self.data.Type == Enum.GoodsType.GT_VITEM then
    local VIItemConf = _G.DataConfigManager:GetVisualItemConf(self.data.Id)
    IconPath = NRCUtils:FormatConfIconPath(VIItemConf.bigIcon, _G.UIIconPath.BagItemPath)
    BgQuality = VIItemConf.item_quality
  elseif self.data.Type == Enum.GoodsType.GT_BAGITEM then
    local id = self.data.Id
    local BagItemConf = _G.DataConfigManager:GetBagItemConf(id)
    IconPath = BagItemConf.icon
    BgQuality = BagItemConf.item_quality
  elseif self.data.Type == _G.Enum.GoodsType.GT_PET then
    local petInfo = _G.DataConfigManager:GetPetConf(self.data.Id)
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petInfo.base_id)
    if nil ~= petBaseConf then
      local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
      if nil ~= modelConf then
        IconPath = NRCUtils:FormatConfIconPath(modelConf.icon, _G.UIIconPath.HeadIconPath)
      end
      self:SetQuality(petBaseConf.quality)
    end
  end
  if self.data.state == _G.ProtoEnum.EMTaskState.EM_TASK_STATE_DONE then
    self.AlreadyReceived:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.txtLV:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#7a7770"))
  else
    self.AlreadyReceived:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.txtLV:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#FFFFFFFF"))
  end
  self.icon:SetPath(IconPath)
  if self.data.Id == self.eggShowId and self.isSpecial then
    self.txtLV:SetText("x" .. self.eggShowNum)
  else
    self.txtLV:SetText("x" .. self.data.Count)
  end
  self:SetQuality(BgQuality)
end

function UMG_DailySurvey_ItemIcon_C:OnItemSelected(_bSelected)
  if _bSelected then
    local id = self.data.Id
    _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.Tips_OpenItemTips, id, self.data.Type, false)
  end
end

function UMG_DailySurvey_ItemIcon_C:SetQuality(quality)
  if 0 == quality then
  elseif 1 == quality then
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_1))
  elseif 2 == quality then
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_2))
  elseif 3 == quality then
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_3))
  elseif 4 == quality then
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_4))
  elseif 5 == quality then
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_5))
  end
end

function UMG_DailySurvey_ItemIcon_C:OnDeactive()
end

return UMG_DailySurvey_ItemIcon_C
