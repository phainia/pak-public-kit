local Base = require("Core.NRCModule.NRCPanelBase")
local UMG_Guidance_Banner_C = Base:Extend("UMG_Guidance_Banner_C")

function UMG_Guidance_Banner_C:OnActive(style, bannerConf)
  local text = ""
  if _G.UE4Helper.IsPCMode() then
    text = bannerConf.pc_text
  else
    text = bannerConf.mobile_text
  end
  self.Text_Hint:SetText(text)
end

return UMG_Guidance_Banner_C
