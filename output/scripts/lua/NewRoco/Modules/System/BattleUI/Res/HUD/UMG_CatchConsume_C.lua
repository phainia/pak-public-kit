local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
require("UnLuaEx")
local UMG_CatchConsume_C = _G.NRCPanelBase:Extend("UMG_CatchConsume_C")

function UMG_CatchConsume_C:OnConstruct()
  self.Pet = nil
  local CostStar = _G.DataConfigManager:GetPetGlobalConfig("team_battle_starlink")
  self.NRCText_323:SetText(CostStar.num)
end

function UMG_CatchConsume_C:OnDestruct()
end

function UMG_CatchConsume_C:OnActive()
end

function UMG_CatchConsume_C:OnDeactive()
end

function UMG_CatchConsume_C:OnAddEventListener()
end

function UMG_CatchConsume_C:SetPanelVisible(_IsShow)
  if _IsShow then
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_CatchConsume_C:BindPet(Pet)
  self.Pet = Pet
end

function UMG_CatchConsume_C:RefreshInfo(recoveryItemType)
  local vItemsConf = _G.DataConfigManager:GetVisualItemConf(recoveryItemType)
  if self.NRCImage_171 then
    self.NRCImage_171:SetPath(NRCUtils:FormatConfIconPath(vItemsConf.bigIcon, _G.UIIconPath.BagItemPath))
  end
end

function UMG_CatchConsume_C:SetCatchConsumeVisible(_IsShow)
  if _IsShow then
    self.CaptureConsumption:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.CaptureConsumption:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_CatchConsume_C:RefreshCatchConsumeInfo(itemType)
  if itemType == _G.Enum.VisualItem.VI_STAR_DEBRIS then
    if self.NRCImage_171 then
      self.NRCImage_171:SetPath("Texture2D'/Game/NewRoco/Modules/System/Common/Icon/BagItem/17.17'")
    end
  elseif itemType == _G.Enum.VisualItem.VI_STAR and self.NRCImage_171 then
    self.NRCImage_171:SetPath("Texture2D'/Game/NewRoco/Modules/System/Common/Icon/BagItem/16.16'")
  end
end

function UMG_CatchConsume_C:SetCatchTipTimeVisible(_IsShowText, _IsShowFailText)
  if _IsShowText then
    self.TextTipTime:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.TextTipTime:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if _IsShowFailText then
    self.Canvas_Capturefailure:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Canvas_Capturefailure:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_CatchConsume_C:ShowTime(time, operateType, params)
  self:Init()
  if operateType == BattleEnum.Operation.ENUM_CATCH then
    if time <= 0 then
      self.TextTipTime:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      local text_catch = _G.DataConfigManager:GetLocalizationConf("TipTime_Catch")
      self.TextTipTime:SetText(string.format(text_catch.msg, tostring(time)))
    end
    if params then
      if params[1] then
      end
      local CatchText
      if params.isInVisitCatch then
        if params.is_high_value then
          if params.free_catch then
            CatchText = _G.DataConfigManager:GetLocalizationConf("Highvaluepet_Owner_Rule_Freepet").msg
          elseif params.isInVisitCatch <= 0 then
            CatchText = _G.DataConfigManager:GetLocalizationConf("visit_xuancai_catch_time_zero_text").msg
          else
            CatchText = _G.DataConfigManager:GetLocalizationConf("visit_xuancai_catch_time_text").msg .. params.isInVisitCatch
          end
        elseif not BattleUtils.IsTeam() or not not params.isInVisitGlassCatch then
          CatchText = (params.isInVisitGlassCatch and LuaText.visit_xuancai_catch_time_text or LuaText.visit_catch_time_text) .. params.isInVisitCatch
        end
        if CatchText then
          self.TextTipTime:SetText(CatchText)
          if params.free_catch then
            self.TextTipTime:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("FFFFFFFF"))
          elseif params.isInVisitCatch <= 3 and params.isInVisitCatch > 0 then
            self.TextTipTime:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("D56C1FFF"))
          elseif params.isInVisitCatch <= 0 then
            self.TextTipTime:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("FF0000FF"))
          end
        end
      end
    end
  elseif operateType == BattleEnum.Operation.ENUM_ITEM then
    local text_item = _G.DataConfigManager:GetLocalizationConf("TipTime_Item")
    self.TextTipTime:SetText(string.format(text_item.msg, tostring(time)))
  else
    Log.WarningFormat("Time of operate type not defined, %d", operateType)
  end
end

function UMG_CatchConsume_C:Init()
  if self.Canvas_Capturefailure then
    self.Canvas_Capturefailure:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function UMG_CatchConsume_C:SetEffectVisible(_IsShow)
  if _IsShow then
    self.EffectSwitcher:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.EffectSwitcher:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_CatchConsume_C:ShowEffect(skill, enemyPet)
  local restraintResult = skill:GetRestraintByPetId(enemyPet.guid)
  local damageText = skill:GetDamageByPetId(enemyPet.guid)
  if damageText > skill.config.dam_para[1] then
    damageText = "<green>" .. tostring(damageText) .. "</>"
  elseif damageText < skill.config.dam_para[1] then
    damageText = "<red>" .. tostring(damageText) .. "</>"
  else
    damageText = "<normal_0>" .. tostring(damageText) .. "</>"
  end
  if restraintResult == BattleEnum.TypeRestraint.ENUM_NORMAL then
    self.EffectSwitcher:SetActiveWidgetIndex(1)
    self.EffectCommonText:SetText(damageText)
    if BattleUtils.IsPartialShow(enemyPet.card) then
      self.Img_EffectCommon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.Img_EffectCommon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  elseif restraintResult == BattleEnum.TypeRestraint.ENUM_RESTRAINT then
    self.EffectSwitcher:SetActiveWidgetIndex(0)
    self.EffectGodText:SetText(damageText)
    if BattleUtils.IsPartialShow(enemyPet.card) then
      self.Img_EffectGod:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.Img_EffectGod:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  elseif restraintResult == BattleEnum.TypeRestraint.ENUM_RESTRAINT_DOUBLE then
    self.EffectSwitcher:SetActiveWidgetIndex(3)
    self.EffectGodText_1:SetText(damageText)
    if BattleUtils.IsPartialShow(enemyPet.card) then
      self.Img_EffectGod_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.Img_EffectGod_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  elseif restraintResult == BattleEnum.TypeRestraint.ENUM_WEAK then
    self.EffectSwitcher:SetActiveWidgetIndex(2)
    self.EffectBadText:SetText(damageText)
    if BattleUtils.IsPartialShow(enemyPet.card) then
      self.Img_EffectBad:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.Img_EffectBad:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  elseif restraintResult == BattleEnum.TypeRestraint.ENUM_WEAK_DOUBLE then
    self.EffectSwitcher:SetActiveWidgetIndex(4)
    self.EffectBadText_1:SetText(damageText)
    if BattleUtils.IsPartialShow(enemyPet.card) then
      self.Img_EffectBad_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.Img_EffectBad_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
end

function UMG_CatchConsume_C:ShowSelectSureKeyUI(bShow)
  if self.ScrollPCKey then
    self.ScrollPCKey:SetKeyVisibility(bShow)
  end
end

function UMG_CatchConsume_C:RefreshSelectSureKeyUI()
  if SystemSettingModuleCmd and self.ScrollPCKey then
    local text, image = _G.NRCModuleManager:DoCmd(SystemSettingModuleCmd.GetMappingKeyUIName, "IA_BattleSure")
    if "" ~= image then
      self.ScrollPCKey:SetImageMode(image)
    else
      self.ScrollPCKey:SetText(text)
    end
  end
end

return UMG_CatchConsume_C
