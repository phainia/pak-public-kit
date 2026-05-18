local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_Base_C")
local UMG_Activity_SpecificTime_C = Base:Extend("UMG_Activity_SpecificTime_C")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")

function UMG_Activity_SpecificTime_C:BindUIElements()
  local uiElements = {}
  uiElements.desireActivityType = _G.Enum.ActivityType.ATP_DROP
  uiElements.title = self.Text_Title
  uiElements.promptText = self.Text_Describe
  uiElements.bgImage = self.Image_Bg
  uiElements.particularsBtn = self.ParticularsBtn
  uiElements.timeRemaining = self.Text_TimeRemaining
  uiElements.openAnimName = "In"
  return uiElements
end

function UMG_Activity_SpecificTime_C:OnConstruct()
  Base.OnConstruct(self)
  self:OnAddEventListener()
end

function UMG_Activity_SpecificTime_C:OnDestruct()
  self:RemoveAllButtonListener()
  self:UnRegisterEvent(self, ActivityModuleEvent.RefreshActivityDropData)
end

function UMG_Activity_SpecificTime_C:OnAddEventListener()
  self:AddButtonListener(self.TraceBtn.btnLevelUp, self.OnTraceBtnClick)
  self:RegisterEvent(self, ActivityModuleEvent.RefreshActivityDropData, self.OnRefreshActivityDropData)
end

function UMG_Activity_SpecificTime_C:OnEnable(firstLoad)
  if firstLoad then
    self.activityDropConf = self.activityInst:GetActivityDropConf()
  end
  if self.activityInst.activityDropData then
    self:OnRefreshActivityDropData(self.activityInst:GetActivityId(), self.activityInst.activityDropData)
  end
end

function UMG_Activity_SpecificTime_C:OnRefreshActivityDropData(_activityId, _activityDropData)
  if self.activityInst:GetActivityId() ~= _activityId then
    return
  end
  if not self.activityDropConf then
    Log.Error("UMG_Activity_SpecificTime_C:OnRefreshActivityDropData --- self.dropConf is nil")
    return
  end
  if not _activityDropData then
    Log.Error("UMG_Activity_SpecificTime_C:OnRefreshActivityDropData --- _activityDropData is nil")
    return
  end
  local DropConf = self.activityDropConf
  local IconPath = ""
  local DailyAlreadyGet = 0
  local TotalAlreadyGet = 0
  if DropConf.goods_type == _G.Enum.GoodsType.GT_VITEM then
    local vItemConf = _G.DataConfigManager:GetVisualItemConf(DropConf.goods_id)
    if nil ~= vItemConf then
      IconPath = vItemConf.bigIcon
    end
  elseif DropConf.goods_type == _G.Enum.GoodsType.GT_BAGITEM then
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(DropConf.goods_id)
    if nil ~= bagItemConf then
      IconPath = bagItemConf.icon
    end
  else
    Log.Error("UMG_Activity_SpecificTime_C:OnRefreshActivityDropData --- not have this GoodsType getIconPath handle", DropConf.goods_type)
  end
  if _activityDropData.method_drop_list then
    for i, v in pairs(_activityDropData.method_drop_list) do
      if v.drop_item_list then
        for j, k in pairs(v.drop_item_list) do
          if k.item_id == DropConf.goods_id then
            DailyAlreadyGet = DailyAlreadyGet + k.item_num_today
            TotalAlreadyGet = TotalAlreadyGet + k.item_num_total
          end
        end
      end
    end
  end
  local ObtainedListData = {
    {
      Desc = DropConf.daily_tips,
      IconPath = IconPath,
      GetNum = DailyAlreadyGet,
      LimitNum = DropConf.day_got_limit
    },
    {
      Desc = DropConf.total_tips,
      IconPath = IconPath,
      GetNum = TotalAlreadyGet,
      LimitNum = DropConf.total_got_limit
    }
  }
  self.MagicLevelText:SetText(DropConf.drop_num_tips)
  if DropConf.track_type_param and #DropConf.track_type_param > 0 then
    self.TraceBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.TraceBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.ObtainedList:InitGridView(ObtainedListData)
end

function UMG_Activity_SpecificTime_C:OnTraceBtnClick()
  local trackType, trackParams = self.activityInst:GetTrackTypeAndParams()
  if trackType and trackParams and #trackParams > 0 then
    if trackType == _G.Enum.ActivityTrackType.ATKT_WORLD_MAP then
      local worldMapConf = _G.DataConfigManager:GetWorldMapConf(trackParams[1])
      if worldMapConf then
        local refreshIds = worldMapConf.npc_refresh_ids
        if refreshIds and #refreshIds > 0 then
          _G.NRCModuleManager:DoCmd(_G.BigMapModuleCmd.OpenWorldMap, {
            centerNPCRefreshId = refreshIds[1]
          })
        end
      end
    elseif trackType == _G.Enum.ActivityTrackType.ATKT_PETBASE then
      local petBaseConf = _G.DataConfigManager:GetPetbaseConf(trackParams[1])
      if petBaseConf and petBaseConf.pet_track_npc_id then
        _G.NRCModuleManager:DoCmd(_G.BigMapModuleCmd.SendZoneNpcTraceQueryReq, petBaseConf.pet_track_npc_id)
      end
    end
  end
end

return UMG_Activity_SpecificTime_C
