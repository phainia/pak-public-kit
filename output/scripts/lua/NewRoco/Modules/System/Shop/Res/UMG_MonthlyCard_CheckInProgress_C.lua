local UMG_MonthlyCard_CheckInProgress_C = _G.NRCPanelBase:Extend("UMG_MonthlyCard_CheckInProgress_C")
local ShopModuleEvent = require("NewRoco.Modules.System.Shop.ShopModuleEvent")

function UMG_MonthlyCard_CheckInProgress_C:OnConstruct()
  self:SetChildViews(self.PopUp1)
  local clientMonthCardConf = _G.NRCModuleManager:DoCmd(_G.ShopModuleCmd.OnCmdGetClientMonthCardConf)
  do
    local signRewardItems = {}
    for _needDays, _rewardId in pairs(clientMonthCardConf.signRewards) do
      local _item = {}
      _item.needDays = _needDays
      _item.rewardId = _rewardId
      table.insert(signRewardItems, _item)
    end
    table.sort(signRewardItems, function(a, b)
      return a.needDays < b.needDays
    end)
    self.StageRewards:InitGridView(signRewardItems)
  end
  self:OnAddEventListener()
end

function UMG_MonthlyCard_CheckInProgress_C:OnActive()
  _G.NRCAudioManager:PlaySound2DAuto(1220002025, "UMG_MonthlyCard_CheckInProgress_C:OnActive")
  self:RegisterEvent(self, ShopModuleEvent.RefreshMonthCardData, self.OnRefreshMonthCardData)
  self:SetCommonPopUpInfo()
  local monthCardData = _G.NRCModuleManager:DoCmd(_G.ShopModuleCmd.OnCmdGetMonthCardData)
  self:OnRefreshMonthCardData(monthCardData)
  self:LoadAnimation(0)
  self:BindInputAction()
end

function UMG_MonthlyCard_CheckInProgress_C:SetCommonPopUpInfo()
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.TitleText = _G.LuaText.YueKa_Sec_Interface_Title
  CommonPopUpData.Desc = string.format(_G.LuaText.YueKa_Sec_Interface_SubTitle, 0)
  CommonPopUpData.Call = self
  CommonPopUpData.ClosePanelHandler = self.OnClickbtnCloseRenamePanel
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  self.PopUp1:SetPanelInfo(CommonPopUpData)
end

function UMG_MonthlyCard_CheckInProgress_C:OnDeactive()
  _G.NRCAudioManager:PlaySound2DAuto(1220002017, "UMG_MonthlyCard_CheckInProgress_C:OnDeactive")
  self:UnRegisterEvent(self, ShopModuleEvent.RefreshMonthCardData)
  self:LoadAnimation(2)
end

function UMG_MonthlyCard_CheckInProgress_C:OnAddEventListener()
end

function UMG_MonthlyCard_CheckInProgress_C:OnClickbtnCloseRenamePanel()
  self:LoadAnimation(2)
end

function UMG_MonthlyCard_CheckInProgress_C:OnRefreshMonthCardData(_monthCardData)
  if not _monthCardData then
    return
  end
  local clientMonthCardConf = _G.NRCModuleManager:DoCmd(_G.ShopModuleCmd.OnCmdGetClientMonthCardConf)
  local signDays = _monthCardData.sign_days or 0
  local maxSignDay = clientMonthCardConf.maxSignDay
  if 0 == maxSignDay then
    self.ProgressBar:SetPercent(0)
  else
    if signDays > maxSignDay then
      signDays = (signDays - 1) % maxSignDay + 1
    end
    local specialSignDays = signDays
    local specialScale = 2.2
    if specialSignDays <= 5 then
      specialSignDays = specialSignDays / specialScale
    else
      specialSignDays = 5 / specialScale + (maxSignDay - 5 / specialScale) * ((specialSignDays - 5) / (maxSignDay - 5))
    end
    self.ProgressBar:SetPercent(specialSignDays / maxSignDay)
  end
  local stageRewardCnt = self.StageRewards:GetItemCount()
  for i = 1, stageRewardCnt do
    self.StageRewards:OpItemByIndex(i, signDays)
  end
  self.PopUp1:SetDescInfo(string.format(_G.LuaText.YueKa_Sec_Interface_SubTitle, signDays))
end

function UMG_MonthlyCard_CheckInProgress_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(0) then
    self:LoadAnimation(1)
  elseif anim == self:GetAnimByIndex(2) then
    _G.NRCModuleManager:DoCmd(ShopModuleCmd.OnCmdCloseMonthlyCardCheckInProgress)
  end
end

function UMG_MonthlyCard_CheckInProgress_C:BindInputAction()
  local mappingContext = self:AddInputMappingContext("IMC_MonthlyCardCheckInProgress")
  if mappingContext then
    mappingContext:BindAction("IA_CloseMonthlyCardCheckInProgress", self, "OnPcClose2")
  end
end

function UMG_MonthlyCard_CheckInProgress_C:OnPcClose2()
  self:OnClickbtnCloseRenamePanel()
end

return UMG_MonthlyCard_CheckInProgress_C
