local NPCActionAsyncBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionAsyncBase")
local Base = NPCActionAsyncBase
local NPCActionOpenChest = Base:Extend("NPCActionOpenChest")

function NPCActionOpenChest:Ctor(Owner, Config, Info, OwnerNpc)
  Base.Ctor(self, Owner, Config, Info, OwnerNpc)
  self.shouldSync = true
end

function NPCActionOpenChest:OnNpcAction()
  local Player = self:GetPlayer()
  if Player.viewObj then
    local Mode = Player.viewObj.CharacterMovement.MovementMode
    if Mode == UE.EMovementMode.MOVE_Falling then
      Log.Debug("\231\142\169\229\174\182\229\164\132\228\186\142\230\142\137\232\144\189\231\138\182\230\128\129")
      return false
    end
    if Mode == UE.EMovementMode.MOVE_Swimming then
      Log.Debug("\230\136\145\231\142\169\229\174\182\230\184\184\230\179\179\228\184\173")
      return false
    end
    if Mode == UE.EMovementMode.MOVE_Custom then
      local CustomMode = Player.viewObj.CharacterMovement.CustomMovementMode
      Log.Warning("\229\165\135\229\165\135\230\128\170\230\128\170\231\154\132\229\167\191\229\138\191\239\188\140\228\184\141\232\131\189\228\186\164\228\186\146", Mode, CustomMode)
      return false
    end
  end
  return Base.OnNpcAction(self)
end

function NPCActionOpenChest:Execute(playerId, needSendReq, FixCoordinateSuccess)
  if self:GetOwnerNPC() == nil then
    Log.Error("\229\175\132\228\186\134...")
    self:Finish()
    return
  end
  self:GetOwnerNPC():SetNotDestroyFlag(true)
  Base.Execute(self, playerId, needSendReq)
  if self.Owner then
    self.Owner:LockPlayerAndBattle()
    self:SetViewObjOption()
  end
end

local BoxBoundCheckRate = 1.01
local TempOrigin = UE.FVector(0, 0, 0)
local TempExtend = UE.FVector(0, 0, 0)

function NPCActionOpenChest:BeforeStartPerform()
  local player = self:GetPlayer()
  local isFacePlay = false
  if player then
    player:FaceTo(self:GetOwnerNPC())
    if player.inputComponent then
      player.inputComponent:SetInputEnable(self, false)
    end
    isFacePlay = self:GetOwnerNPC():IsFacePlay(player.serverData.base.actor_id)
    Log.Debug("NPCActionOpenChest:BeforeStartPerform", isFacePlay, self:GetOwnerNPC():DistanceTo(player, true, false) < 120)
  end
  local isStandOnBox = false
  local box = self:GetOwnerNPCView()
  if box and player then
    local playerLocation = player:GetActorLocation()
    local boxLocation = box:Abs_K2_GetActorLocation()
    local boxRotation = box:K2_GetActorRotation()
    UE.UNRCStatics.GetActorDefaultCollidingBounds(box, TempOrigin, TempExtend)
    isStandOnBox = self:IsInBoxXYRange(playerLocation, boxLocation, boxRotation, TempExtend, BoxBoundCheckRate)
    Log.Debug("NPCActionOpenChest:BeforeStartPerform StandOnBox", isStandOnBox, playerLocation, boxLocation, TempOrigin, TempExtend)
  end
  if not isFacePlay or isStandOnBox then
    self.UseStar = true
  else
    self.UseStar = false
  end
end

function NPCActionOpenChest:IsInBoxXYRange(targetLocation, boxLocation, boxRotation, boxExtend, boundRate)
  boundRate = boundRate or BoxBoundCheckRate
  local relativeLocation = targetLocation - boxLocation
  if boxRotation and 0 ~= boxRotation.Yaw then
    relativeLocation = UE.UKismetMathLibrary.Quat_UnrotateVector(boxRotation:ToQuat(), relativeLocation)
  end
  local xInRange = relativeLocation.X >= -boxExtend.X * boundRate and relativeLocation.X <= boxExtend.X * boundRate
  local yInRange = relativeLocation.Y >= -boxExtend.Y * boundRate and relativeLocation.Y <= boxExtend.Y * boundRate
  return xInRange and yInRange
end

local UseStarResList = {
  Wand = nil,
  MoZhang = "Blueprint'/Game/NewRoco/Modules/Core/NPC/MagicStar/BP_MoZhang.BP_MoZhang_C'",
  Skill = "/Game/ArtRes/Effects/G6Skill/SceneEffect/791244_PlayerStarOpen.791244_PlayerStarOpen_C"
}
local NormalResList = {
  Skill = "/Game/ArtRes/Effects/G6Skill/SceneEffect/791244_PlayerHandOpen.791244_PlayerHandOpen_C"
}

function NPCActionOpenChest:GetPerformResourceList()
  local LocalPlayer = self:GetPlayer()
  if not LocalPlayer then
    return nil
  end
  if self.UseStar then
    UseStarResList.Wand = LocalPlayer:GetCurWandPath()
    return UseStarResList
  else
    return NormalResList
  end
end

function NPCActionOpenChest:OnPerformReady(LoadedAssets, Rsp)
  local Player = self:GetPlayer()
  if not Player then
    self:OnCameraStartEnd()
    return
  end
  Log.Debug("\229\144\140\230\173\165\230\146\173\230\148\190\231\154\132Player Id \230\152\175\232\191\153\228\184\170", self.playerId)
  local box = self:GetOwnerNPCView()
  if nil == box then
    self:OnCameraStartEnd()
    return
  end
  box.useStar = self.UseStar
  local SkillAsset
  if LoadedAssets and next(LoadedAssets) then
    SkillAsset = LoadedAssets.Skill
  end
  local playerView = Player and Player.viewObj
  local skillComp = playerView and playerView.RocoSkill
  if not skillComp then
    self:OnCameraStartEnd()
    return
  end
  if not SkillAsset then
    self:OnCameraStartEnd()
    return
  end
  local Skill = skillComp:FindOrAddSkillObj(SkillAsset)
  if not Skill then
    self:OnCameraStartEnd()
    return
  end
  Skill:SetCaster(Player.viewObj)
  Skill:RegisterEventCallback("End", self, self.OnCameraStartEnd)
  Skill:RegisterEventCallback("Open", self, self.OnBoxOpen)
  Skill:SetTargets({
    Player.viewObj
  })
  Skill:SetPassive(true)
  if self.UseStar and LoadedAssets.Wand and LoadedAssets.MoZhang then
    local World = _G.UE4Helper.GetCurrentWorld()
    local fTransform = UE4.FTransform(UE4.FQuat(), UE4.FVector(-10000, -10000, -10000))
    local MoZhangActor = World:Abs_SpawnActor(LoadedAssets.MoZhang, fTransform, UE4.ESpawnActorCollisionHandlingMethod.AdjustIfPossibleButAlwaysSpawn, nil, nil, nil, {})
    MoZhangActor.SkeletalMesh:SetSkeletalMesh(LoadedAssets.Wand)
    Skill.Blackboard:SetValueAsObject("mozhang", MoZhangActor)
  end
  skillComp:LoadAndPlaySkill(Skill)
end

function NPCActionOpenChest:OnPerformFailed(_)
  self:OnCameraStartEnd()
end

function NPCActionOpenChest:OnBoxOpen()
  local box = self:GetOwnerNPCView()
  if UE4.UObject.IsValid(box) and box.SetBoxOpen then
    box:SetBoxOpen(true)
  end
end

function NPCActionOpenChest:OnCommit(rsp)
  if 0 ~= rsp.ret_info.ret_code then
    self:GetOwnerNPC():SetNotDestroyFlag(false)
  end
  Base.OnCommit(self, rsp)
end

function NPCActionOpenChest:OnCameraStartEnd()
  Log.Debug("NPCActionOpenChest:OpenChest Finished")
  if self.Owner then
    self.Owner:UnLockPlayerAndBattle()
  end
  local player = self:GetPlayer()
  if player and player.inputComponent then
    player.inputComponent:SetInputEnable(self, true)
  end
  self:Finish()
end

function NPCActionOpenChest:HasLocalPerform()
  return true
end

function NPCActionOpenChest:PostOnCommit(rsp)
  if self.Owner and self.Owner.RestoreRideStateAfterInteract then
    self.Owner:RestoreRideStateAfterInteract()
  end
end

return NPCActionOpenChest
