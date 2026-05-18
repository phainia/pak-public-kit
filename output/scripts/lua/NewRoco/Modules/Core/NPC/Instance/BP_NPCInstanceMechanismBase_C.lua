require("UnLuaEx")
local MarkerModuleEvent = reload("NewRoco.Modules.Core.Marker.MarkerModuleEvent")
local PointOfInterestItem = require("NewRoco.Modules.Core.Marker.PointOfInterestItem")
local MarkerEnum = require("NewRoco.Modules.Core.Marker.MarkerEnum")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local BP_NPCInstanceMechanismBase_C = Base:Extend("BP_NPCInstanceMechanismBase_C")

function BP_NPCInstanceMechanismBase_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
  self.inUse = false
  self.ConsumeTagTime = 1
  self.ConsumeTagHandler = -1
  self.CurrentState = false
end

function BP_NPCInstanceMechanismBase_C:ReceiveBeginPlay()
  if self.sceneCharacter then
    self:UpdateState()
  end
  Base.ReceiveBeginPlay(self)
end

function BP_NPCInstanceMechanismBase_C:UpdateState(bInit)
  if not self.sceneCharacter then
    return
  end
  local luaObj = self.sceneCharacter.luaObj
  local Changed = luaObj.LogicStatus ~= self.CurrentState
  self:ChangeState(luaObj.LogicStatus, bInit)
  if not Changed then
    return
  end
  if -1 ~= self.ConsumeTagHandler then
    _G.DelayManager:CancelDelayById(self.ConsumeTagHandler)
    self.ConsumeTagHandler = -1
  end
  local ID = self.sceneCharacter:GetServerId()
  if ID and 0 ~= ID then
    self.ConsumeTagHandler = _G.DelayManager:DelaySeconds(self.ConsumeTagTime or 0.1, self.ConsumeTag, self, ID)
  end
end

function BP_NPCInstanceMechanismBase_C:ConsumeTag(ID)
  _G.NRCModuleManager:DoCmd(_G.SceneModuleCmd.ConsumeCachedActorTag, ID)
end

function BP_NPCInstanceMechanismBase_C:SetInteraction(Flag)
  local AllNpc = NRCModuleManager:DoCmd(NPCModuleCmd.GetAllNPCInIter)
  if not self.sceneCharacter then
    return
  end
  local Pos = self:Abs_K2_GetActorLocation()
  local NPC
  local Dist = -1
  for k, v in pairs(AllNpc) do
    if v ~= self.sceneCharacter then
      local DistLoc = Pos:Dist(v:GetActorLocation())
      if -1 == Dist then
        Dist = DistLoc
        NPC = v
      elseif DistLoc < Dist then
        Dist = DistLoc
        NPC = v
      end
    end
  end
  if NPC then
    if true == Flag then
      NPC.InteractionComponent:TryEnableInteraction()
    else
      NPC.InteractionComponent:TryDisableInteraction()
    end
  end
end

function BP_NPCInstanceMechanismBase_C:ChangeState(State, bInit)
  if self.CurrentState == State then
    return
  end
  if 0 == State then
    if self.POI then
      NRCEventCenter:DispatchEvent(MarkerModuleEvent.POI_REMOVE, self.POI)
      self.POI = nil
    end
    self:DeactivateEvent(bInit)
  elseif 1 == State then
    if self.sceneCharacter and self.sceneCharacter.InteractionComponent then
      local Options = self.sceneCharacter.InteractionComponent:GetAllOptions()
      local OptionConf
      for i, k in pairs(Options) do
        if k.config.action.action_type == Enum.ActionType.ACT_RUN_OPTION_NPC then
          OptionConf = k.config
          break
        end
      end
      if OptionConf and OptionConf.trigger_guide and OptionConf.trigger_guide > 0 and not self.POI then
        self.POI = PointOfInterestItem(self.sceneCharacter.serverPos, MarkerEnum.SourceType.InstanceMechanism)
        self.POI.PointKlass = OptionConf.trigger_guide + 1
        NRCEventCenter:DispatchEvent(MarkerModuleEvent.POI_UPDATE, self.POI)
      end
    end
    self:ActivateEvent(bInit)
  end
  self.CurrentState = State
end

function BP_NPCInstanceMechanismBase_C:ReceiveDestroyed()
  if self.POI then
    NRCEventCenter:DispatchEvent(MarkerModuleEvent.POI_REMOVE, self.POI)
    self.POI = nil
  end
  Base.ReceiveDestroyed(self)
end

function BP_NPCInstanceMechanismBase_C:Recycle()
  if -1 ~= self.ConsumeTagHandler then
    _G.DelayManager:CancelDelayById(self.ConsumeTagHandler)
    self.ConsumeTagHandler = -1
  end
  Base.Recycle(self)
end

return BP_NPCInstanceMechanismBase_C
