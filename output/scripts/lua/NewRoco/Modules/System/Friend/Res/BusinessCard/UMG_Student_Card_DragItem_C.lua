local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")
local UMG_Student_Card_DragItem_C = _G.NRCUmgClass:Extend("UMG_Student_Card_DragItem_C")

function UMG_Student_Card_DragItem_C:Construct()
  Log.Debug("UMG_Student_Card_DragItem_C:Construct")
end

function UMG_Student_Card_DragItem_C:Destruct()
  Log.Debug("UMG_Student_Card_DragItem_C:Destruct")
end

function UMG_Student_Card_DragItem_C:Init(data)
  if not (data and data.ComponentType and data.cardShowType) or not data.petInfo then
    return
  end
  self.data = data
  Log.Error("UMG_Student_Card_DragItem_C:Init", tostring(data.ComponentType), tostring(data.cardShowType))
  self:InitPetInfo()
end

function UMG_Student_Card_DragItem_C:InitPetInfo()
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.data.petInfo.pet_base_id)
  if petBaseConf then
    local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
    if modelConf then
      if PetMutationUtils.GetMutationValue(self.data.petInfo.mutation_diff_type, _G.Enum.MutationDiffType.MDT_SHINING) then
        self.Pet:SetPath(modelConf.shiny_icon)
      else
        self.Pet:SetPath(NRCUtils:FormatConfIconPath(modelConf.icon, _G.UIIconPath.HeadIconPath))
      end
    end
  end
end

return UMG_Student_Card_DragItem_C
