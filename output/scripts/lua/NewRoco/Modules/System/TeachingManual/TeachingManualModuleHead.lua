local TeachingManualModuleHead = NRCModuleHeadBase:Extend("TeachingManualModuleHead")

function TeachingManualModuleHead:OnConstruct()
  _G.TeachingManualModuleCmd = reload("NewRoco.Modules.System.TeachingManual.TeachingManualModuleCmd")
  self:BindCmd(_G.TeachingManualModuleCmd.OpenMainPanel, "OnOpenMainPanel")
  self:BindCmd(_G.TeachingManualModuleCmd.EnableMainPanel, "EnableMainPanel")
  self:BindCmd(_G.TeachingManualModuleCmd.PreLoadMainPanel, "PreLoadMainPanel")
  self:BindCmd(_G.TeachingManualModuleCmd.OpenMainPanelByTeachId, "CmdOpenMainPanelByTeachId")
  self:BindCmd(_G.TeachingManualModuleCmd.SelectTeachIndex, "OnCmdSelectTeachIndex")
  self:BindCmd(_G.TeachingManualModuleCmd.GetSelectTeachManualIndex, "OnCmdGetSelectTeachManualIndex")
  self:BindCmd(_G.TeachingManualModuleCmd.SelectViewPicture, "OnCmdSelectViewPicture")
  self:BindCmd(_G.TeachingManualModuleCmd.GetManualListByTeachManualIndex, "OnCmdGetManualListByTeachManualIndex")
  self:BindCmd(_G.TeachingManualModuleCmd.OnZoneUnlockTeachConditionReq, "OnZoneUnlockTeachConditionReq")
  self:BindCmd(_G.TeachingManualModuleCmd.ResetTeachId, "ResetTeachId")
  self:BindCmd(_G.TeachingManualModuleCmd.GetIsShowRed, "GetIsShowRed")
  self:BindCmd(_G.TeachingManualModuleCmd.JumpToRelatedFunction, "JumpToRelatedFunction")
  self:BindCmd(_G.TeachingManualModuleCmd.CloseTeachingManual, "CloseTeachingManual")
end

return TeachingManualModuleHead
