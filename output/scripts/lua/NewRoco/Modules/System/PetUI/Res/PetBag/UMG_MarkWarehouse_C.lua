local UMG_MarkWarehouse_C = _G.NRCPanelBase:Extend("UMG_MarkWarehouse_C")
local PetUIModuleEvent = require("NewRoco.Modules.System.PetUI.PetUIModuleEvent")

function UMG_MarkWarehouse_C:OnConstruct()
  self:SetChildViews(self.PopUp4)
end

function UMG_MarkWarehouse_C:OnActive(box_data)
  if box_data then
    self.CurEditorBoxId = box_data.id
    self.CurMarkType = box_data.mark_type
  end
  self:OnAddEventListener()
  self:PlayAnimation(self:GetAnimByIndex(0))
  self:SetCommonPopUpInfo(self.PopUp4)
  local playerInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerPetInfo()
  local mark_unlock_info = playerInfo.backpack_info and playerInfo.backpack_info.mark_unlock_info or 0
  self.confs = _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.GetAllWarehousCollectMarkConfigs)
  local markInfos = {}
  local index
  for i, cfg in pairs(self.confs or {}) do
    local info = {
      conf = cfg,
      isUnlock = self:GetMarkFlag(mark_unlock_info, cfg.mark_type)
    }
    table.insert(markInfos, info)
    if cfg.mark_type == self.CurMarkType then
      index = i
    end
  end
  self.FilterList:InitGridView(markInfos)
  if index then
    self.FilterList:SelectItemByIndex(index - 1)
  end
end

function UMG_MarkWarehouse_C:GetMarkFlag(mark_info, mark_type)
  return mark_info & mark_type == mark_type
end

function UMG_MarkWarehouse_C:OnDeactive()
  NRCEventCenter:UnRegisterEvent(self, PetUIModuleEvent.OnSwitchPetBoxMark, self.OnSwitchPetBoxMark)
end

function UMG_MarkWarehouse_C:OnAddEventListener()
  NRCEventCenter:RegisterEvent("UMG_MarkWarehouse_C", self, PetUIModuleEvent.OnSwitchPetBoxMark, self.OnSwitchPetBoxMark)
end

function UMG_MarkWarehouse_C:SetCommonPopUpInfo(PopUp)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.OnBtnCancelClick
  CommonPopUpData.Btn_RightHandler = self.OnBtnOkClick
  CommonPopUpData.ClosePanelHandler = self.OnPanelClose
  CommonPopUpData.Btn_RightGrayStatHandler = self.OnBtnOkClick
  CommonPopUpData.TitleText = LuaText.select_box_icon_titile
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_MarkWarehouse_C:OnBtnCancelClick()
  _G.NRCAudioManager:PlaySound2DAuto(41401002, "UMG_MarkWarehouse_C:OnBtnCancelClick")
  if self:IsAnimationPlaying(self:GetAnimByIndex(2)) then
    return
  end
  self:PlayAnimation(self:GetAnimByIndex(2))
end

function UMG_MarkWarehouse_C:OnPanelClose()
  _G.NRCAudioManager:PlaySound2DAuto(41401014, "UMG_MarkWarehouse_C:OnPanelClose")
  if self:IsAnimationPlaying(self:GetAnimByIndex(2)) then
    return
  end
  self:PlayAnimation(self:GetAnimByIndex(2))
end

function UMG_MarkWarehouse_C:OnBtnOkClick()
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_MarkWarehouse_C:OnBtnOkClick")
  if self.CurEditorBoxId then
    local curSelectMarkType = _G.Enum.WarehouseMarkType.WMT_DEFAULT
    local isUnLock = false
    for i = 1, self.FilterList:GetItemCount() do
      local item = self.FilterList:GetItemByIndex(i - 1)
      if item.selected then
        curSelectMarkType = item.mark_type
        isUnLock = item.data.isUnlock
        break
      end
    end
    if isUnLock then
      if self.CurMarkType ~= curSelectMarkType then
        _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OnCmdZonePetBoxSetMarkTypeReq, self.CurEditorBoxId, curSelectMarkType)
      end
      self:OnBtnCancelClick()
    elseif LuaText.warehouse_mark_lock then
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.warehouse_mark_lock)
    end
  end
end

function UMG_MarkWarehouse_C:OnSwitchPetBoxMark(mark_type, is_unlock)
  if is_unlock then
    self.PopUp4:SetBtnRightEnableState(true)
  else
    self.PopUp4:SetBtnRightEnableState(false)
  end
  local Desc = self:GetMarkDesc(mark_type, is_unlock)
  if Desc then
    self.PopUp4:SetDescInfo(Desc)
  end
end

function UMG_MarkWarehouse_C:GetMarkDesc(mark_type, is_unlock)
  for _, conf in pairs(self.confs or {}) do
    if conf and conf.mark_type == mark_type then
      if mark_type == _G.Enum.WarehouseMarkType.WMT_DEFAULT then
        return conf.mark_desc_text
      elseif is_unlock then
        return conf.mark_desc_text
      elseif conf.mark_unlock_text and conf.mark_unlock_amount then
        local str = string.format(conf.mark_unlock_text, conf.mark_unlock_amount)
        return str
      end
    end
  end
  return nil
end

function UMG_MarkWarehouse_C:OnAnimationFinished(Anim)
  if Anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

return UMG_MarkWarehouse_C
