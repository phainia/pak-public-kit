local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local ResQueue = require("NewRoco.Utils.ResQueue")
local Base = NPCActionBase
local NPCActionDestroyStone = Base:Extend("NPCActionDestroyStone")

function NPCActionDestroyStone:Ctor(Owner, Config, Info, OwnerNpc)
  Base.Ctor(self, Owner, Config, Info, OwnerNpc)
  self.shouldSync = true
end

function NPCActionDestroyStone:ExecuteWithModel()
  local ownerNpc = self:GetOwnerNPC()
  local Player = self:GetPlayer()
  Player:FaceTo(ownerNpc)
  ownerNpc.shouldDestroy = true
  if ownerNpc.InteractionComponent then
    ownerNpc.InteractionComponent:TryDisableInteraction()
  end
  local localPlayer = self:GetPlayer()
  local LoadQueue = ResQueue()
  LoadQueue:InsertObject("Wand", localPlayer:GetCurWandPath(), _G.PriorityEnum.Active_Player_Action)
  LoadQueue:InsertObject("MoZhang", "Blueprint'/Game/NewRoco/Modules/Core/NPC/MagicStar/BP_MoZhang.BP_MoZhang_C'", _G.PriorityEnum.Active_Player_Action)
  LoadQueue:InsertClass("Skill", "/Game/ArtRes/Effects/G6Skill/SceneEffect/G6_Scene_Stonehouse.G6_Scene_Stonehouse", _G.PriorityEnum.Active_Player_Action)
  LoadQueue:StartLoad(self, self.PlayDestroyStone)
end

function NPCActionDestroyStone:PlayDestroyStone(Queue, Success)
  if not Success then
    Log.Error("PlayDestroyStone Load Failed!!!!")
    self:OnSkillEnd()
    return
  end
  local View = self:GetOwnerNPCView()
  local Player = self:GetPlayer()
  local skill = Player.viewObj.RocoSkill:FindOrAddSkillObj(Queue:Get("Skill"))
  skill:SetCaster(Player.viewObj)
  skill:RegisterEventCallback("End", self, self.OnSkillEnd)
  skill:RegisterEventCallback("PreEnd", self, self.OnSkillEnd)
  skill:SetTargets({View})
  skill:SetPassive(true)
  local World = _G.UE4Helper.GetCurrentWorld()
  local fTransform = UE4.FTransform(UE4.FQuat(), UE4.FVector(-10000, -10000, -10000))
  local MoZhangActor = World:Abs_SpawnActor(Queue:Get("MoZhang"), fTransform, UE4.ESpawnActorCollisionHandlingMethod.AdjustIfPossibleButAlwaysSpawn, nil, nil, nil, {})
  MoZhangActor.SkeletalMesh:SetSkeletalMesh(Queue:Get("Wand"))
  skill.Blackboard:SetValueAsObject("mozhang", MoZhangActor)
  Player.viewObj.RocoSkill:PlaySkill(skill)
  if self:IsLocalAction() then
    if self.Owner then
      self.Owner:LockPlayerAndBattle()
    end
    _G.NRCModeManager:GetCurMode():DisablePanelByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
  end
end

function NPCActionDestroyStone:OnSkillEnd()
  if self:IsLocalAction() then
    if self.Owner then
      self.Owner:UnLockPlayerAndBattle()
    end
    _G.NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
  end
  self:Finish()
end

return NPCActionDestroyStone
