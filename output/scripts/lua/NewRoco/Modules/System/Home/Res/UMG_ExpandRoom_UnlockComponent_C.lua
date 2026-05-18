local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ExpandRoom_UnlockComponent_C = Base:Extend("UMG_ExpandRoom_UnlockComponent_C")

function UMG_ExpandRoom_UnlockComponent_C:OnConstruct()
end

function UMG_ExpandRoom_UnlockComponent_C:OnDestruct()
end

function UMG_ExpandRoom_UnlockComponent_C:ExtractDesc(str)
  if not str then
    return ""
  end
  local num1, num2 = str:match("^(%d+)>>(%d+)$")
  if num1 and num2 then
    return num1, num2
  else
    return str
  end
end

function UMG_ExpandRoom_UnlockComponent_C:OnItemUpdate(_data, datalist, index)
  local icon = _data.desc_icon or ""
  if not string.StartsWith(icon, "PaperSprite") then
    icon = ""
  end
  self.Icon:SetPath(icon)
  local Num1, Num2 = self:ExtractDesc(_data.desc_text_1)
  if Num1 and Num2 then
    self.NRCSwitcher_0:SetActiveWidgetIndex(1)
    self.Text_Amount1:SetText(tostring(Num1))
    self.Text_Amount2:SetText(tostring(Num2))
  else
    self.NRCSwitcher_0:SetActiveWidgetIndex(0)
    self.Text_Name:SetText(Num1 or "")
  end
  self.Text_Name_1:SetText(_data.desc_text_2 or "")
end

function UMG_ExpandRoom_UnlockComponent_C:OnItemSelected(_bSelected)
end

function UMG_ExpandRoom_UnlockComponent_C:OnDeactive()
end

return UMG_ExpandRoom_UnlockComponent_C
