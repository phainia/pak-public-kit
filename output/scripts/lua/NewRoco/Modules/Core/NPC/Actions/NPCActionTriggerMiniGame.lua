local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local MiniGameModuleEvent = reload("NewRoco.Modules.System.MiniGame.MiniGameModuleEvent")
local Base = NPCActionBase
local NPCActionTriggerMiniGame = Base:Extend("NPCActionTriggerMiniGame")

function NPCActionTriggerMiniGame:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionTriggerMiniGame:Execute()
  Base.Execute(self)
  local Player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  Player.inputComponent:SetInputEnable(self, false, "MiniGameAction")
  NRCEventCenter:DispatchEvent(MiniGameModuleEvent.AddClock, self.Owner.owner)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1067, "NPCActionTriggerMiniGame:Execute")
  if self.SkipSubmit then
    self:Finish()
  end
end

function NPCActionTriggerMiniGame:OnSubmit(rsp)
  Base.OnSubmit(self, rsp)
  self:Finish()
end

function NPCActionTriggerMiniGame:OnCommit(rsp)
  local Player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  Player.inputComponent:SetInputEnable(self, true, "MiniGameAction")
  Base.OnCommit(self, rsp)
end

function NPCActionTriggerMiniGame:OnNpcActionCustomized()
  local Ban, _ = _G.FunctionBanManager:GetFunctionState(Enum.PlayerFunctionBanType.PFBT_MINIGAME_UI, true, true)
  if Ban then
    return false
  end
  return true
end

return NPCActionTriggerMiniGame
