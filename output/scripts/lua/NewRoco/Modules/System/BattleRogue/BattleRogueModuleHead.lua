local BattleRogueModuleHead = NRCModuleHeadBase:Extend("BattleRogueModuleHead")

function BattleRogueModuleHead:OnConstruct()
  _G.BattleRogueModuleCmd = reload("NewRoco.Modules.System.BattleRogue.BattleRogueModuleCmd")
  self:BindCmd(_G.BattleRogueModuleCmd.HideMainInfo, "OnCmdHideMainInfo")
  self:BindCmd(_G.BattleRogueModuleCmd.GetCurChallengeLevelConf, "GetCurChallengeLevelConf")
  self:BindCmd(_G.BattleRogueModuleCmd.SendChallengeLevelReq, "SendChallengeLevelReq")
  self:BindCmd(_G.BattleRogueModuleCmd.SendChooseRogueEventReq, "SendChooseRogueEventReq")
  self:BindCmd(_G.BattleRogueModuleCmd.SendFixedEventReq, "SendFixedEventReq")
  self:BindCmd(_G.BattleRogueModuleCmd.SendCombineEventReq, "SendCombineEventReq")
  self:BindCmd(_G.BattleRogueModuleCmd.SendRefreshEventReq, "SendRefreshEventReq")
  self:BindCmd(_G.BattleRogueModuleCmd.SendChooseBuffReq, "SendChooseBuffReq")
  self:BindCmd(_G.BattleRogueModuleCmd.SendStartEventReq, "SendStartEventReq")
  self:BindCmd(_G.BattleRogueModuleCmd.SendLetPetFree, "SendLetPetFree")
  self:BindCmd(_G.BattleRogueModuleCmd.OnCmdSelectCombineCard, "OnCmdSelectCombineCard")
  self:BindCmd(_G.BattleRogueModuleCmd.CheckCombineIndexes, "CheckCombineIndexes")
  self:BindCmd(_G.BattleRogueModuleCmd.SelectCombineCard, "OnCmdSelectCombineCard")
  self:BindCmd(_G.BattleRogueModuleCmd.SelectBuffInfo, "OnCmdSelectBuffInfo")
  self:BindCmd(_G.BattleRogueModuleCmd.ChangeState, "ChangeState")
  self:BindCmd(_G.BattleRogueModuleCmd.PetMainClose, "OnCmdPetMainClose")
end

return BattleRogueModuleHead
