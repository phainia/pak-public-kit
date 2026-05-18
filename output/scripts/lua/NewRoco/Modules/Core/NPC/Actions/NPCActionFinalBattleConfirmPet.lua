local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local Base = NPCActionBase
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local NPCActionFinalBattleConfirmPet = Base:Extend("NPCActionReadingMatter")

function NPCActionFinalBattleConfirmPet:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionFinalBattleConfirmPet:Execute()
  Base.Execute(self)
  local req = ProtoMessage:newZoneBattleFinalBattleP2SummonReq()
  local pet = NRCModuleManager:DoCmd(BattleUIModuleCmd.GetFinalBattlePetData)
  req.name = pet.name
  req.confirmed = 1
  req.pet = pet
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_FINAL_BATTLE_P2_SUMMON_REQ, req, self, self.OnFinalBattle2Rsp)
  self.delayID = _G.DelayManager:DelayFrames(1, self.Finish, self, true)
end

function NPCActionFinalBattleConfirmPet:OnFinalBattle2Rsp(rsp)
  _G.BattleEventCenter:Dispatch(BattleEvent.OnFinalBattleSummer, rsp)
end

function NPCActionFinalBattleConfirmPet:OnExit()
  if self.delayID then
    _G.DelayManager:CancelDelayById(self.delayID)
    self.delayID = nil
  end
end

return NPCActionFinalBattleConfirmPet
