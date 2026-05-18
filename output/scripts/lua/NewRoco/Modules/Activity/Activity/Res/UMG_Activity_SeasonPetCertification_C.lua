local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_Base_C")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local UMG_Activity_SeasonPetCertification_C = Base:Extend("UMG_Activity_SeasonPetCertification_C")

function UMG_Activity_SeasonPetCertification_C:BindUIElements()
  local uiElements = {}
  uiElements.title = self.Text_Title
  uiElements.promptText = self.Text_Describe
  uiElements.bgImage = self.Image_Bg
  uiElements.timeRemaining = self.Text_TimeRemaining
  uiElements.particularsBtn = self.ParticularsBtn
  uiElements.openAnimName = "In"
  uiElements.changeAnimName = "In"
  return uiElements
end

function UMG_Activity_SeasonPetCertification_C:OnConstruct()
  Base.OnConstruct(self)
  self:RegisterEvent(self, ActivityModuleEvent.RefreshCertificationActivityData, self.InitPanel)
  self:InitPanel(self.activityInst:GetActivityData())
end

function UMG_Activity_SeasonPetCertification_C:InitPanel(activity_data)
  local base_id = self.activityInst:GetSinglePartId()
  local reward_group = _G.DataConfigManager:GetActivityPetCertification(base_id).reward_group
  local initData = {}
  local bGetReward = activity_data and activity_data.choosen_certificate_pet ~= nil or false
  for _, v in ipairs(reward_group) do
    local itemData = _G.NRCCommonItemIconData()
    itemData.itemType = v.goods_type
    itemData.itemId = v.goods_id
    itemData.itemNum = v.goods_count
    itemData.bShowNum = true
    itemData.bShowGetTag = bGetReward
    table.insert(initData, itemData)
  end
  self.List:InitList(initData)
  local _data = {
    base_id = base_id,
    dayNum = activity_data and activity_data.progress and activity_data.progress or 0,
    bGetReward = bGetReward,
    activity_id = self.activityInst:GetActivityId()
  }
  self.SeasonPetCertification:SetInfo(_data)
end

function UMG_Activity_SeasonPetCertification_C:OnDestruct()
  Base.OnDestruct(self)
  self:UnRegisterEvent(self, ActivityModuleEvent.RefreshCertificationActivityData)
end

return UMG_Activity_SeasonPetCertification_C
