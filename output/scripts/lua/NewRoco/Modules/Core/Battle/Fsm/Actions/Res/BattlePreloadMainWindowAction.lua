local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local Base = BattleActionBase
local BattlePreloadMainWindowAction = Base:Extend("BattlePreloadMainWindowAction")

function BattlePreloadMainWindowAction:Ctor()
  Base.Ctor(self)
  self:SetActionType(BattleActionBase.ActionType.ClientLoadResAction)
end

function BattlePreloadMainWindowAction:OnEnter()
  NRCPanelManager:PreloadPanel("/Game/NewRoco/Modules/System/BattleUI/Res/UMG_BattleMainWindow")
  self:Finish()
end

return BattlePreloadMainWindowAction
