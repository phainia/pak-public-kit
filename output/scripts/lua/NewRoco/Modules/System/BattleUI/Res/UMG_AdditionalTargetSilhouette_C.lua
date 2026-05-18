local UMG_AdditionalTargetSilhouette_C = _G.NRCPanelBase:Extend("UMG_AdditionalTargetSilhouette_C")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")

function UMG_AdditionalTargetSilhouette_C:OnActive(TaskInfo, NpcChallengeInfo, isHideRound, is_flower_task)
  self:OnAddEventListener()
  self:RefreshUI(TaskInfo, NpcChallengeInfo, isHideRound, is_flower_task)
end

function UMG_AdditionalTargetSilhouette_C:OnDeactive()
  self.CurShow = nil
  self.NpcChallengeInfo = nil
  _G.BattleEventCenter:UnBind(self)
end

function UMG_AdditionalTargetSilhouette_C:InitData(TaskInfo)
  self.dataList = {}
  if TaskInfo then
    for _, one in pairs(TaskInfo) do
      table.insert(self.dataList, {
        extra_reward_id = one.task_id,
        extra_reward_status = one.task_state,
        IsLeader = false
      })
    end
  end
  self.taskList = TaskInfo
end

function UMG_AdditionalTargetSilhouette_C:RefreshUI(TaskInfo, NpcChallengeInfo, isHideRound, is_flower_task)
  self.isHideRound = isHideRound
  self.CurShow = true
  self.NpcChallengeInfo = NpcChallengeInfo
  self:PlayAnimation(self.In)
  self:InitData(TaskInfo)
  self.List:InitGridView(self.dataList)
  if is_flower_task then
    self.NumberOfRounds:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.CharacterButton:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.TextTitle:SetText(_G.DataConfigManager:GetLocalizationConf("Activity_FlowerHard_BattleTask").msg)
  else
    local curRound = _G.BattleManager:GetCurRound()
    self:UpdateCurRound(curRound)
    local IsBattle = _G.NRCModuleManager:DoCmd(BattleModuleCmd.IsInBattle)
    if not IsBattle and BattleBossChallengeUtils.IsInLeaderChallengeDungeon() then
      self.NumberOfRounds:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.NumberOfRounds:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    self.TextTitle:SetText(_G.DataConfigManager:GetLocalizationConf("challenge_text_24").msg)
  end
end

function UMG_AdditionalTargetSilhouette_C:UpdateCurRound(CurRound)
  if self.Quantity then
    self.Quantity:SetText(CurRound)
  end
end

function UMG_AdditionalTargetSilhouette_C:OnAddEventListener()
  _G.BattleEventCenter:Bind(self, BattleEvent.Replay_RefreshRoundIdx, BattleEvent.START_BATTLE_PERFORM)
end

function UMG_AdditionalTargetSilhouette_C:OnTick()
end

function UMG_AdditionalTargetSilhouette_C:OnLogin()
end

function UMG_AdditionalTargetSilhouette_C:OnConstruct()
end

function UMG_AdditionalTargetSilhouette_C:OnDestruct()
end

function UMG_AdditionalTargetSilhouette_C:OnAnimationFinished(anim)
end

function UMG_AdditionalTargetSilhouette_C:UpdateBattleTasks(perform_player, data)
  if data and data.perform_info then
    for _, info in pairs(data.perform_info) do
      if info.sync_data and info.sync_data.task_infos then
        _G.BattleManager.battleRuntimeData:UpdateBattleTasks(info.sync_data.task_infos)
        local battle_tasks = _G.BattleManager.battleRuntimeData:GetBattleTasks()
        self:InitData(battle_tasks)
        if UE4.UObject.IsValid(self.List) then
          self.List:Clear()
          self.List:InitGridView(self.dataList)
        end
        break
      end
    end
  end
end

function UMG_AdditionalTargetSilhouette_C:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.Replay_RefreshRoundIdx then
    self:UpdateCurRound(...)
  elseif eventName == BattleEvent.START_BATTLE_PERFORM then
    self:UpdateBattleTasks(...)
  end
end

function UMG_AdditionalTargetSilhouette_C:Hide()
  if self.CurShow then
    self.CurShow = false
    self:PlayAnimation(self.Out)
  end
end

return UMG_AdditionalTargetSilhouette_C
