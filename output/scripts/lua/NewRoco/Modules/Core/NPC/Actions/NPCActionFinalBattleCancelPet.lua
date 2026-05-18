local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local Base = NPCActionBase
local NPCActionFinalBattleCancelPet = Base:Extend("NPCActionReadingMatter")

function NPCActionFinalBattleCancelPet:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionFinalBattleCancelPet:Execute()
  Base.Execute(self)
  NRCModuleManager:DoCmd(BattleUIModuleCmd.OpenCallNamePanel)
  self.delayID = _G.DelayManager:DelayFrames(1, self.Finish, self, true)
end

function NPCActionFinalBattleCancelPet:OnFinalBattle2Rsp()
end

function NPCActionFinalBattleCancelPet:OnExit()
  if self.delayID then
    _G.DelayManager:CancelDelayById(self.delayID)
    self.delayID = nil
  end
end

return NPCActionFinalBattleCancelPet
