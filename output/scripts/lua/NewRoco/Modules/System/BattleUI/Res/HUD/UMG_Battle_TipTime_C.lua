local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
require("UnLuaEx")
local UMG_Battle_TipTime_C = _G.NRCUmgClass:Extend("UMG_Battle_TipTime_C")

function UMG_Battle_TipTime_C:ShowTime(time, operateType, params)
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
          if params.isInVisitCatch <= 3 and params.isInVisitCatch > 0 then
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

function UMG_Battle_TipTime_C:Init()
  if self.Canvas_Capturefailure then
    self.Canvas_Capturefailure:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

return UMG_Battle_TipTime_C
