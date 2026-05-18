local LevelSelectionModuleEvent = require("NewRoco.Modules.System.LevelSelection.LevelSelectionModuleEvent")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local PetUtils = require("NewRoco.Utils.PetUtils")
local UMG_Level_ListItem_Pet_C = Base:Extend("UMG_Level_ListItem_Pet_C")

function UMG_Level_ListItem_Pet_C:OnConstruct()
  self.StartPressTime = 0
  self.LongPressTime = 0.5
end

function UMG_Level_ListItem_Pet_C:OnDestruct()
end

function UMG_Level_ListItem_Pet_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  self.curSelectIdx = 0
  self:StopAllAnimations()
  self.isPetTravel = true
  self.LongPressTime = 0.5
  self.CollectCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if self.data then
    local selectIdx = _G.NRCModuleManager:DoCmd(_G.LevelSelectionModuleCmd.OnCmdGetPetDataSelectIdx, self.data.gid)
    self.isPetTravel = _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.GetPetIsTravel, self.data.gid)
    self.curSelectIdx = selectIdx
    if 0 ~= selectIdx then
      self:PlayAnimation(self.select)
      self.number:SetVisibility(UE4.ESlateVisibility.Visible)
      self.Text_number:SetText(selectIdx)
      self:OnShowCollect(false)
    else
      self:PlayAnimation(self.Normal)
      self.number:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self:OnShowCollect(true)
    end
    self.pet:SetIconPathAndMaterial(self.data.base_conf_id, self.data.mutation_type, self.data.glass_info)
    self.Star:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Text_Quantity:SetText(self.data.level)
  else
    self.Star:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Obturation:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.NRCImage_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.NRCImage_57:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.Travel:SetVisibility(self.isPetTravel and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
end

function UMG_Level_ListItem_Pet_C:OnShowCollect(_bShow)
  if _bShow and self.data.partner_mark and self.data.partner_mark ~= ProtoEnum.PetPartnerMarkType.PPMT_NONE then
    self.Star:SetPath(PetUtils.GetPetCollectTagIcon(self.data.partner_mark))
    self.CollectCanvas:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.CollectCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Level_ListItem_Pet_C:OnItemSelected(_bSelected)
  if _bSelected then
    if self.isPetTravel then
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_petwarehousemain_8)
      return
    end
    local selectIdx = _G.NRCModuleManager:DoCmd(_G.LevelSelectionModuleCmd.OnCmdCompileCurrentTeam, self.data.gid)
    if 0 == selectIdx then
      if self.curSelectIdx ~= selectIdx then
        self:PlayAnimation(self.out)
        self:OnShowCollect(true)
      else
        _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.challenge_text_11)
      end
    else
      self.number:SetVisibility(UE4.ESlateVisibility.Visible)
      self.Text_number:SetText(selectIdx)
      self:PlayAnimation(self.select)
      self:OnShowCollect(false)
    end
    _G.NRCEventCenter:DispatchEvent(LevelSelectionModuleEvent.OnShowPetDataRight, self.data)
    self.curSelectIdx = selectIdx
  end
end

function UMG_Level_ListItem_Pet_C:OnDeactive()
end

function UMG_Level_ListItem_Pet_C:UnRegister()
  _G.UpdateManager:UnRegister(self)
  _G.NRCModeManager:DoCmd(LevelSelectionModuleCmd.OnCmdSetLevelListItemPet, nil)
end

function UMG_Level_ListItem_Pet_C:OnTouchStarted(MyGeometry, InTouchEvent)
  self.IsClick = true
  self.StartPressTime = 0
  self.StartTime = 0
  _G.UpdateManager:Register(self)
  _G.NRCModeManager:DoCmd(LevelSelectionModuleCmd.OnCmdSetLevelListItemPet, self)
  Base.OnTouchStarted(self, MyGeometry, InTouchEvent)
  return UE4.UWidgetBlueprintLibrary.Handled()
end

function UMG_Level_ListItem_Pet_C:OnTouchEnded(MyGeometry, InTouchEvent)
  Base.OnTouchEnded(self, MyGeometry, InTouchEvent)
  self.IsClick = false
  self:UnRegister()
  return UE4.UWidgetBlueprintLibrary.Handled()
end

function UMG_Level_ListItem_Pet_C:OnMouseLeave(MyGeometry, MouseEvent)
  self.IsClick = false
  self:UnRegister()
end

function UMG_Level_ListItem_Pet_C:OnTick(InDeltaTime)
  if self.IsClick then
    self.StartPressTime = self.StartPressTime + InDeltaTime
  end
  if self.StartPressTime >= self.LongPressTime then
    self.StartPressTime = 0
    self.IsLongPress = true
  end
  if self.IsLongPress then
    self.IsClick = false
    self.StartPressTime = 0
    self.StartTime = 0
    self.IsLongPress = false
    self:UnRegister()
    if self.data then
      _G.NRCEventCenter:DispatchEvent(LevelSelectionModuleEvent.OnShowPetDataRight, self.data)
      _G.NRCEventCenter:DispatchEvent(LevelSelectionModuleEvent.OnIsHideArrayRight, true)
    end
  end
end

function UMG_Level_ListItem_Pet_C:OnAnimationFinished(anim)
end

function UMG_Level_ListItem_Pet_C:OnSwitcherSwitcher_bg(SwitcherIndex)
  self.Switcher_bg:SetActiveWidgetIndex(SwitcherIndex)
end

return UMG_Level_ListItem_Pet_C
