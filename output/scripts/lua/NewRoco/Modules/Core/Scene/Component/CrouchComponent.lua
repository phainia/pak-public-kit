local Base = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local CrouchComponent = Base:Extend("CrouchComponent")

function CrouchComponent:Attach(owner)
  Base.Attach(self, owner)
  self._noCrouchNum = 0
  self._dirty = false
  self._isInGrass = false
  self.overlappedGrasses = {}
  self.owner:AddEventListener(self, PlayerModuleEvent.ON_STATUS_CHANGED, self.OnStatusChanged)
  local TempArray = UE4.TArray(UE4.AActor)
  self.owner.viewObj:GetOverlappingActors(TempArray)
  for _, actor in tpairs(TempArray) do
    local actorName = actor:GetName()
    if string.find(actorName, "BP_GrassRegionTrigger") then
      self:AddOverlappedGrass(actor)
    end
  end
end

function CrouchComponent:DeAttach()
  if self._isInGrass then
    self._isInGrass = false
    NRCEventCenter:DispatchEvent(SceneEvent.OnPlayerExitGrass)
  end
  self.owner:RemoveEventListener(self, PlayerModuleEvent.ON_STATUS_CHANGED, self.OnStatusChanged)
  self.overlappedGrasses = nil
  Base.DeAttach(self)
end

function CrouchComponent:InitGrassTrigger()
  self:UnInitGrassTrigger()
  local sceneModule = NRCModuleManager:GetModule("SceneModule")
  if not sceneModule then
    return
  end
  local sceneId = sceneModule.mapID
  local allArea = DataConfigManager:GetTable(DataConfigManager.ConfigTableId.AREA_CONF):GetAllDatas()
  local grassArea = {}
  for _, v in pairs(allArea) do
    local areaConf = v
    if areaConf.stealth_on > 0 and areaConf.scene_id == sceneId then
      table.insert(grassArea, areaConf)
    end
  end
  self.grassTriggers = {}
  self.grassTriggersRef = {}
  for i, v in pairs(grassArea) do
    local area = v
    local triggerClass = UE4.UNRCStatics.ResolveClass(UEPath.BP_GRASS_TRIGGER)
    local grassTrigger = UE4Helper.GetCurrentWorld():Abs_SpawnActor(triggerClass, nil, UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn)
    if grassTrigger then
      grassTrigger:Init(area, i)
    end
    table.insert(self.grassTriggers, grassTrigger)
    table.insert(self.grassTriggersRef, UnLua.Ref(grassTrigger))
  end
end

function CrouchComponent:UnInitGrassTrigger()
  if self.grassTriggers then
    for _, v in pairs(self.grassTriggers) do
      v:Release()
    end
    self.grassTriggers = nil
  end
  self.grassTriggersRef = nil
end

function CrouchComponent:SetNoCrouch(noCrouch)
  local noCrouchBef = self._noCrouchNum > 0
  local addNum = noCrouch and 1 or -1
  self._noCrouchNum = self._noCrouchNum + addNum
  local noCrouchAft = self._noCrouchNum > 0
  if noCrouchBef ~= noCrouchAft then
    self._dirty = true
  end
  if GlobalConfig.DebugCrouchStatus then
    UE4Helper.PrintScreenMsg(string.format("\230\189\156\232\161\140\232\176\131\232\175\149\239\188\154\230\151\160\230\179\149\230\189\156\232\161\140\230\160\135\231\173\190\229\143\152\230\155\180\239\188\140\229\189\147\229\137\141\232\174\161\230\149\176\239\188\154%d", self._noCrouchNum))
  end
end

function CrouchComponent:OnEnterGrass()
  if not self._isInGrass then
    self._isInGrass = true
    NRCEventCenter:DispatchEvent(SceneEvent.OnPlayerEnterGrass)
    local player = self.owner
    local playerBP = player.viewObj
    if playerBP then
      playerBP.MoveFXComponent.IsInGrass = true
    end
  end
end

function CrouchComponent:OnExitGrass()
  if self._isInGrass then
    self._isInGrass = false
    NRCEventCenter:DispatchEvent(SceneEvent.OnPlayerExitGrass)
    local player = self.owner
    local playerBP = player.viewObj
    if playerBP then
      playerBP.MoveFXComponent.IsInGrass = false
    end
    self:TryUnCrouch()
  end
end

function CrouchComponent:Update(deltaTime)
  self:UpdateGrassState()
  if self._dirty then
    self._dirty = false
    local noCrouch = self._noCrouchNum > 0
    if noCrouch then
      self:TryUnCrouch()
      return
    end
  end
end

function CrouchComponent:UpdateGrassState()
  for _, v in pairs(self.overlappedGrasses) do
    if v then
      local localPlayer = self.owner
      if localPlayer and localPlayer.viewObj then
        local playerLocation = localPlayer.viewObj:K2_GetActorLocation()
        local isInArea = false
        isInArea = UE4.UNewRocoHelperLibrary.PointInPolygon(UE4.FVector2D(playerLocation.X, playerLocation.Y), v.PolygonPoints2D)
        if isInArea then
          self:OnEnterGrass()
          return
        end
      end
    end
  end
  self:OnExitGrass()
end

function CrouchComponent:AddOverlappedGrass(grass)
  if not grass then
    return
  end
  if self.overlappedGrasses[grass.id] then
    return
  end
  self.overlappedGrasses[grass.id] = grass
end

function CrouchComponent:RemoveOverlappedGrass(grass)
  if not grass then
    return
  end
  self.overlappedGrasses[grass.id] = nil
end

function CrouchComponent:TryCrouch()
  if self._isInGrass and not self._isInCrouch then
    local player = self.owner
    local status = ProtoEnum.WorldPlayerStatusType.WPST_CROUCHING
    player.statusComponent:ApplyStatus(status)
    self._isInCrouch = player.statusComponent:HasStatus(status)
    if GlobalConfig.DebugCrouchStatus and self._isInCrouch then
      UE4Helper.PrintScreenMsg("\230\189\156\232\161\140\232\176\131\232\175\149\239\188\154\230\189\156\232\161\140\231\138\182\230\128\129\229\143\152\230\155\180\239\188\140\230\189\156\232\161\140\228\184\173")
    end
    if self._isInCrouch then
      local playerBP = player.viewObj
      if playerBP then
        playerBP.MoveFXComponent.CrouchRPTC = 100
        playerBP.IsCrouch = true
      end
    end
  end
end

function CrouchComponent:TryUnCrouch()
  if self._isInCrouch then
    local player = self.owner
    local status = ProtoEnum.WorldPlayerStatusType.WPST_CROUCHING
    player.statusComponent:RemoveStatus(status)
    self._isInCrouch = player.statusComponent:HasStatus(status)
    if GlobalConfig.DebugCrouchStatus and not self._isInCrouch then
      UE4Helper.PrintScreenMsg("\230\189\156\232\161\140\232\176\131\232\175\149\239\188\154\230\189\156\232\161\140\231\138\182\230\128\129\229\143\152\230\155\180\239\188\140\230\189\156\232\161\140\231\187\147\230\157\159")
    end
    if not self._isInCrouch then
      local playerBP = player.viewObj
      if playerBP then
        playerBP.MoveFXComponent.CrouchRPTC = 0
        playerBP.IsCrouch = false
      end
    end
  end
end

function CrouchComponent:OnStatusChanged(status, value, opCode)
  if status == ProtoEnum.WorldPlayerStatusType.WPST_CROUCHING and not self.owner.statusComponent:HasStatus(status) then
    self:TryUnCrouch()
    return
  end
  if not self._isInCrouch then
    self._dirty = true
  end
end

function CrouchComponent:OnDead()
  self._isInGrass = false
  self:TryUnCrouch()
end

function CrouchComponent:IsInGrass()
  return self._isInGrass
end

function CrouchComponent:isInCrouch()
  return self._isInCrouch
end

return CrouchComponent
