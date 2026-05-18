local EnhancedInputModuleEvent = require("NewRoco.Modules.Core.EnhancedInput.EnhancedInputModuleEvent")
local UMG_MagicBookTips_C = _G.NRCPanelBase:Extend("UMG_MagicBookTips_C")

function UMG_MagicBookTips_C:OnActive(tip)
  self.tip = tip
  self.uiData = tip.customData
  self:UpdateUI()
  self:DelaySeconds(4, function()
    self:OnClose()
  end)
  self:OnAddEventListener()
end

function UMG_MagicBookTips_C:OnDeactive()
  if self.tip then
    self.tip:MarkFinished()
  end
end

function UMG_MagicBookTips_C:OnAddEventListener()
  self:AddButtonListener(self.TipsBtn, self.OnClick)
  _G.NRCEventCenter:RegisterEvent("UMG_MagicBookTips_C", self, EnhancedInputModuleEvent.KeyMappingsChanged, self.PCKeySetting)
end

function UMG_MagicBookTips_C:UpdateUI()
  local MageConf = _G.DataConfigManager:GetMageConf(self.uiData.npcID)
  if MageConf then
    local iconPath = MageConf.avatar_res
    self.HeadIcon:SetPath(iconPath)
    self.RichText:SetText(MageConf.unlock_text)
  else
    Log.Error("UMG_MagicBookTips_C:UpdateUI MageConf is nil")
  end
end

function UMG_MagicBookTips_C:OnConstruct()
  self:PCKeySetting()
end

function UMG_MagicBookTips_C:ClosePanel()
  self:OnClose()
end

function UMG_MagicBookTips_C:OnDestruct()
end

function UMG_MagicBookTips_C:OnClick()
  local req = _G.ProtoMessage:newZoneMageBookQueryReq()
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_MAGE_BOOK_QUERY_REQ, req, self, self.OnNPCRsp)
end

function UMG_MagicBookTips_C:OnNPCRsp(rsp)
  if 0 == rsp.ret_info.ret_code and rsp.data.enabled == true then
    self.rsp = rsp
    NRCModuleManager:DoCmd(BagModuleCmd.OpenNPCRoster, self.rsp.data.npcs, self.uiData.npcID)
  end
end

function UMG_MagicBookTips_C:PCKeySetting()
  if SystemSettingModuleCmd then
    local InputAction = string.format("IA_MessageDetails")
    local text, image = _G.NRCModuleManager:DoCmd(SystemSettingModuleCmd.GetMappingKeyUIName, InputAction)
    if "" ~= image then
      self.PCKey:SetImageMode(image)
    else
      self.PCKey:SetText(text)
    end
    self.PCKey:SetKeyVisibility(true)
  end
end

return UMG_MagicBookTips_C
