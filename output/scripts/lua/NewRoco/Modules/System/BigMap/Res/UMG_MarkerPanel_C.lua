local BigMapModuleEvent = reload("NewRoco.Modules.System.BigMap.BigMapModuleEvent")
local UMG_MarkerPanel_C = _G.NRCViewBase:Extend("UMG_MarkerPanel_C")

function UMG_MarkerPanel_C:OnConstruct()
  self.SelectCustomMarkerIndex = nil
  self.firstSelectMark = true
  self.SelectMarkerInfo = nil
  self.MarkerInfo = nil
  self.lockBtn = false
  self:SetBtnInfo()
  self:OnAddEventListener()
end

function UMG_MarkerPanel_C:OnDestruct()
end

function UMG_MarkerPanel_C:OnActive()
end

function UMG_MarkerPanel_C:OnAddEventListener()
  self:AddButtonListener(self.MarkerBtn.btnLevelUp, self.OnClickMarkerBtn)
  self:AddButtonListener(self.RemoveBtn.btnLevelUp, self.OnClickRemoveBtn)
  self:AddButtonListener(self.ReplaceBtn.btnLevelUp, self.OnClickReplaceBtn)
  self:AddButtonListener(self.RemoveAmend.btnLevelUp, self.OnClickRemoveAmend)
  self:RegisterEvent(self, BigMapModuleEvent.UpdateSelectMarkerInfo, self.UpdateSelectMarker)
end

function UMG_MarkerPanel_C:OnClickMarkerBtn()
  if self.lockBtn then
    return
  end
  self.lockBtn = true
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(41401004, "UMG_MarkerPanel_C:OnClickMarkerBtn")
  _G.NRCModuleManager:DoCmd(BigMapModuleCmd.MapMarkOperate, _G.ProtoEnum.MapMarkOpType.MMOT_RELATE_POS, self.SelectMarkerInfo.Index, self.SelectMarkerInfo.SelectScenePos)
end

function UMG_MarkerPanel_C:OnClickRemoveBtn()
  if self.lockBtn then
    return
  end
  self.lockBtn = true
  _G.NRCAudioManager:PlaySound2DAuto(41400003, "UMG_MarkerPanel_C:OnClickRemoveBtn")
  _G.NRCModuleManager:DoCmd(BigMapModuleCmd.MapMarkOperate, _G.ProtoEnum.MapMarkOpType.MMOT_DELETE_MARK, self.SelectMarkerInfo.Index)
end

function UMG_MarkerPanel_C:OnClickReplaceBtn()
  if self.lockBtn then
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_MarkerPanel_C:OnClickRemoveBtn")
  self.lockBtn = true
  local OldMarker = self.SelectMarkerInfo.Index
  local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
  local LocalizationConf = _G.DataConfigManager:GetLocalizationConf("World_Map_Mark_Replace_Tips")
  local TipsContent = string.format(LocalizationConf.msg, OldMarker)
  local dialogContext = DialogContext()
  dialogContext:SetContent(TipsContent):SetMode(DialogContext.Mode.OK_CANCEL):SetButtonText(LuaText.YES, LuaText.NO):SetCloseOnCancel(true):SetCallback(self, self.ConfirmReplace)
  NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, dialogContext)
end

function UMG_MarkerPanel_C:ConfirmReplace(_ok)
  self.lockBtn = false
  if _ok then
    if self.SelectMarkerInfo and self.SelectMarkerInfo.IsOnClickCustomMarker == true then
      _G.NRCModuleManager:DoCmd(BigMapModuleCmd.MapMarkOperate, _G.ProtoEnum.MapMarkOpType.MMOT_REPLACE_POS, self.SelectCustomMarkerIndex + 1, nil, self.SelectMarkerInfo.Index)
    else
      _G.NRCModuleManager:DoCmd(BigMapModuleCmd.MapMarkOperate, _G.ProtoEnum.MapMarkOpType.MMOT_REPLACE_POS, self.SelectMarkerInfo.Index, self.SelectMarkerInfo.SelectScenePos)
    end
  end
end

function UMG_MarkerPanel_C:OnClickRemoveAmend()
  if self.lockBtn then
    return
  end
  self.lockBtn = true
  _G.NRCAudioManager:PlaySound2DAuto(1004, "UMG_MarkerPanel_C:OnClickRemoveBtn")
  _G.NRCModuleManager:DoCmd(BigMapModuleCmd.MapMarkOperate, _G.ProtoEnum.MapMarkOpType.MMOT_UPDATE_MARK, self.SelectCustomMarkerIndex + 1, nil, self.SelectMarkerInfo.Index)
end

function UMG_MarkerPanel_C:OnDeactive()
end

function UMG_MarkerPanel_C:UpdateSelectMarker(_SelectMarkerInfo)
  if not self.firstSelectMark then
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1072, "UMG_Customdot_C:OnItemSelected")
  else
    self.firstSelectMark = false
  end
  self.SelectMarkerInfo = _SelectMarkerInfo
  if self.SelectMarkerInfo.IsOnClickCustomMarker == true then
    if self.SelectCustomMarkerIndex == self.SelectMarkerInfo.Index - 1 then
      self.btnSwitcher:SetActiveWidgetIndex(1)
    elseif true == self.SelectMarkerInfo.IsMarker then
      self.btnSwitcher:SetActiveWidgetIndex(2)
    else
      self.btnSwitcher:SetActiveWidgetIndex(3)
    end
  elseif true == self.SelectMarkerInfo.IsMarker then
    self.btnSwitcher:SetActiveWidgetIndex(2)
  else
    self.btnSwitcher:SetActiveWidgetIndex(0)
  end
end

function UMG_MarkerPanel_C:InitPanelData(_Data)
  self.MarkerInfo = _Data
  self.lockBtn = false
  self:SetMarkerList()
end

function UMG_MarkerPanel_C:SetMarkerList()
  local MarkerPanelInfo = self.MarkerInfo
  local IsMarkerAllInfo, Index = self:IsMarkerAll()
  if MarkerPanelInfo.IsOnClickCustomMarker == true then
    self.SelectCustomMarkerIndex = MarkerPanelInfo.CustomMarkerIndex - 1
  elseif IsMarkerAllInfo then
    self.SelectCustomMarkerIndex = Index
  else
    self.SelectCustomMarkerIndex = Index - 1
  end
  self.dotList:InitGridView(MarkerPanelInfo.DotList)
  self.dotList:SelectItemByIndex(self.SelectCustomMarkerIndex)
end

function UMG_MarkerPanel_C:IsMarkerAll()
  local DotList = self.MarkerInfo.DotList
  for i, v in ipairs(DotList) do
    if v.IsMarker == false then
      return false, i
    end
  end
  return true, 0
end

function UMG_MarkerPanel_C:OnPanelShow(_isShow)
  if _isShow then
    _G.NRCProfilerLog:NRCPanelOpenAnimation(true, self.panelName)
    self:PlayAnimation(self.open)
  else
    self:PlayAnimation(self.close)
  end
end

function UMG_MarkerPanel_C:OnAnimationFinished(Animation)
  if Animation == self.open then
    _G.NRCProfilerLog:NRCPanelOpenAnimation(false, self.panelName)
    self:PlayAnimation(self.loop)
  end
end

function UMG_MarkerPanel_C:SetBtnInfo()
  self.MarkerBtn:SetBtnText(LuaText.umg_markerpanel_1)
  self.RemoveBtn:SetBtnText(LuaText.umg_markerpanel_2)
  self.ReplaceBtn:SetBtnText(LuaText.umg_markerpanel_3)
  self.RemoveAmend:SetBtnText(LuaText.umg_markerpanel_4)
end

return UMG_MarkerPanel_C
