local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local Base = BattleActionBase
local WaitOtherAction = Base:Extend("WaitOtherAction")
FsmUtils.MergeMembers(Base, WaitOtherAction, {})

function WaitOtherAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.RandomAnimList = {
    "Alert",
    "Becute",
    "Happy",
    "Fear",
    "Relax",
    "Shock",
    "Sad1"
  }
  self:SetActionType(BattleActionBase.ActionType.WatingOtherPlayerSelectAction)
end

function WaitOtherAction:OnEnter()
  self.BattleManager = _G.BattleManager
  self.ClickTime = 0
  self.WaitHide = false
  self.player = self.BattleManager.battlePawnManager.TeamatePlayer
  self.enemyPlayer = self.BattleManager.battlePawnManager:GetPlayerEnemyTeam()
  self.isShowThinking = false
  self.isShowPop = false
  self.timeout = self.timeoutValue
  local battlePets = self.BattleManager.battlePawnManager:GetAllPets()
  for _, v in pairs(battlePets) do
    v:SetClickable(true)
  end
  if BattleUtils.IsTeam() then
    _G.BattleManager.vBattleField.battleCameraManager:ChangeToSkill(0.1, true)
  elseif BattleUtils.IsWatchingBattle() then
    _G.BattleManager.vBattleField.battleCameraManager:ChangeToSkill(0.5, true)
  else
    NRCModeManager:DoCmd(BattleUIModuleCmd.ShowWaiting)
    _G.BattleManager.vBattleField.battleCameraManager:ChangeToSkill(0, true)
  end
  self.fsm:Pause()
  self:SafeDelaySeconds("d_ShowPopup", 0.5, self.ShowPopup, self)
  local player = self.BattleManager.battlePawnManager.TeamatePlayer
  if player and UE.UObject.IsValid(player.model) then
    player:StopAll()
    player.model:PlayAnimByName("Stand2", 1, -1, 0, 0, -1, -1)
  end
  _G.BattleEventCenter:Bind(self, BattleEvent.CLICKED_WAIT_EMO_LIST, BattleEvent.CLICKED_WAIT_EMO_BACK, BattleEvent.CLICKED_WAIT_EMO, BattleEvent.BATTLE_CLICKED_PET, BattleEvent.EMO_HIDE_OVER)
end

function WaitOtherAction:ShowPopup()
  if not self.active then
    return
  end
  if BattleUtils.IsFriendAssist() then
    self.isShowPop = true
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.DataConfigManager:GetGlobalConfigByKeyType("syn_battle_waiting_tip", _G.DataConfigManager.ConfigTableId.BATTLE_GLOBAL_CONFIG).str, 99)
  end
  if self.enemyPlayer and self.enemyPlayer.model then
    self.isShowThinking = true
    self.enemyPlayer.model:ShowThinking()
  end
end

function WaitOtherAction:HidePopup()
  if self.isShowPop then
    local TipsModule = NRCModuleManager:GetModule("TipsModule")
    if TipsModule and TipsModule:HasPanel("UMG_TopHUD") then
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_HideTips)
    else
      TipsModule:ClosePanel("UMG_TopHUD")
    end
  end
  if self.isShowThinking and self.enemyPlayer and self.enemyPlayer.model then
    self.enemyPlayer.model:HideEmoji()
  end
end

function WaitOtherAction:CanClick()
  local curTime = UE4Helper.GetTime()
  if curTime - self.ClickTime > 3 then
    return true
  end
  return false
end

function WaitOtherAction:ShowEmoList()
  NRCModeManager:DoCmd(BattleUIModuleCmd.ShowEmoList)
end

function WaitOtherAction:HideEmoList()
  NRCModeManager:DoCmd(BattleUIModuleCmd.HideEmoList)
end

function WaitOtherAction:ClickEmoList()
  if self:CanClick() then
    self.WaitHide = false
    _G.BattleManager.vBattleField.battleCameraManager:ChangeToPlayerChangePet(0.1)
    self:ShowEmoList()
  end
end

function WaitOtherAction:ClickEmoBack()
  if self:CanClick() then
    self.WaitHide = true
    self:HideEmoList()
  end
end

function WaitOtherAction:EmoListHideOver()
  if self.WaitHide then
    _G.BattleManager.vBattleField.battleCameraManager:ChangeToSkill(0.1)
  end
end

function WaitOtherAction:ClickEmo(EmoIndex)
  if self:CanClick() then
    self.WaitHide = false
    self.ClickTime = UE4Helper.GetTime()
    local req = _G.ProtoMessage:newZoneBattleEmojiReq()
    req.emoji = EmoIndex
    local player = BattleManager.battlePawnManager.EnemyPlayer
    if player then
      req.aim_uin = player.guid
    end
    _G.BattleNetManager:SendBattleShowEmo(req, self, self.EmojiRsp)
  end
end

function WaitOtherAction:EmojiRsp(rsp)
  if rsp and 0 == rsp.ret_info.ret_code then
    self:HideEmoList()
    NRCModeManager:DoCmd(BattleUIModuleCmd.HideWaiting)
    self:SafeDelaySeconds("d_PlayEmoOver", 3, self.PlayEmoOver, self)
  else
    self.ClickTime = 0
  end
end

function WaitOtherAction:PlayEmoOver()
  if self.BattleManager then
    NRCModeManager:DoCmd(BattleUIModuleCmd.ShowWaiting)
    self:ShowEmoList()
  end
end

function WaitOtherAction:OnPetClicked(Pet)
  if BattleUtils.IsTeam() then
    return
  end
  local animCount = #self.RandomAnimList
  if animCount > 0 then
    self.curAnimListTime = 0
    local animIndex = math.random(animCount)
    local aniName = self.RandomAnimList[animIndex]
    Pet:PlayAnimByName(aniName, 1, -1, 0, 0, 1, -1)
  end
end

function WaitOtherAction:OnFinish()
  if BattleUtils.IsFinalBattle() then
    NRCModeManager:DoCmd(BattleUIModuleCmd.HideBattlePopupPanel)
    NRCModeManager:DoCmd(BattleUIModuleCmd.MainHideAll, true)
  end
  _G.BattleEventCenter:UnBind(self)
  self.BattleManager = nil
  self.ClickTime = 0
  NRCModeManager:DoCmd(BattleUIModuleCmd.HideWaiting)
  self:HidePopup()
  self.enemyPlayer = nil
end

function WaitOtherAction:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.CLICKED_WAIT_EMO_LIST then
    self:ClickEmoList()
    return true
  elseif eventName == BattleEvent.CLICKED_WAIT_EMO_BACK then
    self:ClickEmoBack()
    return true
  elseif eventName == BattleEvent.CLICKED_WAIT_EMO then
    self:ClickEmo(...)
    return true
  elseif eventName == BattleEvent.BATTLE_CLICKED_PET then
    self:OnPetClicked(...)
    return true
  elseif eventName == BattleEvent.EMO_HIDE_OVER then
    self:EmoListHideOver()
    return true
  end
end

return WaitOtherAction
