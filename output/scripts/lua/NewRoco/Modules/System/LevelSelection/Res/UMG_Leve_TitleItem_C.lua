local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Leve_TitleItem_C = Base:Extend("UMG_Leve_TitleItem_C")

function UMG_Leve_TitleItem_C:OnConstruct()
end

function UMG_Leve_TitleItem_C:OnDestruct()
end

function UMG_Leve_TitleItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.ruleConf = _data.ruleConf
  self.Title:SetText(self.ruleConf.title)
  self:ChangeNormalAim()
end

function UMG_Leve_TitleItem_C:ChangeNormalAim()
  self:PlayAnimation(self.Normal)
end

function UMG_Leve_TitleItem_C:OnItemSelected(_bSelected)
  self:StopAllAnimations()
  if _bSelected then
    self:PlayAnimation(self.Select_in)
    _G.NRCModuleManager:DoCmd(LevelSelectionModuleCmd.OnCmdOpenLeaderTraitTips, self.ruleConf.id, self.data.petbaseId, LuaText.challenge_text_22)
  else
    self:PlayAnimation(self.Select_out)
  end
end

function UMG_Leve_TitleItem_C:OnClickNRCButton()
  _G.NRCModuleManager:DoCmd(LevelSelectionModuleCmd.OnCmdOpenLeaderTraitTips, self.ruleConf.id, self.data.petbaseId, LuaText.challenge_text_22)
end

function UMG_Leve_TitleItem_C:OnDeactive()
end

return UMG_Leve_TitleItem_C
