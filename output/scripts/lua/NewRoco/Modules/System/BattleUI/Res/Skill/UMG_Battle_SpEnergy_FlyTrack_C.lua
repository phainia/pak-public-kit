local UMG_Battle_SpEnergy_FlyTrack_C = _G.NRCPanelBase:Extend("UMG_Battle_SpEnergy_FlyTrack_C")
local LuaMathUtils = require("NewRoco.Utils.LuaMathUtils")

function UMG_Battle_SpEnergy_FlyTrack_C:OnConstruct()
end

function UMG_Battle_SpEnergy_FlyTrack_C:OnDestruct()
  self.SpEnergyList = nil
  self.spEnergyElement = nil
end

function UMG_Battle_SpEnergy_FlyTrack_C:InitByData(spEnergyElement)
  self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.Fire:SetVisibility(spEnergyElement.dam_type == Enum.SkillDamType.SDT_FIRE and UE4.ESlateVisibility.HitTestInvisible or UE4.ESlateVisibility.Hidden)
  self.Grass:SetVisibility(spEnergyElement.dam_type == Enum.SkillDamType.SDT_GRASS and UE4.ESlateVisibility.HitTestInvisible or UE4.ESlateVisibility.Hidden)
  self.Light:SetVisibility(spEnergyElement.dam_type == Enum.SkillDamType.SDT_LIGHT and UE4.ESlateVisibility.HitTestInvisible or UE4.ESlateVisibility.Hidden)
  self.Water:SetVisibility(spEnergyElement.dam_type == Enum.SkillDamType.SDT_WATER and UE4.ESlateVisibility.HitTestInvisible or UE4.ESlateVisibility.Hidden)
  self.Dust:SetVisibility(spEnergyElement.dam_type == Enum.SkillDamType.SDT_EARTH and UE4.ESlateVisibility.HitTestInvisible or UE4.ESlateVisibility.Hidden)
  if spEnergyElement.dam_type ~= Enum.SkillDamType.SDT_FIRE and spEnergyElement.dam_type ~= Enum.SkillDamType.SDT_GRASS and spEnergyElement.dam_type ~= Enum.SkillDamType.SDT_LIGHT and spEnergyElement.dam_type ~= Enum.SkillDamType.SDT_WATER and spEnergyElement.dam_type ~= Enum.SkillDamType.SDT_EARTH then
    self.Light:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  end
  local objCanvasSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self)
  objCanvasSlot:SetPosition(self.sourcePos)
  self.restWaitTime = 1
  self.waitTotalTime = 1
end

function UMG_Battle_SpEnergy_FlyTrack_C:GetModeFromList(idx)
  if 0 == idx then
    return LuaMathUtils.Ease.Sine
  elseif 1 == idx then
    return LuaMathUtils.Ease.Linear
  elseif 2 == idx then
    return LuaMathUtils.Ease.Cubic
  elseif 3 == idx then
    return LuaMathUtils.Ease.Quart
  elseif 4 == idx then
    return LuaMathUtils.Ease.Quint
  elseif 5 == idx then
    return LuaMathUtils.Ease.Quad
  elseif 6 == idx then
    return LuaMathUtils.Ease.Expo
  elseif 7 == idx then
    return LuaMathUtils.Ease.Circ
  elseif 8 == idx then
    return LuaMathUtils.Ease.Back
  else
    return LuaMathUtils.Ease.Bounce
  end
end

function UMG_Battle_SpEnergy_FlyTrack_C:SetMovingModeFromList(idx)
  self.lerpEaseType = self:GetModeFromList(idx)
end

function UMG_Battle_SpEnergy_FlyTrack_C:RegisterTick()
  _G.UpdateManager:Register(self)
end

function UMG_Battle_SpEnergy_FlyTrack_C:UnRegisterTick()
  _G.UpdateManager:UnRegister(self)
end

function UMG_Battle_SpEnergy_FlyTrack_C:Fly(startPos, endPos, spEnergyList, syncData)
  self.sourcePos = startPos
  self.destPos = endPos
  self.SpEnergyList = spEnergyList
  self.spEnergyElement = syncData
  self.isFinish = false
  self:InitByData(syncData)
  self:RegisterTick()
end

function UMG_Battle_SpEnergy_FlyTrack_C:OnTick(InDeltaTime)
  if self.restWaitTime > 0 then
    self.restWaitTime = self.restWaitTime - InDeltaTime
    local PassedPercent = 1.0 - self.restWaitTime / self.waitTotalTime
    if self.destPos then
      local EaseFunc = LuaMathUtils[self.lerpEaseType]
      local EasePercent = EaseFunc and EaseFunc(PassedPercent) or PassedPercent
      self.curPos = self.sourcePos * (1 - EasePercent) + self.destPos * EasePercent
      local objCanvasSlot = self.Slot
      if objCanvasSlot then
        objCanvasSlot:SetPosition(self.curPos)
      end
    end
    if PassedPercent >= 1.0 then
      self.restWaitTime = 0
    end
  else
    self.curPos = self.destPos
    local objCanvasSlot = self.Slot
    if objCanvasSlot then
      objCanvasSlot:SetPosition(self.curPos)
    end
    self:UnRegisterTick()
    self:Finish()
  end
end

function UMG_Battle_SpEnergy_FlyTrack_C:Finish()
  if self.isFinish then
    return
  end
  self.isFinish = true
  self.SpEnergyList:FlyEffectCallBack(self.spEnergyElement)
  self:SetVisibility(UE4.ESlateVisibility.Hidden)
  self:RemoveFromParent()
end

return UMG_Battle_SpEnergy_FlyTrack_C
