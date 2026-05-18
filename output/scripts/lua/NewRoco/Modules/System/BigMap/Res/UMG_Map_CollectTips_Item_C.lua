local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Map_CollectTips_Item_C = Base:Extend("UMG_Map_CollectTips_Item_C")

function UMG_Map_CollectTips_Item_C:OnConstruct()
end

function UMG_Map_CollectTips_Item_C:OnDestruct()
end

function UMG_Map_CollectTips_Item_C:OnItemUpdate(_data, datalist, index)
  if #datalist == index then
    self.Line:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.Line:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  local campConf = _G.DataConfigManager:GetCampConf(_data.belong_camp)
  if campConf then
    self.Name:SetText(_data.exploreName)
    local progressText = string.format("%d/%d", _data.explore_num, _data.total_num)
    if _data.explore_num == _data.total_num then
      self.Progress:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("FFC65fFF"))
    else
      self.Progress:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("F4EEE1FF"))
    end
    self.Progress:SetText(progressText)
    local exploreConf = _G.DataConfigManager:GetWorldExploringStatisticConf(_data.exploreType + 1)
    local iconPath = ""
    if exploreConf and exploreConf.option and #exploreConf.option > 0 then
      for k, v in ipairs(exploreConf.option) do
        for key, val in ipairs(v.npc_id) do
          if val == _data.npc_id then
            iconPath = v.world_exploring_icon_path
          end
        end
      end
    end
    self.Icon:SetPath(iconPath)
  end
end

function UMG_Map_CollectTips_Item_C:OnItemSelected(_bSelected)
end

function UMG_Map_CollectTips_Item_C:OnDeactive()
end

return UMG_Map_CollectTips_Item_C
