local PetUtils = require("NewRoco.Utils.PetUtils")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")
local UIUtils = require("NewRoco.Utils.UIUtils")
local UMG_PetItemTemplate1_C = Base:Extend("UMG_PetItemTemplate1_C")

function UMG_PetItemTemplate1_C:OnConstruct()
  self.ScrollType = UIUtils.ScrollPageItemType.PetWareHouseExchange
end

function UMG_PetItemTemplate1_C:OnDestruct()
end

function UMG_PetItemTemplate1_C:OnItemUpdate(_data, datalist, index)
  self._data = _data.data
  self.PetData = _data.data
  self.IsChangeItem = _data.IsChangeItem
  self.ParentPanel = _data.panel
  self.index = index
  self.isTeamItem = _data.isTeamItem
  if self.PetData then
    self.IsMainTeam = _G.DataModelMgr.PlayerDataModel:GetIsTeamPetByGid(self.PetData.gid)
  else
    self.IsMainTeam = false
  end
  self:SetData()
end

function UMG_PetItemTemplate1_C:SetData()
  if self.PetData then
    self.hasPet = true
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.PetData.base_conf_id)
    if petBaseConf then
      if self.PetData.partner_mark and self.PetData.partner_mark ~= ProtoEnum.PetPartnerMarkType.PPMT_NONE then
        self.CollectCanvas:SetVisibility(UE4.ESlateVisibility.Visible)
        self.Star:SetVisibility(UE4.ESlateVisibility.Visible)
        self.Star:SetPath(PetUtils.GetPetCollectTagIcon(self.PetData.partner_mark))
      else
        self.CollectCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
      local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
      local icon = modelConf.icon
      if PetMutationUtils.GetMutationValue(self.PetData.mutation_type, _G.Enum.MutationDiffType.MDT_SHINING) then
        icon = modelConf.shiny_icon
      end
      self.ItemIcon:SetIconPathAndMaterial(self.PetData.base_conf_id, self.PetData.mutation_type, self.PetData.glass_info)
      self.ItemIconMask:SetPath(icon)
      local pos = self.NumText.Slot:GetPosition()
      if self.PetData.level < 10 then
        pos.x = 44
      else
        pos.x = 24
      end
      self.NumText.Slot:SetPosition(pos)
      self.NumText:SetText(self.PetData.level)
      self.ItemIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.NumText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.TextBG:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    if self.IsChangeItem then
      self.TagIcon_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.TheHoodBlack:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.ItemIconMask:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.ChangeBg:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.MaskIcon_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.clickable = false
    else
      if self.IsMainTeam then
      end
      self.TheHoodBlack:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.ItemIconMask:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.ChangeBg:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.MaskIcon_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.clickable = true
    end
    self.Add:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.clickable = true
    self.hasPet = false
    self.TagIcon_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.ItemIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.ItemIconMask:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.NumText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local pos = self.NumText.Slot:GetPosition()
    pos.x = 24
    self.NumText.Slot:SetPosition(pos)
    self.NumText:SetText("--")
    self.TextBG:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.MaskIcon_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.TheHoodBlack:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Add:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.ChangeBg:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.CollectCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_PetItemTemplate1_C:OnDespawn()
  if self._parent._selectedItemIndex == self.index then
    self:StopAllAnimations()
    self.NumText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("908F85FF"))
    self:PlayAnimation(self.UnSelect)
  end
end

function UMG_PetItemTemplate1_C:CancelAllDelay()
  if self.DelayHandle then
    _G.DelayManager:CancelDelayById(self.DelayHandle)
    self.DelayHandle = nil
  end
end

function UMG_PetItemTemplate1_C:OnTouchStarted(_MyGeometry, _TouchEvent)
  self:CancelAllDelay()
  self.DelayHandle = _G.DelayManager:DelaySeconds(0.3, self.LongPress, self)
  Base.OnTouchStarted(self, _MyGeometry, _TouchEvent)
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_PetItemTemplate1_C:OnMouseLeave(_MyGeometry, _TouchEvent)
  self:CancelAllDelay()
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_PetItemTemplate1_C:CancelAllDelay()
  if self.DelayHandle then
    _G.DelayManager:CancelDelayById(self.DelayHandle)
    self.DelayHandle = nil
  end
end

function UMG_PetItemTemplate1_C:LongPress()
  if self.hasPet then
    _G.NRCModeManager:DoCmd(PetUIModuleCmd.ShowChangePetConfirm, self.PetData)
  end
end

function UMG_PetItemTemplate1_C:OnTouchEnded(_MyGeometry, _TouchEvent)
  self:CancelAllDelay()
  Base.OnTouchEnded(self, _MyGeometry, _TouchEvent)
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_PetItemTemplate1_C:OnItemSelected(_bSelected, _bScrolled)
  if _bSelected then
    if self.canOpenTips and not _bScrolled then
    else
      self.NumText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("F4EEE1FF"))
      self.SelectedbBg:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      if self.PetData then
        self.TextBG_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
      self:StopAllAnimations()
      self:PlayAnimation(self.Select)
      self.canOpenTips = true
    end
    local gid = self.PetData and self.PetData.gid
    self.ParentPanel:OnSelectChangeMainPetItem(self.index, gid, self.isTeamItem)
  else
    self:StopAllAnimations()
    self.NumText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("908F85FF"))
    self:PlayAnimation(self.UnSelect)
    self.canOpenTips = false
  end
end

function UMG_PetItemTemplate1_C:OnAnimationFinished(anim)
  if anim == self.UnSelect then
    self.SelectedbBg:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.TextBG_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif anim == self.Select then
  end
end

function UMG_PetItemTemplate1_C:OnDeactive()
end

return UMG_PetItemTemplate1_C
