local PVPRankedMatchModuleUtils = require("NewRoco.Modules.System.PVPQualifier.PVPRankedMatchModuleUtils")
local UMG_Common_ClassIcon_C = _G.NRCPanelBase:Extend("UMG_Common_ClassIcon_C")

function UMG_Common_ClassIcon_C:OnActive()
end

function UMG_Common_ClassIcon_C:OnDeactive()
end

function UMG_Common_ClassIcon_C:OnAddEventListener()
end

function UMG_Common_ClassIcon_C:SetRankInfo(RankConf, pvpRankOrder)
  local maxRankStar = _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.CmdGetMaxRankStar)
  if maxRankStar <= RankConf.id then
    local icon_mini = RankConf.icon_mini
    do
      local TopMasterInfo = _G.NRCModuleManager:DoCmd(PVPRankedMatchModuleCmd.CmdGetTopMaster)
      local bTopMaster = TopMasterInfo.type == _G.ProtoEnum.PVP_RANK_MASTER_TYPE.PVP_RANK_MASTER_TYPE_TOP_MASTER
      if bTopMaster then
        local topMasterConf = DataConfigManager:GetTopMasterConf(1)
        if topMasterConf then
          icon_mini = topMasterConf.icon_mini
        end
      end
    end
    self.ClassIcon:SetPath(icon_mini)
    self.Switcher_1:SetActiveWidgetIndex(1)
    if self.RankingText1 then
      self.RankingText1:SetText(PVPRankedMatchModuleUtils.GetOrderOrRankName(pvpRankOrder))
    end
  else
    self.ClassIcon:SetPath(RankConf.icon_mini)
    self.Switcher_1:SetActiveWidgetIndex(0)
    self.DanGrading:SetPath(RankConf.number)
  end
end

return UMG_Common_ClassIcon_C
