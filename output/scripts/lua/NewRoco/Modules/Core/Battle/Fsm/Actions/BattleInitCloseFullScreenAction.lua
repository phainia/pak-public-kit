local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local Enum = require("Data.Config.Enum")
local BattleInitCloseFullScreenAction = BattleActionBase:Extend("BattleInitCloseFullScreenAction")

function BattleInitCloseFullScreenAction:Ctor(name, properties)
  BattleActionBase.Ctor(self, name, properties)
  self.BattleManager = _G.BattleManager
end

function BattleInitCloseFullScreenAction:OnEnter()
  NRCPanelManager:CloseAllPanelByLayer(_G.Enum.UILayerType.UI_LAYER_FULLSCREEN)
  self:Finish()
end

function BattleInitCloseFullScreenAction:OnExit()
  self.BattleManager = nil
  self.preLoadAssetNumber = 0
end

return BattleInitCloseFullScreenAction
