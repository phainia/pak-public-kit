local ProtoEnum = require("Data.PB.ProtoEnum")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local PopupAttributeInfo = require("NewRoco.Modules.Core.Battle.Entity.Components.BuffEffectPopup.PopupAttributeInfo")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local PopupData = NRCClass()
PopupData.DamagePopupPathMap = {
  [BattleEnum.PopupShowType.Normal] = BattleConst.UI.UMG_Battle_DamageGeneral,
  [BattleEnum.PopupShowType.IsCritical] = BattleConst.UI.UMG_Battle_DamageGeneral,
  [BattleEnum.PopupShowType.IsRestraint] = BattleConst.UI.UMG_Battle_DamageGeneral,
  [BattleEnum.PopupShowType.IsCritical | BattleEnum.PopupShowType.IsRestraint] = BattleConst.UI.UMG_Battle_DamageGeneral,
  [BattleEnum.PopupShowType.IsRestrainted] = BattleConst.UI.UMG_Battle_DamageGeneral,
  [BattleEnum.PopupShowType.IsRestrainted | BattleEnum.PopupShowType.IsCritical] = BattleConst.UI.UMG_Battle_DamageGeneral,
  [BattleEnum.PopupShowType.IsHeal] = BattleConst.UI.UMG_Battle_HealNumber
}

function PopupData:Ctor()
  self.content = ""
  self.popupSubShowType = BattleEnum.PopupShowType.Normal
  self.isHit = true
  self.isHealing = false
  self.attrInfo = nil
  self.power = 1
  self.CurDamage = 0
  self.damageType = 1
end

function PopupData:SetHit(isHit)
  self.isHit = isHit
  return self
end

function PopupData:SetHeal(isHeal)
  self.isHealing = isHeal
  return self
end

function PopupData:SetSourceId(sourceId)
  self.SourceId = sourceId
  return self
end

function PopupData:SetDamageType(type)
  if not type or type <= 0 then
    return
  end
  self.damageType = type
  return self
end

function PopupData:SetCritical(Critical)
  if Critical then
    self.popupSubShowType = self.popupSubShowType | BattleEnum.PopupShowType.IsCritical
  end
  return self
end

function PopupData:SetRestraintType(ResType)
  local isRestraint = ResType == ProtoEnum.SkillRestraintType.SRT_RESTRAINT_ONE or ResType == ProtoEnum.SkillRestraintType.SRT_RESTRAINT_TWO or ResType == ProtoEnum.SkillRestraintType.SRT_RESTRAINT_THREE
  if isRestraint then
    self.popupSubShowType = self.popupSubShowType | BattleEnum.PopupShowType.IsRestraint
  end
  local isRestrainted = ResType == ProtoEnum.SkillRestraintType.SRT_RESTRAINTED_ONE or ResType == ProtoEnum.SkillRestraintType.SRT_RESTRAINTED_TWO or ResType == ProtoEnum.SkillRestraintType.SRT_RESTRAINTED_THREE
  if isRestrainted then
    self.popupSubShowType = self.popupSubShowType | BattleEnum.PopupShowType.IsRestrainted
  end
  return self
end

function PopupData:IsCritical()
  return self.popupSubShowType & BattleEnum.PopupShowType.IsCritical > 0
end

function PopupData:IsRestraint()
  return self.popupSubShowType & BattleEnum.PopupShowType.IsRestraint > 0
end

function PopupData:IsRestrainted()
  return self.popupSubShowType & BattleEnum.PopupShowType.IsRestrainted > 0
end

function PopupData:IsPowerful()
  return self.power >= 4.0
end

function PopupData:SetAttributeInfo(AttrInfo)
  self.attrInfo = AttrInfo
  return self
end

function PopupData:SetAttributeInfoAsNum(UINum)
  if 0 ~= UINum then
    self.attrInfo = PopupAttributeInfo(PopupAttributeInfo.AttributeType.NORMAL, -1, UINum)
  else
    self.attrInfo = nil
  end
  return self
end

function PopupData:SetPower(power)
  self.power = power
  return self
end

function PopupData:SetDamageNumber(totalNumber, curNumber, addDamage)
  self.TotalDamageNumber = totalNumber
  self.CurDamageNumber = curNumber
  self.CurDamage = self.CurDamage + addDamage
  return self
end

function PopupData:GetDamageType()
  return self.damageType
end

function PopupData:GetUMG(caller, callBack)
  self.callInfo = {caller = caller, callBack = callBack}
  local umgPath
  if not self.isHit then
    umgPath = BattleConst.UI.UMG_Battle_Miss
  elseif self.popupShowType == ProtoEnum.AddIcon.AI_UP then
    umgPath = BattleConst.UI.UMG_Battle_BuffEffectUp
  elseif self.popupShowType == ProtoEnum.AddIcon.AI_DOWN then
    umgPath = BattleConst.UI.UMG_Battle_BuffEffectDown
  elseif self.popupShowType == ProtoEnum.AddIcon.AI_DAMAGE then
    if self.isHealing then
      umgPath = PopupData.DamagePopupPathMap[BattleEnum.PopupShowType.IsHeal]
    else
      umgPath = PopupData.DamagePopupPathMap[self.popupSubShowType]
    end
  elseif self.popupShowType == ProtoEnum.AddIcon.AI_BUFF then
    umgPath = BattleConst.UI.UMG_Battle_Common_1
  else
    umgPath = BattleConst.UI.UMG_Battle_Common_1
  end
  local BattleMain = BattleUtils.GetMainWindow()
  if not BattleMain or not umgPath then
    self.callInfo.callBack(self.callInfo.caller, nil, self.isHit, self)
    return
  end
  self.umgPath = umgPath
  if caller and caller.umgPool then
    caller.umgPool:Acquire(umgPath, function(retUMG, poolSuccess)
      if poolSuccess and retUMG then
        self:OnUmgLoad(retUMG)
      else
        Log.DebugFormat("[PopupData] Pool acquire failed for %s, fallback to dynamic create", umgPath)
        BattleResourceManager:LoadWidgetAsync(self, umgPath, nil, self.OnUmgLoadDynamic, nil, BattleMain)
      end
    end, nil, caller:GetFatherPanel(self))
  else
    BattleResourceManager:LoadWidgetAsync(self, umgPath, nil, self.OnUmgLoadDynamic, nil, BattleMain)
  end
end

function PopupData:OnUmgLoadDynamic(retUMG)
  local parent = self.callInfo.caller:GetFatherPanel(self)
  if parent then
    parent:AddChildtoCanvas(retUMG)
  end
  self:OnUmgLoad(retUMG)
end

function PopupData:OnUmgLoad(retUMG)
  if not retUMG or not self.callInfo then
    self.callInfo = nil
    return
  end
  self.umgRef = UnLua.Ref(retUMG)
  if self.popupShowType == ProtoEnum.AddIcon.AI_UP or self.popupShowType == ProtoEnum.AddIcon.AI_DOWN then
    if retUMG.SetContent then
      retUMG:SetContent(self.content)
    else
      Log.Error("zgx weird thing happened!!!  UMG no SetContent")
    end
  elseif self.popupShowType == ProtoEnum.AddIcon.AI_DAMAGE then
    if retUMG.SetContent then
      retUMG:SetContent(self.isHealing and self.content or self)
    else
      Log.Error("zgx weird thing happened!!!  UMG no SetContent")
    end
  elseif retUMG.SetContent then
    retUMG:SetContent(self.content, self:GetBuffColor(), self:GetBuffOutlineColor())
  else
    Log.Error("zgx weird thing happened!!!  UMG no SetContent")
  end
  self.callInfo.callBack(self.callInfo.caller, retUMG, self)
end

function PopupData:RecycleUMG(umg)
  if self.callInfo and self.callInfo.caller then
    self.callInfo.caller:RecycleUMG(umg, self.umgPath)
  end
end

function PopupData.MakePopup(Info, ShowType)
  local data = PopupData()
  data.content = tostring(Info)
  data.popupShowType = ShowType
  return data
end

function PopupData.FromBuffID(ID, bIsAttach)
  local Conf = _G.DataConfigManager:GetBuffConf(ID)
  if not Conf then
    return nil
  end
  if bIsAttach and (not Conf.add_des or Conf.add_des == "") then
    Log.Dump(Conf, 1, "no add des, skip")
    return nil
  end
  if not bIsAttach and (not Conf.trigger_des or "" == Conf.trigger_des) then
    Log.Dump(Conf, 1, "no trigger des, skip")
    return nil
  end
  local Content = bIsAttach and Conf.add_des or Conf.trigger_des
  local Icon = bIsAttach and Conf.add_icon or Conf.trigger_icon
  local data = PopupData.MakePopup(Content, Icon)
  return data
end

function PopupData.FromEffectConf(Conf, UINum)
  if not Conf then
    return nil
  end
  local data = PopupData.MakePopup(Conf.add_des or "", Conf.add_icon or "")
  data.isHit = true
  data:SetAttributeInfo(PopupAttributeInfo.FromEffect(Conf.id, UINum))
  return data
end

function PopupData:GetBuffColor()
  if self.popupShowType then
    if self.popupShowType == ProtoEnum.AddIcon.AI_POISON then
      return UE4.UNRCStatics.HexToSlateColor("#c46fe9ff")
    elseif self.popupShowType == ProtoEnum.AddIcon.AI_FIRE then
      return UE4.UNRCStatics.HexToSlateColor("#e34c1aff")
    elseif self.popupShowType == ProtoEnum.AddIcon.AI_FREEZEN then
      return UE4.UNRCStatics.HexToSlateColor("#89cbe7ff")
    elseif self.popupShowType == ProtoEnum.AddIcon.AI_BLOOD then
      return UE4.UNRCStatics.HexToSlateColor("#de3976ff")
    elseif self.popupShowType == ProtoEnum.AddIcon.AI_SEED then
      return UE4.UNRCStatics.HexToSlateColor("#53bb76ff")
    elseif self.popupShowType == ProtoEnum.AddIcon.AI_BUFF then
      return UE4.UNRCStatics.HexToSlateColor("#73C615FF")
    elseif self.popupShowType == ProtoEnum.AddIcon.AI_DEBUFF then
      return UE4.UNRCStatics.HexToSlateColor("#73C615FF")
    else
      return UE4.UNRCStatics.HexToSlateColor("#73C615FF")
    end
  end
  return nil
end

function PopupData:GetBuffOutlineColor()
  if self.popupShowType then
    if self.popupShowType == ProtoEnum.AddIcon.AI_POISON then
      return UE4.UNRCStatics.HexToSlateColor("#763393FF")
    elseif self.popupShowType == ProtoEnum.AddIcon.AI_FIRE then
      return UE4.UNRCStatics.HexToSlateColor("#B74651FF")
    elseif self.popupShowType == ProtoEnum.AddIcon.AI_FREEZEN then
      return UE4.UNRCStatics.HexToSlateColor("#3893A6FF")
    elseif self.popupShowType == ProtoEnum.AddIcon.AI_BLOOD then
      return UE4.UNRCStatics.HexToSlateColor("#852e4eFF")
    elseif self.popupShowType == ProtoEnum.AddIcon.AI_SEED then
      return UE4.UNRCStatics.HexToSlateColor("#447936FF")
    elseif self.popupShowType == ProtoEnum.AddIcon.AI_BUFF then
      return UE4.UNRCStatics.HexToSlateColor("#000000B3")
    elseif self.popupShowType == ProtoEnum.AddIcon.AI_DEBUFF then
      return UE4.UNRCStatics.HexToSlateColor("#000000B3")
    else
      return UE4.UNRCStatics.HexToSlateColor("#000000B3")
    end
  end
  return nil
end

return PopupData
