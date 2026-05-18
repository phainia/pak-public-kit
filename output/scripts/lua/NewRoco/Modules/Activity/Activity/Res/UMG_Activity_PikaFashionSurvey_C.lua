local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_Base_C")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")
local UMG_Activity_PikaFashionSurvey_C = Base:Extend("UMG_Activity_PikaFashionSurvey_C")

function UMG_Activity_PikaFashionSurvey_C:BindUIElements()
  local uiElements = {}
  uiElements.desireActivityType = Enum.ActivityType.ATP_PET_PHOTO
  uiElements.title = self.Text_Title
  uiElements.promptText = self.Text_Describe
  uiElements.particularsBtn = self.ParticularsBtn
  uiElements.bgImage = self.BG
  uiElements.timeRemainingRoot = self.timeRemainingRoot
  uiElements.timeRemaining = self.Text_TimeRemaining
  uiElements.openAnimName = "In_1"
  uiElements.changeAnimName = "In_1"
  uiElements.loopAnimName = "Deng_Loop"
  return uiElements
end

function UMG_Activity_PikaFashionSurvey_C:OnEnable(firstLoad)
  Base.OnEnable(self, firstLoad)
  self:OnAddEventListener()
  TEST_PANEL = self
end

function UMG_Activity_PikaFashionSurvey_C:OnDisable()
  Base.OnDisable(self)
  self:OnRemoveEventListener()
end

function UMG_Activity_PikaFashionSurvey_C:OnAddEventListener()
  self:RegisterEvent(self, ActivityModuleEvent.RefreshTakePhotoPetIdentifyActivityData, self.InitPanel)
  if not self.bButtonInitialized then
    self.bButtonInitialized = true
    self:AddButtonListener(self.Btn_CheckSuit.btnLevelUp, self.GotoFashion)
    self:AddButtonListener(self.Btn_ToPhoto.btnLevelUp, self.OpenDetails)
    self:AddButtonListener(self.ClickBtn, self.ReqTakeReward)
    self:InitPanel(self:GetActivityObject():GetActivityData())
  end
end

function UMG_Activity_PikaFashionSurvey_C:OnRemoveEventListener()
  self:UnRegisterEvent(self, ActivityModuleEvent.RefreshTakePhotoPetIdentifyActivityData)
end

function UMG_Activity_PikaFashionSurvey_C:GetActivityObject()
  return self.activityInst
end

function UMG_Activity_PikaFashionSurvey_C:InitPanel(ActivityData)
  if ActivityData then
    local activityObject = self:GetActivityObject()
    if activityObject then
      local Conf = _G.DataConfigManager:GetActivityPetPhoto(activityObject:GetActivityId(), true)
      local v1 = ActivityData.already_taken_pets and #ActivityData.already_taken_pets or 0
      local v2 = #Conf.condition_group
      self.PartName:SetText(Conf and Conf.part_name or "")
      self.ProgressText:SetText(string.format("%s/%s", v1, v2))
      self.ProgressBar:SetPercent(v1 / v2)
      self.PetPhotoConf = Conf
      self:RefreshItem()
      self.Btn_CheckSuit:SetCommonText(LuaText.PET_PHOTO_1)
      self.Btn_ToPhoto:SetCommonText(LuaText.PET_PHOTO_2)
      if "" ~= (Conf.photo_res or "") then
        self.Photo:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
        self.Photo:SetPath(Conf.photo_res)
      else
        self.Photo:SetVisibility(UE.ESlateVisibility.Collapsed)
      end
    end
  end
end

function UMG_Activity_PikaFashionSurvey_C:RefreshItem()
  local Conf = self.PetPhotoConf
  if Conf then
    local ActivityObj = self:GetActivityObject()
    local ActivityData = ActivityObj:GetActivityData()
    local bGetReward = ActivityData and ActivityData.is_disposable_reward_taken or false
    if Conf.goods_type == Enum.GoodsType.GT_BAGITEM then
      local Icon = (_G.DataConfigManager:GetBagItemConf(Conf.goods_id, true) or {}).big_icon or ""
      self.Item:SetPath(Icon)
    elseif Conf.goods_type == Enum.GoodsType.GT_VITEM then
      local Icon = (_G.DataConfigManager:GetVisualItemConf(Conf.goods_id, true) or {}).bigIcon or ""
      self.Item:SetPath(Icon)
    else
      self.Item:SetPath("")
    end
    self.Collected:SetVisibility(bGetReward and UE.ESlateVisibility.SelfHitTestInvisible or UE.ESlateVisibility.Collapsed)
    self.BgSwitcher:SetActiveWidgetIndex(bGetReward and 1 or 0)
    if bGetReward then
      if not self:IsAnimationPlaying(self.Reward_get) then
        self:PlayAnimationForward(self.Reward_get, 9999)
      end
    else
      self:PlayAnimation(self.In_2)
    end
    self:SetRedDotData(ActivityEnum.RedPointKey.DetailReward, {
      ActivityObj:GetActivityId()
    })
    local v1 = ActivityData.already_taken_pets and #ActivityData.already_taken_pets or 0
    local v2 = #Conf.condition_group
    local bCanReward = 0 ~= v1 and v1 == v2 and not bGetReward
    self.bCanReward = bCanReward
    if bCanReward then
      self:PlayAnimationByName("Reward_ready_loop")
    end
  end
end

function UMG_Activity_PikaFashionSurvey_C:OnAnimationFinished(Anim)
  Log.Debug("UMG_Activity_PikaFashionSurvey_C:OnAnimationFinished", Anim:GetName(), self.bCanReward)
  if self.bCanReward and self.Reward_ready_loop == Anim then
    self:PlayAnimation(self.Reward_ready_loop)
  end
end

function UMG_Activity_PikaFashionSurvey_C:ReqTakeReward()
  local Conf = self.PetPhotoConf
  local ActivityObj = self:GetActivityObject()
  if not Conf or not ActivityObj then
    Log.Warning("UMG_Activity_PikaFashionSurvey_C: Cannot found config or activity object", Conf, ActivityObj)
    return
  end
  local ActivityData = ActivityObj:GetActivityData()
  local bGetReward = ActivityData and ActivityData.is_disposable_reward_taken or false
  local v1 = ActivityData.already_taken_pets and #ActivityData.already_taken_pets or 0
  local v2 = #Conf.condition_group
  local bCanReward = 0 ~= v1 and v1 == v2 and not bGetReward
  if not bCanReward then
    Log.Warning("UMG_Activity_PikaFashionSurvey_C: ReqTakeReward", v1, v2, bGetReward)
    self:OpenTips(Conf.goods_id, Conf.goods_type)
    return
  end
  _G.NRCModuleManager:DoCmd(_G.ActivityModuleCmd.OnCmdTakeReward, ActivityObj:GetActivityId(), ActivityObj:GetPartIds()[1], nil, function(bSuccess)
    if bSuccess and self.isShowing then
      self:OnRewardGet()
    end
    ActivityObj:SyncActivityDataOnAvailable()
  end, true)
end

function UMG_Activity_PikaFashionSurvey_C:OnRewardGet()
  self.bCanReward = false
  self:StopAnimation(self.Reward_ready_loop)
  self.BgSwitcher:SetActiveWidgetIndex(1)
  self.Collected:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self:PlayAnimationByName("Reward_get")
end

function UMG_Activity_PikaFashionSurvey_C:SetRedDotData(key, extraKey)
  ;(self.redPointReward or self.redPointNew):SetupKey(key, extraKey)
end

function UMG_Activity_PikaFashionSurvey_C:OpenTips(itemId, itemType)
  _G.NRCAudioManager:PlaySound2DAuto(1303, "UMG_Activity_PikaFashionSurvey_C:OpenTips")
  if itemType == _G.Enum.GoodsType.GT_FASHION_SUITS then
    _G.NRCModuleManager:DoCmd(AppearanceModuleCmd.OpenAppearanceSuitDetailsPanel, itemId)
  elseif itemType == _G.Enum.GoodsType.GT_REWARD then
    ActivityUtils.ShowRewardPreview(itemId)
  else
    local remainCnt, maxCnt, isBattleState, Position, overrideNum, Caller, CallBack, OpenCallBack
    local showErrorTipsWhenNotFound = false
    local showDefaultIconWhenNotFound = false
    _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, itemId, itemType, false, remainCnt, maxCnt, isBattleState, Position, overrideNum, Caller, CallBack, OpenCallBack, showErrorTipsWhenNotFound, showDefaultIconWhenNotFound)
  end
end

function UMG_Activity_PikaFashionSurvey_C:IsMale()
  return _G.DataModelMgr.PlayerDataModel.playerInfo.brief_info.sex == _G.ProtoEnum.ESexValue.SEX_MALE
end

function UMG_Activity_PikaFashionSurvey_C:GotoFashion()
  local activityObject = self:GetActivityObject()
  if not activityObject or not self.PetPhotoConf then
    return
  end
  local PackageId = 0
  if self:IsMale() then
    PackageId = self.PetPhotoConf.package_id1
  else
    PackageId = self.PetPhotoConf.package_id2
  end
  _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.OpenTryOnByPackageId, PackageId)
end

function UMG_Activity_PikaFashionSurvey_C:OpenDetails()
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_Activity_PikaFashionSurvey_C:OpenTips")
  _G.NRCModuleManager:DoCmd(_G.ActivityModuleCmd.OnCmdOpenPikaFashionSurveyToPhoto, self)
end

return UMG_Activity_PikaFashionSurvey_C
