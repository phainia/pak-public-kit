local EditComponentItemData = require("NewRoco.Modules.System.Friend.EditComponentItemData")
local FriendEnum = require("NewRoco.Modules.System.Friend.FriendEnum")
local Base = EditComponentItemData
local EditComponentItemDataFashion = Base:Extend("EditComponentItemDataFashion")

function EditComponentItemDataFashion:Ctor()
end

function EditComponentItemDataFashion:InitFromBadgeInfo(badgeInfo, cardShowType)
  self.ComponentType = _G.ProtoEnum.RoleCardModuleType.RCMT_BADGE
  self.cardShowType = cardShowType or FriendEnum.CardComponentShowType.None
  self.fashionInfo = badgeInfo
end

function EditComponentItemDataFashion:InitEmptyInfo(componentType, cardShowType)
  self.ComponentType = componentType
  self.cardShowType = cardShowType or FriendEnum.CardComponentShowType.None
  self.fashionInfo = nil
end

function EditComponentItemDataFashion:Compare(other)
  if not other then
    return false
  end
  if other.ComponentType ~= _G.ProtoEnum.RoleCardModuleType.RCMT_BADGE then
    return false
  end
  if self.ComponentType ~= other.ComponentType then
    return false
  end
  return other.fashionInfo.fashion_bond_id == self.fashionInfo.fashion_bond_id and other.fashion_info.index == self.fashionInfo.index
end

function EditComponentItemDataFashion:CompareFromServerCollectInfo(collectFashionInfo)
  if not collectFashionInfo then
    return false
  end
  if self.ComponentType ~= _G.ProtoEnum.RoleCardModuleType.RCMT_BADGE or not self.fashionInfo then
    return false
  end
  return self.fashionInfo.fashion_bond_id == collectFashionInfo.fashion_bond_id and self.fashionInfo.index == collectFashionInfo.index
end

function EditComponentItemDataFashion:CompareFromFashinInfo(fashion_bond_id)
  if self.ComponentType ~= _G.ProtoEnum.RoleCardModuleType.RCMT_BADGE or not self.fashionInfo then
    return false
  end
  return self.fashionInfo.fashion_bond_id == fashion_bond_id
end

function EditComponentItemDataFashion:IsCardInfoEmpty()
  if self.fashionInfo and self.fashionInfo.fashion_bond_id and self.fashionInfo.fashion_bond_id > 0 then
    return false
  end
  return true
end

function EditComponentItemDataFashion:GetIndex()
  return self.fashionInfo.index or 0
end

function EditComponentItemDataFashion:SetIndex(index)
  self.fashionInfo.index = index
end

function EditComponentItemDataFashion:GetId()
  return self.fashionInfo.fashion_bond_id
end

return EditComponentItemDataFashion
