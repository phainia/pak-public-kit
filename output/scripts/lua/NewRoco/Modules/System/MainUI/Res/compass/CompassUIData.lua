local CompassUIData = NRCClass:Extend("CompassUIData")
local math_abs = math.abs
CompassUIData.MapAreaState = {
  MAP_AREA = 1,
  CHANGE_TO_NPC = 2,
  MAP_NPC = 3,
  PET_SENSE = 4,
  CLOSEING_PET_SENSE = 5,
  CLOSE_PET_SENSE = 6,
  MARK = 7,
  TASK = 8,
  Visit = 9,
  None = 999
}
CompassUIData.MapAreaStatePriority = {
  [CompassUIData.MapAreaState.TASK] = 0,
  [CompassUIData.MapAreaState.MARK] = 1
}

function CompassUIData:Ctor(fatherLayer, compass, Space, LevelArray)
  self.fatherLayer = fatherLayer
  self.Compass = compass
  self.SpacePerAngle = Space
  self.DistanceLevelArray = LevelArray
  self.WorldPos = UE4.FVector(0, 0, 0)
end

function CompassUIData:ResetData()
  self.WorldMapConfig = nil
  self.TaskAngleLimit = nil
  self.NpcAngleLimit = nil
  self.NpcConfig = nil
  self.IsOwlStarNpc = false
  self.UpdateVersion = -1
  self.ComPassAngle = 0
  self.IsCathPetNpc = false
  self.IsFinshCatchAnimation = false
  self.Gap = 0
  self.MinAngle = 0
  self.MaxAngle = 0
  self.DisSquareInXY = 0
  self.DistanceInXYSquare = 0
  self.ZOrderForOverlap = 0
  self.HeightParam = -1
  self.DirParam = -1
  self.glass_info = nil
  self.mutation_type = nil
end

function CompassUIData:InitData(Info, worldMap, ViewField)
  self:ResetData()
  self:SetPos(Info.Position)
  self.WorldMapConfig = worldMap
  self.IsUnLock = Info.IsUnLock
  self.IsFinish = Info.IsFinish
  self.Id = Info.Id
  self.LogicId = Info.LogicId
end

function CompassUIData:UpdateData(Info, worldMap)
  self:SetPos(Info.Position)
  self.WorldMapConfig = worldMap
  self.IsUnLock = Info.IsUnLock
  self.LogicId = Info.LogicId
  self:SetIcon()
end

function CompassUIData:InitUI()
  if self.CompWidget then
    self.CompWidget:StopAllAnimations()
    self:SetUpOrDown(0, true)
    self:SetRightOrLeft(0, true)
    self:SetDistance()
    self:SetTrace(self.IsTrace, self.isPlayAni, self.isPlayLoop, self.IsTraceInHVDistance)
    self:SetIsBig(self.IsBig, true)
    self:SetZOrder(self.ZOrderForOverlap)
    self:SetIcon()
  end
end

function CompassUIData:SetShowArray(array)
  self:SetShowArrayValue(nil)
  self.ShowArray = array
  if self.IsShow then
    self:SetShowArrayValue(true)
  end
end

function CompassUIData:SetShowArrayValue(value)
  if self.ShowArray and self.Id then
    self.ShowArray[self.Id] = value
  end
end

function CompassUIData:SetZOrder(ZOrder)
  self.ZOrderForOverlap = ZOrder
  if self.CompWidget and self.CompWidget.ZOrder ~= self.ZOrderForOverlap then
    self.CompWidget.ZOrder = self.ZOrderForOverlap
    self.CompWidget.Slot:SetZOrder(self.ZOrderForOverlap)
  end
end

function CompassUIData:SetDistance(distance)
  if self.CompWidget then
    self.CompWidget:SetDistance(distance)
  end
end

function CompassUIData:SetUpOrDown(param, isforce)
  if (self.HeightParam ~= param or isforce) and self.CompWidget then
    self.HeightParam = param
    self.CompWidget:SetUpOrDown(param)
  end
end

function CompassUIData:SetRightOrLeft(param, isforce)
  if (self.DirParam ~= param or isforce) and self.CompWidget then
    self.DirParam = param
    self.CompWidget:SetRightOrLeft(param)
  end
end

function CompassUIData:SetIcon()
  if self.CompWidget then
    self.CompWidget:SetIcon()
  end
end

function CompassUIData:IsCathPet()
  return self.IsCathPetNpc
end

function CompassUIData:FinshCatchAnimation()
  return self.IsFinshCatchAnimation
end

function CompassUIData:MapAreaChangeToNpc(Info, worldMap, newLevelArray, newShowArray)
  self.WorldMapConfig = worldMap
  self.IsUnLock = Info.IsUnLock
  self.NpcConfig = Info.NpcConfig
  self.NPC_level = Info.NPC_Level
  self:ChangeDisArrayValue(nil)
  self:SetShowArrayValue(nil)
  self.DistanceLevelArray = newLevelArray
  self.Id = Info.Id
  self:ChangeDisArrayValue(true)
  self:SetShowArray(newShowArray)
  if self.CurState == CompassUIData.MapAreaState.MAP_AREA then
    self.CurState = CompassUIData.MapAreaState.CHANGE_TO_NPC
    if self.CompWidget then
      self.CompWidget:PlayAnimation(self.CompWidget.close)
    else
      self.CurState = CompassUIData.MapAreaState.MAP_NPC
    end
  elseif self.CurState == CompassUIData.MapAreaState.MAP_NPC then
    self:SetIcon()
  end
end

function CompassUIData:OpenPetSense()
  if self.CurState ~= CompassUIData.MapAreaState.CLOSEING_PET_SENSE then
    if self.CompWidget then
      self.CompWidget:PlayAnimation(self.CompWidget.open)
    end
    self:SetIsBig(true)
  end
  self.CurState = CompassUIData.MapAreaState.PET_SENSE
end

function CompassUIData:ClosePetSense()
  self:SetIsBig(false)
  self.CurState = CompassUIData.MapAreaState.CLOSEING_PET_SENSE
end

function CompassUIData:BurnSenseTime(time)
  if self.PetSenseTime > 0 then
    self.PetSenseTime = self.PetSenseTime - time
    return true
  elseif self.CurState == CompassUIData.MapAreaState.PET_SENSE then
    self:ClosePetSense()
  end
  return false
end

function CompassUIData:SetTrace(isTrace, isPlayAni, isPlayLoop, isTraceInHVDistance)
  self.IsTrace = isTrace
  self.IsTraceInHVDistance = isTraceInHVDistance
  self.isPlayAni = isPlayAni
  self.isPlayLoop = isPlayLoop
  if self.IsTrace then
    self:DisableDistanceLevel()
  end
  if self.CompWidget then
    self.CompWidget:SetTrace(isTrace, isPlayAni, isPlayLoop)
  end
end

function CompassUIData:PlayCatchPetEffect(event_info)
  if self.CompWidget then
    self.CompWidget:PlayCatchPetEffect(event_info)
  end
end

function CompassUIData:SetIsShow(isShow)
  if self.IsShow ~= nil and self.IsShow == isShow then
    return false
  end
  self.IsShow = isShow
  if isShow then
    self:CreateWidget()
    self.CompWidget:SetIsShow(self.IsShow)
    self:SetShowArrayValue(true)
  else
    self:ClearWidget()
    self:SetShowArrayValue(nil)
  end
  return true
end

function CompassUIData:SetIsBig(isBig, isForce)
  if self.IsBig ~= isBig or isForce then
    self.IsBig = isBig
    if self.CompWidget then
      self.CompWidget:PlayChangeSizeAni()
    end
  end
end

function CompassUIData:SetPosByCamera(CameraDir)
  local gap = self.ComPassAngle - CameraDir
  if math_abs(gap) > 180 then
    if gap > 0 then
      gap = gap - 360
    else
      gap = 360 + gap
    end
  end
  if self.TaskAngleLimit then
    if gap > self.TaskAngleLimit then
      gap = self.TaskAngleLimit
    elseif gap < -1 * self.TaskAngleLimit then
      gap = -1 * self.TaskAngleLimit
    end
  end
  if self.IsTrace then
    if gap > self.NpcAngleLimit then
      gap = self.NpcAngleLimit
      self:SetRightOrLeft(1)
    elseif gap < -1 * self.NpcAngleLimit then
      gap = -1 * self.NpcAngleLimit
      self:SetRightOrLeft(2)
    else
      self:SetRightOrLeft()
    end
  end
  self.Gap = gap
  if self.CompWidget then
    self.CompWidget:SetPosByCamera()
  end
end

function CompassUIData:GetZOrderSort()
  return self.DistanceInXYSquare * 1000 + math.abs(self.Gap)
end

function CompassUIData:SetPos(pos)
  if not self.WorldPos then
    self.WorldPos = UE4.FVector(0, 0, 0)
  end
  if pos then
    self.WorldPos.X = pos.X
    self.WorldPos.Y = pos.Y
    self.WorldPos.Z = pos.Z
  end
end

function CompassUIData:CreateWidget()
  if not self.CompWidget then
    self.CompWidget = self.Compass:CreateCompItemWidget(self.fatherLayer, self.itemUClass)
    self.CompWidget.uiData = self
    self.CompWidget.ZOrder = 0
    self:InitUI()
  end
end

function CompassUIData:ClearWidget()
  if self.CompWidget then
    self.CompWidget:SetIsShow(false)
    self.CompWidget:RemoveFromParent()
    self.CompWidget = nil
  end
end

function CompassUIData:CircleSelf()
  if self.Compass then
    self.Compass:RemoveUIData(self)
  end
end

function CompassUIData:EnableDistanceLevel()
  self:ChangeDistanceLevel(0)
end

function CompassUIData:DisableDistanceLevel()
  self:ChangeDistanceLevel(-1)
end

function CompassUIData:CalDistanceLevel(log2)
  if self.DistanceLevel >= 0 then
    self:ChangeDistanceLevel(math.max(0, math.floor(math.log(self.DistanceInXYSquare) / (2 * log2))))
  end
end

function CompassUIData:ChangeDistanceLevel(distanceLevel)
  if self.DistanceLevel ~= distanceLevel then
    self:ChangeDisArrayValue(nil)
    self.DistanceLevel = distanceLevel
    self:ChangeDisArrayValue(true)
  end
end

function CompassUIData:ChangeDisArrayValue(value)
  if self.DistanceLevel and self.DistanceLevelArray and self.Id then
    local Layer = self.DistanceLevelArray[self.DistanceLevel]
    if value and not Layer then
      Layer = {}
      Layer.UpdateIndex = 1
      Layer.NeedUpdateCount = 0
      Layer.KeysList = {}
      Layer.ItemNumber = 0
      self.DistanceLevelArray[self.DistanceLevel] = Layer
      self.DistanceLevelArray.MaxLayer = math.max(self.DistanceLevelArray.MaxLayer or 0, self.DistanceLevel)
      self.DistanceLevelArray.CycleTickTime = math.ceil((self.DistanceLevelArray.MaxLayer + 1) / self.Compass.DisUpdatePerTick)
    end
    if Layer then
      if value then
        Layer.ItemNumber = Layer.ItemNumber + 1
        if 1 == Layer.ItemNumber then
          if Layer.CurUpdateKey then
            Log.Error("zgx should not has value", Layer.CurUpdateKey, Layer.DistanceLevel)
          end
          Layer.CurUpdateKey = self.Id
        end
      elseif Layer.KeysList[self.Id] then
        Layer.ItemNumber = Layer.ItemNumber - 1
        if Layer.CurUpdateKey == self.Id then
          local integerId = math.tointeger(self.Id)
          local nextKey = integerId or self.Id
          Layer.CurUpdateKey = next(Layer.KeysList, nextKey)
          if Layer.ItemNumber > 0 and not Layer.CurUpdateKey then
            Layer.CurUpdateKey = next(Layer.KeysList)
          end
        end
      end
      Layer.KeysList[self.Id] = value
      if self.DistanceLevel >= 0 then
        self.DistanceLevelArray.NeedUpdateFrame = math.max(self.DistanceLevelArray.NeedUpdateFrame or 1, self.DistanceLevelArray.CycleTickTime * math.ceil(Layer.ItemNumber / self.Compass.LayerUpdatePerTick))
      end
      if Layer.ItemNumber < 0 then
        Log.Error("zgx Layer num is error", self.DistanceLevel, Layer.ItemNumber)
      end
    end
  end
end

function CompassUIData:UpdateWorldPos()
end

function CompassUIData:OnDestruct()
  self.Compass = nil
  self.WorldMapConfig = nil
  self.NpcConfig = nil
  self.IsOwlStarNpc = false
  self.CompWidget = nil
end

return CompassUIData
