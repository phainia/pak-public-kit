local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Pass_PropertyItme_C = Base:Extend("UMG_Pass_PropertyItme_C")

function UMG_Pass_PropertyItme_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  local cfg = _G.DataConfigManager:GetAttributeConf(self.data.id)
  self.Icon = {}
  self.Icon[1] = "PaperSprite'/Game/NewRoco/Modules/System/BattleUI/Raw/Atlas/PetSystem/Frames/ui_pet_attribute_01grew_png.ui_pet_attribute_01grew_png'"
  self.Icon[2] = "PaperSprite'/Game/NewRoco/Modules/System/BattleUI/Raw/Atlas/PetSystem/Frames/ui_pet_attribute_02grew_png.ui_pet_attribute_02grew_png'"
  self.Icon[3] = "PaperSprite'/Game/NewRoco/Modules/System/BattleUI/Raw/Atlas/PetSystem/Frames/ui_pet_attribute_04grew_png.ui_pet_attribute_04grew_png'"
  self.Icon[4] = "PaperSprite'/Game/NewRoco/Modules/System/BattleUI/Raw/Atlas/PetSystem/Frames/ui_pet_attribute_03grew_png.ui_pet_attribute_03grew_png'"
  self.Icon[5] = "PaperSprite'/Game/NewRoco/Modules/System/BattleUI/Raw/Atlas/PetSystem/Frames/ui_pet_attribute_05grew_png.ui_pet_attribute_05grew_png'"
  self.Icon[6] = "PaperSprite'/Game/NewRoco/Modules/System/BattleUI/Raw/Atlas/PetSystem/Frames/ui_pet_attribute_06grew_png.ui_pet_attribute_06grew_png'"
  if cfg then
    self.Department:SetPath(self.Icon[cfg.attribute])
    self.NRC_NoChange_1:SetText(cfg.attribute_name)
  end
  if self.data then
    self.NRC_Change:SetText(self.data.value)
    self.Schedule:SetPercent(self.data.value / self.data.value_max)
  end
end

return UMG_Pass_PropertyItme_C
