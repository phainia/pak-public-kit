local FriendModuleEvent = require("NewRoco.Modules.System.Friend.FriendModuleEvent")
local UMG_Card_Type_Select_C = _G.NRCPanelBase:Extend("UMG_Card_Type_Select_C")

function UMG_Card_Type_Select_C:OnConstruct()
  self.data = self.module:GetData("FriendModuleData")
  self:SetChildViews(self.PopUp3)
  self:RegisterEvent(self, FriendModuleEvent.UpdatePetTypeSelect, self.HandleUpdatePetTypeSelect)
end

function UMG_Card_Type_Select_C:OnDestruct()
  self:UnRegisterEvent(self, FriendModuleEvent.UpdatePetTypeSelect)
end

function UMG_Card_Type_Select_C:OnActive()
  self.data:SetCurEditPetTypeIdList(self.data:GetPetTypeFilterList())
  self:SetCommonPopUpInfo(self.PopUp3)
  self:UpdatePetTypeList()
  self:PlayOpenAnim()
end

function UMG_Card_Type_Select_C:OnDeactive()
end

function UMG_Card_Type_Select_C:OnAddEventListener()
end

function UMG_Card_Type_Select_C:OnAnimationFinished(anim)
end

function UMG_Card_Type_Select_C:HandleUpdatePetTypeSelect()
  self:UpdatePetTypeList()
end

function UMG_Card_Type_Select_C:SetCommonPopUpInfo(PopUp, TitleText, TitleIcon)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  if TitleText then
    CommonPopUpData.TitleText = TitleText
  end
  if TitleIcon then
    CommonPopUpData.TitleIcon = TitleIcon
  end
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.OnResetBtnClick
  CommonPopUpData.Btn_RightHandler = self.OnClickConfirm
  CommonPopUpData.ClosePanelHandler = self.OnCloseClick
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_Card_Type_Select_C:UpdatePetTypeList()
  local petTypeList = self:GetAllPetTypeIdList()
  local validPetTypeList = {}
  for _, petTypeId in ipairs(petTypeList) do
    if self.data:IsValidPetType(petTypeId) then
      table.insert(validPetTypeList, petTypeId)
    end
  end
  table.sort(validPetTypeList, function(a, b)
    return a < b
  end)
  self.DepartmentList:InitGridView(validPetTypeList)
end

function UMG_Card_Type_Select_C:GetAllPetTypeIdList()
  local petTypeIdList = {}
  local TypeAllData = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.TYPE_DICTIONARY):GetAllDatas()
  for _, typeData in ipairs(TypeAllData) do
    table.insert(petTypeIdList, typeData.id)
  end
  return petTypeIdList
end

function UMG_Card_Type_Select_C:OnCloseClick()
  self:PlayCloseAnim()
end

function UMG_Card_Type_Select_C:OnClickConfirm()
  self.data:SetPetTypeFilterList(self.data:GetCurEditPetTypeIdList())
  self.module:DispatchEvent(FriendModuleEvent.UpdateCardComponentEdit)
  self:PlayCloseAnim()
end

function UMG_Card_Type_Select_C:OnResetBtnClick()
  self.data:SetPetTypeFilterList(nil)
  self.module:DispatchEvent(FriendModuleEvent.UpdateCardComponentEdit)
  self:PlayCloseAnim()
end

function UMG_Card_Type_Select_C:PlayOpenAnim()
  self:LoadAnimation(0)
end

function UMG_Card_Type_Select_C:PlayCloseAnim()
  self:LoadAnimation(2)
end

function UMG_Card_Type_Select_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(2) then
    self:DoClose()
  elseif anim == self:GetAnimByIndex(0) then
    self:LoadAnimation(1)
  end
end

return UMG_Card_Type_Select_C
