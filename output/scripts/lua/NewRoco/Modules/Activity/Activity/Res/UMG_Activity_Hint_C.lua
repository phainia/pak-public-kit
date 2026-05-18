local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local UMG_Activity_Hint_C = _G.NRCPanelBase:Extend("UMG_Activity_Hint_C")

function UMG_Activity_Hint_C:OnConstruct()
  self:SetChildViews(self.PopUp4)
end

function UMG_Activity_Hint_C:OnDestruct()
end

function UMG_Activity_Hint_C:OnActive(_activityInst, FlowerSendId, _IsSelectOther)
  self.activityInst = _activityInst
  self.FlowerSendId = FlowerSendId
  self:SetCommonPopUpInfo(self.PopUp4)
  local petList = {}
  local retSeedData, level = ActivityUtils.GetPlayerSelectSpecFlowerSeedDataById(FlowerSendId)
  local petData = {
    level = level,
    base_conf_id = retSeedData.petBaseId
  }
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(retSeedData.petBaseId)
  table.insert(petList, {PetData = petData, isHasPet = true})
  self.List:InitGridView(petList)
  if 1 == _IsSelectOther then
    self.PopUp4:SetDescInfo(LuaText.activity_pet_raise_choose_confirm_01)
  elseif 2 == _IsSelectOther then
    self.PopUp4:SetDescInfo(LuaText.activity_pet_raise_choose_confirm_02)
  elseif 3 == _IsSelectOther then
    self.PopUp4.Btn_Left:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.PopUp4.Btn_Right:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.PopUp4:SetDescInfo(string.format(LuaText.activity_pet_raise_choose_confirm_03, petBaseConf.name))
  end
  self:OnAddEventListener()
  self:LoadAnimation(0)
end

function UMG_Activity_Hint_C:OnDeactive()
  if self.OkClose then
    self.activityInst:SendZoneSelectLimitedFlowerSeedPetReq(self.FlowerSendId)
  end
end

function UMG_Activity_Hint_C:SetCommonPopUpInfo(PopUp, TitleText, TitleIcon)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  if TitleText then
    CommonPopUpData.TitleText = TitleText
  end
  if TitleIcon then
    CommonPopUpData.TitleIcon = TitleIcon
  end
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.OnCancel
  CommonPopUpData.Btn_RightHandler = self.OnOk
  CommonPopUpData.ClosePanelHandler = self.OnCancel
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_Activity_Hint_C:OnAddEventListener()
end

function UMG_Activity_Hint_C:OnCancel()
  _G.NRCAudioManager:PlaySound2DAuto(41400010, "UMG_Activity_Hint_C:OnCancel")
  self.OkClose = false
  self:LoadAnimation(2)
end

function UMG_Activity_Hint_C:OnOk()
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_Activity_Hint_C:OnOk")
  self.OkClose = true
  self:LoadAnimation(2)
end

function UMG_Activity_Hint_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(2) then
    self:DoClose()
  elseif anim == self:GetAnimByIndex(0) then
    self:LoadAnimation(1)
  end
end

return UMG_Activity_Hint_C
