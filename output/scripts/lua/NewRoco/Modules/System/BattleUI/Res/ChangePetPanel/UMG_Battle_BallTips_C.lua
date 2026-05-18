require("UnLuaEx")
local UMG_Battle_BallTips_C = NRCUmgClass:Extend("")

function UMG_Battle_BallTips_C:UpdateInfo(cfg)
  if not cfg then
    Log.ErrorFormat("Config is nil")
    return
  end
  self.NameTxt:SetText(cfg.name)
  self.ContentTxt:SetText(cfg.description)
end

return UMG_Battle_BallTips_C
