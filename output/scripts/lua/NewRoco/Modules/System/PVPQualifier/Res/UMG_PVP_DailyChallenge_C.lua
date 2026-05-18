local PVPRankedMatchModuleUtils = require("NewRoco.Modules.System.PVPQualifier.PVPRankedMatchModuleUtils")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local UMG_PVP_DailyChallenge_C = _G.NRCPanelBase:Extend("UMG_PVP_DailyChallenge_C")

function UMG_PVP_DailyChallenge_C:OnActive()
  self:OnAddEventListener()
  self:InitData()
  self:RefreshUI()
  self:SetCommonPopUpInfo()
end

function UMG_PVP_DailyChallenge_C:SetCommonPopUpInfo()
  local curWeekWinCount, requireWinCount = _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.CmdGetCurWeekWinCount)
  local seasonStep = self.data:GetCurSeasonStep()
  local timeStr = ""
  if seasonStep == ProtoEnum.PVP_RANK_STEP.STEP_PK then
    timeStr = string.format(_G.DataConfigManager:GetBattleGlobalConfig("pvp_rank_character7").str, curWeekWinCount, requireWinCount, PVPRankedMatchModuleUtils.GetWeekRefreshRemainTimeStr())
  else
  end
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.Call = self
  CommonPopUpData.Desc = timeStr
  CommonPopUpData.ClosePanelHandler = self.OnClickCloseBtn
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  self.PopUp1:SetPanelInfo(CommonPopUpData)
end

function UMG_PVP_DailyChallenge_C:OnDeactive()
end

function UMG_PVP_DailyChallenge_C:OnAddEventListener()
end

function UMG_PVP_DailyChallenge_C:OnLogin()
end

function UMG_PVP_DailyChallenge_C:OnConstruct()
  self:SetChildViews(self.PopUp1)
end

function UMG_PVP_DailyChallenge_C:OnDestruct()
end

function UMG_PVP_DailyChallenge_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

function UMG_PVP_DailyChallenge_C:OnClickCloseBtn()
  self:LoadAnimation(2)
end

function UMG_PVP_DailyChallenge_C:InitData()
  self.data = self.module:GetData("PVPRankedMatchModuleData")
  self.dataList = self.data:GetCurWeekReward()
end

function UMG_PVP_DailyChallenge_C:RefreshUI()
  if not self.dataList then
    return
  end
  self.GridView:InitGridView(self.dataList)
  local weekRefreshTime = self.data:GetCurWeekRefreshTime()
  if not weekRefreshTime then
    return
  end
  local curTime = os.msTime()
  local remainTime = weekRefreshTime - curTime
  local str = ActivityUtils.GetTimeFormatStr(remainTime)
  local Conf = _G.DataConfigManager:GetBattleGlobalConfig("pvp_rank_character6")
  local weekWinCount = self.data:GetCurWeekWinCount()
  local weekWinCountRequired = self.data:GetCurWeekWinCountRequired()
  string.format(Conf.str, weekWinCount, weekWinCountRequired)
  self:LoadAnimation(0)
end

return UMG_PVP_DailyChallenge_C
