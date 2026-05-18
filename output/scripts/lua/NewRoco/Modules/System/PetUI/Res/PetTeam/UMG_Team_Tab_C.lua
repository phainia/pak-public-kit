local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Team_Tab_C = Base:Extend("UMG_Team_Tab_C")
local PetUIModuleEvent = require("NewRoco.Modules.System.PetUI.PetUIModuleEvent")

function UMG_Team_Tab_C:OnConstruct()
end

function UMG_Team_Tab_C:OnDestruct()
  self.RedDot:UnRegister()
end

function UMG_Team_Tab_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.TextTab:SetText(_data.name)
  self.isEraseRed = false
  if _data.redKey then
    self.isEraseRed = _data.isEraseRed
    self.RedDot:SetupKey(_data.redKey)
  end
end

function UMG_Team_Tab_C:OnItemSelected(_bSelected)
  self:StopAllAnimations()
  if _bSelected then
    if self.isEraseRed then
      self.RedDot:EraseRedPoint()
    end
    local data = self.data
    local callback = data and data.OnSelectCallback
    local callbackOwner = data and data.OnSelectCallbackOwner
    local index = data and data.index or 1
    if callback then
      tcall(callbackOwner, callback, index)
    end
    self:PlayAnimation(self.select)
  else
    self:PlayAnimation(self.normal)
  end
end

function UMG_Team_Tab_C:OnDeactive()
end

function UMG_Team_Tab_C:OnTick()
end

function UMG_Team_Tab_C:OnLogin()
end

function UMG_Team_Tab_C:OnAnimationFinished(anim)
end

return UMG_Team_Tab_C
