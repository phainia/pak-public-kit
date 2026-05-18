local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattlePlayAnimBaseAction = require("NewRoco.Modules.Core.Battle.Fsm.Actions.Base.BattlePlayAnimBaseAction")
local BattleShowTeamBattleResultUIAction = BattlePlayAnimBaseAction:Extend("BattleShowTeamBattleResultUIAction")
local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")

function BattleShowTeamBattleResultUIAction:OnEnter()
  self.BattleManager = _G.BattleManager
  _G.BattleEventCenter:Bind(self, BattleEvent.CLICKED_Result_Close, BattleEvent.PET_SPAWNED)
  self.Boss = BattleManager.battlePawnManager:GetTeamPet(BattleEnum.Team.ENUM_ENEMY, 1)
  local catchPet = self:GetCatchPetId()
  if self.Boss and catchPet and self.Boss.card.petBaseConf and catchPet ~= self.Boss.card.petBaseConf.id then
    self.Boss.card:RefreshByInfoAndBaseConf(self.Boss.card.petInfo, catchPet)
    BattleManager.battlePawnManager:PawnPet(self.Boss.teamEnm, self.Boss.team, self.Boss.card, self.Boss.player, false, true)
    return
  end
  self:OpenUI()
end

function BattleShowTeamBattleResultUIAction:GetCatchPetId()
  local RewardData = _G.BattleManager.battleRuntimeData.battleSettleData:BattleRewardData()
  if RewardData and RewardData.rewards and #RewardData.rewards > 0 then
    for _, v in pairs(RewardData.rewards) do
      if v.type == ProtoEnum.GoodsType.GT_PET and v.pet_data then
        return v.pet_data.base_conf_id
      end
    end
  end
end

function BattleShowTeamBattleResultUIAction:OnPawnNewPetFinish(pet)
  if self.Boss then
    self.Boss:OnRecall()
  end
  self.Boss = pet
  self.Boss:SetScale(1)
  self.Boss:ShowPet()
  self:OpenUI()
end

function BattleShowTeamBattleResultUIAction:OpenUI()
  if BattleUtils.IsReplayMode() then
    self.replayClickCloseDelay = _G.DelayManager:DelaySeconds(5, function()
      _G.BattleEventCenter:Dispatch(BattleEvent.CLICKED_Result_Close)
    end)
  end
  if BattleUtils.IsBloodTeam() then
    if self:GetCatchPetId() then
      self:PlaySkill()
    else
      self:CloseResult()
    end
  elseif BattleUtils.IsBeastTeam() then
    if _G.BattleManager.battleRuntimeData.battleExitParam.IsCatchSuccess then
      if self:GetCatchPetId() then
        self:PlaySkill()
      else
        self:CloseResult()
      end
    else
      self:CloseResult()
    end
  end
end

function BattleShowTeamBattleResultUIAction:HideAllTeammate()
  local teams = BattleManager.battlePawnManager:GetAllTeam(BattleEnum.Team.ENUM_TEAM) or {}
  for _, team in pairs(teams) do
    if team.player then
      team.player:ClearSkill()
      team.player:HidePlayer()
      for _, pet in pairs(team.pets) do
        pet:HidePet()
      end
    end
  end
end

function BattleShowTeamBattleResultUIAction:SafeExit()
  self:CloseResult()
end

function BattleShowTeamBattleResultUIAction:PlaySkill()
  local skillPath = BattleConst.TeamBattleBalance
  if not self.Boss or not self.Boss.model then
    Log.Warning("There is no model in Boss !!!")
    self:CloseResult()
    return
  end
  self:Play(self.Boss, nil, skillPath, true)
end

function BattleShowTeamBattleResultUIAction:SetBossShowPos()
  local BattleCenterTable = UE4.UGameplayStatics.GetAllActorsOfClassWithTag(_G.UE4Helper.GetCurrentWorld(), UE4.AActor, "CW_TeamShowUi"):ToTable()
  if BattleCenterTable and #BattleCenterTable > 0 then
    local BattleCenter = BattleCenterTable[1]
    local location = BattleCenter:K2_GetActorLocation()
    location.z = location.z + self.Boss:GetHalfHeight()
    self.Boss.model:K2_SetActorLocation(location, false, nil, false)
    local rotate = BattleCenter:K2_GetActorRotation()
    rotate.Yaw = rotate.Yaw + 90
    self.Boss.model:K2_SetActorRotation(rotate, false)
    self.Boss:PinOnTheGround()
  end
end

function BattleShowTeamBattleResultUIAction:ActionStart()
  if BattleUtils.IsBloodTeam() then
    local RewardData = _G.BattleManager.battleRuntimeData.battleSettleData:BattleRewardData()
    if self:GetCatchPetId() then
      NRCModeManager:DoCmd(BattleUIModuleCmd.OpenPetCatchPanel, true, RewardData, self.BattleManager.battleRuntimeData.battleSettleData:BattleNpcLevel())
    end
  elseif BattleUtils.IsBeastTeam() and _G.BattleManager.battleRuntimeData.battleExitParam.IsCatchSuccess then
    local RewardData = self.BattleManager.battleRuntimeData.battleSettleData:BattleRewardData()
    if self:GetCatchPetId() then
      NRCModuleManager:DoCmd(LegendaryBattleModuleCmd.OpenLegendaryBattleCatchSuccPanel, RewardData, self.BattleManager.battleRuntimeData.battleSettleData:BattleNpcLevel())
    end
  end
  self:HideAllTeammate()
  self:UpdateBossAppearanceAfterCatch(self.BattleManager.battleRuntimeData.battleSettleData:BattleRewardData())
  self.Boss:ShowPet()
  self.Boss:ChangeBuffVisibility(false)
  self.Boss.buffComponent:RemoveBuffs(true)
  self.Boss.buffComponent:ClearBuff()
  self.Boss.card.petState:SetCatchStun(false)
  self.Boss.buffComponent:StopStateEffect(Enum.BuffGroupSign.BGS_CATCHSTUN, true)
  self:SetBossShowPos()
end

function BattleShowTeamBattleResultUIAction:CloseResult(_IsBClose)
  self.Boss = nil
  self._IsBClose = _IsBClose
  self.fsm:Resume()
  self:Finish()
end

function BattleShowTeamBattleResultUIAction:OnFinish()
  BattlePlayAnimBaseAction.OnFinish(self)
  if not self._IsBClose then
    NRCModeManager:DoCmd(BattleUIModuleCmd.OpenPetCatchPanel, false)
    NRCModeManager:DoCmd(LegendaryBattleModuleCmd.CloseLegendaryBattleCatchSuccPanel)
  end
  _G.BattleEventCenter:UnBind(self)
  self.BattleManager = nil
  self._IsBClose = nil
  if self.replayClickCloseDelay then
    _G.DelayManager:CancelDelayById(self.replayClickCloseDelay)
    self.replayClickCloseDelay = nil
  end
end

function BattleShowTeamBattleResultUIAction:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.CLICKED_Result_Close then
    self:CloseResult(true)
    return true
  elseif eventName == BattleEvent.PET_SPAWNED then
    self:OnPawnNewPetFinish(...)
    return true
  end
end

function BattleShowTeamBattleResultUIAction:UpdateBossAppearanceAfterCatch(goodsReward)
  if goodsReward.rewards then
    for _, reward in ipairs(goodsReward.rewards) do
      if reward.type == _G.ProtoEnum.GoodsType.GT_PET then
        PetMutationUtils.DoMutation(self.Boss.model, reward.pet_data)
      end
    end
  end
end

return BattleShowTeamBattleResultUIAction
