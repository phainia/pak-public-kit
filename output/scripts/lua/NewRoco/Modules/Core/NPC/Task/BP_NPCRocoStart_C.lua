local ViewNPCBase = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local Base = ViewNPCBase
local BP_NPCRocoStart_C = Base:Extend("BP_NPCRocoStart_C")

function BP_NPCRocoStart_C:SetupAction(Action)
  self.PlayFlag = true
  self.action = Action
  self.DelayId = nil
end

function BP_NPCRocoStart_C:OnLoadResource()
  Base.OnLoadResource(self)
  self.FxActor = self:GetFxActor()
  if self.FxActor then
    self.FxActor.OnStageChange:Add(self, self.OnStageChangedEvent)
  end
end

function BP_NPCRocoStart_C:PlayLevel2()
  self.PlayFlag = true
  self.AudioSessionID = _G.NRCAudioManager:PlaySound2DAuto(41580010, "BP_NPCRocoStart")
  if UE4.UObject.IsValid(self.FxActor) then
    self.FxActor:ToLevel2()
  end
end

function BP_NPCRocoStart_C:OnStageChangedEvent(Stage)
  if 4 == Stage then
    self.action:Finish(true)
    local serverID = self.sceneCharacter:GetServerId()
    _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.RemoveNPC, serverID)
  end
  if self.PlayFlag then
    if 2 == Stage then
      if UE4.UObject.IsValid(self.FxActor) then
        self.FxActor:ToLevel3()
      end
    elseif 3 == Stage then
      _G.NRCModuleManager:DoCmd(_G.DialogueModuleCmd.PlayStartUpEndAnim)
      self.PlayFlag = false
    end
  end
end

function BP_NPCRocoStart_C:PlayLevel4()
  if self.AudioSessionID and 0 ~= self.AudioSessionID then
    _G.NRCAudioManager:StopWwiseEventForActor(self.AudioSessionID)
    _G.NRCAudioManager:ReleaseSession(self.AudioSessionID, true, "BP_NPCRocoStart", false)
  end
  if UE4.UObject.IsValid(self.FxActor) then
    self.FxActor:ToLevel4()
  end
  _G.NRCAudioManager:PlaySound2DAuto(41580020, "BP_NPCRocoStart")
  if self.DelayId then
    _G.DelayManager:CancelDelayById(self.DelayId)
    self.DelayId = nil
  end
  self.DelayId = _G.DelayManager:DelaySeconds(0.5, function()
    _G.NRCEventCenter:DispatchEvent(NRCGlobalEvent.OPEN_WHITE_SCREEN)
  end)
end

function BP_NPCRocoStart_C:StopAnim()
  if self.AudioSessionID and 0 ~= self.AudioSessionID then
    _G.NRCAudioManager:StopWwiseEventForActor(self.AudioSessionID)
    _G.NRCAudioManager:ReleaseSession(self.AudioSessionID, true, "BP_NPCRocoStart", false)
  end
  self.PlayFlag = false
end

function BP_NPCRocoStart_C:Destruct()
  if self.DelayId then
    _G.DelayManager:CancelDelayById(self.DelayId)
    self.DelayId = nil
  end
  self.FxActor = nil
end

return BP_NPCRocoStart_C
