local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local UMG_Activity_ReviewTab_C = Base:Extend("UMG_Activity_ReviewTab_C")

function UMG_Activity_ReviewTab_C:OnConstruct()
  self._bSelected = false
end

function UMG_Activity_ReviewTab_C:OnDestruct()
end

function UMG_Activity_ReviewTab_C:SetRedVisibility(bShow)
  if bShow then
    self.redPointSpecial:SetupKey(453, self.data.activity_id)
  else
    self.redPointSpecial:SetupKey(0)
  end
end

function UMG_Activity_ReviewTab_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  local num = _data.num
  local numStr = ""
  for i = 1, 3 do
    local modNum = num % 10
    numStr = tostring(modNum) .. numStr
    num = num // 10
  end
  local petConf = _G.DataConfigManager:GetPetbaseConf(_data.pet_base_id)
  local petName = petConf.name
  local iconPath = _G.DataConfigManager:GetModelConf(petConf.model_conf).icon
  self.icon:SetPath(iconPath)
  self.Title:SetText(string.format(_G.DataConfigManager:GetLocalizationConf("Activity_PlayerCoCreation_review_number_name").msg, numStr, petName))
  self.redPointSpecial:SetupKey(453, _data.activity_id)
end

function UMG_Activity_ReviewTab_C:OnItemSelected(_bSelected)
  if self._bSelected == _bSelected or not self.data.caller:CanChangeTab() then
    return
  end
  self._bSelected = _bSelected
  if _bSelected then
    self:PlayAnimation(self.Select)
    self.data.handler(self.data.caller, self.data.num)
  else
    self:PlayAnimation(self.Unselect)
  end
end

function UMG_Activity_ReviewTab_C:OnDeactive()
end

return UMG_Activity_ReviewTab_C
