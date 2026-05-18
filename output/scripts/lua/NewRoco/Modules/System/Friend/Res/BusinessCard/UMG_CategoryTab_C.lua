local FriendModuleEvent = require("NewRoco.Modules.System.Friend.FriendModuleEvent")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_CategoryTab_C = Base:Extend("UMG_CategoryTab_C")

function UMG_CategoryTab_C:OnConstruct()
  self.module = _G.NRCModuleManager:GetModule("FriendModule")
  self.moduleData = self.module:GetData("FriendModuleData")
end

function UMG_CategoryTab_C:OnDestruct()
end

function UMG_CategoryTab_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  if self.TextBlock_1 then
    self.TextBlock_1:SetText(self.data.PetType.short_name)
  end
  if self.Normal_Bg then
    self.Normal_Bg:SetPath(self.data.PetType.type_icon)
  end
end

function UMG_CategoryTab_C:OnItemSelected(_bSelected)
  if _bSelected then
    self:PlayAnimation(self.Press)
    self.moduleData:SetEditSelectedPetTypeId(self.data.PetType.id)
    self.module:DispatchEvent(FriendModuleEvent.OnComponentEditPetTypeSelected)
  else
    self:PlayAnimation(self.Normal)
  end
end

function UMG_CategoryTab_C:OnDeactive()
end

return UMG_CategoryTab_C
