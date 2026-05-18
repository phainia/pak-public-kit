local DialogueModuleCmd = require("NewRoco.Modules.System.Dialogue.DialogueModuleCmd")
local NPCModuleCmd = require("NewRoco.Modules.Core.NPC.NPCModuleCmd")
local NPCActionBattle = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBattle")
local ActionUtils = require("NewRoco.Modules.Core.NPC.Actions.ActionUtils")
local Base = NPCActionBattle
local CDConf = _G.DataConfigManager:GetBattleGlobalConfig("touch_battle_min_cd")
local CD = 3
if CDConf and CDConf.num then
  CD = CDConf.num
end
local NPCActionTouchBattle = Base:Extend("NPCActionTouchBattle")

function NPCActionTouchBattle:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionTouchBattle:OnNpcAction()
  if GlobalConfig.DisableTouchBattle then
    return false
  end
  local NPC = self.OwnerNpc
  local Comp = NPC and NPC.AIComponent
  if Comp and Comp:HasControlFlags(Enum.SceneAiControlFlags.SACF_DISABLE_TOUCH_BATTLE) then
    return false
  end
  local Now = _G.UpdateManager.Timestamp
  local LastDialogue = self:DoCmd(DialogueModuleCmd.GetLastDialogueEndTime) or 0
  if Now < LastDialogue + CD then
    Log.Error("Last Dialogue Time", LastDialogue, Now)
    return false
  end
  local LastBattle = self:DoCmd(NPCModuleCmd.GetLastBattleEndTime) or 0
  if Now < LastBattle + CD then
    Log.Error("Last Battle Time", LastBattle, Now)
    return false
  end
  local Ban, Msg = _G.FunctionBanManager:GetFunctionState(Enum.PlayerFunctionBanType.PFBT_TOUCH_BATTLE, false, false, CD)
  if Ban then
    Log.Debug("\228\186\146\230\150\165\231\179\187\231\187\159\230\139\166\230\136\170,CD", Msg)
    return false
  end
  local PlayerPursue, NPCPursue = ActionUtils.CalcPursue(self)
  if PlayerPursue or NPCPursue then
    return Base.OnNpcAction(self)
  else
    return false
  end
end

return NPCActionTouchBattle
