require("UnLua")
local BP_MiniGame_Guide_C = NRCClass("BP_MiniGame_Guide_C")

function BP_MiniGame_Guide_C:Initialize(Conf)
  self.MiniGameConf = Conf
end

function BP_MiniGame_Guide_C:ReceiveBeginPlay()
  local SplineConf = DataConfigManager:GetSplineConf(self.MiniGameConf.guide_rode)
  if not SplineConf then
    return
  end
  self.Overridden.ReceiveBeginPlay(self)
  UE.UNRCStatics.FillSpline(self.Spline, "SPLINE_CONF", SplineConf.id)
  self.NS_MiniGame_Spline:SetVariableFloat("RibbonWidth", self.MiniGameConf.rode_width * 100)
end

return BP_MiniGame_Guide_C
