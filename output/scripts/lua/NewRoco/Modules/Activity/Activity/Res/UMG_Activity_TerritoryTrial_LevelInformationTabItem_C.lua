local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Activity_TerritoryTrial_LevelInformationTabItem_C = Base:Extend("UMG_Activity_TerritoryTrial_LevelInformationTabItem_C")

function UMG_Activity_TerritoryTrial_LevelInformationTabItem_C:OnConstruct()
end

function UMG_Activity_TerritoryTrial_LevelInformationTabItem_C:OnDestruct()
end

function UMG_Activity_TerritoryTrial_LevelInformationTabItem_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  local selected_index = _data.caller:GetSelectedIndex()
  if selected_index then
    self:StopAllAnimations()
    if index == selected_index then
      self:PlayAnimation(self.change1, self.change1:GetEndTime() - 0.01)
      self._bSelected = true
    else
      self:PlayAnimation(self.change2, self.change2:GetEndTime() - 0.01)
      self._bSelected = false
    end
  end
  self.Title:SetText(_data.name)
  if not _data.bBoss then
    self.icon_1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Activity/Raw/Frames/img_PetTab1_png.img_PetTab1_png'")
    self.icon_2:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Activity/Raw/Frames/img_PetTab2_png.img_PetTab2_png'")
  else
    self.icon_1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Activity/Raw/Frames/img_BossTab1_png.img_BossTab1_png'")
    self.icon_2:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Activity/Raw/Frames/img_BossTab2_png.img_BossTab2_png'")
  end
  self.index = index
end

function UMG_Activity_TerritoryTrial_LevelInformationTabItem_C:OnItemSelected(_bSelected)
  if self._bSelected == _bSelected then
    return
  end
  self._bSelected = _bSelected
  self:StopAllAnimations()
  if _bSelected then
    self:PlayAnimation(self.change1)
    self.uiData.selectedCallback(self.uiData.caller, self.index)
  else
    self:PlayAnimation(self.change2)
  end
end

function UMG_Activity_TerritoryTrial_LevelInformationTabItem_C:OnDeactive()
end

return UMG_Activity_TerritoryTrial_LevelInformationTabItem_C
