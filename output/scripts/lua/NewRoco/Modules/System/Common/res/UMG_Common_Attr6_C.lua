local Base = require("NewRoco.Modules.System.Common.res.CommonAttrBase")
local UMG_Common_Attr6_C = Base:Extend("UMG_Common_Attr6_C")

function UMG_Common_Attr6_C:OnTouchStarted(MyGeometry, InTouchEvent)
  _G.NRCEventCenter:RegisterEvent("UMG_PetImage3D_C", self, _G.NRCGlobalEvent.OnRocoTouchEnd, self.OnRocoTouchEndHandler)
  self:PlayAnimation(self.Press)
  Base.OnTouchStarted(self, MyGeometry, InTouchEvent)
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_Common_Attr6_C:OnRocoTouchEndHandler(MyGeometry, InTouchEvent)
  self:PlayAnimation(self.Up)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.OnRocoTouchEnd, self.OnRocoTouchEndHandler)
end

function UMG_Common_Attr6_C:OnItemSelected(_bSelected)
  if _bSelected and not self.IsIgnore and self.needBloodItemList and self.needBloodItemList.NeedItemList then
    self:OpenSoloveBloodDiff()
  end
end

function UMG_Common_Attr6_C:OpenSoloveBloodDiff()
  if self.needBloodItemList and self.needBloodItemList.NeedItemList then
    NRCModuleManager:DoCmd(PetUIModuleCmd.OpenTeamChangeBloodPanel, self.needBloodItemList)
  end
end

function UMG_Common_Attr6_C:HideDiffMark()
  self.IsIgnore = true
  self.QuestionMark:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.HighlightOutline:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Common_Attr6_C:OnItemUpdate(_data, datalist, index)
  if type(_data) == "table" then
    self.QuestionMark.btnLevelUp:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.data = _data
    if _data.needBloodItemList and _data.needBloodItemList.NeedItemList then
      self.needBloodItemList = _data.needBloodItemList
      if not self.needBloodItemList.IsIgnore then
        self.HighlightOutline:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self.QuestionMark:SetVisibility(UE4.ESlateVisibility.Visible)
      else
        self.QuestionMark:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self.HighlightOutline:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    else
      self.needBloodItemList = nil
      self.QuestionMark:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.HighlightOutline:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  else
    self.data = {Type = _data}
  end
  self.index = index
  self:SetInfo(self.data)
end

function UMG_Common_Attr6_C:OnItemClicked(bClicked)
  if bClicked and self.data.Callback then
    self.data.Callback()
  end
end

return UMG_Common_Attr6_C
