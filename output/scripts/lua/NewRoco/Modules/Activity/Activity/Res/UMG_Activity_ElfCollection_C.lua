local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_PetCollectTemplate_C")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local UMG_Activity_ElfCollection_C = Base:Extend("UMG_Activity_ElfCollection_C")

function UMG_Activity_ElfCollection_C:OnConstruct()
  Base.OnConstruct(self)
  self:InitPetList()
  self:ShowPetGroupName(self.NRCText_71)
  self:ShowActivityTime(self.CanvasPanel_356)
  self:ShowRewardIcon(self.Icon)
  self:ShowRewardName(self.NRCText_70)
  self:SetRedPoints(self.redPointReward)
  if self.activityInst then
    self.activityInst:AddActivityExpiredCallback("CoCreationPetExpired", self, self.CloseRewardPanel)
  end
  self:GetPlayerCardData()
end

function UMG_Activity_ElfCollection_C:OnEnable(firstLoad)
  Base.OnEnable(self)
  self.ParticleSystemWidget2_63:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:PlayAnimation(self.In)
  if self.uiElements.itemList then
    for i = 1, self.uiElements.itemList:GetItemCount() do
      local item = self.uiElements.itemList:GetItemByIndex(i - 1)
      item:PlayInAnim()
    end
  end
end

function UMG_Activity_ElfCollection_C:OnDestruct()
  Base.OnDestruct(self)
  self:RemoveButtonListener(self.AwardBtn, self.OnOpenAwardTip)
end

function UMG_Activity_ElfCollection_C:OnAddEventListener()
  Base.OnAddEventListener(self)
  self:AddButtonListener(self.AwardBtn, self.OnOpenAwardTip)
end

function UMG_Activity_ElfCollection_C:OnOpenAwardTip()
  _G.NRCAudioManager:PlaySound2DAuto(41400009, "UMG_Activity_ElfCollection_C:OnOpenAwardTip")
  if self:CheckActivityExpired() then
    ActivityUtils.ShowActivityExpiredTips()
    return
  end
  local petCollectionConf = self:GetPetCollectionConf()
  if petCollectionConf and petCollectionConf.pet_group then
    local petGroup = petCollectionConf.pet_group
    local maxNum = 0
    if petGroup then
      maxNum = #petGroup
    end
    local curNum = self:GetCurCollectedPetNum()
    local activityId = self:GetActivityId()
    local data = {
      maxNum = maxNum,
      curNum = curNum,
      rewardId = petCollectionConf.reward_id,
      petGroup = petGroup,
      activityId = activityId
    }
    _G.NRCModuleManager:DoCmd(ActivityModuleCmd.OpenActivityElfCollectionAwardTips, data)
  end
end

function UMG_Activity_ElfCollection_C:GetReturnActivityData()
  if self.activityInst and self.activityInst.returnActivityData then
    return self.activityInst.returnActivityData.pet_collection_data
  end
  return nil
end

function UMG_Activity_ElfCollection_C:OnRefreshCollectPetList(_activityInst, petCollectData)
  if not _activityInst or _activityInst ~= self.activityInst then
    return
  end
  if _activityInst:GetActivityId() == petCollectData.activity_id then
    local returnActivityData = self:GetReturnActivityData()
    local collectPetGroup
    if returnActivityData and returnActivityData.collection_pet then
      collectPetGroup = returnActivityData.collection_pet
    end
    if collectPetGroup then
      for _, petCollectId in ipairs(collectPetGroup) do
        if self.uiElements.itemList then
          for i = 1, self.uiElements.itemList:GetItemCount() do
            local item = self.uiElements.itemList:GetItemByIndex(i - 1)
            if item.PetBaseId == petCollectId and not item.IsCollected then
              item:UpdateIsCollected()
            end
          end
        end
      end
    end
  end
end

function UMG_Activity_ElfCollection_C:OnAnimationFinished(Animation)
  if Animation == self.In then
    local activityId = self:GetActivityId()
    if _G.NRCModuleManager:DoCmd(_G.ActivityModuleCmd.CheckPetCollectIsFinish, activityId) then
      _G.NRCAudioManager:PlaySound2DAuto(1373, "UMG_Activity_ElfCollection_C:OnAnimationFinished")
      self.ParticleSystemWidget2_63:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self:PlayAnimation(self.Label2)
    else
      self:PlayAnimation(self.Label)
    end
  elseif Animation == self.Label then
    self:PlayAnimation(self.Background)
  elseif Animation == self.Label2 then
    self:PlayAnimation(self.Background)
  elseif Animation == self.Background then
    self:PlayAnimation(self.Background)
  end
end

function UMG_Activity_ElfCollection_C:CloseRewardPanel()
  _G.NRCModuleManager:DoCmd(ActivityModuleCmd.ActivityExpiredCloseAwardTips)
end

function UMG_Activity_ElfCollection_C:GetPlayerCardData()
  local req = ProtoMessage:newZoneGetShareFormInfoReq()
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_GET_SHARE_FORM_INFO_REQ, req, self, self.OnZoneGetShareFormInfoRsp, false, true)
end

function UMG_Activity_ElfCollection_C:OnZoneGetShareFormInfoRsp(rsp)
  if rsp.ret_info and 0 == rsp.ret_info.ret_code and self.activityInst then
    self.activityInst.PlayerCardData = rsp.share_form_item
  end
end

return UMG_Activity_ElfCollection_C
