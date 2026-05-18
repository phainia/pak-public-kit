local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_Base_C")
local UMG_Activity_SpeedUpHatching_C = Base:Extend("UMG_Activity_SpeedUpHatching_C")

function UMG_Activity_SpeedUpHatching_C:BindUIElements()
  local uiElements = {}
  uiElements.bgImage = self.BG
  uiElements.particularsBtn = self.BtnParticulars
  uiElements.timeRemaining = self.Text_TimeRemaining
  uiElements.openAnimName = "Open"
  uiElements.changeAnimName = "Change"
  uiElements.closeAnimName = "Close"
  return uiElements
end

function UMG_Activity_SpeedUpHatching_C:OnConstruct()
  Base.OnConstruct(self)
  self.ViewBtn.btnLevelUp.OnClicked:Add(self, self.ViewBtnClick)
  self.RetrospectBtn.btnLevelUp.OnClicked:Add(self, self.RetrospectBtnClick)
  local activityConf = self.activityInst.activityConf
  local HatchingConf = _G.DataConfigManager:GetActivityConf(activityConf.id)
  self.Text_Title:SetText(HatchingConf.activity_name)
  self.Text_Describe:SetText(HatchingConf.prompt_text)
  self.ViewBtn.RedDot:SetupKey(366, {
    activityConf.id
  })
end

function UMG_Activity_SpeedUpHatching_C:OnDestruct()
  self.ViewBtn.btnLevelUp.OnClicked:Remove(self, self.ViewBtnClick)
  self.RetrospectBtn.btnLevelUp.OnClicked:Remove(self, self.RetrospectBtnClick)
  Base.OnDestruct(self)
end

function UMG_Activity_SpeedUpHatching_C:OnEnable(firstLoad)
  if firstLoad then
    self:PlayAnimation(self.Open)
  else
    self:PlayAnimation(self.Change)
  end
end

function UMG_Activity_SpeedUpHatching_C:ViewBtnClick()
  _G.NRCAudioManager:PlaySound2DAuto(1327, "UMG_Activity_SpeedUpHatching_C:ViewBtnClick")
  if 0 ~= self.activityInst:GetActivityTimeLeft() then
    local eggList = _G.DataModelMgr.PlayerDataModel:GetPlayerBackpackEggInfo()
    local eggGid
    if eggList and #eggList > 0 then
      eggGid = eggList[1].gid
    end
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPetHatchingPanel, eggGid)
  else
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.DataConfigManager:GetLocalizationConf("activity_expired_interaction_tip").msg)
  end
end

function UMG_Activity_SpeedUpHatching_C:RetrospectBtnClick()
  _G.NRCAudioManager:PlaySound2DAuto(1078, "UMG_Activity_SpeedUpHatching_C:RetrospectBtnClick")
  if 0 ~= self.activityInst:GetActivityTimeLeft() then
    self.activityInst:ReqGetPlayerActivityData()
    Base.DelaySeconds(self, 0.1, function()
      local svrActivityData = self.activityInst.svrActivityData
      if svrActivityData and svrActivityData.up_data and svrActivityData.up_data.hatch_up_stats then
        _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPetHatchingReview, self.activityInst)
      else
        _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.DataConfigManager:GetLocalizationConf("hatch_weekend_no_logging_tips").msg)
      end
    end)
  else
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.DataConfigManager:GetLocalizationConf("activity_expired_interaction_tip").msg)
  end
end

return UMG_Activity_SpeedUpHatching_C
