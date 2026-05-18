local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_Base_C")
local UMG_Activity_ServerActivationOutfit_C = Base:Extend("UMG_Activity_ServerActivationOutfit_C")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")

function UMG_Activity_ServerActivationOutfit_C:OnConstruct()
  Base.OnConstruct(self)
  self:OnAddEventListener()
end

function UMG_Activity_ServerActivationOutfit_C:OnDestruct()
  self:RemoveAllButtonListener()
  self:UnRegisterEvent(self, ActivityModuleEvent.ConditionRewardItemProgressChange)
  self:UnRegisterEvent(self, ActivityModuleEvent.ConditionRewardItemStatusChange)
end

function UMG_Activity_ServerActivationOutfit_C:OnAddEventListener()
  self:AddButtonListener(self.Examine.btnLevelUp, self.OnExamineBtnClick)
  self:RegisterEvent(self, ActivityModuleEvent.ConditionRewardItemProgressChange, self.OnConditionRewardItemProgressChange)
  self:RegisterEvent(self, ActivityModuleEvent.ConditionRewardItemStatusChange, self.OnConditionRewardItemProgressChange)
end

function UMG_Activity_ServerActivationOutfit_C:BindUIElements()
  local uiElements = {}
  uiElements.particularsBtn = self.ParticularsBtn
  uiElements.timeRemaining = self.Text_TimeRemaining
  uiElements.title = self.Text_Title
  uiElements.promptText = self.Text_Describe
  uiElements.openAnimName = "In"
  uiElements.changeAnimName = "In"
  return uiElements
end

function UMG_Activity_ServerActivationOutfit_C:OnEnable(firstLoad)
  Base.OnEnable(self, firstLoad)
  if firstLoad then
    self:InitData()
    self:RefreshFixedView()
  end
  self:RefreshSignInView(true)
end

function UMG_Activity_ServerActivationOutfit_C:OnConditionRewardItemProgressChange()
  self:RefreshSignInView()
end

function UMG_Activity_ServerActivationOutfit_C:InitData()
  local jumpConf = _G.DataConfigManager:GetActivityGlobalConfig("activity_give_appearanche_option_1600019")
  local playerGender = Enum.ESexValue.SEX_MALE
  local player = _G.NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if player then
    playerGender = player.gender
  end
  local jumpId
  if jumpConf and jumpConf.numList and jumpConf.numList[playerGender] then
    jumpId = jumpConf.numList[playerGender]
  end
  self.jumpConf = jumpConf
  self.playerGender = playerGender
  self.jumpId = jumpId
end

function UMG_Activity_ServerActivationOutfit_C:RefreshFixedView()
  local bgPath = self.activityInst and self.activityInst.activityConf and self.activityInst.activityConf.image_path or nil
  if bgPath then
    local bgs = string.split(bgPath, "|")
    if bgs and #bgs > 0 and bgs[self.playerGender] then
      self.Image_Bg:SetPath(bgs[self.playerGender])
    end
  end
  local jumpConf = self.jumpConf
  if jumpConf then
    self.TextName:SetText(jumpConf.str or "")
  end
end

function UMG_Activity_ServerActivationOutfit_C:RefreshSignInView(bIsMove)
  if self.activityInst then
    local allRewardItem = self.activityInst:GetRewardItems()
    local curTotalLoginDay = self.activityInst:GetActivityLoginDays()
    local maxNeedLoginDay = 30
    local showPosIndex = -1
    local progressValue = 0
    local halfItemProgress = allRewardItem and 1 / (#allRewardItem * 2 - 1) or 0
    if allRewardItem and #allRewardItem > 0 then
      table.sort(allRewardItem, function(a, b)
        return a.conf.condition_group[1].condition_param < b.conf.condition_group[1].condition_param
      end)
      maxNeedLoginDay = allRewardItem[#allRewardItem].conf.condition_group[1].condition_param
      local lastItemNeedLoginDay = 0
      local nextItemNeedLoginDay
      for i, v in ipairs(allRewardItem) do
        v:UpdateProgress()
        if v:GetRewardStatus() > 1 then
          curTotalLoginDay = math.max(curTotalLoginDay, v.conf.condition_group[1].condition_param)
        end
        local curItemNeedLoginDay = v.conf.condition_group[1].condition_param
        if i < #allRewardItem then
          nextItemNeedLoginDay = allRewardItem[i + 1].conf.condition_group[1].condition_param
        else
          nextItemNeedLoginDay = nil
        end
        if curTotalLoginDay >= curItemNeedLoginDay then
          progressValue = (i - 1) * halfItemProgress * 2 + halfItemProgress * 0.85
        elseif lastItemNeedLoginDay < curTotalLoginDay then
          progressValue = progressValue + (curTotalLoginDay - lastItemNeedLoginDay) / (curItemNeedLoginDay - lastItemNeedLoginDay) * halfItemProgress * 2
        end
        local rewardState = v:GetRewardStatus()
        if showPosIndex < 0 and rewardState <= 2 then
          showPosIndex = i
        end
        lastItemNeedLoginDay = curItemNeedLoginDay
      end
    end
    if showPosIndex < 0 then
      showPosIndex = 1
    end
    if maxNeedLoginDay <= curTotalLoginDay then
      progressValue = 1
    end
    local valueDay = allRewardItem[#allRewardItem - 1].conf.condition_group[1].condition_param
    if curTotalLoginDay == valueDay + 1 then
      progressValue = progressValue + (curTotalLoginDay - valueDay) / (maxNeedLoginDay - valueDay) * halfItemProgress * 2 * 0.5
    end
    self.MagicLevelText:SetText(string.format(LuaText.activity_login_gift_tips, curTotalLoginDay, maxNeedLoginDay))
    self.List:InitGridView(allRewardItem)
    self.List:SetCustomData(self.activityInst)
    self.TaskProgress:SetPercent(progressValue)
    if bIsMove then
      self.ScrollBox_21:ScrollWidgetIntoView(self.List:GetItemByIndex(showPosIndex), false, UE4.EDescendantScrollDestination.Center)
    end
  end
end

function UMG_Activity_ServerActivationOutfit_C:OnExamineBtnClick()
  if self.jumpId then
    _G.NRCAudioManager:PlaySound2DAuto(40002013, "UMG_Activity_ServerActivationOutfit_C:OnExamineBtnClick")
    ActivityUtils.DoActivityOptionCmd(self.jumpId)
  end
end

return UMG_Activity_ServerActivationOutfit_C
