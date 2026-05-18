local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local UMG_Pet_PartnerMarker_C = _G.NRCPanelBase:Extend("UMG_Pet_PartnerMarker_C")

function UMG_Pet_PartnerMarker_C:OnConstruct()
  self:SetChildViews(self.PopUp4)
end

function UMG_Pet_PartnerMarker_C:OnDestruct()
end

function UMG_Pet_PartnerMarker_C:OnActive(PetGid, curMark)
  self.pet_gid = PetGid
  self.skipAudio = true
  self:OnAddEventListener()
  self:SetCommonPopUpInfo(self.PopUp4)
  local PetFilterConf = _G.DataConfigManager:GetAllByName("PET_FILTER_CONF")
  local MarkList = {}
  local selectIndex = 0
  for _, v in pairs(PetFilterConf) do
    if v.filter_type == Enum.FilterRule.FIL_PET_MARK then
      table.insert(MarkList, {data = v})
    end
  end
  for i, v in pairs(MarkList) do
    local data = v.data
    if _G.Enum[data.filter_enum_name][data.filter_enum_value] == curMark then
      selectIndex = i - 1
      break
    end
  end
  if curMark and curMark ~= ProtoEnum.PetPartnerMarkType.PPMT_NONE then
    self.PopUp4:SetDescInfo("\229\183\178\232\174\190\229\174\154\230\160\135\232\174\176")
  else
    self.PopUp4:SetDescInfo("\230\156\170\232\174\190\229\174\154\230\160\135\232\174\176")
  end
  
  local function MarkListSort(a, b)
    local IdA = _G.Enum[a.data.filter_enum_name][a.data.filter_enum_value]
    local IdB = _G.Enum[b.data.filter_enum_name][b.data.filter_enum_value]
    return IdA < IdB
  end
  
  table.sort(MarkList, MarkListSort)
  self.FilterList:InitGridView(MarkList)
  self.FilterList:SelectItemByIndex(selectIndex)
  self:LoadAnimation(0)
  self:BindInputAction()
  local touchReasonType = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, "EggIncubatePanel").PETCOLLECT
  _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.UnlockIsSelectBtn, "PetUIModule", "EggIncubatePanel", touchReasonType)
end

function UMG_Pet_PartnerMarker_C:OnDeactive()
end

function UMG_Pet_PartnerMarker_C:SetCommonPopUpInfo(PopUp, TitleText, TitleIcon)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  if TitleText then
    CommonPopUpData.TitleText = TitleText
  end
  if TitleIcon then
    CommonPopUpData.TitleIcon = TitleIcon
  end
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.CancelBtnClick
  CommonPopUpData.Btn_RightHandler = self.OkBtnClick
  CommonPopUpData.ClosePanelHandler = self.CloseBtnClick
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_Pet_PartnerMarker_C:OnAnimationFinished(Anim)
  if Anim == self:GetAnimByIndex(2) then
    self:DoClose()
  elseif Anim == self:GetAnimByIndex(0) then
    self:LoadAnimation(1)
  end
end

function UMG_Pet_PartnerMarker_C:CancelBtnClick()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(41401002, "UMG_Dialog_C:OnClickCancelButton")
  self:LoadAnimation(2)
end

function UMG_Pet_PartnerMarker_C:CloseBtnClick()
  self:LoadAnimation(2)
end

function UMG_Pet_PartnerMarker_C:OkBtnClick()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(41401001, "UMG_Dialog_C:OnClickOkButton")
  _G.NRCModeManager:DoCmd(PetUIModuleCmd.SetPetCollect, {
    {
      pet_gid = self.pet_gid,
      partner_mark = self.SelectMarkType
    }
  })
  self:LoadAnimation(2)
end

function UMG_Pet_PartnerMarker_C:OnAddEventListener()
  self:RegisterEvent(self, PetUIModuleEvent.SelectPetCollectMarkType, self.SelectPetCollectMark)
end

function UMG_Pet_PartnerMarker_C:SelectPetCollectMark(MarkType, name)
  if self.skipAudio then
    self.skipAudio = false
  else
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(41401003, "UMG_Pet_PartnerMarker_C:SelectPetCollectMark")
  end
  if MarkType and MarkType ~= ProtoEnum.PetPartnerMarkType.PPMT_NONE then
    self.PopUp4:SetDescInfo(LuaText.pet_mark_selected)
  else
    self.PopUp4:SetDescInfo(LuaText.pet_mark_none)
  end
  self.SelectMarkType = MarkType
end

function UMG_Pet_PartnerMarker_C:BindInputAction()
  local mappingContext = self:AddInputMappingContext("IMC_PetPartnerMarker")
  if mappingContext then
    mappingContext:BindAction("IA_ClosePetPartnerMarker", self, "OnPcClose2")
  end
end

function UMG_Pet_PartnerMarker_C:OnPcClose2()
  self:CloseBtnClick()
end

return UMG_Pet_PartnerMarker_C
