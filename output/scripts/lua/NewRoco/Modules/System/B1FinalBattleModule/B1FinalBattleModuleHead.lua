local B1FinalBattleModuleHead = NRCModuleHeadBase:Extend("B1FinalBattleModuleHead")

function B1FinalBattleModuleHead:OnConstruct()
  _G.B1FinalBattleModuleCmd = require("NewRoco.Modules.System.B1FinalBattleModule.B1FinalBattleModuleCmd")
  self:BindCmd(_G.B1FinalBattleModuleCmd.OpenTwoScreenDialogue, "OnOpenTwoScreenDialogue")
  self:BindCmd(_G.B1FinalBattleModuleCmd.CloseTwoScreenDialogue, "OnCloseTwoScreenDialogue")
  self:BindCmd(_G.B1FinalBattleModuleCmd.OpenTwoPetDialogueCamera, "OnOpenTwoPetDialogueCamera")
  self:BindCmd(_G.B1FinalBattleModuleCmd.ClearDialogueCamera, "OnClearDialogueCamera")
  self:BindCmd(_G.B1FinalBattleModuleCmd.SetFirstEnterP2Battle, "OnSetFirstEnterP2Battle")
  self:BindCmd(_G.B1FinalBattleModuleCmd.GetFirstEnterP2Battle, "OnGetFirstEnterP2Battle")
  self:BindCmd(_G.B1FinalBattleModuleCmd.SetIsFirstDialogue, "OnSetIsFirstDialogue")
  self:BindCmd(_G.B1FinalBattleModuleCmd.GetIsFirstDialogue, "OnGetIsFirstDialogue")
end

return B1FinalBattleModuleHead
