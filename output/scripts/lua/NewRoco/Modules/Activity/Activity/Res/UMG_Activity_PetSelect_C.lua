local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local UMG_Activity_PetSelect_C = _G.NRCPanelBase:Extend("UMG_Activity_PetSelect_C")

function UMG_Activity_PetSelect_C:OnActive(activityInst)
  self:SetChildViews(self.PetSelectItem1, self.PetSelectItem2)
  self.activityInst = activityInst
  self.FlowerSeedInfo = activityInst:GetPlayerLimitedFlowerSeedInfo()
  self.petRaiseConf = activityInst:GetPetRaiseConf()
  self:OnAddEventListener()
  self:SetInfo()
  self:PlayAnimation(self.Open)
end

function UMG_Activity_PetSelect_C:SetInfo()
  local petGroup = self.petRaiseConf.pet_group
  for i, v in pairs(petGroup) do
    if i <= 3 then
      self["PetSelectItem" .. i]:SetVisibility(UE4.ESlateVisibility.Visible)
      self["PetSelectItem" .. i]:SetInfo(v)
    end
  end
  if 1 == #petGroup then
    self["PetSelectItem" .. 1]:OnClick(false)
    self.GoToInvestigate:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    for i, v in pairs(petGroup) do
      if v.activity_spec_flower_seed_conf_id == self.FlowerSeedInfo.spec_flower_seed_id and i <= 3 then
        self["PetSelectItem" .. i]:OnClick(false)
      end
    end
    if self.FlowerSeedInfo.spec_flower_seed_id then
      self.GoToInvestigate:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.Desc:SetText(LuaText.activity_pet_raise_choose_down_tips_01)
      self.GoToInvestigate:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_Activity_PetSelect_C:SetSelectLimitedFlowerId(LimitedFlowerId, NeedSetOtherUnSelect)
  if NeedSetOtherUnSelect then
    local petGroup = self.petRaiseConf.pet_group
    for i, v in pairs(petGroup) do
      if v.activity_spec_flower_seed_conf_id ~= LimitedFlowerId and i <= 3 then
        self["PetSelectItem" .. i]:CancelSelect()
      end
    end
    _G.NRCAudioManager:PlaySound2DAuto(40002006, "UMG_Activity_PetSelect_C:SetSelectLimitedFlowerId")
  end
  self.SelectLimitedFlowerId = LimitedFlowerId
  if self.FlowerSeedInfo.spec_flower_seed_id and self.SelectLimitedFlowerId == self.FlowerSeedInfo.spec_flower_seed_id then
    self.Desc:SetText(LuaText.activity_pet_raise_choose_down_tips_02)
    self.GoToInvestigate:SetBtnText("\229\137\141\229\190\128\232\176\131\230\159\165")
  elseif self.FlowerSeedInfo.spec_flower_seed_id and self.SelectLimitedFlowerId ~= self.FlowerSeedInfo.spec_flower_seed_id then
    self.Desc:SetText(LuaText.activity_pet_raise_choose_down_tips_01)
    self.GoToInvestigate:SetBtnText("\230\155\180\230\141\162\232\176\131\230\159\165")
  elseif not self.FlowerSeedInfo.spec_flower_seed_id then
    self.Desc:SetText(LuaText.activity_pet_raise_choose_down_tips_01)
    self.GoToInvestigate:SetBtnText("\231\161\174\232\174\164\232\176\131\230\159\165")
  end
  self.GoToInvestigate:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_Activity_PetSelect_C:OnDeactive()
  _G.ZoneServer:RemoveProtocolListener(self, _G.ProtoCMD.ZoneSvrCmd.ZONE_SELECT_LIMITED_FLOWER_SEED_PET_RSP, self.OnZoneSelectLimitedFlowerSeedPetRsp)
  self:UnRegisterEvent(self, ActivityModuleEvent.SetSelectLimitedFlowerId)
end

function UMG_Activity_PetSelect_C:ClosePanel()
  _G.NRCAudioManager:PlaySound2DAuto(41400010, "UMG_Activity_PetSelect_C:ClosePanel")
  self:DoClose()
end

function UMG_Activity_PetSelect_C:OnAddEventListener()
  _G.ZoneServer:AddProtocolListener(self, _G.ProtoCMD.ZoneSvrCmd.ZONE_SELECT_LIMITED_FLOWER_SEED_PET_RSP, self.OnZoneSelectLimitedFlowerSeedPetRsp)
  self:RegisterEvent(self, ActivityModuleEvent.SetSelectLimitedFlowerId, self.SetSelectLimitedFlowerId)
  self:AddButtonListener(self.GoToInvestigate.btnLevelUp, self.GoToInvestigateClick)
  self:AddButtonListener(self.BtnClose, self.ClosePanel)
end

function UMG_Activity_PetSelect_C:OnZoneSelectLimitedFlowerSeedPetRsp(rsp)
  if not rsp or 0 ~= rsp.ret_info.ret_code then
    self:DoClose()
    return
  else
    _G.NRCModuleManager:DoCmd(_G.ActivityModuleCmd.OpenLimitedFlowerHint, self.activityInst, self.SelectLimitedFlowerId, 3)
    self:DoClose()
  end
end

function UMG_Activity_PetSelect_C:GoToInvestigateClick()
  _G.NRCAudioManager:PlaySound2DAuto(40002003, "UMG_Activity_PetSelect_C:GoToInvestigateClick")
  if self.SelectLimitedFlowerId == self.FlowerSeedInfo.spec_flower_seed_id then
    local TaskState, TaskId = self.activityInst:GetInvestTaskInfo()
    if TaskId then
      _G.NRCPanelManager:CloseAllPanelByLayer(_G.Enum.UILayerType.UI_LAYER_FULLSCREEN)
      _G.NRCEventCenter:DispatchEvent(MainUIModuleEvent.OnClickTaskTrackToWorldFast)
      _G.NRCModeManager:DoCmd(_G.TaskModuleCmd.OnSetTraceTaskInfo, TaskId, true)
    else
      Log.Debug("UMG_Activity_PetSelect_C:GoToInvestigateClick() -- not found TaskId")
    end
    return
  end
  if 1 == #self.petRaiseConf.pet_group then
    self.activityInst:SendZoneSelectLimitedFlowerSeedPetReq(self.SelectLimitedFlowerId)
  else
    local selectOther = 1
    if self.FlowerSeedInfo.spec_flower_seed_id ~= nil then
      selectOther = 2
    end
    _G.NRCModuleManager:DoCmd(_G.ActivityModuleCmd.OpenLimitedFlowerHint, self.activityInst, self.SelectLimitedFlowerId, selectOther)
  end
end

return UMG_Activity_PetSelect_C
