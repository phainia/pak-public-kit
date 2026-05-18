local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local UMG_Battle_HUD_C = NRCUmgClass:Extend("")

function UMG_Battle_HUD_C:Construct()
  self.battleManager = _G.BattleManager
  self:AddListener()
end

function UMG_Battle_HUD_C:Destruct()
  self:RemoveListener()
  NRCUmgClass.Destruct(self)
end

function UMG_Battle_HUD_C:AddListener()
  _G.BattleEventCenter:Bind(self, BattleEvent.UI_HIDE)
end

function UMG_Battle_HUD_C:RemoveListener()
  _G.BattleEventCenter:UnBind(self)
end

function UMG_Battle_HUD_C:Hide()
  self:SetVisibility(UE4.ESlateVisibility.Hidden)
end

function UMG_Battle_HUD_C:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.UI_HIDE then
    self:Hide()
    return true
  end
end

return UMG_Battle_HUD_C
