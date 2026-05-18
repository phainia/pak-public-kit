local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_FriendHeadItem_C = Base:Extend("UMG_FriendHeadItem_C")

function UMG_FriendHeadItem_C:OnConstruct()
end

function UMG_FriendHeadItem_C:OnDestruct()
end

function UMG_FriendHeadItem_C:OnItemUpdate(_data, datalist, index)
  if _data.icon then
    local CardIconConf = _G.DataConfigManager:GetCardIconConf(_data.icon)
    if CardIconConf then
      local AvatarPath = CardIconConf.icon_resource_path
      AvatarPath = string.format("%s%s.%s'", "Texture2D'/Game/NewRoco/Modules/System/Common/Icon/HeadIcon/", AvatarPath, AvatarPath)
      self.HeadPortrait:SetPath(AvatarPath)
    else
      Log.Error("UMG_FriendHeadItem_C", "OnItemUpdate", "CardIconConf is nil")
    end
  end
end

function UMG_FriendHeadItem_C:OnItemSelected(_bSelected)
end

function UMG_FriendHeadItem_C:OnDeactive()
end

return UMG_FriendHeadItem_C
