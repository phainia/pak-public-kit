local LuaMathUtils = require("NewRoco.Utils.LuaMathUtils")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local Zero = UE4.FVector2D(0, 0)
local UMG_Battle_EnergyTrack_C = NRCUmgClass:Extend("")
UMG_Battle_EnergyTrack_C.Data = NRCUmgClass:Extend("")

function UMG_Battle_EnergyTrack_C.Data:Ctor(sourcePos, destPos, anim, targetView)
  self.sourcePos = sourcePos
  self.destPos = destPos
  self.anim = anim
  self.targetView = targetView
end

function UMG_Battle_EnergyTrack_C:Ctor()
  self.lerpRemainTime = 0
  self.lerpTotalTime = 0
  self.animTotalTime = 0
  self.animRestTime = 0
  self.sequenceIdx = 1
  self.lerpEaseType = LuaMathUtils.Ease.Quad
  self.BattleManager = _G.BattleManager
  self.sequenceDataList = {}
  self.isFinished = false
  self.lerpOffsetTarget = UE4.FVector2D(0, 0)
  self.rand = _G.UE4.UKismetMathLibrary.RandomInteger(1000)
end

function UMG_Battle_EnergyTrack_C:Construct()
  self.DecreaseStarList = {
    self.StarFly_1,
    self.StarFly_2,
    self.StarFly_3,
    self.StarFly_4,
    self.StarFly_5,
    self.StarFly_6
  }
end

function UMG_Battle_EnergyTrack_C:Destruct()
  table.clear(self.DecreaseStarList)
  self:UnRegisterTick()
  self:RemoveFromParent()
  NRCUmgClass.Destruct(self)
end

function UMG_Battle_EnergyTrack_C:SetMovingMode(lerpEaseType)
  if lerpEaseType then
    self.lerpEaseType = lerpEaseType
  end
end

function UMG_Battle_EnergyTrack_C:SetMovingModeRandom()
  self.lerpEaseType = self:GetRandomMode()
end

function UMG_Battle_EnergyTrack_C:SetMovingModeFromList(idx)
  self.lerpEaseType = self:GetModeFromList(idx)
end

function UMG_Battle_EnergyTrack_C:OnActive()
end

function UMG_Battle_EnergyTrack_C:RegisterTick()
  _G.UpdateManager:Register(self)
end

function UMG_Battle_EnergyTrack_C:UnRegisterTick()
  _G.UpdateManager:UnRegister(self)
end

function UMG_Battle_EnergyTrack_C:UnRegisterTickInternal()
  self.canPlay = false
  if self.targetEnergyView and self.isAdd then
    self.targetEnergyView:IncreaseEnergy(1, true)
  else
  end
  self:OnProcessEnergyTrack()
end

function UMG_Battle_EnergyTrack_C:RegisterTickInternal()
  self.canPlay = true
end

function UMG_Battle_EnergyTrack_C:GeneralFly(startPos, endPos, callbackOwner, callback)
  local _startPos = startPos
  local _endPos = endPos
  local anim = self.StarTrailAnim_Increase
  table.insert(self.sequenceDataList, UMG_Battle_EnergyTrack_C.Data(_startPos, _endPos, anim, nil))
  self:CalculateTotalTime()
  self.callbackOwner = callbackOwner
  self.callback = callback
  self:RegisterTick()
  self:OnProcessEnergyTrack()
end

function UMG_Battle_EnergyTrack_C:DirectFly(startPos, energyView, callbackOwner, callback)
  local _startPos = startPos
  local targetEnergyView = energyView
  local _endPos = UE4.USlateBlueprintLibrary.GetLocalTopLeft(targetEnergyView:GetCachedGeometry())
  local anim = self.StarTrailAnim_Increase
  table.insert(self.sequenceDataList, UMG_Battle_EnergyTrack_C.Data(_startPos, _endPos, anim, targetEnergyView))
  self:CalculateTotalTime()
  local BattleMain = BattleUtils.GetMainWindow()
  BattleMain.EnergyTrack = nil
  BattleMain.EnergyTrack = self
  self.callbackOwner = callbackOwner
  self.callback = callback
  self:RegisterTick()
  self:OnProcessEnergyTrack()
end

function UMG_Battle_EnergyTrack_C:BounceAndFly(startPos, energyView)
  local _endPos = UE4.FVector2D(0, 0)
  local _startPos = startPos
  local viewport = UE4.UWidgetLayoutLibrary.GetViewportSize(UE4Helper.GetCurrentWorld())
  local cP = UE4.FVector2D(viewport.X / 2, viewport.Y / 2)
  UE4.USlateBlueprintLibrary.ScreenToViewport(_G.UE4Helper.GetCurrentWorld(), cP, _endPos)
  local anim = self.StarBounceAnim
  table.insert(self.sequenceDataList, UMG_Battle_EnergyTrack_C.Data(_startPos, _endPos, anim))
  local targetEnergyView = energyView
  _startPos = _endPos
  _endPos = UE4.USlateBlueprintLibrary.GetLocalTopLeft(targetEnergyView:GetCachedGeometry())
  anim = self.StarTrailAnim_Increase
  table.insert(self.sequenceDataList, UMG_Battle_EnergyTrack_C.Data(_startPos, _endPos, anim, targetEnergyView))
  self:CalculateTotalTime()
  local BattleMain = BattleUtils.GetMainWindow()
  BattleMain.EnergyTrack = self
  self:RegisterTick()
  self:OnProcessEnergyTrack()
end

function UMG_Battle_EnergyTrack_C:DecreaseFly(energyView, num, callbackOwner, callback)
  self.StarFx:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.decreaseNum = num
  for idx = 1, num do
    if self.DecreaseStarList[idx] then
      self.DecreaseStarList[idx]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
  local targetEnergyView = energyView
  local _endPos = UE4.USlateBlueprintLibrary.GetLocalTopLeft(targetEnergyView:GetCachedGeometry())
  local _startPos = _endPos
  local anim = self.StarTrailAnim_Decrease
  table.insert(self.sequenceDataList, UMG_Battle_EnergyTrack_C.Data(_startPos, _endPos, anim, targetEnergyView))
  self:CalculateTotalTime()
  self.callbackOwner = callbackOwner
  self.callback = callback
  self:RegisterTick()
  self:OnProcessEnergyTrack()
  self.targetEnergyView:DecreaseEnergy(self.decreaseNum)
end

function UMG_Battle_EnergyTrack_C:CalculateTotalTime()
  local totalTime = 0
  for idx = 1, #self.sequenceDataList do
    local data = self.sequenceDataList[idx]
    totalTime = totalTime + self:GetAnimTime(data.anim)
  end
  self.animTotalTime = totalTime
end

function UMG_Battle_EnergyTrack_C:OnProcessEnergyTrack()
  if self.sequenceIdx <= #self.sequenceDataList then
    local sequenceData = self.sequenceDataList[self.sequenceIdx]
    self.sequenceIdx = self.sequenceIdx + 1
    local startPos = sequenceData.sourcePos
    local endPos = sequenceData.destPos
    local anim = sequenceData.anim
    if sequenceData.targetView then
      self.targetEnergyView = sequenceData.targetView
    else
      self.targetEnergyView = nil
    end
    local objCanvasSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self)
    objCanvasSlot:SetPosition(startPos)
    self.lerpOffsetStart = startPos
    self.lerpOffsetTarget = endPos
    self.lerpOffsetRatio = 0.99
    self.lerpTotalTime = self:GetAnimTime(anim)
    self.lerpRemainTime = self.lerpTotalTime
    self:StopAllAnimations()
    self:PlayAnimation(anim)
    self:SetVisibility(UE4.ESlateVisibility.Visible)
    self:RegisterTickInternal()
  else
    self:Finish()
    self:UnRegisterTick()
    self:Destruct()
  end
end

function UMG_Battle_EnergyTrack_C:Finish()
  local BattleMain = BattleUtils.GetMainWindow()
  if BattleMain then
    BattleMain.EnergyTrack = nil
  end
  self.isFinished = true
  local Owner = self.callbackOwner
  local Callback = self.callback
  self.callback = nil
  self.callbackOwner = nil
  if Callback then
    Callback(Owner)
  end
end

function UMG_Battle_EnergyTrack_C:GetAnimTime(anim)
  return anim:GetEndTime() - anim:GetStartTime()
end

function UMG_Battle_EnergyTrack_C:GetRemainTime()
  return self.animTotalTime
end

function UMG_Battle_EnergyTrack_C:LogPos()
  local geometrySelf = self:GetCachedGeometry()
  local tmp = UE4.USlateBlueprintLibrary.GetLocalTopLeft(geometrySelf)
  Log.Error("Log pos")
  Log.Error(tmp)
end

function UMG_Battle_EnergyTrack_C:ResetPosition()
  local objCanvasSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self)
  objCanvasSlot:SetPosition(self.posInitial)
end

function UMG_Battle_EnergyTrack_C:GetRandomMode()
  local rand = _G.UE4.UKismetMathLibrary.RandomInteger(9)
  return self:GetModeFromList(rand)
end

function UMG_Battle_EnergyTrack_C:GetModeFromList(idx)
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

function UMG_Battle_EnergyTrack_C:OnTick(InDeltaTime)
  if self.canPlay then
    if self.lerpTotalTime and self.lerpRemainTime and self.lerpTotalTime + self.lerpRemainTime > 0 then
      self.lerpRemainTime = math.clamp(self.lerpRemainTime - InDeltaTime, 0, self.lerpTotalTime)
      self.animTotalTime = self.animTotalTime - InDeltaTime
      local PassedPercent = 1.0 - self.lerpRemainTime / self.lerpTotalTime
      if self.lerpOffsetTarget then
        local EaseFunc = LuaMathUtils[self.lerpEaseType]
        local EasePercent = EaseFunc and EaseFunc(PassedPercent) or PassedPercent
        self.TargetOffset = self.lerpOffsetStart * (1 - EasePercent) + self.lerpOffsetTarget * EasePercent
        local objCanvasSlot = self.Slot
        if objCanvasSlot then
          objCanvasSlot:SetPosition(self.TargetOffset)
        end
      end
      if PassedPercent >= 1.0 then
        self.lerpTotalTime = 0
        self.lerpRemainTime = 0
        self.lerpStartTargetOffset = nil
      end
    elseif self.lerpOffsetTarget then
      if UE4.FVector2D.DistSquared(self.lerpOffsetTarget, self.TargetOffset) > 1.0E-6 then
        self.TargetOffset = LuaMathUtils.LerpVector(self.TargetOffset, self.lerpOffsetTarget, self.lerpOffsetRatio * InDeltaTime)
        local objCanvasSlot = self.Slot
        objCanvasSlot:SetPosition(self.TargetOffset)
      else
        self.TargetOffset = self.lerpOffsetTarget
        local objCanvasSlot = self.Slot
        if objCanvasSlot then
          objCanvasSlot:SetPosition(self.TargetOffset)
        end
        self:UnRegisterTickInternal()
      end
    end
  end
end

return UMG_Battle_EnergyTrack_C
