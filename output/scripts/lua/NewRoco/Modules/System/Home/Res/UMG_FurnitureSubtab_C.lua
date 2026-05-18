local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_FurnitureSubtab_C = Base:Extend("UMG_FurnitureSubtab_C")
local AllSecondTabIconPath = "PaperSprite'/Game/NewRoco/Modules/System/Home/Raw/HomeMain/Frames/img_TabIcon0_png.img_TabIcon0_png'"

function UMG_FurnitureSubtab_C:OnConstruct()
end

function UMG_FurnitureSubtab_C:OnDestruct()
end

function UMG_FurnitureSubtab_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  local TabConf = _data.TabConf
  if TabConf then
    if TabConf.is_first_tab then
      self.BtnIcon_1:SetPath(AllSecondTabIconPath)
    else
      self.BtnIcon_1:SetPath(_data.TabConf.tab_icon)
    end
  end
end

function UMG_FurnitureSubtab_C:OnItemSelected(_bSelected)
  self:StopAllAnimations()
  if _bSelected then
    self:PlayAnimation(self.Press)
  else
    self:PlayAnimation(self.Normal)
  end
  if _bSelected and self.data.OnClick then
    self.data.OnClick()
  end
end

function UMG_FurnitureSubtab_C:OnDeactive()
end

return UMG_FurnitureSubtab_C
