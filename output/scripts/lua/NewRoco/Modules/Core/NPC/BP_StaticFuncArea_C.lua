require("UnLuaEx")
local Base = require("Core.NRCClass")
local NPCLuaUtils = require("NewRoco.Modules.Core.NPC.NPCLuaUtils")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local ThrowSessionEvent = require("NewRoco.Modules.Core.NPC.ThrowSessionEvent")
local ThrowSessionStatusEnum = require("NewRoco.Modules.Core.NPC.ThrowSessionStatusEnum")
local BP_StaticFuncArea_C = Base:Extend("BP_StaticFuncArea_C")
local FuncAreaType = {
  None = 0,
  Death = 1,
  ReSetPet = 2,
  DestroyNpc = 4
}

function BP_StaticFuncArea_C:Ctor()
  self.FuncBitSet = 0
end

function BP_StaticFuncArea_C:ReceiveBeginPlay()
  self:Init()
end

function BP_StaticFuncArea_C:Init()
  for _, EnumValue in tpairs(self.FuncAreaType) do
    self.FuncBitSet = self.FuncBitSet | 1 << EnumValue
  end
end

function BP_StaticFuncArea_C:OnAreaBeginOverlap(OtherActor, OtherComp)
  if OtherComp ~= OtherActor.CapsuleComponent then
    return
  end
  if self.FuncBitSet == nil or self.FuncBitSet == FuncAreaType.None then
    return
  end
  if 0 ~= self.FuncBitSet & FuncAreaType.Death then
    self:DeathFunc(OtherActor, OtherComp)
  end
  if 0 ~= self.FuncBitSet & FuncAreaType.ReSetPet then
    self:ResetPetFunc(OtherActor, OtherComp)
  end
  if 0 ~= self.FuncBitSet & FuncAreaType.DestroyNpc then
    self:DestroyNpcFunc(OtherActor, OtherComp)
  end
end

function BP_StaticFuncArea_C:DeathFunc(OtherActor, OtherComp)
  local Player = self:PlayerCheck(OtherActor, OtherComp)
  if not Player then
    return
  end
  local PlayerRoleHpComp = Player and Player.roleHPComponent
  local BanDeath, BanMsg = _G.FunctionBanManager:GetFunctionState(_G.Enum.PlayerFunctionBanType.PFBT_DUNGEON_DEATH_AREA, true, false)
  if not BanDeath and PlayerRoleHpComp then
    PlayerRoleHpComp:ReduceAllRoleHP(_G.ProtoEnum.RoleHpReduceReason.HP_REDUCE_REASON_FALLING)
    Log.Debug("Kill Player By BP_StaticDeathArea, Reason: \230\145\148\230\173\187\228\186\134")
    return
  end
  Log.Debug("[StaticFuncArea] \232\167\146\232\137\178\230\137\163\232\161\128\229\183\178\232\162\171\231\166\129\231\148\168: ", BanMsg)
end

function BP_StaticFuncArea_C:ResetPetFunc(OtherActor, OtherComp)
  local PetCharacter, ResetPos, ResetRotator = self:PetCheck(OtherActor, OtherComp)
  if not PetCharacter then
    return
  end
  local TransitionTime = self.DestroyTime or 0.6
  NPCLuaUtils.ResetPet(OtherActor, TransitionTime, ResetPos, ResetRotator)
end

function BP_StaticFuncArea_C:PlayerCheck(OtherActor, OtherComp)
  local Character = OtherActor.sceneCharacter
  if not Character then
    if OtherActor:IsA(UE.ARocoVehicleCharacter) then
      local Rider = OtherActor.Rider
      Character = Rider and Rider.sceneCharacter
    else
      return nil
    end
  end
  if not Character then
    return nil
  end
  if not Character.isLocal then
    return nil
  end
  if OtherComp ~= OtherActor.CapsuleComponent then
    return nil
  end
  Log.Debug("[StaticFuncArea] PlayerChecked Actor:", UE.UObject.GetName(OtherActor))
  return Character
end

function BP_StaticFuncArea_C:PetCheck(OtherActor, _)
  local SceneCharacter = OtherActor.sceneCharacter
  if SceneCharacter and SceneCharacter.IsPet and SceneCharacter:IsPet() then
    Log.Debug("[StaticFuncArea] PetChecked Actor:", UE.UObject.GetName(OtherActor))
    if SceneCharacter.ThrowSession then
      if SceneCharacter.ThrowSession.Status < ThrowSessionStatusEnum.PostInteract then
        SceneCharacter.ThrowSession:AddEventListener(self, ThrowSessionEvent.OnStatusChanged, self.OnPetStatusChanged)
      else
        SceneCharacter.ThrowSession:Recycle()
      end
      return nil, nil, nil
    end
    return SceneCharacter, SceneCharacter.landPos, SceneCharacter.serverDataRotate
  end
  return nil, nil, nil
end

function BP_StaticFuncArea_C:OnPetStatusChanged(Session, Status)
  if Status == ThrowSessionStatusEnum.PostInteract then
    Session:Recycle()
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.LuaText.pet_eco_reject)
    Session:RemoveEventListener(self, ThrowSessionEvent.OnStatusChanged, self.OnPetStatusChanged)
  end
end

function BP_StaticFuncArea_C:GetContentConfPos(ContentID)
  if 0 ~= ContentID then
    local ContentConf = _G.DataConfigManager:GetNpcRefreshContentConf(ContentID)
    if ContentConf.refresh_type == _G.Enum.RefreshType.RFT_AREA then
      local RefreshAreaConf = _G.DataConfigManager:GetAreaConf(ContentConf.refresh_param)
      if RefreshAreaConf then
        local RefreshCenterPos, RefreshRotation
        if RefreshAreaConf.area_type == _G.Enum.AreaType.AREAT_POINT or RefreshAreaConf.area_type == _G.Enum.AreaType.AREAT_POLYGON then
          local ConfPos = RefreshAreaConf.pos[1].position_xyz
          local ConfRotation = RefreshAreaConf.pos[1].rotation_xyz
          RefreshCenterPos = UE.FVector(ConfPos[1], ConfPos[2], ConfPos[3])
          RefreshRotation = UE.FRotator(ConfRotation[1], ConfRotation[2], ConfRotation[3])
        elseif RefreshAreaConf.area_type == _G.Enum.AreaType.AREAT_POINTSET then
          local RandomIndex = math.random(1, table.len(RefreshAreaConf.pos))
          local ConfPos = RefreshAreaConf.pos[RandomIndex].position_xyz
          local ConfRotation = RefreshAreaConf.pos[RandomIndex].rotation_xyz
          RefreshCenterPos = UE.FVector(ConfPos[1], ConfPos[2], ConfPos[3])
          RefreshRotation = UE.FRotator(ConfRotation[1], ConfRotation[2], ConfRotation[3])
        else
          local LocalPlayer = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
          local Pos = LocalPlayer:GetActorLocationFrameCache()
          local Rot = LocalPlayer:GetActorRotationFrameCache()
          RefreshCenterPos = Pos + Rot:RotateVector(UE.FVector(300, 0, 0))
          local PlayerRotation = LocalPlayer:GetActorRotation()
          RefreshRotation = UE.FRotator(PlayerRotation.Pitch, PlayerRotation.Yaw + 180, PlayerRotation.Roll)
        end
        return RefreshCenterPos, RefreshRotation
      end
    end
  end
end

function BP_StaticFuncArea_C:NpcCheck(OtherActor, _)
  if (OtherActor:IsA(UE.ANPCBaseActor) or OtherActor:IsA(UE.ANPCBaseCharacter)) and UE.UObject.IsValid(OtherActor) then
    Log.Debug("[StaticFuncArea] NpcChecked Actor:", UE.UObject.GetName(OtherActor))
    return OtherActor
  end
  return nil
end

function BP_StaticFuncArea_C:DestroyNpcFunc(OtherActor, OtherComp)
  local NpcActor = self:NpcCheck(OtherActor, OtherComp)
  local SceneNpc = NpcActor and NpcActor.sceneCharacter
  if not NpcActor or not SceneNpc then
    return
  end
  SceneNpc:Destroy()
end

return BP_StaticFuncArea_C
