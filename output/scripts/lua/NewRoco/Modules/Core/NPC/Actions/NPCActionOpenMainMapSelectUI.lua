local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local TipEnum = require("NewRoco.Modules.System.TipsModule.Utils.TipEnum")
local Base = NPCActionBase
local NPCActionOpenMainMapSelectUI = Base:Extend("NPCActionReceiveCampPetReportBonus")

function NPCActionOpenMainMapSelectUI:ExecuteWithModel()
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.PauseTip, TipEnum.TipsPauseReason.OpenMainMapSelectUI)
  _G.NRCModuleManager:DoCmd(DialogueModuleCmd.OpenMapModeSelection, self)
end

function NPCActionOpenMainMapSelectUI:EndAction()
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.ResumeTip, TipEnum.TipsPauseReason.OpenMainMapSelectUI)
  self:Finish()
end

function NPCActionOpenMainMapSelectUI:IsNeedCloseDialogueUI()
  return false
end

return NPCActionOpenMainMapSelectUI
