local ActionUtils = require("NewRoco.Modules.Core.NPC.Actions.ActionUtils")
local PetActionFactory = require("NewRoco.Modules.Core.NPC.Actions.PetActionFactory")
local PetHolderComponent = require("NewRoco.Modules.Core.Scene.Component.Interaction.PetHolderComponent")
local PlayerThrowInteractionComponent = require("NewRoco.Modules.Core.Scene.Component.Interaction.PlayerThrowInteractionComponent")
local ThrowSessionStatusEnum = require("NewRoco.Modules.Core.NPC.ThrowSessionStatusEnum")
local ActorComponent = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local PetActionEvent = require("NewRoco.Modules.Core.NPC.Actions.PetActionEvent")
local BubbleComponent = require("NewRoco.Modules.Core.Scene.Component.Bubble.BubbleComponent")
local PetStatusComponent = require("NewRoco.Modules.Core.Scene.Component.Status.PetStatusComponent")
local PetActionBatchCollect = require("NewRoco.Modules.Core.NPC.Actions.PetActions.PetActionBatchCollect")
local PetStatusType = require("NewRoco.Modules.Core.Scene.Component.Status.PetStatusType")
local NPCModuleEnum = require("NewRoco.Modules.Core.NPC.NPCModuleEnum")
local PetHUDComponent = require("NewRoco.Modules.Core.Scene.Component.HUD.PetHUDComponent")
local Base = ActorComponent
local PetInteractionComponent = Base:Extend("PetInteractionComponent")

function PetInteractionComponent:Attach(owner)
  Base.Attach(self, owner)
  self.interactionSpecialAction = nil
  self.interactionNormalAction = nil
end

function PetInteractionComponent:InteractWithAction(Action, SkipEnableCheck)
  if self.interactionSpecialAction then
    Log.Error("\229\183\178\231\187\143\229\156\168\232\191\144\232\161\140\231\137\185\230\174\138\233\135\135\233\155\134\228\186\134,\230\151\160\230\179\149\230\137\167\232\161\140\230\150\176\231\154\132")
    return false
  end
  if not SkipEnableCheck and not Action:IsEnabled() then
    Log.Error("\232\176\131\232\175\149\231\148\168\230\151\165\229\191\151\239\188\154\231\137\185\230\174\138\228\186\164\228\186\146\230\172\161\230\149\176\229\183\178\231\187\143\230\187\161\228\186\134")
    self:GetOwner():TryRecycle()
    return false
  end
  if Action:IsExecuting() then
    Log.Error("\232\176\131\232\175\149\231\148\168\230\151\165\229\191\151\239\188\154\229\183\178\231\187\143\229\173\152\229\156\168\231\137\185\230\174\138\228\186\164\228\186\146\228\186\134")
    self:GetOwner():TryRecycle()
    return false
  end
  if self.owner:IsControlledByPlayer() and self.owner.ThrowSession then
    self.owner.ThrowSession:SetStatus(ThrowSessionStatusEnum.Interacting)
  end
  self.interactionSpecialAction = Action
  self.interactionSpecialAction:AddEventListener(self, PetActionEvent.OnFinish, self.OnSpecialActionFinished)
  self.owner:LockAIForReason(true, false, _G.AIDefines.LockReason.ACTION_PROCESS)
  self.interactionSpecialAction:Execute(self.owner)
  return true
end

function PetInteractionComponent:OnSpecialActionFinished(Action, Success)
  local OwnerView = self:GetOwnerView()
  local Session = OwnerView and OwnerView.ThrowSession
  if Action ~= self.interactionSpecialAction then
    Log.Error("\230\137\167\232\161\140\231\154\132Action\228\184\141\228\184\128\232\135\180!!!")
    if OwnerView then
      OwnerView:RecycleThrowSession()
    end
    return
  end
  self.interactionSpecialAction:RemoveEventListener(self, PetActionEvent.OnFinish, self.OnSpecialActionFinished)
  self.interactionSpecialAction = nil
  self.owner:LockAIForReason(false, true, _G.AIDefines.LockReason.ACTION_PROCESS)
  if not self.owner:IsControlledByPlayer() then
    return
  end
  if Action.name == "PetActionCommon" then
    if Success then
      return
    end
    if Session then
      Session:SetStatus(ThrowSessionStatusEnum.PostInteract)
      Session:ForceSetCanBeRecycle(true)
    end
    if OwnerView then
      OwnerView:RecycleThrowSession()
    end
    return
  end
  if not Success then
    local SkillComp = Action:GetRunnerSkillComponent()
    if SkillComp then
      SkillComp:StopCurrentSkill()
    end
    if Session then
      Log.Debug("\229\174\162\230\136\183\231\171\175\233\162\132\229\136\164\230\151\160\230\179\149\228\186\164\228\186\146\239\188\140\232\161\165\229\143\145EndThrow")
      Session:SendFailEndThrowReq()
    else
      Log.Error("\229\176\157\232\175\149\230\184\133\231\144\134\229\174\162\230\136\183\231\171\175\233\162\132\229\136\164\230\151\160\230\179\149\228\186\164\228\186\146\231\154\132ThrowSession\229\164\177\232\180\165\239\188\140\230\151\160\230\179\149\232\142\183\229\143\150ThrowSession")
    end
    if OwnerView then
      OwnerView:RecycleThrowSession()
    end
    return
  end
  if not Action:ContinueWhenSuccess() then
    Session:SetStatus(ThrowSessionStatusEnum.PostInteract)
    self.owner:EnsureComponent(PetHUDComponent):ForceUpdate()
    return
  end
  if Action:ContinueNormalInteract() and Action:GetIsMainPerformAction() then
    local PetBallComponent = require("NewRoco.Modules.Core.Scene.Component.Interaction.PetBallComponent")
    local Comp = self.owner:EnsureComponent(PetBallComponent)
    local _, _, NormalOptions, _ = Comp:Query(self.owner.ThrowSession.petData)
    local ActionOwner = Action and Action:GetOwnerNPC()
    local OwnerLuaObj = ActionOwner and ActionOwner.luaObj
    local Children = OwnerLuaObj:GetChildrenNPCs()
    for _, Child in ipairs(Children) do
      local InteractType = Child.config.throwing_interact_type
      local bIsNormal = InteractType == Enum.THROWING_INTERACT_TYPE.TIT_COMMONOBJ
      local InterComp = Child.InteractionComponent
      if bIsNormal and InterComp then
        local Normal, Special = InterComp:GetPetOption(self.owner.ThrowSession.petData, true)
        if not Special and Normal then
          NormalOptions = NormalOptions or {}
          if not table.contains(NormalOptions, Normal) then
            table.insert(NormalOptions, Normal)
          end
        end
      end
    end
    if NormalOptions and #NormalOptions > 0 then
      for _, Option in ipairs(NormalOptions) do
        Log.Debug("Adding Normal Option", Option.owner:DebugNPCNameAndID())
      end
      self:InteractWithOptions(NormalOptions, false)
    elseif OwnerView then
      OwnerView:RecycleThrowSession()
    end
  elseif OwnerView then
    OwnerView:RecycleThrowSession()
  end
end

function PetInteractionComponent:InteractWithOptions(options, bAlreadyInteracted)
  if nil == options or 0 == #options then
    self.owner.ThrowSession:SetStatus(ThrowSessionStatusEnum.PostInteract)
    return
  end
  local AnyOption = false
  for _, Option in ipairs(options) do
    if Option:IsOptionEnable() then
      AnyOption = true
      break
    end
  end
  local Session = self.owner.ThrowSession
  if not AnyOption and not bAlreadyInteracted then
    Session:SetStatus(ThrowSessionStatusEnum.PostInteract)
    return
  end
  if Session.Status ~= ThrowSessionStatusEnum.CriticalInteracting then
    Session:SetStatus(ThrowSessionStatusEnum.Interacting)
  end
  if self.interactionNormalAction then
    Log.Error("\229\183\178\231\187\143\229\156\168\232\191\155\232\161\140\230\153\174\233\128\154\233\135\135\233\155\134\228\186\134...")
    return
  end
  local BatchCollectAction = PetActionBatchCollect()
  BatchCollectAction:AddEventListener(self, PetActionEvent.OnFinish, self.OnHarvestSkillComplete)
  BatchCollectAction:AddEventListener(self, PetActionEvent.OnHarvest, self.InstantHarvest)
  self.interactionNormalAction = BatchCollectAction
  BatchCollectAction:Execute(self.owner, options, bAlreadyInteracted)
end

function PetInteractionComponent:InstantHarvest(options)
  if not options then
    Log.Debug("PetInteractionComponent:OnHarvest \230\178\161\230\156\137\229\143\175\230\143\144\228\186\164\231\154\132\229\134\133\229\174\185")
    self:OnHarvestSkillComplete()
    return
  end
  local req = ProtoMessage:newZoneSceneEndThrowReq()
  req.gid = self.owner.ThrowSession:GetGID()
  req.throw_id = self.owner.ThrowSession:GetThrowID()
  req.throw_type = ProtoEnum.ThrowType.THROW_PET
  req.throw_effect = ProtoEnum.ThrowEffect.TRIG_PET_INTERACT
  req.item_conf_id = self.owner.ThrowSession:GetItemID()
  self.collect_npcs = {}
  for _, option in ipairs(options) do
    if option:IsOptionEnable() then
      Log.Debug("Submitting Normal Option", option.owner:DebugNPCNameAndID())
      table.insert(req.throw_target_npc_infos, option:GetThrowTargetNpcInfo())
      local actor_id = option:GetOwnerId()
      if actor_id then
        self.collect_npcs[actor_id] = true
      end
    end
  end
  if 0 == #req.throw_target_npc_infos then
    Log.Debug("PetInteractionComponent:OnHarvest \230\178\161\230\156\137\229\143\175\230\143\144\228\186\164\231\154\132\229\134\133\229\174\185")
    return
  end
  for actor_id, _ in pairs(self.collect_npcs) do
    local npc = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, actor_id)
    if npc and npc.InteractionComponent then
      npc.InteractionComponent:SetInteractionEnable(false, NPCModuleEnum.NpcInteractDisableFlag.PICK_BY_PLAYER, true)
    end
  end
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_END_THROW_REQ, req, self, self.OnBatchInteract, false, true)
end

function PetInteractionComponent:OnBatchInteract(rsp)
  for actor_id, _ in pairs(self.collect_npcs) do
    local npc = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, actor_id)
    if npc and npc.InteractionComponent and not npc.shouldDestroy then
      npc.InteractionComponent:SetInteractionEnable(true, NPCModuleEnum.NpcInteractDisableFlag.PICK_BY_PLAYER, true)
    end
  end
  table.clear(self.collect_npcs)
end

function PetInteractionComponent:OnHarvestSkillComplete()
  if self.interactionNormalAction then
    self.interactionNormalAction:RemoveEventListener(self, PetActionEvent.OnHarvest, self.InstantHarvest)
    self.interactionNormalAction:RemoveEventListener(self, PetActionEvent.OnFinish, self.OnHarvestSkillComplete)
    self.interactionNormalAction = nil
  end
  self.owner:TryRecycle()
end

function PetInteractionComponent:SendRandomOption(options)
  if not options then
    Log.Debug("PetInteractionComponent:SendRandomOption \230\178\161\230\156\137\229\143\175\230\143\144\228\186\164\231\154\132\229\134\133\229\174\185")
    self:OnHarvestSkillComplete()
    return
  end
  local req = ProtoMessage:newZoneSceneEndThrowReq()
  req.gid = self.owner.ThrowSession:GetGID()
  req.throw_id = self.owner.ThrowSession:GetThrowID()
  req.throw_type = ProtoEnum.ThrowType.THROW_PET
  req.throw_effect = ProtoEnum.ThrowEffect.TRIG_PET_INTERACT
  req.item_conf_id = self.owner.ThrowSession:GetItemID()
  for _, option in ipairs(options) do
    table.insert(req.throw_target_npc_infos, option:GetThrowTargetNpcInfo())
  end
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_END_THROW_REQ, req, self, self.OnRandomInteractRsp, false, true)
end

function PetInteractionComponent:OnRandomInteractRsp(rsp)
  if 0 ~= rsp.ret_info.ret_code then
    Log.Error("\231\178\190\231\129\181\233\154\143\230\156\186\228\186\164\228\186\146\230\138\165\233\148\153", rsp.ret_info.ret_code)
    return
  end
  if not rsp.random_result or 0 == #rsp.random_result then
    Log.Error("\231\178\190\231\129\181\230\178\161\230\156\137\233\154\143\230\156\186\228\186\164\228\186\146\231\187\147\230\158\156...", rsp.ret_info.ret_code)
    return
  end
  local Player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local PlayerComp = Player:EnsureComponent(PlayerThrowInteractionComponent)
  PlayerComp:RunOptions(self.owner, rsp.random_result)
  Log.Dump(rsp.random_result, 3, "Show random result")
end

function PetInteractionComponent:GetOwnerView()
  return self.owner.viewObj
end

function PetInteractionComponent:Destroy()
  self:TryStop()
end

function PetInteractionComponent:TryStop()
  local CurrentSpecialAction = self.interactionSpecialAction
  self.interactionSpecialAction = nil
  if not CurrentSpecialAction then
    return
  end
  CurrentSpecialAction:RemoveEventListener(self, PetActionEvent.OnFinish, self.OnSpecialActionFinished)
  CurrentSpecialAction:TryStop(nil)
end

function PetInteractionComponent:RunInteractResultAction(Action, isMainPerformAction)
  local Pets = self:GetActionHolderPets(Action)
  if Pets and #Pets > 1 then
    self:SetPetCriticalInteracting()
  else
    self:SetPetInteracting()
  end
  self.owner:LockAIForReason(true, false, _G.AIDefines.LockReason.BUBBLE_SHOW)
  local BubbleComp = self.owner:EnsureComponent(BubbleComponent)
  BubbleComp:StopAll()
  BubbleComp:Play(nil, Enum.EmotionType.EMT_PET_JINGYA, self, self.OnInteractResult, Action, isMainPerformAction)
end

function PetInteractionComponent:OnInteractResult(Success, Action, isMainPerformAction)
  local NPC = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, Action.npc_id)
  local InterComp = NPC and NPC.InteractionComponent
  if not Success then
    self:GetOwnerView():RecycleThrowSession()
    return
  end
  self.owner:LockAIForReason(false, true, _G.AIDefines.LockReason.BUBBLE_SHOW)
  local Group = _G.DataConfigManager:GetPetInteractionConf(Action.pet_interact_cfg_id)
  if not Group then
    self:GetOwnerView():RecycleThrowSession()
    return
  end
  local Option = InterComp and InterComp:GetOptionByID(Action.option_id)
  if not Option then
    self:GetOwnerView():RecycleThrowSession()
    return
  end
  self:TryStop()
  local NewAction = PetActionFactory:GetAction(Option, Group, true)
  NewAction.ConfType = ProtoEnum.ClientOperationConfType.COCT_PET_INTERACTION_CONF
  NewAction.ConfID = Action.pet_interact_cfg_id
  NewAction:SetNextSubmissionMode(isMainPerformAction and ActionUtils.ActionSubmissionMode.NextAct or ActionUtils.ActionSubmissionMode.Local)
  NewAction:SetSkipSync(true)
  NewAction:SetIsMainPerformAction(isMainPerformAction)
  self:InteractWithAction(NewAction, true)
end

function PetInteractionComponent:UpdateInteractResult(Action)
  if not Action then
    return
  end
  if Action.status == ProtoEnum.SpaceAct_PetInteractResNty.PetInteractStatus.SUCCESS then
    local Pets = self:GetActionHolderPets(Action)
    if Pets and #Pets > 0 then
      for _, Pet in ipairs(Pets) do
        local Comp = Pet:EnsureComponent(PetInteractionComponent)
        Comp:RunInteractResultAction(Action, Pet == self.owner)
      end
    end
  elseif Action.status == ProtoEnum.SpaceAct_PetInteractResNty.PetInteractStatus.FAIL then
    self:SetPetInteracting()
    self.owner:LockAIForReason(true, false, _G.AIDefines.LockReason.BUBBLE_SHOW)
    local BubbleComp = self.owner:EnsureComponent(BubbleComponent)
    BubbleComp:Play(nil, Enum.EmotionType.EMT_SHILUO, self, self.OnFailedCallback)
  elseif Action.status == ProtoEnum.SpaceAct_PetInteractResNty.PetInteractStatus.WAIT_FOR_COMBINED_INTERACT then
    self:TryStop()
  elseif Action.status == ProtoEnum.SpaceAct_PetInteractResNty.PetInteractStatus.CANCEL_COMBINED_INTERACT then
    local Pets = self:GetActionHolderPets(Action)
    if Pets and #Pets > 0 then
      for _, Pet in ipairs(Pets) do
        local InterComp = Pet:EnsureComponent(PetInteractionComponent)
        if InterComp then
          InterComp:SetPetInteracting()
          Pet:LockAIForReason(true, false, _G.AIDefines.LockReason.BUBBLE_SHOW)
          local BubbleComp = Pet:EnsureComponent(BubbleComponent)
          if BubbleComp then
            BubbleComp:Play(nil, Enum.EmotionType.EMT_SHILUO, InterComp, InterComp.OnFailedCallback)
          end
        end
      end
    end
  else
    Log.Error("\230\156\170\229\174\158\231\142\176\231\154\132\230\158\154\228\184\190", Action.status)
  end
end

function PetInteractionComponent:GetActionHolderPets(Action)
  local Pets = {}
  if Action.combine_interact_pet_npc_ids then
    for _, ID in ipairs(Action.combine_interact_pet_npc_ids) do
      local Pet = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, ID)
      if Pet then
        table.insert(Pets, Pet)
      end
    end
  end
  table.insert(Pets, self.owner)
  return Pets
end

function PetInteractionComponent:OnFailedCallback()
  self.owner:LockAIForReason(false, true, _G.AIDefines.LockReason.BUBBLE_SHOW)
  if self.interactionSpecialAction then
    self.interactionSpecialAction:Finish(false)
  end
  local OwnerView = self:GetOwnerView()
  if OwnerView then
    OwnerView:RecycleThrowSession()
  end
end

function PetInteractionComponent:SetPetWaiting()
  local StatusComp = self.owner:EnsureComponent(PetStatusComponent)
  StatusComp:SetStatus(PetStatusType.Wait)
  local Session = self.owner and self.owner.ThrowSession
  if not Session then
    return
  end
  Session:SetStatus(ThrowSessionStatusEnum.PostInteract)
end

function PetInteractionComponent:SetPetInteracting()
  local StatusComp = self.owner:EnsureComponent(PetStatusComponent)
  if StatusComp then
    StatusComp:SetStatus(PetStatusType.Interact)
  end
  local Session = self.owner and self.owner.ThrowSession
  if not Session then
    return
  end
  Session:SetStatus(ThrowSessionStatusEnum.Interacting)
end

function PetInteractionComponent:SetPetCriticalInteracting()
  local StatusComp = self.owner:EnsureComponent(PetStatusComponent)
  if StatusComp then
    StatusComp:SetStatus(PetStatusType.Interact)
  end
  local Session = self.owner and self.owner.ThrowSession
  if not Session then
    return
  end
  Session:SetStatus(ThrowSessionStatusEnum.CriticalInteracting)
end

return PetInteractionComponent
