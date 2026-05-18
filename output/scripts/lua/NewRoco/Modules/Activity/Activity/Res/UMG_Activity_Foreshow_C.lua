local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_Base_C")
local UMG_Activity_Foreshow_C = Base:Extend("UMG_Activity_Foreshow_C")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local PetUtils = require("NewRoco.Utils.PetUtils")

function UMG_Activity_Foreshow_C:BindUIElements()
  local uiElements = {}
  uiElements.desireActivityType = Enum.ActivityType.ATP_COMMON_SHOW
  uiElements.title = self.Text_Title
  uiElements.titleLabelIcon = self.Label
  uiElements.titleLabelText = self.NRCText_61
  uiElements.promptText = self.Text_Describe
  uiElements.bgImage = self.BG
  uiElements.timeRemainingRoot = self.time
  uiElements.timeRemaining = self.Text_TimeRemaining
  uiElements.particularsBtn = self.ParticularsBtn
  uiElements.openAnimName = "In"
  uiElements.changeAnimName = "In"
  uiElements.closeAnimName = "Out"
  return uiElements
end

function UMG_Activity_Foreshow_C:OnConstruct()
  Base.OnConstruct(self)
  if self.GeneralReward then
    self:SetChildViews(self.GeneralReward)
  end
  local _activityInst = self.activityInst
  local petBaseId = _activityInst:GetPetBaseId()
  if petBaseId and 0 ~= petBaseId then
    local petBaseData = _G.DataConfigManager:GetPetbaseConf(petBaseId)
    self.Name:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.TextName:SetText(petBaseData and petBaseData.name or "")
    local petShowParam = _activityInst:GetPetShowParam()
    local showPetBloodId, showPetNatureId
    if petShowParam then
      for _, petShowGroup in ipairs(petShowParam) do
        if petShowGroup.show_type == Enum.ActivityPreviewPetShow.APPS_BLOOD then
          showPetBloodId = petShowGroup.show_param
        elseif petShowGroup.show_type == Enum.ActivityPreviewPetShow.APPS_BLOOD_FLOWER then
          showPetBloodId = ActivityUtils.GetPetBloodIdBySeedId(petShowGroup.show_param)
        elseif petShowGroup.show_type == Enum.ActivityPreviewPetShow.APPS_NATURE then
          showPetNatureId = petShowGroup.show_param
        elseif petShowGroup.show_type == Enum.ActivityPreviewPetShow.APPS_NATURE_FLOWER then
          showPetNatureId = ActivityUtils.GetPetNatureIdBySeedId(petShowGroup.show_param)
        end
      end
    end
    self.showPetNatureId = showPetNatureId
    self.Attr:InitGridView(ActivityUtils.CreatePetCommonAttrListData(petBaseData and petBaseData.unit_type, showPetBloodId, nil, PetUtils.CreateFakePetData(petBaseId)))
    if showPetNatureId and 0 ~= showPetNatureId then
      self.Panel_Character:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      local petNatureConf = _G.DataConfigManager:GetNatureConf(showPetNatureId)
      self.textPetNature:SetText(petNatureConf and petNatureConf.name or "")
    else
      self.Panel_Character:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  else
    self.Name:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  local jumpOptionType, jumpParam1 = _activityInst:GetJumpOption()
  if jumpOptionType and jumpOptionType ~= Enum.ActivityOptionType.AOT_NONE then
    self.TraceBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.TraceBtn:SetBtnText(jumpParam1)
  else
    self.TraceBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.NRCImage_Logo then
    local logoIcon = _activityInst:GetLogoIcon()
    if string.IsNilOrEmpty(logoIcon) then
      self.NRCImage_Logo:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.NRCImage_Logo:SetPath(logoIcon)
      self.NRCImage_Logo:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    end
  end
  if self.GeneralReward then
    local rewards = _activityInst:GetRewardPreview()
    if #rewards > 0 then
      local rewardData = {}
      rewardData.itemDataTemplate = {}
      rewardData.itemDataTemplate.bShowNum = true
      rewardData.itemDataTemplate.bShowTip = true
      rewardData.itemList = {}
      for _, rewardId in ipairs(rewards) do
        local _data = {}
        _data.itemType = _G.Enum.GoodsType.GT_BAGITEM
        _data.itemId = rewardId
        _data.itemNum = 1
        table.insert(rewardData.itemList, _data)
      end
      self.GeneralReward:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.GeneralReward:SetData(rewardData)
    else
      self.GeneralReward:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  self:AddButtonListener(self.ExamineBtn, self.OnClickShowPetData)
  self:AddButtonListener(self.NRCButton_43, self.OnClickShowPetNatureTips)
  self:AddButtonListener(self.TraceBtn.btnLevelUp, self.OnTraceBtnClick)
end

function UMG_Activity_Foreshow_C:OnClickShowPetData()
  _G.NRCAudioManager:PlaySound2DAuto(40002013, "UMG_Activity_Foreshow_C:OnClickShowPetData")
  local activityInst = self.activityInst
  local petBaseId = activityInst and activityInst:GetPetBaseId()
  if petBaseId and 0 ~= petBaseId then
    _G.NRCModuleManager:DoCmd(_G.BattlePassModuleCmd.OpenPetDetailPanel, petBaseId, true)
  end
end

function UMG_Activity_Foreshow_C:OnTraceBtnClick()
  _G.NRCAudioManager:PlaySound2DAuto(1077, "UMG_Activity_Foreshow_C:OnTraceBtnClick")
  if self.activityInst:IsActivityInactive() then
    ActivityUtils.ShowActivityExpiredTips()
    return
  end
  local activityInst = self.activityInst
  if activityInst then
    activityInst:ExecuteJumpOption()
  end
end

function UMG_Activity_Foreshow_C:OnClickShowPetNatureTips()
  _G.NRCAudioManager:PlaySound2DAuto(40008031, "UMG_Activity_Foreshow_C:OnClickShowPetNatureTips")
  local activityInst = self.activityInst
  local petBaseId = activityInst and activityInst:GetPetBaseId()
  if petBaseId and 0 ~= petBaseId then
    local showPetNatureId = self.showPetNatureId
    if showPetNatureId and 0 ~= showPetNatureId then
      ActivityUtils.ShowPetNatureTips(showPetNatureId, petBaseId)
    end
  end
end

return UMG_Activity_Foreshow_C
