local EditComponentItemData = require("NewRoco.Modules.System.Friend.EditComponentItemData")
local FriendEnum = require("NewRoco.Modules.System.Friend.FriendEnum")
local Base = EditComponentItemData
local EditComponentItemDataPet = Base:Extend("EditComponentItemDataPet")

function EditComponentItemDataPet:Ctor()
end

function EditComponentItemDataPet:InitFromPetInfo(collectPetInfo, cardShowType)
  self.ComponentType = _G.ProtoEnum.RoleCardModuleType.RCMT_FAVOURITE_PET
  self.cardShowType = cardShowType or FriendEnum.CardComponentShowType.None
  self.petInfo = collectPetInfo
end

function EditComponentItemData:InitEmptyInfo(componentType, cardShowType)
  self.ComponentType = componentType
  self.cardShowType = cardShowType or FriendEnum.CardComponentShowType.None
  self.petInfo = nil
end

function EditComponentItemDataPet:Compare(other)
  if not other or not other.petInfo then
    return false
  end
  if not other.ComponentType ~= ProtoEnum.RoleCardModuleType.RCMT_FAVOURITE_PET then
    return false
  end
  if self.ComponentType ~= other.ComponentType then
    return false
  end
  return self.petInfo.pet_base_id == other.petInfo.pet_base_id and self.petInfo.index == other.petInfo.index
end

function EditComponentItemDataPet:CompareFromServerCollectInfo(collectPetInfo)
  if not collectPetInfo then
    return false
  end
  if self.ComponentType ~= _G.ProtoEnum.RoleCardModuleType.RCMT_FAVOURITE_PET or not self.petInfo then
    return false
  end
  return self.petInfo.pet_base_id == collectPetInfo.pet_base_id and self.petInfo.mutation_diff_type == collectPetInfo.mutation_diff_type and self.petInfo.index == collectPetInfo.index
end

function EditComponentItemDataPet:CompareFromPetHandbook(petHandbook)
  if not petHandbook then
    return false
  end
  if self.ComponentType ~= _G.ProtoEnum.RoleCardModuleType.RCMT_FAVOURITE_PET or not self.petInfo then
    return false
  end
  return self.petInfo.pet_base_id == petHandbook.pet_base_id and self.petInfo.mutation_diff_type == petHandbook.mutation_type
end

function EditComponentItemDataPet:IsCardInfoEmpty()
  if self.petInfo and self.petInfo.pet_base_id and 0 ~= self.petInfo.pet_base_id then
    return false
  else
    return true
  end
end

function EditComponentItemDataPet:GetIndex()
  return self.petInfo.index or 0
end

function EditComponentItemDataPet:SetIndex(index)
  self.petInfo.index = index
end

function EditComponentItemDataPet:GetId()
  return self.petInfo.pet_base_id
end

return EditComponentItemDataPet
