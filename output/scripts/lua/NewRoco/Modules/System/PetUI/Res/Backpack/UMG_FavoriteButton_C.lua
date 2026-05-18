local PetUtils = require("NewRoco.Utils.PetUtils")
local UMG_FavoriteButton_C = _G.NRCViewBase:Extend("UMG_FavoriteButton_C")

function UMG_FavoriteButton_C:OnConstruct()
end

function UMG_FavoriteButton_C:UpdateInfo(partner_mark, NotAnim)
  if partner_mark then
    self.Switcher:SetActiveWidgetIndex(0)
    self.Star:SetPath(PetUtils.GetPetCollectTagIcon(partner_mark))
  else
    self.Switcher:SetActiveWidgetIndex(1)
  end
end

function UMG_FavoriteButton_C:UpdateAsIcon()
end

function UMG_FavoriteButton_C:OnDeactive()
end

function UMG_FavoriteButton_C:OnAddEventListener()
end

return UMG_FavoriteButton_C
