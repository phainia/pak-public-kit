local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Activity_ReviewItem_C = Base:Extend("UMG_Activity_ReviewItem_C")

function UMG_Activity_ReviewItem_C:OnConstruct()
  self:AddButtonListener(self.Button_Click, self.OnBtnClick)
end

function UMG_Activity_ReviewItem_C:OnDestruct()
  self:RemoveButtonListener(self.Button_Click)
end

function UMG_Activity_ReviewItem_C:OnItemUpdate(_data, datalist, index)
  local num = _data.num
  local numStr
  if num > 9990000 then
    num = 999
    numStr = string.format(_G.DataConfigManager:GetLocalizationConf("Activity_PlayerCoCreation_count2").msg, tostring(num))
  elseif num >= 10000 then
    num = num // 1000
    num = num / 10
    numStr = string.format(_G.DataConfigManager:GetLocalizationConf("Activity_PlayerCoCreation_count2").msg, tostring(num))
  else
    numStr = tostring(num)
  end
  self.TextQuantity:SetText(numStr)
  self.data = _data
  if _data.bSelected then
    self.ImageIcon:SetPath(_data.selectIcon)
  else
    self.ImageIcon:SetPath(_data.icon)
  end
end

function UMG_Activity_ReviewItem_C:OnBtnClick()
  self.data.callback(self.data.caller, self.data.type, self.data.bSelected)
end

function UMG_Activity_ReviewItem_C:PlayItemAnim(bOpen)
  if bOpen then
    self:PlayAnimation(self.In)
  else
    self:PlayAnimation(self.Out)
  end
end

function UMG_Activity_ReviewItem_C:OnDeactive()
end

return UMG_Activity_ReviewItem_C
