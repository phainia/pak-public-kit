local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_HomeVisit_Information_C = Base:Extend("UMG_HomeVisit_Information_C")

function UMG_HomeVisit_Information_C:OnConstruct()
end

function UMG_HomeVisit_Information_C:OnDestruct()
end

function UMG_HomeVisit_Information_C:OnItemUpdate(_data, datalist, index)
  self.Text_Name:SetText(_data.title)
  local icon_var = _data.icon_name and self[_data.icon_name]
  local icon_path = icon_var and icon_var.AssetPathName or ""
  self.Icon:SetPath(icon_path)
  if _data.serverInfoBinder then
    self.Text_Amount:SetText("")
    _data.serverInfoBinder:Promise(self, function(_, proto, bSuccess)
      if bSuccess then
        local ls = proto.unlocked_furniture_info.handbook_list
        _data.cur_cnt = ls and #ls or 0
        self.Text_Amount:SetText(string.format("%d/%d", _data.cur_cnt, _data.max_cnt))
      end
    end)
  else
    self.Text_Amount:SetText(string.format("%d/%d", _data.cur_cnt, _data.max_cnt))
  end
end

function UMG_HomeVisit_Information_C:OnItemSelected(_bSelected)
end

function UMG_HomeVisit_Information_C:OnDeactive()
end

return UMG_HomeVisit_Information_C
