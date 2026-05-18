local UMG_AvatarAnimList_C = _G.NRCClass:Extend("UMG_AvatarAnimList_C")

function UMG_AvatarAnimList_C:Construct()
end

function UMG_AvatarAnimList_C:Init(avatarActor)
  self.AnimBrowser:SetAvatarActor(avatarActor)
end

return UMG_AvatarAnimList_C
