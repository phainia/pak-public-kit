local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattlePlayAnimBaseAction = require("NewRoco.Modules.Core.Battle.Fsm.Actions.Base.BattlePlayAnimBaseAction")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleExitHelper = require("NewRoco.Modules.Core.Battle.Players.BattleExitHelper")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local Base = BattlePlayAnimBaseAction
local BattlePveNpcLeaveAction = Base:Extend("BattlePveNpcLeaveAction")
FsmUtils.MergeMembers(Base, BattlePveNpcLeaveAction, {})

function BattlePveNpcLeaveAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattlePveNpcLeaveAction:OnEnter()
  Log.Debug("BattlePveNpcLeaveAction OnEnter ")
  if BattleUtils.IsPve() then
    Log.Debug("BattlePveNpcLeaveAction OnEnter 0")
    local npcInfos = _G.BattleManager.battleRuntimeData:GetAllNPCs()
    local isNpcFound = false
    if npcInfos then
      for _, npcInfo in ipairs(npcInfos) do
        local npc = npcInfo.npc
        if npc and npc.viewObj then
          npc:SetVisibleForBattleReason(true)
          isNpcFound = true
        end
      end
    end
    if not isNpcFound then
      Log.Warning("BattleManager:LeaveBattle Can't Restore TraceNPC\239\188\140\229\166\130\230\158\156\230\152\175\230\181\139\232\175\149\233\157\162\230\157\191\232\191\155\229\133\165\230\136\152\230\150\151\230\151\160\232\167\134\230\173\164\230\138\165\233\148\153")
      self:Finish()
    end
    Log.Debug("BattlePveNpcLeaveAction OnEnter 1:", type(_G.BattleManager.battlePawnManager:GetPlayerEnemyTeam()))
    _G.BattleManager.battlePawnManager:HideAll(false)
    local Player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    self:ShowPlayer()
    NRCModeManager:DoCmd(BattleUIModuleCmd.HideMainWindow, false, true)
    _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.HideBattlePopupPanel)
    BattleExitHelper.SetFinishPveSeamless()
  else
    Log.Debug("BattlePveNpcLeaveAction OnEnter 2")
    self:Finish()
  end
end

function BattlePveNpcLeaveAction:ShowPlayer()
  NRCModeManager:DoCmd(PlayerModuleCmd.HIDE_ALL, false)
end

function BattlePveNpcLeaveAction:OnExit()
end

return BattlePveNpcLeaveAction
