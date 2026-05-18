local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local UMG_QuickSelection_C = _G.NRCPanelBase:Extend("UMG_QuickSelection_C")

function UMG_QuickSelection_C:OnConstruct()
  self:SetChildViews(self.PopUp4)
end

function UMG_QuickSelection_C:OnDestruct()
end

function UMG_QuickSelection_C:OnActive(num1, num2, num3)
  local TalentList = {}
  local numList = {
    num1,
    num2,
    num3
  }
  for i = 1, 3 do
    table.insert(TalentList, {
      Talent = i,
      num = numList[i]
    })
  end
  self.List = {}
  self.CandidateListGrid:InitGridView(TalentList)
  self:SetCommonPopUpInfo(self.PopUp4)
  self.PopUp4:SetDescInfo(LuaText.fast_select_tips)
  self:LoadAnimation(0)
  self:OnAddEventListener()
end

function UMG_QuickSelection_C:OnDeactive()
end

function UMG_QuickSelection_C:SetCommonPopUpInfo(PopUp, TitleText, TitleIcon)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  if TitleText then
    CommonPopUpData.TitleText = TitleText
  end
  if TitleIcon then
    CommonPopUpData.TitleIcon = TitleIcon
  end
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.CancelClosePanel
  CommonPopUpData.Btn_RightHandler = self.ApplyBatch
  CommonPopUpData.ClosePanelHandler = self.ClosePanel
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_QuickSelection_C:AddOrRemoveItemFromBatchList(Item, _add)
  if _add then
    table.insert(self.List, {TalentIndex = Item})
  else
    for i = 1, #self.List do
      if self.List[i].TalentIndex == Item then
        table.remove(self.List, i)
        break
      end
    end
  end
end

function UMG_QuickSelection_C:ApplyBatch()
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_PetWarehouseMain_C:OnCloseBtnClicked")
  self:DispatchEvent(PetUIModuleEvent.ApplyBatchSelectFree, self.List)
  self:LoadAnimation(2)
end

function UMG_QuickSelection_C:CancelClosePanel()
  _G.NRCAudioManager:PlaySound2DAuto(41401014, "UMG_PetWarehouseMain_C:OnCloseBtnClicked")
  self:LoadAnimation(2)
end

function UMG_QuickSelection_C:ClosePanel()
  _G.NRCAudioManager:PlaySound2DAuto(41401002, "UMG_PetWarehouseMain_C:OnCloseBtnClicked")
  self:LoadAnimation(2)
end

function UMG_QuickSelection_C:OnAddEventListener()
  self:RegisterEvent(self, PetUIModuleEvent.AddOrRemoveItemFromBatchList, self.AddOrRemoveItemFromBatchList)
end

function UMG_QuickSelection_C:OnPcClose()
  if self:IsPlayingAnimation() then
    return
  end
  self:ClosePanel()
end

function UMG_QuickSelection_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

return UMG_QuickSelection_C
