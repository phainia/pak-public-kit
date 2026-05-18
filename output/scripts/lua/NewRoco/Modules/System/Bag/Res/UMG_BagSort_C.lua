local BagModuleEvent = require("NewRoco.Modules.System.Bag.BagModuleEvent")
local UMG_BagSort_C = _G.NRCPanelBase:Extend("UMG_BagSort_C")

function UMG_BagSort_C:OnConstruct()
  self:SetChildViews(self.PopUp3)
end

function UMG_BagSort_C:OnDestruct()
end

function UMG_BagSort_C:OnActive(sortList, sortIndex, bskipSound)
  if not bskipSound then
    _G.NRCAudioManager:PlaySound2DAuto(41400002, "UMG_BagSort_C:OnActive")
  end
  self.data = self.module:GetData("BagModuleData")
  self:LoadAnimation(0)
  self:OnAddEventListener()
  self:AddPcInputBlock()
  self:SetCommonPopUpInfo(self.PopUp3)
  sortIndex = sortIndex or 1
  self.SortList:InitGridView(sortList)
  for i = 1, self.SortList:GetItemCount() do
    local item = self.SortList:GetItemByIndex(i - 1)
    if item.data.sequence == sortIndex then
      item.CanPlayAudio = false
      self.SortList:SelectItemByIndex(i - 1)
      break
    end
  end
end

function UMG_BagSort_C:OnDeactive()
  self:RemovePcInputBlock()
end

function UMG_BagSort_C:SetCommonPopUpInfo(PopUp, TitleText, TitleIcon)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  if TitleText then
    CommonPopUpData.TitleText = TitleText
  end
  if TitleIcon then
    CommonPopUpData.TitleIcon = TitleIcon
  end
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.OnBtnClose
  CommonPopUpData.Btn_RightHandler = self.OnBtnSort
  CommonPopUpData.ClosePanelHandler = self.OnBtnClose
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_BagSort_C:AddPcInputBlock()
end

function UMG_BagSort_C:RemovePcInputBlock()
end

function UMG_BagSort_C:OnAddEventListener()
end

function UMG_BagSort_C:OnPcClose()
  self:OnBtnClose()
end

function UMG_BagSort_C:OnBtnSort()
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_Bag_BXTips_C:OnClose")
  for i = 1, self.SortList:GetItemCount() do
    local item = self.SortList:GetItemByIndex(i - 1)
    if item.CurSelected == true then
      _G.NRCEventCenter:DispatchEvent(BagModuleEvent.UpdateSort, i, item.data)
      break
    end
  end
  self:OnBtnClose(true)
end

function UMG_BagSort_C:OnBtnClose(Ok)
  if Ok then
  else
    _G.NRCAudioManager:PlaySound2DAuto(41401002, "UMG_Bag_BXTips_C:OnClose")
  end
  _G.NRCAudioManager:PlaySound2DAuto(41400003, "UMG_Bag_BXTips_C:OnClose")
  self:LoadAnimation(2)
end

function UMG_BagSort_C:OnAnimationFinished(aim)
  if aim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

return UMG_BagSort_C
