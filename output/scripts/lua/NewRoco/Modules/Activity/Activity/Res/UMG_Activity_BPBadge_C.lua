local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_Base_C")
local UMG_Activity_BPBadge_C = Base:Extend("UMG_Activity_BPBadge_C")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")

function UMG_Activity_BPBadge_C:BindUIElements()
  local uiElements = {}
  uiElements.openAnimName = "In"
  uiElements.changeAnimName = "In"
  uiElements.loopAnimName = "Loop"
  uiElements.particularsBtn = self.ParticularsBtn
  uiElements.title = self.Text_Title
  uiElements.promptText = self.Text_Describe
  uiElements.timeRemaining = self.Text_TimeRemaining
  return uiElements
end

function UMG_Activity_BPBadge_C:OnConstruct()
  Base.OnConstruct(self)
  self.index = 1
  local _activityInst = self.activityInst
  local activityGoodConf = _G.DataConfigManager:GetActivityGoodsConf(_activityInst:GetActivityId()).goods_group
  if #activityGoodConf > 1 then
    local initData = {}
    for _, v in ipairs(activityGoodConf) do
      local data = {
        text = v.option_name,
        caller = self,
        handler = self.OnItemSelected
      }
      table.insert(initData, data)
    end
    self.TabList1:InitGridView(initData)
    self.TabList1:SelectItemByIndex(0)
  else
    self.TabList1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.TabBG:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:OnItemSelected(1)
  end
  self:AddButtonListener(self.Btn_Claimable.btnLevelUp, self.OnClickJoinActivity)
end

function UMG_Activity_BPBadge_C:OnClickJoinActivity()
  _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_Activity_BPBadge_C:OnClickJoinActivity")
  self:DelaySeconds(0.1, function()
    local _activityInst = self.activityInst
    if _activityInst then
      local activityGoodConf = _G.DataConfigManager:GetActivityGoodsConf(_activityInst:GetActivityId()).goods_group
      local _itemObject = _activityInst:CreateWebSiteItem(activityGoodConf[self.index].website_id)
      return _activityInst:PerformActivityInteraction(ActivityEnum.ActivityInteractionType.Join, _itemObject)
    end
  end)
end

function UMG_Activity_BPBadge_C:OnItemSelected(index)
  local activityGoodConf = _G.DataConfigManager:GetActivityGoodsConf(self.activityInst:GetActivityId()).goods_group
  self.index = index
  self.Bg:SetPath(activityGoodConf[index].bg_path)
  self.ReverseSide:SetPath(activityGoodConf[index].goods_back)
  self:LoadPanelRes(activityGoodConf[index].back_ae_img, 255, self.OnLoadIconMaterialSucceed)
  self.Front:SetPath(activityGoodConf[index].goods_front)
  self.Front_1:SetPath(activityGoodConf[index].ae_img1)
  self.Front_2:SetPath(activityGoodConf[index].ae_img1)
end

function UMG_Activity_BPBadge_C:OnLoadIconMaterialSucceed(_, asset)
  self.ReverseSide_1:SetBrushFromMaterial(asset)
end

function UMG_Activity_BPBadge_C:OnDestruct()
  self:RemoveButtonListener(self.Btn_Claimable.btnLevelUp)
end

return UMG_Activity_BPBadge_C
