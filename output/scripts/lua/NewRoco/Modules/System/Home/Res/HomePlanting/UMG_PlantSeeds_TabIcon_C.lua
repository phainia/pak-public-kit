local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PlantSeeds_TabIcon_C = Base:Extend("UMG_PlantSeeds_TabIcon_C")

function UMG_PlantSeeds_TabIcon_C:OnConstruct()
  self.bFirstSelected = true
  self._selected = false
end

function UMG_PlantSeeds_TabIcon_C:OnDestruct()
end

function UMG_PlantSeeds_TabIcon_C:OnDeactive()
end

function UMG_PlantSeeds_TabIcon_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self.Title:SetText(_data.TabTitle)
  if _data.iconFmtPath then
    self.icon_1:SetPath(string.format(_data.iconFmtPath, 1, 1))
    self.icon_2:SetPath(string.format(_data.iconFmtPath, 2, 2))
  end
  self:PlayAnimation(self.normal)
  self:PlayAnimation(self.Open)
end

function UMG_PlantSeeds_TabIcon_C:OnItemSelected(_bSelected)
  if self._selected ~= _bSelected then
    if not self.bFirstSelected then
      self:StopAllAnimations()
    else
      self.bFirstSelected = false
    end
    if _bSelected then
      self:PlayAnimation(self.change1)
    else
      self:PlayAnimation(self.change2)
    end
  end
  self._selected = _bSelected
  local myUIData = self.uiData
  if not myUIData then
    return
  end
  local caller = myUIData.caller
  local callback = myUIData.callback
  local tabEnum = myUIData.TabEnum
  if _bSelected and caller and callback then
    callback(caller, tabEnum, _bSelected)
  end
end

function UMG_PlantSeeds_TabIcon_C:OnAnimationFinished(Anim)
  if Anim == self.change1 then
    self:PlayAnimation(self.select_loop, 0, 0)
  end
end

return UMG_PlantSeeds_TabIcon_C
