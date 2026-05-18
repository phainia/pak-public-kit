require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.Box.BP_NPCBox_C")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local BP_NPCNaughtyBox_C = Base:Extend("BP_NPCNaughtyBox_C")

function BP_NPCNaughtyBox_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
end

function BP_NPCNaughtyBox_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

function BP_NPCNaughtyBox_C:Init()
  Base.Init(self)
end

function BP_NPCNaughtyBox_C:OnDistanceOptimize(distance, viewDotValue, bulkyVisible, distanceRatio)
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GetPlayerByServerID, self.sceneCharacter.serverData.base.owner_id)
  if not player then
    return
  end
  local BoxLocation = self.sceneCharacter:GetActorLocation()
  local PlayerLocation = player:GetActorLocation()
  local DistanceSquared = UE4.FVector.DistSquared2D(BoxLocation, PlayerLocation)
  if DistanceSquared < 640000 then
    self:SetPlayerNearby(true)
    self:FollowPlayer(player.viewObj)
  else
    self:SetPlayerNearby(false)
  end
end

function BP_NPCNaughtyBox_C:CanEnterThrowInter(Comp)
  if self.SkeletalMesh and self.SkeletalMesh == Comp then
    return true
  end
  return false
end

function BP_NPCNaughtyBox_C:CanThrowInter(throwInfo)
  return true
end

function BP_NPCNaughtyBox_C:SetBoxStateLua(boxState)
  self:SetBoxState(boxState)
end

function BP_NPCNaughtyBox_C:SetOpenLua(boxOpen)
  self:ResetEyes()
  self:SetOpenState(boxOpen)
end

function BP_NPCNaughtyBox_C:PlayShowSkill(isStar)
  local skillPath
  if isStar then
    skillPath = "/Game/ArtRes/Effects/G6Skill/SceneEffect/G6_Scene_Baoxiang_Staropen.G6_Scene_Baoxiang_Staropen"
  else
    skillPath = "/Game/ArtRes/Effects/G6Skill/SceneEffect/G6_Scene_Baoxiang_Handopen.G6_Scene_Baoxiang_Handopen"
  end
  
  local function registerEvent(skill)
    skill:RegisterEventCallback("Open", self, self.OnOpenedInAnim)
    skill:RegisterEventCallback("Shoot", self, self.OnShootInAnim)
  end
  
  self:PlaySkill(skillPath, self, nil, registerEvent)
end

function BP_NPCNaughtyBox_C:OnVisible()
  Base.OnVisible(self)
  self:SwitchBoxState()
end

function BP_NPCNaughtyBox_C:SwitchBoxState()
  local npc = self.sceneCharacter
  if not npc then
    return
  end
  if SceneUtils.IsLogicStatusBlindActivated(npc) or SceneUtils.IsLogicStatusFearActivated(npc) then
    self:SetBoxStateLua(1)
  elseif SceneUtils.IsLogicStatusCharmActivated(npc) then
    self:SetBoxStateLua(2)
  elseif SceneUtils.IsLogicStatusHipnosisActivated(npc) then
    self:SetBoxStateLua(3)
  else
    self:SetBoxStateLua(0)
  end
end

function BP_NPCNaughtyBox_C:SetBoxOpen(isOpen)
  self:SetOpenLua(isOpen)
end

function BP_NPCNaughtyBox_C:Recycle()
  self:SetOpenLua(false)
  self:SetBoxStateLua(0)
  Base.Recycle(self)
end

function BP_NPCNaughtyBox_C:PlayLockLoopEffect()
end

function BP_NPCNaughtyBox_C:PlayUnlockEffect(lockNum)
end

function BP_NPCNaughtyBox_C:LoadLockEffect()
end

return BP_NPCNaughtyBox_C
