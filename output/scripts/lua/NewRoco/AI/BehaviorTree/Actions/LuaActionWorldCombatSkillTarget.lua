local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local WorldCombatBuffComponent = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatBuffComponent")
local LuaActionWorldCombatSkillTarget = Base:Extend("LuaActionWorldCombatSkillTarget")

function LuaActionWorldCombatSkillTarget:OnStart(AIController, ...)
  local args = {
    ...
  }
  local owner = AIController
  local Radius = self.TargetSearchRadius:GetValue(owner)
  local TargetType = self.TargetType:GetValue(owner)
  local TargetTagType = self.TargetTagType:GetValue(owner)
  local TargetTagValue = self.TargetTagValue:GetValue(owner)
  local TargetTagOpType = self.TargetTagOpType:GetValue(owner)
  local TargetSearchType = self.TargetSearchType:GetValue(owner)
  local TargetLocation, TargetActor
  local OwnerLocation = owner.Npc:GetActorLocation()
  if TargetType == Enum.WorldCombatTargetType.WCT_SELF then
    TargetLocation = owner.Npc:GetActorLocation()
    TargetActor = owner.Npc
  elseif TargetType == Enum.WorldCombatTargetType.WCT_PLAYER then
    local PlayerList = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_ALL_PLAYER)
    if TargetSearchType == Enum.WorldCombatTargetSearchType.WCTS_RANDOM then
      if #PlayerList > 0 then
        local RandomIndex = math.random(1, #PlayerList)
        local RandomPlayer = PlayerList[RandomIndex]
        TargetLocation = RandomPlayer:GetActorLocation()
        TargetActor = RandomPlayer
      end
    elseif nil ~= PlayerList then
      local LastDist
      for _, Player in pairs(PlayerList) do
        if nil == Player.viewObj then
        else
          local SceneCharacter = Player.viewObj.sceneCharacter
          if nil == SceneCharacter then
          elseif not self:CheckTagOp(SceneCharacter, TargetTagOpType, TargetTagType, TargetTagValue) then
          else
            local Dist = UE4.FVector.Dist(OwnerLocation, SceneCharacter:GetActorLocation())
            if Radius < Dist then
            elseif not self:CheckDist(TargetSearchType, LastDist, Dist) then
            else
              LastDist = Dist
              TargetLocation = SceneCharacter:GetActorLocation()
              TargetActor = SceneCharacter
            end
          end
        end
      end
    end
  else
    local OutActors, Result = UE4.UKismetSystemLibrary.Abs_SphereOverlapActors(owner:GetWorld(), OwnerLocation, Radius, nil, nil, nil)
    if Result then
      if TargetSearchType == Enum.WorldCombatTargetSearchType.WCTS_RANDOM then
        if #OutActors > 0 then
          local RandomIndex = math.random(1, #OutActors)
          local RandomActor = OutActors[RandomIndex]
          TargetLocation = RandomActor:GetActorLocation()
          TargetActor = RandomActor
        end
      else
        local LastDist
        for i = 1, OutActors:Length() do
          local Actor = OutActors:Get(i)
          local SceneCharacter = Actor.sceneCharacter
          if not SceneCharacter or UE4.UNRCStatics.GetObjectUniqueID(SceneCharacter.viewObj) == UE4.UNRCStatics.GetObjectUniqueID(owner.Npc.viewObj) then
          elseif not self:CheckTagOp(SceneCharacter, TargetTagOpType, TargetTagType, TargetTagValue) then
          else
            local Dist = UE4.FVector.Dist(OwnerLocation, SceneCharacter:GetActorLocation())
            if not self:CheckDist(TargetSearchType, LastDist, Dist) then
            else
              LastDist = Dist
              TargetLocation = SceneCharacter:GetActorLocation()
              TargetActor = SceneCharacter
            end
          end
        end
      end
    end
  end
  if nil ~= TargetLocation and nil ~= TargetActor then
    local TargetType = self.Target:GetType()
    if TargetType == LuaParamType.Vector then
      self.Target:SetValue(owner, TargetLocation)
    elseif TargetType == LuaParamType.Object then
      self.Target:SetValue(owner, TargetActor)
    else
      Log.Error("UnSupported Target Param Type")
      self:Finish(false)
      return
    end
    self:Finish(true)
  else
    self:Finish(false)
  end
end

function LuaActionWorldCombatSkillTarget:CheckTagOp(SceneCharacter, TagOpType, TagType, TagValue)
  local CheckTagResult = self:CheckTag(SceneCharacter, TagType, TagValue)
  if TagOpType == Enum.WorldCombatTargetTagOpType.WCTTO_SELECT then
    if true == CheckTagResult then
      return true
    end
  elseif TagOpType == Enum.WorldCombatTargetTagOpType.WCTTO_SELECT_INVERT and true ~= CheckTagResult then
    return true
  end
  return false
end

function LuaActionWorldCombatSkillTarget:CheckTag(SceneCharacter, TagType, TagValue)
  if TagType == Enum.WorldCombatTargetTagType.WCTT_NONE then
    return true
  elseif TagType == Enum.WorldCombatTargetTagType.WCTT_NPC_CONF_ID then
    if nil == TagValue then
      return true
    end
    if nil == SceneCharacter.config then
      return false
    end
    if SceneCharacter.config.id == TagValue then
      return true
    end
    return false
  elseif TagType == Enum.WorldCombatTargetTagType.WCTT_REFRESH_CONF_ID then
    if nil == TagValue then
      return true
    end
    if SceneCharacter.serverData.npc_base.npc_content_cfg_id == TagValue then
      return true
    end
    return false
  elseif TagType == Enum.WorldCombatTargetTagType.WCTT_BUFF_ID then
    if nil == TagValue then
      return true
    end
    local BuffComponent = SceneCharacter:GetComponent(WorldCombatBuffComponent)
    if BuffComponent.HasBuff(TagValue) then
      return true
    end
    return false
  end
  return false
end

function LuaActionWorldCombatSkillTarget:CheckDist(Dir, LastDist, Dist)
  if nil == LastDist then
    return true
  end
  if Dir == Enum.WorldCombatTargetSearchType.WCTS_FORWARD then
    if Dist < LastDist then
      return true
    end
  elseif Dir == Enum.WorldCombatTargetSearchType.WCTS_BACKWARD and LastDist < Dist then
    return true
  end
  return false
end

return LuaActionWorldCombatSkillTarget
