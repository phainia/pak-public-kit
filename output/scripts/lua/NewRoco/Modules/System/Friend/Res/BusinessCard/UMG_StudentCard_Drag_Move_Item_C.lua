local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")
local UMG_StudentCard_Drag_Move_Item_C = _G.NRCViewBase:Extend("UMG_StudentCard_Drag_Move_Item_C")

function UMG_StudentCard_Drag_Move_Item_C:OnConstruct()
end

function UMG_StudentCard_Drag_Move_Item_C:OnDestruct()
end

function UMG_StudentCard_Drag_Move_Item_C:Init(data)
  if not data or not data.ComponentType then
    return
  end
  self.data = data
  if self.data.ComponentType == _G.ProtoEnum.RoleCardModuleType.RCMT_FAVOURITE_PET then
    self.NRCSwitcher_0:SetActiveWidgetIndex(0)
    self:InitPetInfo()
  elseif self.data.ComponentType == _G.ProtoEnum.RoleCardModuleType.RCMT_BADGE then
    self.NRCSwitcher_0:SetActiveWidgetIndex(1)
    self:InitFashionInfo()
  else
    Log.Error("UMG_StudentCard_Drag_Move_Item_C:Init - Unsupported component type: ", tostring(data.ComponentType))
  end
end

function UMG_StudentCard_Drag_Move_Item_C:InitPetInfo()
  if self.Icon then
    self.Icon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.Add then
    self.Add:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.Name then
    self.Name:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.move then
    self.move:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.Mask then
    self.Mask:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.Empty then
    self.Empty:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  if self.BtnBlacklist then
    self.BtnBlacklist:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.data.petInfo and 0 ~= self.data.petInfo.pet_base_id then
    self.Pet:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.IconBg:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local PetBaseConf = _G.DataConfigManager:GetPetbaseConf(self.data.petInfo.pet_base_id)
    local typeDic = _G.DataConfigManager:GetTypeDictionary(self.data.petInfo.skill_dam_type)
    if typeDic then
      self.IconBg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(typeDic.rolecard_favorite_pets_colour))
    end
    if PetBaseConf then
      local modelConf = _G.DataConfigManager:GetModelConf(PetBaseConf.model_conf)
      if modelConf then
        local mutation_type = self.data.petInfo.mutation_diff_type
        if PetMutationUtils.GetMutationValue(mutation_type, _G.Enum.MutationDiffType.MDT_SHINING) then
          self.Pet:SetPath(modelConf.shiny_icon)
        else
          self.Pet:SetPath(NRCUtils:FormatConfIconPath(modelConf.icon, _G.UIIconPath.HeadIconPath))
        end
      end
    end
  end
end

function UMG_StudentCard_Drag_Move_Item_C:InitFashionInfo()
  local fashionData = self.data
  if not (fashionData and fashionData.fashionInfo and fashionData.fashionInfo.fashion_bond_id) or fashionData.fashionInfo.fashion_bond_id <= 0 then
    return
  end
  local bondConf = _G.DataConfigManager:GetFashionBondConf(fashionData.fashionInfo.fashion_bond_id)
  if not bondConf then
    return
  end
  self.Icon_1:SetPath(bondConf.fashion_bond_big_icon)
  self.Icon_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

return UMG_StudentCard_Drag_Move_Item_C
