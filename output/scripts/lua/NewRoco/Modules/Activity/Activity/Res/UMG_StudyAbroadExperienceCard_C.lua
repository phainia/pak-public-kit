local UMG_StudyAbroadExperienceCard_C = _G.NRCPanelBase:Extend("UMG_StudyAbroadExperienceCard_C")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")

function UMG_StudyAbroadExperienceCard_C:OnConstruct()
  self:AddButtonListener(self.JumpButton, self.OnClickClose)
  self.TextTitle:SetText(_G.LuaText.activity_mix_CollegeGlory_des3)
end

function UMG_StudyAbroadExperienceCard_C:OnDestruct()
end

function UMG_StudyAbroadExperienceCard_C:OnActive(factionCfg, finishFactionItems)
  local collegeItems = {}
  local finishedFactions = {}
  if finishFactionItems then
    for _, item in ipairs(finishFactionItems) do
      finishedFactions[item.faction] = item.finish_time
    end
  end
  if factionCfg then
    for _, factionGroup in ipairs(factionCfg.faction_group) do
      local item = {}
      item.name = factionGroup.name
      item.badge = factionGroup.faction_icon
      local finishTimestamp = finishedFactions[factionGroup.faction_type]
      if finishTimestamp and finishTimestamp > 0 then
        item.finished = true
        local timeDetailData = ActivityUtils.ToTimeDetailData(finishTimestamp)
        item.finishedTime = string.safeFormat(_G.LuaText.Activity_CollegeGlory_faction_finish, timeDetailData.year, timeDetailData.month, timeDetailData.day)
      end
      table.insert(collegeItems, item)
    end
  end
  self.CollegeList:InitGridView(collegeItems)
end

function UMG_StudyAbroadExperienceCard_C:OnClickClose()
  self:OnClose()
end

function UMG_StudyAbroadExperienceCard_C:OnPcClose()
  self:OnClickClose()
end

return UMG_StudyAbroadExperienceCard_C
