local UMG_Magic_DetailsTips_C = _G.NRCPanelBase:Extend("UMG_Magic_DetailsTips_C")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")

function UMG_Magic_DetailsTips_C:OnConstruct()
  self.CanClose = false
  self:AddButtonListener(self.HotArea, self.OnClose)
  self:PlayAnimation(self.open)
end

function UMG_Magic_DetailsTips_C:OnActive(param)
  self:OnAddEventListener()
  local petbaseId = param.petbaseId
  local propIcon, quality, name, desc = self:GetPetInfo(petbaseId)
  if param.needBlur then
    self.BG_1:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.BG_1:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
  if param.isSketch and param.notAcquired then
    self.Icon.ItemIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.Icon.headIconRetainer:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Icon.Silhouette:SetPath(propIcon)
  else
    self.Icon.ItemIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Icon.headIconRetainer:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.Icon.ItemIcon:SetPath(propIcon)
  end
  if param.notAcquired then
    self.TitleText:SetText("??????")
    self.BuffListingBox:SetVisibility(UE4.ESlateVisibility.Hidden)
    if param.isSketch then
      self.ContentText:SetText(_G.DataConfigManager:GetLocalizationConf("Map_Unknow_Pet_Tips_Desc").msg)
    else
      self.ContentText:SetText(_G.DataConfigManager:GetLocalizationConf("Camp_Unknow_Pet_Tips_Desc").msg)
    end
  else
    self.TitleText:SetText(name)
    self.SetQualityTextColor(self.TitleText, quality)
    self.ContentText:SetText(desc)
    self:SetTypes(BattleUtils.GetPetDefaultTypes(petbaseId))
    self.BuffListingBox:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  if param.insufficientLv then
    self.SizeBox_Bottom:SetVisibility(UE4.ESlateVisibility.Visible)
    local msgFmt = _G.DataConfigManager:GetLocalizationConf("Camp_Cannot_Refresh_Pet_Tips").msg
    self.prompt:SetText(string.format(msgFmt, name))
  else
    self.SizeBox_Bottom:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.touchLimitData = param.touchLimitData
end

function UMG_Magic_DetailsTips_C:OnDeactive()
end

function UMG_Magic_DetailsTips_C:OnAddEventListener()
end

function UMG_Magic_DetailsTips_C:OnAnimationFinished(anim)
  if anim == self.close then
    self:DoClose()
  end
end

function UMG_Magic_DetailsTips_C:OnClose()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1076, "UMG_Magic_DetailsTips_C:OnClose")
  self:RemoveButtonListener(self.HotArea)
  if self:IsAnimationPlaying(self.close) then
    return
  end
  self:PlayAnimation(self.close)
end

function UMG_Magic_DetailsTips_C:GetPetInfo(id)
  local itemConf
  local propIconPath = ""
  local quality = 0
  local name = ""
  local desc = ""
  itemConf = _G.DataConfigManager:GetPetbaseConf(id, true)
  if not itemConf then
    local PetConf = _G.DataConfigManager:GetPetConf(id, true)
    if not PetConf then
      Log.Error("PET_CONF\229\146\140PETBASE_CONF\228\184\173\233\131\189\230\137\190\228\184\141\229\136\176\232\191\153\228\184\170ID", id)
    end
    itemConf = _G.DataConfigManager:GetPetbaseConf(PetConf and PetConf.base_id or 0, true)
  end
  if itemConf then
    local model = _G.DataConfigManager:GetModelConf(itemConf.model_conf)
    propIconPath = NRCUtils:FormatConfIconPath(model.icon, _G.UIIconPath.HeadIconPath)
    if itemConf.quality == Enum.PetQuality.PQ_PURPLE then
      quality = 4
    elseif itemConf.quality == Enum.PetQuality.PQ_ORANGE then
      quality = 5
    else
      quality = 3
    end
    name = itemConf.name
    desc = itemConf.description
  end
  return propIconPath, quality, name, desc
end

function UMG_Magic_DetailsTips_C:SetQualityTextColor(text, quality)
  if 0 == quality then
    text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#ff0000"))
  elseif 1 == quality then
    text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#ffffff"))
  elseif 2 == quality then
    text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#96db71"))
  elseif 3 == quality then
    text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#43adef"))
  elseif 4 == quality then
    text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#c67fcc"))
  elseif 5 == quality then
    text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#e6c142"))
  end
end

function UMG_Magic_DetailsTips_C:SetTypes(Types)
  local attr1 = Types[1]
  local attr2 = Types[2]
  local attr3 = Types[3]
  local petTypes = {
    attr1,
    attr2,
    attr3
  }
  if petTypes then
    for i = 1, 3 do
      local petType = petTypes[i]
      if petType and petType > 0 then
        local conf = _G.DataConfigManager:GetTypeDictionary(petType)
        if i <= #petTypes and petType > 1 and conf then
          self["Attr" .. i]:SetVisibility(UE4.ESlateVisibility.Visible)
          local iconPath = conf.type_icon
          self["Attr" .. i]:SetPath(iconPath)
        else
          self["Attr" .. i]:SetVisibility(UE4.ESlateVisibility.Hidden)
        end
      end
    end
  end
end

function UMG_Magic_DetailsTips_C:OnAnimationFinished(Anim)
  if Anim == self.open and self.touchLimitData then
    local touchReasonType = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, self.touchLimitData.panel).TIPSITEM
    _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.UnlockIsSelectBtn, param.touchLimitData.module, self.touchLimitData.panel, touchReasonType)
  end
end

return UMG_Magic_DetailsTips_C
