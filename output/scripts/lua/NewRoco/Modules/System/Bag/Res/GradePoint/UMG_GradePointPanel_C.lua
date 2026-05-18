local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local UMG_GradePointPanel_C = _G.NRCPanelBase:Extend("UMG_GradePointPanel_C")

function UMG_GradePointPanel_C:OnConstruct()
  self.data = {}
  self.bCloseBtnLock = false
  self.CanSelectItem = true
  self:SetRenderOpacity(0)
end

function UMG_GradePointPanel_C:OnDestruct()
end

function UMG_GradePointPanel_C:OnActive()
  self.NRCSwitcher_0:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.CanSelectItem = true
  self:PlayAnimation(self:GetAnimByIndex(0))
  self:GetGPContestInfo()
  self:OnAddEventListener()
  self.RedDot:SetupKey(390, {
    _G.Enum.ItemLableType.ILT_TASK,
    290025
  })
end

function UMG_GradePointPanel_C:OnDeactive()
end

function UMG_GradePointPanel_C:GetGPContestInfo()
  local req = _G.ProtoMessage:newZoneGetPlayerGpContestInfoReq()
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_GET_PLAYER_GP_CONTEST_INFO_REQ, req, self, self.GetGPContestInfoRsp, false, false)
end

function UMG_GradePointPanel_C:GetGPContestInfoRsp(rsp)
  if 0 == rsp.ret_info.ret_code then
    self.data = rsp.gp_contest_info
    self:SetMainInfo()
    self:SetRenderOpacity(1)
  else
    Log.Error("\232\142\183\229\143\150\231\187\169\231\130\185\229\164\167\232\181\155\228\191\161\230\129\175\229\164\177\232\180\165\228\186\134\239\188\129\239\188\129\239\188\129")
  end
end

function UMG_GradePointPanel_C:SetMainInfo()
  if self.data.gp_contest_rank_id and self.data.gp_contest_state then
    self.gpContestRankId = self.data.gp_contest_rank_id
    self.gpContestState = self.data.gp_contest_state
    self.FinalRewardId = _G.DataConfigManager:GetRoleGlobalConfig("gp_contest_reward_conf_id").num
    local rewardList = _G.DataConfigManager:GetRewardConf(self.FinalRewardId).RewardItem
    local gpContestConf = _G.DataConfigManager:GetGpContestConf(self.gpContestRankId)
    local rewardsTable = self:SetRewards(rewardList)
    if self.gpContestState == ProtoEnum.PlayerGPContestInfo.GPContestState.GPCS_OPEN then
      self.Label_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self:SetRankListInfo(gpContestConf)
      self:SetUpRewardItemOpen(rewardsTable)
    elseif self.gpContestState == ProtoEnum.PlayerGPContestInfo.GPContestState.GPCS_REWARD then
      self.Label_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self:SetRankListInfo(gpContestConf)
      self:SetUpRewardItemOpen(rewardsTable)
      self:PlayAnimation(self.Available, 0, 0)
      self.Mask_4:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Mask_5:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    elseif self.gpContestState == ProtoEnum.PlayerGPContestInfo.GPContestState.GPCS_DONE then
      self.Label_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Mask_3:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Mask_4:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Mask_5:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Claimed:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self:PlayAnimation(self.ReceiveAward2)
      self:SetRankListInfo(gpContestConf)
      self:SetUpRewardItemOpen(rewardsTable)
    end
  else
    self.gpContestState = ProtoEnum.PlayerGPContestInfo.GPContestState.GPCS_NONE
    self.FinalRewardId = _G.DataConfigManager:GetRoleGlobalConfig("gp_contest_reward_conf_id").num
    local rewardList = _G.DataConfigManager:GetRewardConf(self.FinalRewardId).RewardItem
    local rewardsTable = self:SetRewards(rewardList)
    self.Label:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:SetUpRewardItemOpen(rewardsTable)
  end
  self:UpdateRewardList()
  self:UpdateGradePoint()
end

function UMG_GradePointPanel_C:SetUpRewardItemOpen(rewardsTable)
  local iconPath = ""
  if rewardsTable[2] then
    self.FinalItemType = rewardsTable[2].itemType
    if self.FinalItemType == _G.Enum.GoodsType.GT_VITEM then
      self.FinalItemId = rewardsTable[2].itemId
      local vItemConf = _G.DataConfigManager:GetVisualItemConf(self.FinalItemId)
      if nil ~= vItemConf then
        self:SetQualityOpen(vItemConf.item_quality)
        iconPath = vItemConf.bigIcon
      end
      if rewardsTable[2].gpContestState == ProtoEnum.PlayerGPContestInfo.GPContestState.GPCS_REWARD and 2 == rewardsTable[2].index then
        self:PlayAnimation(self.ReceiveAward2)
        self.hasRewardCollect = true
      end
      self.Icon_3:SetPath(iconPath)
      self.Icon_3:SetBrushSize(UE4.FVector2D(256, 256))
    elseif self.FinalItemType == _G.Enum.GoodsType.GT_BAGITEM then
      self.FinalItemId = rewardsTable[2].itemId
      local bagItemConf = _G.DataConfigManager:GetBagItemConf(self.FinalItemId)
      if nil ~= bagItemConf then
        self:SetQualityOpen(bagItemConf.item_quality)
        if bagItemConf.big_icon then
          iconPath = bagItemConf.big_icon
        else
          iconPath = bagItemConf.icon
        end
      end
      if rewardsTable[2].gpContestState == ProtoEnum.PlayerGPContestInfo.GPContestState.GPCS_REWARD and 2 == rewardsTable[2].index then
        self:PlayAnimation(self.ReceiveAward2)
        self.hasRewardCollect = true
      end
      self.Icon_3:SetPath(iconPath)
      self.Icon_3:SetBrushSize(UE4.FVector2D(256, 256))
    elseif self.FinalItemType == _G.Enum.GoodsType.GT_PET then
      self.FinalItemId = rewardsTable[2].itemId
      local petInfo = _G.DataConfigManager:GetPetConf(self.FinalItemId)
      local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petInfo.base_id)
      if nil ~= petBaseConf then
        local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
        iconPath = modelConf.icon
      end
      if rewardsTable[2].gpContestState == ProtoEnum.PlayerGPContestInfo.GPContestState.GPCS_REWARD and 2 == rewardsTable[2].index then
        self:PlayAnimation(self.ReceiveAward2)
        self.hasRewardCollect = true
      end
      self.Icon_3:SetPath(iconPath)
      self.Icon_3:SetBrushSize(UE4.FVector2D(256, 256))
    elseif self.FinalItemType == _G.Enum.GoodsType.GT_CARD_SKIN then
      self.FinalItemId = rewardsTable[2].itemId
      local cardSkinConf = _G.DataConfigManager:GetCardSkinConf(self.FinalItemId)
      if cardSkinConf then
        self:SetQualityOpen(cardSkinConf.card_quality)
        iconPath = string.format(UEPath.CARD_SKIN_PATH, cardSkinConf.skin_resource_path, cardSkinConf.skin_resource_path)
      end
      if rewardsTable[2].gpContestState == ProtoEnum.PlayerGPContestInfo.GPContestState.GPCS_REWARD and 2 == rewardsTable[2].index then
        self:PlayAnimation(self.ReceiveAward2)
        self.hasRewardCollect = true
      end
      self.Icon_3:SetPath(iconPath)
      self.Icon_3:SetBrushSize(UE4.FVector2D(256, 256))
    end
  end
end

function UMG_GradePointPanel_C:SetQualityOpen(quality)
  if 1 == quality then
    self.Color_3:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_1))
  elseif 2 == quality then
    self.Color_3:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_2))
  elseif 3 == quality then
    self.Color_3:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_3))
  elseif 4 == quality then
    self.Color_3:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_4))
  elseif 5 == quality then
    self.Color_3:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_5))
  end
end

function UMG_GradePointPanel_C:SetRewards(rewardList)
  local rewardsTable = {}
  for i, rewardItem in ipairs(rewardList) do
    local reward = _G.NRCCommonItemIconData()
    reward.itemType = rewardItem.Type
    reward.itemId = rewardItem.Id
    reward.gpContestState = self.gpContestState
    reward.index = i
    table.insert(rewardsTable, reward)
  end
  return rewardsTable
end

function UMG_GradePointPanel_C:SetRankListInfo(gpContestConf)
  if 0 == gpContestConf.contest_list[1].gp then
    self.Name1:SetText(_G.DataModelMgr.PlayerDataModel:GetPlayerName())
    self.GradePoint1:SetText(self.data.gp_num_add)
  else
    self.Name1:SetText(gpContestConf.contest_list[1].name)
    self.GradePoint1:SetText(gpContestConf.contest_list[1].gp)
  end
  if 0 == gpContestConf.contest_list[2].gp then
    self.Name2:SetText(_G.DataModelMgr.PlayerDataModel:GetPlayerName())
    self.GradePoint2:SetText(self.data.gp_num_add)
  else
    self.Name2:SetText(gpContestConf.contest_list[2].name)
    self.GradePoint2:SetText(gpContestConf.contest_list[2].gp)
  end
  if 0 == gpContestConf.contest_list[3].gp then
    self.Name3:SetText(_G.DataModelMgr.PlayerDataModel:GetPlayerName())
    self.GradePoint3:SetText(self.data.gp_num_add)
  else
    self.Name3:SetText(gpContestConf.contest_list[3].name)
    self.GradePoint3:SetText(gpContestConf.contest_list[3].gp)
  end
end

function UMG_GradePointPanel_C:OnAddEventListener()
  self:AddButtonListener(self.Button, self.ClaimReward)
  self:AddButtonListener(self.btnCloseRenamePanel, self.ClosePanel)
end

function UMG_GradePointPanel_C:ClosePanel()
  if self.bCloseBtnLock == false then
    self.bCloseBtnLock = true
    self:PlayAnimation(self:GetAnimByIndex(2))
  end
end

function UMG_GradePointPanel_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(2) then
    self.bCloseBtnLock = false
    self:DoClose()
  end
end

function UMG_GradePointPanel_C:ClaimReward()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(41401006, "UMG_GradePointPanel_C:ClaimReward")
  if self.hasRewardCollect then
    _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.ReceiveGpContestRewardReq, {final = true})
  else
    _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.Tips_OpenItemTips, self.FinalItemId, self.FinalItemType)
  end
end

function UMG_GradePointPanel_C:UpdateRewardList()
  local rewardList = _G.DataConfigManager:GetTaskGlobalConfig("gp_rank_list").numList
  local resultList = {}
  for _, rewardId in ipairs(rewardList) do
    table.insert(resultList, {rewardId = rewardId, parent = self})
  end
  self.StageRewards:InitGridView(resultList)
end

function UMG_GradePointPanel_C:UpdateGradePoint()
  local curGrade = 0
  if self.data.gp_num_add then
    curGrade = self.data.gp_num_add
  end
  local maxGrade = _G.DataConfigManager:GetTaskGlobalConfig("gp_rank_list_total").num
  self.ProgressBar:SetPercent(curGrade / maxGrade)
  self.SuitName_7:SetText(string.format("\231\187\169\231\130\185:%d", curGrade))
end

function UMG_GradePointPanel_C:GetRewardRefresh(isGetFinalReward)
  if isGetFinalReward then
    ActivityUtils.ShowRewardGetTips(self.FinalRewardId)
    self.hasRewardCollect = false
    self:StopAllAnimations()
    self.Claimed:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Mask_3:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    _G.NRCModuleManager:DoCmd(BagModuleCmd.ShowGradePointLabel_1)
  else
    local item = self.StageRewards:GetItemByIndex(self.SelectIndex - 1)
    ActivityUtils.ShowRewardGetTips(item.RewardId)
    item:UpdateRewardState()
    self.CanSelectItem = true
  end
end

function UMG_GradePointPanel_C:GetAddGradeReward(index)
  self.CanSelectItem = false
  self.SelectIndex = index
  _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.ReceiveGpContestRewardReq, {seq = index})
end

return UMG_GradePointPanel_C
