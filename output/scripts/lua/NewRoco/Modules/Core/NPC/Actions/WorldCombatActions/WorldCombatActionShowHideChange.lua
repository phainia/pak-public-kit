local WorldCombatActionBase = require("NewRoco.Modules.Core.NPC.Actions.WorldCombatActions.WorldCombatActionBase")
local NPCModuleEnum = require("NewRoco.Modules.Core.NPC.NPCModuleEnum")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Base = WorldCombatActionBase
local WorldCombatActionShowHideChange = Base:Extend("WorldCombatActionShowHideChange")

function WorldCombatActionShowHideChange:Ctor(Runner, SkillId, ActionType, ServerInfo)
  Base.Ctor(self, Runner, SkillId, ActionType, ServerInfo)
end

function WorldCombatActionShowHideChange:PreExecute()
  Base.PreExecute(self)
  self.RunnerView = self.Runner.viewObj
end

function WorldCombatActionShowHideChange:InternalExecute()
  Base.InternalExecute(self)
  if not self.RunnerView then
    return
  end
  local bActorShow = self.ServerInfo.show_state
  if nil ~= bActorShow then
    self.Runner:SetVisibleForReason(bActorShow, NPCModuleEnum.NpcReasonFlags.WORLD_COMBAT_HIDDEN)
    if bActorShow then
      local meshComp = SceneUtils.GetActorMesh(self.RunnerView)
      if meshComp then
        Log.Debug("WorldCombatActionShowHideChange:InternalExecute: meshComp", meshComp, meshComp:IsVisible(), bActorShow)
        meshComp:SetVisibility(bActorShow, false)
        local HiddenComponent = self.Runner.HiddenComponent
        if not HiddenComponent or not HiddenComponent:IsHidden() then
          meshComp:SetHiddenInGame(not bActorShow, false)
        end
      end
    end
    Log.DebugFormat("WorldCombatActionShowHideChange:InternalExecute1: Runner = %s, bActorShow = %s", self.Runner.config.name, bActorShow)
  end
  if not self.RunnerView then
    Log.Debug("WorldCombatActionShowHideChange:InternalExecute: RunnerView is InValid!!!")
    return
  end
  if not self.ServerInfo.comp_list then
    return
  end
  for _, compListInfo in ipairs(self.ServerInfo.comp_list) do
    local compList = UE.UNRCStatics.GetActorComponentsByClassName(self.RunnerView, compListInfo.comp_name)
    if compList then
      compList = compList:ToTable()
      for _, comp in ipairs(compList) do
        comp:SetVisibility(compListInfo.show_state, compListInfo.propagate_to_children)
        Log.DebugFormat("WorldCombatActionShowHideChange:InternalExecute2: Runner = %s, comp_name = %s, comp = %s", self.Runner.config.name, compListInfo.comp_name, comp)
        if comp:IsA(UE.UPrimitiveComponent) then
          local overrideProfile
          if compListInfo.show_state then
            if self.Runner.config.genre == _G.Enum.ClientNpcType.CNT_PETBOSS then
              overrideProfile = "NPCCharacterBossMesh"
            elseif not comp:IsA(UE.USkeletalMeshComponent) then
              overrideProfile = "Trigger"
            else
              overrideProfile = comp:GetCollisionProfileName()
            end
          else
            overrideProfile = "NPCCharacterFreeNoInteract"
          end
          if not comp:ComponentHasTag("SkillHit") then
            comp:SetCollisionProfileName(overrideProfile)
            Log.DebugFormat("WorldCombatActionShowHideChange:InternalExecute3: comp_name = %s, show_state = %s, propagate_to_children = %s, overrideProfile = %s", comp:GetName(), compListInfo.show_state, compListInfo.propagate_to_children, overrideProfile)
          end
        end
      end
    end
  end
end

function WorldCombatActionShowHideChange:ProcessPerformOnReConnect(skillId, actionData)
  local worldCombatModule = _G.NRCModuleManager:GetModule("WorldCombatModule")
  if not worldCombatModule then
    return
  end
  if not self.Runner or not self.Runner.viewObj then
    return
  end
  local bInWorldCombat = _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsSelfInWorldCombat)
  local actionObj = self:GetSkillActionByGuid(actionData.GUID)
  if bInWorldCombat and actionData.GUID and not UE.UObject.IsValid(actionObj) then
    Log.Error("WorldCombatActionShowHideChange:ProcessPerformOnReConnect: actionObj is inValid hen in WorldCombat!!!")
    return
  end
  local showHideInfo = _G.ProtoMessage:newWorldCombatDotsSkillShowHideInfo()
  showHideInfo.GUID = actionData.GUID
  showHideInfo.skill_id = skillId
  showHideInfo.show_state = actionData.show_hide_snapshoot.show_hide_info.show_state
  showHideInfo.comp_list = actionData.show_hide_snapshoot.show_hide_info.comp_list
  self.ServerInfo = showHideInfo
  Log.Dump(showHideInfo, 1, "WorldCombatActionShowHideChange:ProcessPerformOnReConnect")
  self:Execute(worldCombatModule)
end

return WorldCombatActionShowHideChange
