local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local ResQueue = require("NewRoco.Utils.ResQueue")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local NPCModuleEnum = require("NewRoco.Modules.Core.NPC.NPCModuleEnum")
local Base = NPCActionBase
local NPCActionPickPetEgg = Base:Extend("NPCActionPickPetEgg")

function NPCActionPickPetEgg:Ctor(Owner, Config, Info, OwnerNpc)
  Base.Ctor(self, Owner, Config, Info, OwnerNpc)
  self.shouldSync = false
end

function NPCActionPickPetEgg:Destroy()
  if self.LoadQueue then
    self.LoadQueue:Release()
    self.LoadQueue = nil
  end
end

function NPCActionPickPetEgg:Execute(playerId, needSendReq)
  local OwnerNPC = self:GetOwnerNPC()
  if OwnerNPC then
    OwnerNPC:SetNotDestroyFlag(true)
  end
  self:LockPlayer()
  self.playerId = playerId
  self.needSendReq = needSendReq
  _G.NRCModeManager:GetCurMode():DisablePanelByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
  self.OwnerNpc:AddEventListener(self, NPCModuleEvent.OnLeaveDialogue, self.TryRecoverEgg)
  _G.NRCEventCenter:RegisterEvent("NPCActionPickPetEgg", self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReConnect)
  self:PrepareShow()
end

function NPCActionPickPetEgg:PrepareShow()
  if self.LoadQueue then
    self.LoadQueue:Release()
    self.LoadQueue = nil
  end
  self.LoadQueue = ResQueue(30, ResQueue.RunMode.Concurrent, _G.PriorityEnum.Active_Player_Action)
  self.LoadQueue:InsertClass("IntroSkill", "/Game/ArtRes/Effects/G6Skill/SceneEffect/G6_Pick_Egg_BlackScreen.G6_Pick_Egg_BlackScreen")
  self.LoadQueue:InsertClass("PickSkill", "/Game/ArtRes/Effects/G6Skill/SceneEffect/G6_Pick_Egg.G6_Pick_Egg")
  self.LoadQueue:StartLoad(self, self.BaseExecute)
end

function NPCActionPickPetEgg:BaseExecute()
  Base.Execute(self, self.playerId, self.needSendReq)
  self:PlaySkillIntro()
  if self.SkipSubmit then
    self:EndBlackScreen()
  end
end

function NPCActionPickPetEgg:PlaySkillIntro()
  if not self.LoadQueue:Get("IntroSkill") or not self.LoadQueue:Get("PickSkill") then
    Log.Error("NPCActionPickPetEgg Load Res failed")
    self:OnSkillComplete()
    return
  end
  local player = self:GetPlayer()
  if not player then
    self:OnSkillComplete()
    return
  end
  self:SetPlayerCollision(false)
  local OwnerNpcView = self:GetOwnerNPCView()
  local IntroSkillClass = self.LoadQueue:Get("IntroSkill")
  self.IntroSkillObj = player.viewObj.RocoSkill:FindOrAddSkillObj(IntroSkillClass)
  self.IntroSkillObj:SetCaster(player.viewObj)
  self.IntroSkillObj:SetTargets({OwnerNpcView})
  self.IntroSkillObj:RegisterEventCallback("BlackScreenIn", self, self.PlaySkill)
  self.IntroSkillObj:SetPassive(true)
  self.IntroSkillObj.Blackboard:SetValueAsInt("Ready", -1)
  player.viewObj.RocoSkill:PlaySkill(self.IntroSkillObj)
end

function NPCActionPickPetEgg:ExecuteWithModel()
end

function NPCActionPickPetEgg:OnSubmit(rsp)
  Base.OnSubmit(self, rsp)
  if 0 ~= rsp.ret_info.ret_code then
    local OwnerNPC = self:GetOwnerNPC()
    if OwnerNPC then
      OwnerNPC:SetNotDestroyFlag(false)
    end
    self:UnlockPlayer()
    self:Finish()
    self:OnSkillComplete()
    local player = self:GetPlayer()
    local playerView = player and player.viewObj
    local playerSkillComp = playerView and playerView.RocoSkill
    if playerSkillComp and self.IntroSkillObj then
      playerSkillComp:CancelSkill(self.IntroSkillObj, UE4.ESkillActionResult.SkillActionResultSuccessful)
    end
    return
  end
  self.IntroSkillObj.Blackboard:SetValueAsInt("Ready", 0)
end

function NPCActionPickPetEgg:EndBlackScreen()
  if not self or not self.IntroSkillObj then
    return
  end
  self.IntroSkillObj.Blackboard:SetValueAsInt("Ready", 0)
end

function NPCActionPickPetEgg:LockPlayer()
  local player = self:GetPlayer()
  if player then
    player:FaceTo(self:GetOwnerNPC())
    if player.inputComponent then
      player.inputComponent:SetInputEnable(self, false)
    end
  end
end

function NPCActionPickPetEgg:UnlockPlayer()
  local player = self:GetPlayer()
  if player and player.inputComponent then
    player.inputComponent:SetInputEnable(self, true)
  end
end

function NPCActionPickPetEgg:SetPlayerCollision(Enable)
  local player = self:GetPlayer()
  if player and player.viewObj then
    player.viewObj:SetActorEnableCollision(Enable)
  end
end

function NPCActionPickPetEgg:PlaySkill()
  local player = self:GetPlayer()
  if not player then
    self:OnSkillComplete()
    return
  end
  if not self.LoadQueue then
    self:OnSkillComplete()
    return
  end
  self:SetPlayerCollision(false)
  local OwnerNpcView = self:GetOwnerNPCView()
  local PickSkillClass = self.LoadQueue:Get("PickSkill")
  local PickSkillObj = player.viewObj.RocoSkill:FindOrAddSkillObj(PickSkillClass)
  PickSkillObj:SetCaster(player.viewObj)
  PickSkillObj:SetTargets({OwnerNpcView})
  local action_param2 = self.Config and self.Config.action_param2
  if "IsShortVersion" == action_param2 then
    PickSkillObj.Blackboard:SetValueAsString("IsShortVersion", "IsShortVersion")
  end
  PickSkillObj:RegisterEventCallback("End", self, self.OnSkillComplete)
  PickSkillObj.BattleGenderType = _G.DataModelMgr.PlayerDataModel.playerInfo.brief_info.sex
  if OwnerNpcView and UE4.UObject.IsValid(OwnerNpcView) then
    if OwnerNpcView:IsA(UE.ARocoCharacter) then
      UE.UNRCCharacterUtils.SetCharacterMeshScale(OwnerNpcView, 1)
    else
      OwnerNpcView:SetActorScale3D(_G.FVectorOne)
    end
    OwnerNpcView:ForceLockOnGround()
  end
  player.viewObj.RocoSkill:LoadAndPlaySkill(PickSkillObj)
end

function NPCActionPickPetEgg:OnSkillComplete()
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReConnect)
  self:GetOwnerNPC():SetCollisionDisable(true, NPCModuleEnum.NpcReasonFlags.SKILL_DEFAULT)
  self:UnlockPlayer()
  self:SetPlayerCollision(true)
  if self:IsLocalAction() then
    _G.NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
  end
  local OwnerNPC = self:GetOwnerNPC()
  if OwnerNPC then
    OwnerNPC:SetNotDestroyFlag(false)
  end
  if OwnerNPC.viewObj and UE.UObject.IsValid(OwnerNPC.viewObj) then
    self:Finish()
  end
  if self.LoadQueue then
    self.LoadQueue:Release()
    self.LoadQueue = nil
  end
end

function NPCActionPickPetEgg:OnReConnect()
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReConnect)
  local player = self:GetPlayer()
  if player and player.viewObj and player.viewObj.RocoSkill then
    player.viewObj.RocoSkill:StopCurrentSkill()
    player:StopAllMontage(0.1)
  end
  self.IntroSkillObj.Blackboard:SetValueAsInt("Ready", 0)
  self.IntroSkillObj:UnregisterEventCallback("BlackScreenIn", self, self.PlaySkill)
  self.SkipCommit = true
  self:OnSkillComplete()
end

function NPCActionPickPetEgg:TryRecoverEgg()
  local OwnerNpc = self:GetOwnerNPC()
  local OwnerNpcView = self:GetOwnerNPCView()
  if OwnerNpc and OwnerNpcView and UE.UObject.IsValid(OwnerNpcView) then
    Log.Warning("\230\141\161\232\155\139\229\135\186\233\151\174\233\162\152\228\186\134\239\188\140\229\176\157\232\175\149\230\129\162\229\164\141\232\155\139\239\188\129")
    local player = self:GetPlayer()
    if player and player.viewObj and player.viewObj.RocoSkill then
      player.viewObj.RocoSkill:StopCurrentSkill()
      player:StopAllMontage(0.1)
    end
    OwnerNpc:RemoveEventListener(self, NPCModuleEvent.OnLeaveDialogue, self.TryRecoverEgg)
    OwnerNpcView:K2_DetachFromActor(UE4.EAttachmentRule.KeepWorld, UE4.EAttachmentRule.KeepWorld, UE4.EAttachmentRule.KeepWorld)
    OwnerNpc:SetActorLocation(OwnerNpc.landPos)
    OwnerNpc:SetActorRotation(OwnerNpc.serverDataRotate)
    OwnerNpc:SetHidden(false, NPCModuleEnum.NpcReasonFlags.SKILL_DEFAULT)
  end
end

return NPCActionPickPetEgg
