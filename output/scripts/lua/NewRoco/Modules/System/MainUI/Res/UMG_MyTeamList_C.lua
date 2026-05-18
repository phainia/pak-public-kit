local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_MyTeamList_C = Base:Extend("UMG_MyTeamList_C")

function UMG_MyTeamList_C:OnConstruct()
end

function UMG_MyTeamList_C:OnDestruct()
end

function UMG_MyTeamList_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self:PCKeyShow(self.index)
  self.petList1 = _data.petList
  self.IsMainTeam = _data.IsMainTeam
  self.team = _data.team
  self.ParentPanel = _data.Panel
  self.IsEmptyTeam = self:GetIsEmptyTeam(self.petList1)
  self.PetList:InitGridView(self.petList1)
  if self.IsMainTeam then
    self.AtPresent:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.AtPresent:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self:SetCurTeamNameAndBloodLineMagic()
end

function UMG_MyTeamList_C:PCKeyShow(_index)
  self.Text_PCKey:SetText(_index)
  self.Text_PCKey:SetKeyVisibility(true)
end

function UMG_MyTeamList_C:GetIsEmptyTeam(petList)
  local IsEmptyTeam = true
  for i, v in ipairs(petList) do
    if "nil" ~= v then
      IsEmptyTeam = false
      break
    end
  end
  return IsEmptyTeam
end

function UMG_MyTeamList_C:SetCurTeamNameAndBloodLineMagic()
  local default_name = _G.DataConfigManager:GetPetGlobalConfig("mainworld_team_default_name").str
  local CurPetTeam = self.team
  if CurPetTeam.team_name then
    self.TeamName:SetText(CurPetTeam.team_name)
  else
    self.TeamName:SetText(string.format(default_name, self.index))
  end
  local BagItemS = _G.NRCModuleManager:DoCmd(BagModuleCmd.GetBagItemArrayByType, Enum.BagItemType.BI_PLAYERSKILL)
  local IsHasBlood = BagItemS and #BagItemS > 0 and true or false
  if IsHasBlood and CurPetTeam.role_magic_gid and CurPetTeam.role_magic_gid > 0 then
    for i, BagItem in ipairs(BagItemS) do
      if BagItem.gid == CurPetTeam.role_magic_gid then
        local BagItemConf = _G.DataConfigManager:GetBagItemConf(BagItem.id)
        if BagItemConf then
          self.MagicIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
          self.MagicIcon:SetPath(BagItemConf.icon)
        end
      end
    end
  else
    self.MagicIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_MyTeamList_C:OnDespawn()
  if self._parent and self._parent._selectedItemIndex == self.index then
    self:StopAllAnimations()
    local Num = self.PetList:GetItemCount()
    for i = 1, Num do
      local item = self.PetList:GetItemByIndex(i - 1)
      item.NRCSwitcher_0:SetActiveWidgetIndex(0)
    end
    self:PlayAnimation(self.Normal)
  end
end

function UMG_MyTeamList_C:OnTouchStarted(MyGeometry, InTouchEvent)
  self.IsTouchStart = true
  Base.OnTouchStarted(self, MyGeometry, InTouchEvent)
  return UE4.UWidgetBlueprintLibrary.Handled()
end

function UMG_MyTeamList_C:OnTouchEnded(MyGeometry, InTouchEvent)
  if self.IsTouchStart then
    Base.OnTouchEnded(self, MyGeometry, InTouchEvent)
  end
  return UE4.UWidgetBlueprintLibrary.Handled()
end

function UMG_MyTeamList_C:OnItemSelected(_bSelected, _bScroll)
  if _bSelected then
    _G.NRCAudioManager:PlaySound2DAuto(40002006, "UMG_MyTeamList_C:OnItemSelected")
    if self.IsEmptyTeam then
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, _G.LuaText.mainworld_use_empty_team_tips)
    else
      self:PlayAnimation(self.Select)
      local Num = self.PetList:GetItemCount()
      for i = 1, Num do
        local item = self.PetList:GetItemByIndex(i - 1)
        item.NRCSwitcher_0:SetActiveWidgetIndex(1)
      end
      self.ParentPanel:SetCurTeamIndex(self.index)
    end
  else
    if _bScroll then
      self:StopAllAnimations()
      local Num = self.PetList:GetItemCount()
      for i = 1, Num do
        local item = self.PetList:GetItemByIndex(i - 1)
        item.NRCSwitcher_0:SetActiveWidgetIndex(0)
      end
      self:PlayAnimation(self.Normal)
    end
    if self.IsEmptyTeam then
    else
      local Num = self.PetList:GetItemCount()
      for i = 1, Num do
        local item = self.PetList:GetItemByIndex(i - 1)
        item.NRCSwitcher_0:SetActiveWidgetIndex(0)
      end
      self:PlayAnimationReverse(self.Select)
    end
  end
end

function UMG_MyTeamList_C:OnDeactive()
end

return UMG_MyTeamList_C
