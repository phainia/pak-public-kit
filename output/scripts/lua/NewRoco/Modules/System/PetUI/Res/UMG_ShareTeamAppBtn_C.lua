local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ShareTeamAppBtn_C = Base:Extend("UMG_ShareTeamAppBtn_C")

function UMG_ShareTeamAppBtn_C:OnConstruct()
end

function UMG_ShareTeamAppBtn_C:OnDestruct()
end

function UMG_ShareTeamAppBtn_C:OnItemUpdate(_data, datalist, index)
  self.Icon:SetPath(_data.path)
  self.caller = _data.caller
  self.callback = _data.callback
  self.type = _data.type
end

function UMG_ShareTeamAppBtn_C:OnItemSelected(_bSelected)
  if _bSelected then
    local caller = self.caller
    local callback = self.callback
    if not callback then
      return
    end
    if caller then
      callback(caller, self.type)
    end
  end
end

function UMG_ShareTeamAppBtn_C:OnDeactive()
end

return UMG_ShareTeamAppBtn_C
