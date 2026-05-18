local NRCClass = require("Core.NRCClass")
local FriendEnum = require("NewRoco.Modules.System.Friend.FriendEnum")
local Base = NRCClass
local EditComponentItemData = Base:Extend("EditComponentItemData")

function EditComponentItemData:Ctor()
end

function EditComponentItemData:Create(_componentType)
  if _componentType == _G.ProtoEnum.RoleCardModuleType.RCMT_FAVOURITE_PET then
    local EditComponentItemDataPet = require("NewRoco.Modules.System.Friend.EditComponentItemDataPet")
    return EditComponentItemDataPet()
  elseif _componentType == _G.ProtoEnum.RoleCardModuleType.RCMT_BADGE then
    local EditComponentItemDataFashion = require("NewRoco.Modules.System.Friend.EditComponentItemDataFashion")
    return EditComponentItemDataFashion()
  else
    Log.Error("EditComponentItemData:Create() - Unsupported component type: ", _componentType)
    return nil
  end
end

function EditComponentItemData:InitEmptyInfo(componentType, cardShowType)
  Log.Debug("EditComponentItemData:InitEmptyInfo", componentType, cardShowType)
end

function EditComponentItemData:Compare(other)
  return false
end

function EditComponentItemData:CompareFromServerCollectInfo(serverCollectInfo)
  return false
end

function EditComponentItemData:IsComponentPet()
  return self.ComponentType == _G.ProtoEnum.RoleCardModuleType.RCMT_FAVOURITE_PET
end

function EditComponentItemData:IsComponentBadge()
  return self.ComponentType == _G.ProtoEnum.RoleCardModuleType.RCMT_BADGE
end

function EditComponentItemData:IsCardInfoEmpty()
  Log.Debug("EditComponentItemData:IsCardInfoEmpty() - ComponentType: ", self.ComponentType)
  return true
end

function EditComponentItemData:GetIndex()
  return 0
end

function EditComponentItemData:SetIndex(index)
end

function EditComponentItemData:GetId()
  return 0
end

function EditComponentItemData:SetCardShowType(cardShowType)
  self.cardShowType = cardShowType or FriendEnum.CardComponentShowType.None
end

return EditComponentItemData
