local TeamBattleModuleEvent = require("NewRoco.Modules.System.TeamBattle.TeamBattleModuleEvent")
local BagModuleEvent = require("NewRoco.Modules.System.Bag.BagModuleEvent")
local UIUtils = require("NewRoco.Utils.UIUtils")
local TeamBattleModuleEnum = require("NewRoco.Modules.System.TeamBattle.TeamBattleModuleEnum")
local UMG_PrewarConfirmation_C = _G.NRCPanelBase:Extend("UMG_PrewarConfirmation_C")

function UMG_PrewarConfirmation_C:OnActive(challengeType, challengeInfo, tips)
  UE4Helper.SetDesiredShowCursor(true, "UMG_PrewarConfirmation_C")
  self.uiData = challengeInfo
  self.challengeType = challengeType
  self.showTips = tips
  self.module.CurChallengeType = self.challengeType
  self:UpdatePanelInfo(challengeInfo)
  self:SetCommonPopUpInfo()
end

function UMG_PrewarConfirmation_C:OnDeactive()
  UE4Helper.ReleaseDesiredShowCursor("UMG_PrewarConfirmation_C")
end

function UMG_PrewarConfirmation_C:OnAddEventListener()
  self:RegisterEvent(self, TeamBattleModuleEvent.StarNumChange, self.UpdateHealth)
  _G.NRCEventCenter:RegisterEvent("UMG_PrewarConfirmation_C", self, BagModuleEvent.OnMoneyBtnClick, self.OnMoneyBtnClick)
end

function UMG_PrewarConfirmation_C:OnRemoveEventListener()
  self:UnRegisterEvent(self, TeamBattleModuleEvent.StarNumChange, self.UpdateHealth)
  _G.NRCEventCenter:UnRegisterEvent(self, BagModuleEvent.OnMoneyBtnClick, self.OnMoneyBtnClick)
end

function UMG_PrewarConfirmation_C:OnConstruct()
  self:SetChildViews(self.PopUp3)
  self.data = self.module:GetData("TeamBattleModuleData")
  self:OnAddEventListener()
  self.NeedStarChainNum = _G.DataConfigManager:GetGlobalConfigByKeyType("team_battle_starlink", _G.DataConfigManager.ConfigTableId.PET_GLOBAL_CONFIG).num
  _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.AddCondition, Enum.PlayerConditionType.PCT_UI, "PreWarConfirmation")
end

function UMG_PrewarConfirmation_C:OnDestruct()
  self:OnRemoveEventListener()
  _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.RemoveCondition, Enum.PlayerConditionType.PCT_UI, "PreWarConfirmation")
end

function UMG_PrewarConfirmation_C:SetCommonPopUpInfo()
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.OnCancelBtnClicked
  CommonPopUpData.Btn_RightHandler = self.OnConfirmBtnClicked
  CommonPopUpData.ClosePanelHandler = self.OnCancelBtnClicked
  self.PopUp3:SetPanelInfo(CommonPopUpData)
end

function UMG_PrewarConfirmation_C:OnCancelBtnClicked()
  local bVisit = _G.DataModelMgr.PlayerDataModel:IsVisitState()
  if bVisit and self.challengeType ~= _G.ProtoEnum.TeamBattleChallengeType.TBCT_BLOOD_SINGLE and self.challengeType ~= _G.ProtoEnum.TeamBattleChallengeType.TBCT_BEAST_SINGLE then
    local bOwner = _G.DataModelMgr.PlayerDataModel:IsVisitOwner()
    if not bOwner then
      self.module:OnZoneTeamBattleConfirmInviteReq(false)
    end
  end
  self.module:ClosePanel("PreWarInformation")
  self:OnClose()
end

function UMG_PrewarConfirmation_C:OnConfirmBtnClicked()
  if self.challengeType == _G.ProtoEnum.TeamBattleChallengeType.TBCT_BLOOD_SINGLE then
    self.module:OnSendZoneTeamBattleChallengeReq(self.data:GetCurNPCActorId(), self.data.TargetNPCLogicId, _G.ProtoEnum.TeamBattleChallengeType.TBCT_BLOOD_SINGLE, nil, self.data.module.teamBattleInfo.blood)
  elseif self.challengeType == _G.ProtoEnum.TeamBattleChallengeType.TBCT_BEAST_SINGLE then
    self.module:OnSendZoneTeamBattleChallengeReq(self.uiData.actorId, self.uiData.logicId, _G.ProtoEnum.TeamBattleChallengeType.TBCT_BEAST_SINGLE, {
      battleId = self.uiData.battleId,
      starNum = self.uiData.starNum
    })
  else
    local bOwner = _G.DataModelMgr.PlayerDataModel:IsVisitOwner()
    if bOwner then
      if self.challengeType == _G.ProtoEnum.TeamBattleChallengeType.TBCT_BLOOD_TEAM then
        self.module:OnCmdOpenTeamBattleStartConfirmTips()
      elseif self.challengeType == _G.ProtoEnum.TeamBattleChallengeType.TBCT_BEAST then
        if self.uiData.bMatch == true then
          _G.NRCModuleManager:DoCmd(LegendaryBattleModuleCmd.OnSendZoneBeastStartMatchReq, self.uiData.battleId, self.uiData.starNum)
        else
          self.module:OnSendZoneTeamBattleChallengeReq(self.uiData.actorId, self.uiData.logicId, self.challengeType, {
            battleId = self.uiData.battleId,
            starNum = self.uiData.starNum
          })
        end
      end
    else
      local bInVisit = _G.DataModelMgr.PlayerDataModel:IsVisitState()
      if bInVisit then
        self.module:OnZoneTeamBattleConfirmInviteReq(true)
      else
        _G.NRCModuleManager:DoCmd(LegendaryBattleModuleCmd.OnSendZoneBeastStartMatchReq, self.uiData.battleId, self.uiData.starNum)
      end
    end
  end
  self.module:ClosePanel("PreWarInformation")
  self:DoClose()
end

function UMG_PrewarConfirmation_C:OnMoneyBtnClick(costId)
  Log.Error("UMG_PrewarConfirmation_C:OnMoneyBtnClick", costId)
  if costId == _G.DataConfigManager:GetLegendaryGlobalConfig("beast_challenge_ticket_id").num then
  end
end

function UMG_PrewarConfirmation_C:MoneyBtnHandler()
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_PrewarConfirmation_C:MoneyBtnCallBack()
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_PrewarConfirmation_C:UpdatePanelInfo(EnterCondition)
  self:UpdateHealth()
  if self.challengeType == _G.ProtoEnum.TeamBattleChallengeType.TBCT_BLOOD_TEAM or self.challengeType == _G.ProtoEnum.TeamBattleChallengeType.TBCT_BLOOD_SINGLE then
    if EnterCondition == TeamBattleModuleEnum.EnterConditionState.None then
      local showTip = _G.DataConfigManager:GetGlobalConfigByKeyType("team_battle_no_star_ball", _G.DataConfigManager.ConfigTableId.PET_GLOBAL_CONFIG).str
      local curStarNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_STAR)
      self.ContentText:SetText(string.format(showTip, tostring(self.NeedStarChainNum), tostring(curStarNum)))
    elseif EnterCondition == TeamBattleModuleEnum.EnterConditionState.OnlyStarChainOK then
      local showTip = _G.DataConfigManager:GetGlobalConfigByKeyType("team_battle_no_ball", _G.DataConfigManager.ConfigTableId.PET_GLOBAL_CONFIG).str
      self.ContentText:SetText(showTip)
    elseif EnterCondition == TeamBattleModuleEnum.EnterConditionState.OnlyBallOK then
      self.ContentText:SetText(LuaText.not_enough_expend)
    end
  elseif self.challengeType == _G.ProtoEnum.TeamBattleChallengeType.TBCT_BEAST or self.challengeType == _G.ProtoEnum.TeamBattleChallengeType.TBCT_BEAST_SINGLE then
    if self.showTips == nil then
      local costItemId, needLegendaryItemNum = _G.NRCModuleManager:DoCmd(_G.LegendaryBattleModuleCmd.GetLegendaryTicketIDAndNum)
      local needLegendaryItemNum1 = _G.DataConfigManager:GetLegendaryGlobalConfig("star_consume").num
      local checkCoinInfos = {
        {
          UIUtils.CheckCoinType.CI_BagItem,
          costItemId,
          needLegendaryItemNum
        },
        {
          UIUtils.CheckCoinType.CI_VisualItem,
          Enum.VisualItem.VI_STAR,
          needLegendaryItemNum1
        }
      }
      local enoughCoinTable = UIUtils.CheckEnterCondition(checkCoinInfos)
      local tip = ""
      local leftChallengeTimes, totalChallengeTimes = _G.NRCModuleManager:DoCmd(_G.LegendaryBattleModuleCmd.GetChallengeTimes)
      local bagItemConf = _G.DataConfigManager:GetBagItemConf(costItemId)
      local name = ""
      if bagItemConf then
        name = bagItemConf.name
      end
      if leftChallengeTimes > 0 then
        if 0 == #enoughCoinTable then
          local msg = _G.DataConfigManager:GetLocalizationConf("legendary_battle_tips_13").msg
          tip = string.format(msg, name)
        elseif #enoughCoinTable < 2 then
          for k, v in ipairs(enoughCoinTable) do
            if v.CheckType == UIUtils.CheckCoinType.CI_BagItem then
              local msg = _G.DataConfigManager:GetLocalizationConf("legendary_battle_tips_12").msg
              tip = string.format(msg, name)
            end
          end
        end
      else
        local bEnough = false
        for k, v in ipairs(enoughCoinTable) do
          if v.CheckType == UIUtils.CheckCoinType.CI_BagItem then
            bEnough = true
          end
        end
        if not bEnough then
          local tip1 = _G.DataConfigManager:GetLocalizationConf("legendary_battle_tips_5").msg
          tip = string.format(tip1, bagItemConf.name)
        end
      end
      self.ContentText:SetText(tip)
    else
      self.ContentText:SetText(self.showTips)
    end
  end
end

function UMG_PrewarConfirmation_C:UpdateHealth()
  if self.challengeType == _G.ProtoEnum.TeamBattleChallengeType.TBCT_BLOOD_TEAM or self.challengeType == _G.ProtoEnum.TeamBattleChallengeType.TBCT_BLOOD_SINGLE then
    local moneyNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_STAR)
    local stamina = _G.DataConfigManager:GetRoleGlobalConfig("star_top_limit")
    local StaminaProportion = string.format("%s%s%s", moneyNum, "/", stamina.num)
    local debrisNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_STAR_DEBRIS)
    local debrisProportion = string.format("%s%s%s", debrisNum, "/", stamina.num)
    local moneyInfo = {
      {
        moneyType = _G.Enum.VisualItem.VI_STAR,
        sum = StaminaProportion,
        IsShowBuyIcon = true,
        Call = self,
        Handler = self.MoneyBtnHandler,
        SourceReturnFlag = self,
        SourceReturnFunc = self.MoneyBtnCallBack
      },
      {
        moneyType = _G.Enum.VisualItem.VI_STAR_DEBRIS,
        sum = debrisProportion,
        IsShowBuyIcon = true,
        Call = self,
        Handler = self.MoneyBtnHandler,
        SourceReturnFlag = self,
        SourceReturnFunc = self.MoneyBtnCallBack
      }
    }
    self.MoneyBtn:InitGridView(moneyInfo)
  elseif self.challengeType == _G.ProtoEnum.TeamBattleChallengeType.TBCT_BEAST or self.challengeType == _G.ProtoEnum.TeamBattleChallengeType.TBCT_BEAST_SINGLE then
    local costItemId, _ = _G.NRCModuleManager:DoCmd(_G.LegendaryBattleModuleCmd.GetLegendaryTicketIDAndNum)
    local itemConf = _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.GetBagItemByID, costItemId)
    local starNum = 0
    if nil == itemConf then
      starNum = 0
    else
      starNum = itemConf.num
    end
    local moneyNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_STAR)
    local moneyInfo = {
      {
        moneyType = _G.Enum.VisualItem.VI_STAR,
        sum = moneyNum,
        IsShowBuyIcon = true,
        Call = self,
        Handler = self.MoneyBtnHandler,
        SourceReturnFlag = self,
        SourceReturnFunc = self.MoneyBtnCallBack
      },
      {
        moneyType = costItemId,
        sum = starNum,
        IsShowBuyIcon = true,
        bLegendary = true,
        Call = self,
        Handler = self.MoneyBtnHandler,
        SourceReturnFlag = self,
        SourceReturnFunc = self.MoneyBtnCallBack
      }
    }
    self.MoneyBtn:InitGridView(moneyInfo)
  end
end

return UMG_PrewarConfirmation_C
