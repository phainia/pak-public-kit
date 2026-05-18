local PetUIModuleEnum = require("NewRoco.Modules.System.PetUI.PetUIModuleEnum")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_MoreList_C = Base:Extend("UMG_MoreList_C")

function UMG_MoreList_C:OnConstruct()
end

function UMG_MoreList_C:OnDestruct()
end

function UMG_MoreList_C:OnItemUpdate(_data, datalist, index)
  self.caller = _data.caller
  self.callback = _data.callback
  self.type = _data.type
  if _data.type == PetUIModuleEnum.PetTitleListShowType.NameSet then
    self.Text_PlaceName:SetText(LuaText.change_mainworld_team_name_tips)
  elseif _data.type == PetUIModuleEnum.PetTitleListShowType.ShareTeam then
    self.Text_PlaceName:SetText(LuaText.lineup_code_share_team)
  elseif _data.type == PetUIModuleEnum.PetTitleListShowType.LoadTeam then
    self.Text_PlaceName:SetText(LuaText.lineup_code_use_code)
  end
  self.Icon:SetPath(_data.IconPath)
end

function UMG_MoreList_C:OnItemSelected(_bSelected)
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

function UMG_MoreList_C:OnDeactive()
end

return UMG_MoreList_C
