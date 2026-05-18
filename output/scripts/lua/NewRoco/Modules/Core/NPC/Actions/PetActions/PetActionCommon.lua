local PetActionFactory
local ThrowSessionStatusEnum = require("NewRoco.Modules.Core.NPC.ThrowSessionStatusEnum")
local PetActionEvent = require("NewRoco.Modules.Core.NPC.Actions.PetActionEvent")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local BubbleComponent = require("NewRoco.Modules.Core.Scene.Component.Bubble.BubbleComponent")
local PetStatusComponent = require("NewRoco.Modules.Core.Scene.Component.Status.PetStatusComponent")
local PetStatusType = require("NewRoco.Modules.Core.Scene.Component.Status.PetStatusType")
local PetActionBase = require("NewRoco.Modules.Core.NPC.Actions.PetActionBase")
local ActionUtils = require("NewRoco.Modules.Core.NPC.Actions.ActionUtils")
local Base = PetActionBase
local PetActionCommon = Base:Extend("PetActionCommon")

function PetActionCommon:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
  self.SingleAction = nil
  self.RealActionIndex = -1
  self.PetInteractionConf = nil
  self.isCombineAction = true
end

function PetActionCommon:OnExecute()
  Log.Debug("\229\144\136\229\135\187\228\186\164\228\186\146\230\151\165\229\191\151: PetActionCommon:OnExecute", table.getKeyName(ActionUtils.ActionSubmissionMode, self.NextSubmissionMode))
  if self.NextSubmissionMode == ActionUtils.ActionSubmissionMode.SceneNpc then
    self:PreExecute(true, self.Runner)
    return
  end
  self:Submit()
  self:SetSessionRecycle(false)
end

function PetActionCommon:PreExecute(Success, Runner)
  if self.SingleAction then
    self.SingleAction.Runner = nil
  end
  self.SingleAction:AddEventListener(self, PetActionEvent.OnFinish, self.CheckSingleFinished)
  self.SingleAction:SetNextSubmissionMode(self.NextSubmissionMode)
  self.SingleAction:Execute(Runner)
end

function PetActionCommon:SubmitForChild(Req, Action)
  self:Submit()
  self:SetSessionRecycle(false)
end

function PetActionCommon:OnSubmit(Rsp)
  if 0 == Rsp.ret_info.ret_code then
  else
    self:SetSessionRecycle(true)
  end
  Base.OnSubmit(self, Rsp)
end

function PetActionCommon:DontSync()
  return true
end

function PetActionCommon:CheckSingleFinished()
  self.SingleAction:RemoveEventListener(self, PetActionEvent.OnFinish, self.CheckSingleFinished)
  self:Finish(true)
end

function PetActionCommon:PreFailed(Success)
  self:Finish(false)
end

function PetActionCommon:NotifyCreatePet(Runner)
  local Session = Runner and Runner.ThrowSession
  if Session then
    local Comp = Runner:EnsureComponent(PetStatusComponent)
    Comp:SetStatus(PetStatusType.Wait)
    Session:SetStatus(ThrowSessionStatusEnum.PostInteract)
  end
  self:Finish(true)
end

function PetActionCommon:GetRangeType()
  if self.SingleAction then
    return self.SingleAction:GetRangeType()
  else
    return Base.GetRangeType(self)
  end
end

function PetActionCommon:GetRangeParams()
  if not string.IsNilOrEmpty(self.Config.action_param2) then
    return string.split(self.Config.action_param2, ";")
  elseif self.SingleAction then
    return self.SingleAction:GetRangeParams()
  else
    return Base.GetRangeParams(self)
  end
end

function PetActionCommon:GetLookAtType()
  if self.SingleAction then
    return self.SingleAction:GetLookAtType()
  else
    return Base.GetLookAtType(self)
  end
end

function PetActionCommon:ContinueWhenSuccess()
  if self.SingleAction then
    return self.SingleAction:ContinueWhenSuccess()
  else
    return Base.ContinueWhenSuccess(self)
  end
end

function PetActionCommon:GetThrowEffectType()
  return ProtoEnum.ThrowEffect.TRIG_PET_INTERACT
end

function PetActionCommon:IsExecuting()
  if self.SingleAction and self.SingleAction:IsExecuting() then
    return true
  end
  return Base.IsExecuting(self)
end

function PetActionCommon:GetDerivedAction(PetData)
  if self.SingleAction and self.SingleAction:IsExecuting() then
    return nil
  end
  if not PetData then
    Log.Warning("PetActionCommon:GetDerivedAction Getting nil pet data")
    return nil
  end
  if not self.PetInteractionConf then
    local NumberStrings = string.Split(self.Config.action_param1, ";")
    NumberStrings = NumberStrings or {
      self.Config.action_param1
    }
    for Index, Str in ipairs(NumberStrings) do
      NumberStrings[Index] = _G.DataConfigManager:GetPetInteractionConf(tonumber(Str))
    end
    self.PetInteractionConf = NumberStrings
  end
  local Index, Group, Stash = self:FindInteractGroup(PetData)
  if -1 == Index and Stash and 1 == #self.PetInteractionConf then
    Index = 1
    Group = self.PetInteractionConf[Index]
  end
  if self.SingleAction and self.SingleAction:IsExecuting() then
    return nil
  end
  if self.RealActionIndex ~= Index then
    if self.SingleAction then
      self.SingleAction:Destroy()
      self.SingleAction = nil
    end
    if Group then
      self.SingleAction = self:CreateAction(Group)
    end
  end
  return self
end

function PetActionCommon:RecreateSingleAction(ConfID)
  if not ConfID then
    return
  end
  if self.SingleAction and ConfID == self.SingleAction.Config.id then
    return
  end
  if self.SingleAction then
    self.SingleAction:Destroy()
    self.SingleAction = nil
  end
  local Conf = _G.DataConfigManager:GetPetInteractionConf(ConfID)
  if Conf then
    self.SingleAction = self:CreateAction(Conf)
  end
end

function PetActionCommon:FindInteractGroup(PetData)
  if not self.PetInteractionConf then
    return -1, nil
  end
  local Stash = false
  for Index, Group in ipairs(self.PetInteractionConf) do
    local Pass, NeedStash = self:VerifyConditions(Group, PetData)
    Stash = Stash or NeedStash
    if Pass then
      return Index, Group, false
    end
  end
  return -1, nil, Stash
end

function PetActionCommon:VerifyConditions(Conf, PetData)
  if not Conf then
    return true, false
  end
  if not Conf.interact_cond_group then
    return true, false
  end
  if 0 == #Conf.interact_cond_group then
    return true, false
  end
  local CheckType = Conf.cond_logic_type or Enum.PetInteractCondLogicType.PICT_AND
  if CheckType == Enum.PetInteractCondLogicType.PICT_AND then
    for _, Condition in ipairs(Conf.interact_cond_group) do
      if not self:VerifyCondition(Condition, PetData) then
        return false, Condition.interact_cond == Enum.PetInteract_cond.COND_WEIGHT
      end
    end
    return true, false
  elseif CheckType == Enum.PetInteractCondLogicType.PICT_OR then
    local HasWeight = false
    for _, Condition in ipairs(Conf.interact_cond_group) do
      if self:VerifyCondition(Condition, PetData) then
        HasWeight = HasWeight or Condition.interact_cond == Enum.PetInteract_cond.COND_WEIGHT
        return true, false
      end
    end
    return false, HasWeight
  else
    return true, false
  end
end

function PetActionCommon:VerifyCondition(Condition, PetData)
  if not Condition then
    return true
  end
  if not PetData.base_conf_id then
    return false
  end
  local PetBaseConf = _G.DataConfigManager:GetPetbaseConf(PetData.base_conf_id)
  if Enum.PetInteract_cond.COND_ECOLOGY == Condition.interact_cond then
    local EcoTypes = PetBaseConf.ecology_feature
    for _, Eco in ipairs(EcoTypes) do
      for _, Type in ipairs(Condition.interact_cond_param) do
        local RequiredType = Enum.ECOLOGY_FEATURE[Type]
        if RequiredType == Eco then
          return true
        end
      end
    end
    return false
  elseif Enum.PetInteract_cond.COND_SKILLDAM == Condition.interact_cond then
    local PetDamageTypes = PetBaseConf.unit_type
    for _, PetDamageType in ipairs(PetDamageTypes) do
      for _, Type in ipairs(Condition.interact_cond_param) do
        local RequiredType = Enum.SkillDamType[Type]
        if RequiredType == PetDamageType then
          return true
        end
      end
    end
    return false
  elseif Enum.PetInteract_cond.COND_CLASS == Condition.interact_cond then
    for _, Type in ipairs(Condition.interact_cond_param) do
      local RequiredType = Enum.PetClassis[Type]
      if RequiredType == PetBaseConf.pet_classis_id then
        return true
      end
    end
    return false
  elseif Enum.PetInteract_cond.COND_HEIGHT == Condition.interact_cond then
    return (PetData.height or 0) >= tonumber(Condition.interact_cond_param[1])
  elseif Enum.PetInteract_cond.COND_WEIGHT == Condition.interact_cond then
    return (PetData.weight or 0) >= tonumber(Condition.interact_cond_param[1])
  elseif Enum.PetInteract_cond.COND_LEVEL == Condition.interact_cond then
    return (PetData.level or 0) >= tonumber(Condition.interact_cond_param[1])
  elseif Enum.PetInteract_cond.COND_PET_BASE_ID == Condition.interact_cond then
    local ConfParam = tonumber(Condition.interact_cond_param[1])
    if -1 == ConfParam then
      return true
    else
      return PetData.base_conf_id == ConfParam
    end
  elseif Enum.PetInteract_cond.COND_AVATAR_HP == Condition.interact_cond then
    local Player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    return Player.serverData.attrs.hp == tonumber(Condition.interact_cond_param[1])
  elseif Enum.PetInteract_cond.COND_TARGET_LOGIC_STATE == Condition.interact_cond then
    local StatusName = Condition.interact_cond_param[1]
    if string.IsNilOrEmpty(StatusName) then
      return false
    end
    local StatusValue = Enum.SpaceActorLogicStatus[StatusName]
    if nil == StatusValue then
      return false
    end
    local NPC = self:GetOwnerNPC()
    if not NPC then
      return false
    end
    local LogicStatusComp = NPC.LogicStatusComponent
    if not LogicStatusComp then
      return false
    end
    return LogicStatusComp:GetStatus(StatusValue)
  elseif Enum.PetInteract_cond.COND_COMPLEX == Condition.interact_cond then
    return false
  else
    Log.Error("\230\156\170\229\174\158\231\142\176", Condition.interact_cond, table.getKeyName(Enum.PetInteract_cond, Condition.interact_cond))
    return false
  end
  return false
end

function PetActionCommon:UpdateInfo(NewAction)
  Base.UpdateInfo(self, NewAction)
  if self.SingleAction then
    self.SingleAction:UpdateInfo(NewAction)
  end
end

function PetActionCommon:ContinueWhenSuccess()
  if self.SingleAction then
    return self.SingleAction:ContinueWhenSuccess()
  else
    return Base.ContinueWhenSuccess(self)
  end
end

function PetActionCommon:Destroy()
  if self.SingleAction then
    self.SingleAction:Destroy()
    self.SingleAction = nil
  end
end

function PetActionCommon:CreateAction(Group)
  if not PetActionFactory then
    PetActionFactory = require("NewRoco.Modules.Core.NPC.Actions.PetActionFactory")
  end
  local Action = PetActionFactory:GetAction(self.Owner, Group)
  if not Action then
    Log.Error("\230\151\160\230\179\149\229\136\155\229\187\186Action")
    Log.Dump(Group, 3, "Failed to create pet action")
    return nil
  end
  Action.ConfType = ProtoEnum.ClientOperationConfType.COCT_PET_INTERACTION_CONF
  Action.ConfID = Group.id
  return Action
end

function PetActionCommon:OnOptionChange()
end

return PetActionCommon
