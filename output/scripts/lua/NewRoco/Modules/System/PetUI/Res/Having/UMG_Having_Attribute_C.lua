local PetUtils = require("NewRoco.Utils.PetUtils")
local UMG_Having_Attribute_C = _G.NRCViewBase:Extend("UMG_Having_Attribute_C")

function UMG_Having_Attribute_C:OnConstruct()
end

function UMG_Having_Attribute_C:OnDestruct()
end

function UMG_Having_Attribute_C:OnActive(_data)
  self.uiData = _data
  self:SetProperty()
end

function UMG_Having_Attribute_C:SetProperty()
  local List = {}
  local SkillList = {}
  local conf = _G.DataConfigManager:GetPetGlobalConfig("pet_max_equip_num")
  local maxNum = conf.num
  local itemInfo = self.uiData.petData.possession.item
  for i = 1, maxNum do
    if i <= #itemInfo and itemInfo[i] and itemInfo[i].conf_id then
      local Property = PetUtils.GetHavingPropertyByPossession(itemInfo[i])
      if Property and #Property > 0 then
        for _, PropertyInfo in ipairs(Property) do
          if List and #List < 5 then
            table.insert(List, PropertyInfo)
          end
        end
      end
      local SkillInfo = PetUtils.GetHavingSkillPropertyByPossession(itemInfo[i])
      table.insert(SkillList, SkillInfo)
    end
  end
  if #List < 5 then
    for i = #List + 1, 5 do
      table.insert(List, {IsHasProperty = false})
    end
  end
  self.List:InitGridView(List)
  self.List_1:InitGridView(SkillList)
end

function UMG_Having_Attribute_C:OnDeactive()
end

function UMG_Having_Attribute_C:OnAddEventListener()
  self:AddButtonListener(self.BtnSwich, self.OnClickBtnSwich)
end

function UMG_Having_Attribute_C:OnClickBtnSwich()
end

return UMG_Having_Attribute_C
