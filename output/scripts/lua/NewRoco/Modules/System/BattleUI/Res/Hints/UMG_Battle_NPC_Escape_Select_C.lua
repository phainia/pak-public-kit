local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local UMG_Battle_NPC_Escape_Select_C = _G.NRCPanelBase:Extend("UMG_Battle_NPC_Escape_Select_C")

function UMG_Battle_NPC_Escape_Select_C:OnActive(data)
  self.data = data
  self:OnAddEventListener()
  self.battleManager = _G.BattleManager
  self:SetText()
  self:PlayAnimation(self.In)
end

function UMG_Battle_NPC_Escape_Select_C:OnDeactive()
end

function UMG_Battle_NPC_Escape_Select_C:OnAddEventListener()
  self:AddButtonListener(self.BtnNo, self.OnClickBtnNo)
  self:AddButtonListener(self.ButtonYes, self.OnClickButtonYes)
end

function UMG_Battle_NPC_Escape_Select_C:OnAnimationFinished(anim)
  if anim == self.In then
  elseif anim == self.Out then
    self:DoClose()
  end
end

function UMG_Battle_NPC_Escape_Select_C:OnClickBtnNo()
  _G.BattleEventCenter:Dispatch(BattleEvent.NPC_AUTO_ESCAPE_Deny)
  self:StopAllAnimations()
  self:PlayAnimation(self.Out)
end

function UMG_Battle_NPC_Escape_Select_C:OnClickButtonYes()
  _G.BattleEventCenter:Dispatch(BattleEvent.NPC_AUTO_ESCAPE_Accept)
  self:StopAllAnimations()
  self:PlayAnimation(self.Out)
end

function UMG_Battle_NPC_Escape_Select_C:Clear()
  self.data = nil
end

function UMG_Battle_NPC_Escape_Select_C:SetText()
  local cfg = _G.DataConfigManager:GetLocalizationConf("Escape_string")
  if cfg then
    local rawTxt = cfg.msg
    local name = _G.BattleManager.battlePawnManager:GetTeam(BattleEnum.Team.ENUM_ENEMY).player.roleInfo.base.name
    rawTxt = string.format(rawTxt, name)
    self.TypeWritter.Dialogue:SetJustification(UE4.ETextJustify.Left)
    self.TypeWritter:Init(1.0E-4, 1)
    self.TypeWritter:WriteOnSamePage(rawTxt)
  else
    Log.Error("Escape_string not found in localization conf")
  end
end

return UMG_Battle_NPC_Escape_Select_C
