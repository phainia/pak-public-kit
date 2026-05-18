local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local PetUtils = require("NewRoco.Utils.PetUtils")
local PetUIModuleEnum = require("NewRoco.Modules.System.PetUI.PetUIModuleEnum")
local UMG_PetGrowUpPanel_C = _G.NRCPanelBase:Extend("UMG_PetGrowUpPanel_C")

function UMG_PetGrowUpPanel_C:OnConstruct()
  _G.NRCProfilerLog:NRCPanelOpenAnimation(true, self.panelName)
  self:PlayAnimation(self.In, 0, 1, 0, 1.5)
  self.IsMoveUp = false
  self.IsLock = true
  self.PetGrowUpType = PetUIModuleEnum.PetGrowUpType.None
  self.GrowPropertyInfo = nil
  self.changes = nil
  self:OnAddEventListener()
end

function UMG_PetGrowUpPanel_C:OnDestruct()
end

function UMG_PetGrowUpPanel_C:OnActive(_changes, GrowUpType, GrowPropertyInfo, _PetBeForePropertyInfo, oldPetData, Property)
  self.PetGrowUpType = GrowUpType
  self.GrowPropertyInfo = GrowPropertyInfo
  self.PetBeForePropertyInfo = _PetBeForePropertyInfo
  local changes = _changes
  if changes then
    for i, changItem in ipairs(changes) do
      if changItem.type == ProtoEnum.GoodsType.GT_PET then
        self.uiData = changItem.pet_data
      end
    end
  else
    Log.Error("UMG_PetGrowUpPanel_C:OnActive changes is nil")
  end
  self.List:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.CanvasPanel_169:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.CatchHardLv:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.CatchHardLv_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.CatchHardLv_pre:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.CatchHardLv_pre_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if self.PetGrowUpType == PetUIModuleEnum.PetGrowUpType.WaitToBreakThrough then
    self.catchLv = PetUtils.GetBreakThroughStarsList(self.uiData, true, true)
    self.OldCatchLv = PetUtils.GetBreakThroughStarsList(oldPetData, true, true)
    self.Property = Property
    self.targetDir = nil
    self.targetDist = nil
    self.starNum = 0
    self.CatchHardLv:InitGridView(self.catchLv)
    self.CatchHardLv_pre:InitGridView(self.OldCatchLv)
    self.CatchHardLv:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.CatchHardLv_pre:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:GetEndStarDir()
    self.posX = 0
    self.posY = 0
    self.CanvasPanel_72:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.NRCTitle:SetText(LuaText.umg_petlevelup_17)
    self.NRCSwitcher_60:SetActiveWidgetIndex(1)
    if self.NRC_Subtitle then
      self.NRC_Subtitle:SetText(LuaText.umg_petlevelup_23)
    end
  elseif self.PetGrowUpType == PetUIModuleEnum.PetGrowUpType.WaitToGrowUp then
    self.CanvasPanel_72:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.NRCTitle:SetText(LuaText.umg_petlevelup_17)
    self.NRCSwitcher_60:SetActiveWidgetIndex(0)
    if self.NRC_Subtitle then
      self.NRC_Subtitle:SetText(LuaText.umg_petlevelup_23)
    end
  elseif self.PetGrowUpType == PetUIModuleEnum.PetGrowUpType.WaitToInspire then
    self.catchLv = PetUtils.GetInspireStarsList(self.uiData)
    self.OldCatchLv = PetUtils.GetInspireStarsList(oldPetData)
    self.starNum = 0
    self.CatchHardLv_1:InitGridView(self.catchLv)
    self.CatchHardLv_pre_1:InitGridView(self.OldCatchLv)
    self.CatchHardLv_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.CatchHardLv_pre_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.NRCTitle:SetText(LuaText.inspire_text_1)
    if self.NRC_Subtitle then
      self.NRC_Subtitle:SetText(LuaText.inspire_text_7)
    end
    self:GetEndStarDir()
    self.posX = 0
    self.posY = 0
  end
  self.changes = _changes
  self:SetNumber()
  self:SetUpgradeTime()
  _G.NRCAudioManager:PlaySound2DAuto(40002015, "UMG_PetGrowUp_C:OnCloseBtnClick")
end

function UMG_PetGrowUpPanel_C:SetListInfo()
  local PetNewInfo = {}
  if self.PetGrowUpType == PetUIModuleEnum.PetGrowUpType.WaitToGrowUp then
    PetNewInfo = self.GrowPropertyInfo
  elseif self.PetGrowUpType == PetUIModuleEnum.PetGrowUpType.WaitToBreakThrough then
    self:SetBaseInfo()
    PetNewInfo = self.PetBeForePropertyInfo
  elseif self.PetGrowUpType == PetUIModuleEnum.PetGrowUpType.WaitToInspire then
    PetNewInfo = self.PetBeForePropertyInfo
    for i, v in pairs(PetNewInfo or {}) do
      if v then
        v.bTextBold = true
        v.TextColor = "62605E"
        if v.IsEffortLevel ~= nil and v.IsEffortLevel == false then
          v.TextColor = "D56C1F"
        end
      end
    end
  end
  self.List:InitGridView(PetNewInfo)
  if PetNewInfo and #PetNewInfo > 0 then
    for i, PetNew in ipairs(PetNewInfo) do
      local Item = self.List:GetItemByIndex(i - 1)
      if Item then
        Item:SetParent(self)
      end
    end
  elseif self.IsLock then
    self:SetLock()
  end
end

function UMG_PetGrowUpPanel_C:SetBaseInfo()
  local BaseInfo = self.Property
  if BaseInfo then
    self.CanvasPanel_169:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.NRC_NoChange_1:SetText(BaseInfo.attribute_name)
    self.NRCIcon:SetPath(BaseInfo.attribute_icon)
    self.NRC_NoChange:SetText(BaseInfo.PetBeforeProperty)
    self.NRC_Change:SetText(BaseInfo.PetLaterProperty)
  end
end

function UMG_PetGrowUpPanel_C:SetList(Info, Index, talent, AttributeType, name, PetNewInfo)
  local PetAddAttribute
  if Info then
    self.PetBeForePropertyInfo[Index].PetLaterProperty = self.PetBeForePropertyInfo[Index].PetLaterProperty
    self.PetBeForePropertyInfo[Index].GrowthProperty = talent
    local IsNewAdd = talent - self.PetBeForePropertyInfo[Index].PetLaterProperty
    if 0 ~= IsNewAdd then
      table.insert(PetNewInfo, self.PetBeForePropertyInfo[Index])
    end
  else
    PetAddAttribute = _G.DataConfigManager:GetAttributeConf(AttributeType)
    table.insert(PetNewInfo, {
      PetAddAttribute = PetAddAttribute,
      name = name,
      GrowthProperty = talent,
      IsShowNew = true
    })
  end
  return PetNewInfo
end

function UMG_PetGrowUpPanel_C:FindBeForePropertyInfo(_PetBeForePropertyInfo, _type)
  local PetBeForePropertyInfo = _PetBeForePropertyInfo
  local type = _type
  for i, Info in ipairs(PetBeForePropertyInfo) do
    if Info.type and Info.type == type then
      return Info, i
    end
  end
  return nil
end

function UMG_PetGrowUpPanel_C:GetEndStarDir()
  local StarNum = 0
  for k, v in ipairs(self.catchLv) do
    if 1 == v.IsShow then
      StarNum = StarNum + 1
    end
  end
  self.starNum = StarNum
  local targetPos = self.TargetPos.Slot:GetPosition()
  targetPos.X = targetPos.X + 15.0 * StarNum
  self.targetDir = targetPos - self.fX_TUPO.Slot:GetPosition()
  self.targetDist = ((targetPos.X - self.fX_TUPO.Slot:GetPosition().X) ^ 2 + (targetPos.Y - self.fX_TUPO.Slot:GetPosition().Y) ^ 2) ^ 0.5
  self.targetDir:Normalize()
end

function UMG_PetGrowUpPanel_C:OnTick(InDeltaTime)
  if self.IsMoveUp == true and self.posY ~= nil and self.posY >= self.TargetPos.Slot:GetPosition().Y then
    self.posX = self.posX + self.targetDist / 0.5 * InDeltaTime * self.targetDir.X
    self.posY = self.posY + self.targetDist / 0.5 * InDeltaTime * self.targetDir.Y
    local pos = UE4.FVector2D(self.posX, self.posY)
    self.fX_TUPO.Slot:SetPosition(pos)
  end
end

function UMG_PetGrowUpPanel_C:OnAddEventListener()
  self:AddButtonListener(self.btnCloseRenamePanel, self.OnCloseButtonClicked)
end

function UMG_PetGrowUpPanel_C:OnPcClose()
  self:OnCloseButtonClicked()
end

function UMG_PetGrowUpPanel_C:OnCloseButtonClicked()
  if self.IsLock then
    return
  end
  if self.PetGrowUpType ~= PetUIModuleEnum.PetGrowUpType.WaitToGrowUp then
    local IsClose = true
    for i, v in ipairs(self.catchLv) do
      if 0 == v.IsShow then
        IsClose = false
        break
      end
    end
    if true == IsClose then
      self:DispatchEvent(PetUIModuleEvent.CloseGrowUpSwitchCloseBtn)
      self:DispatchEvent(PetUIModuleEvent.RightPanelHideSubPanel)
      self:DispatchEvent(PetUIModuleEvent.RightPanelShowSubPanel, 1)
    end
  end
  self:SetLock()
  _G.NRCAudioManager:PlaySound2DAuto(40002016, "UMG_PetGrowUpPanel_C:OnCloseButtonClicked")
  self:PlayAnimation(self.out)
  self:DispatchEvent(PetUIModuleEvent.ResetIsInEvolution)
end

function UMG_PetGrowUpPanel_C:SetLock()
  self.IsLock = not self.IsLock
end

function UMG_PetGrowUpPanel_C:OnAnimationFinished(Animation)
  if Animation == self.In then
    _G.NRCProfilerLog:NRCPanelOpenAnimation(false, self.panelName)
    if self.PetGrowUpType ~= PetUIModuleEnum.PetGrowUpType.WaitToGrowUp then
      self.IsMoveUp = true
      for i = 1, #self.catchLv do
        table.insert(self.catchLv[i], {
          animIndex = self.starNum
        })
      end
      self.CatchHardLv:InitGridView(self.catchLv)
    end
    self.List:SetVisibility(UE4.ESlateVisibility.Visible)
    self:SetListInfo()
  elseif Animation == self.out then
    self:SetLock()
    self:DoClose()
  end
end

function UMG_PetGrowUpPanel_C:SetNumber()
  local PetData = self.uiData
  if not PetData then
    Log.Error("UMG_PetGrowUpPanel_C:SetNumber PetData is nil")
    return
  end
  if PetData.base_conf_id then
    local PetBaseConf = _G.DataConfigManager:GetPetbaseConf(PetData.base_conf_id)
    if PetBaseConf then
      self.NRCText_50:SetText(string.format("%03d", PetBaseConf.pictorial_book_id or 0))
    end
  end
end

function UMG_PetGrowUpPanel_C:SetUpgradeTime()
  local nowTimePoke = math.floor(_G.ZoneServer:GetServerTime() / 1000)
  local ban_time = os.date("%Y.%m.%d", nowTimePoke)
  self.NRCText_96:SetText(ban_time)
end

function UMG_PetGrowUpPanel_C:OnDeactive()
end

return UMG_PetGrowUpPanel_C
