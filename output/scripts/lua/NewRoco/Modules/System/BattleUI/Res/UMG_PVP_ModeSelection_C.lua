local UMG_PVP_ModeSelection_C = _G.NRCPanelBase:Extend("UMG_PVP_ModeSelection_C")

function UMG_PVP_ModeSelection_C:OnConstruct()
  self:AddButtonListener(self.Close.btnClose, self.OnCloseClick)
  self:AddButtonListener(self.PVP_Single.Btn, self.OnOnePVPClick)
  self:AddButtonListener(self.PVP_Single1.Btn, self.OnTwoPVPClick)
  self.PVP_Single.Text:SetText(LuaText.umg_pvp_modeselection_1)
  self.PVP_Single1.Text:SetText(LuaText.umg_pvp_modeselection_2)
end

function UMG_PVP_ModeSelection_C:OnActive()
  self.isClick = false
  self.isClose = false
  self:StopAllAnimations()
  self:PlayAnimation(self.Open)
  self.UMG_Common_BIconPar:Open()
  UE4Helper.SetEnableWorldRendering(false)
end

function UMG_PVP_ModeSelection_C:OnDeactive()
end

function UMG_PVP_ModeSelection_C:OnCloseClick()
  if not self.isClose then
    self.isClose = true
    self:StopAllAnimations()
    self:PlayAnimation(self.Close_)
    self.UMG_Common_BIconPar:Close()
    UE4Helper.SetEnableWorldRendering(true)
  end
end

function UMG_PVP_ModeSelection_C:OnOnePVPClick()
  if not self.isClick and not self.isClose then
    self.isClick = true
    local req = ProtoMessage:newZoneGmMatchReq()
    req.act_id = 307001
    req.team_aim_num = 1
    req.rand_pet = false
    req.pve = false
    _G.ZoneServer:Send(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_MATCH_REQ, req)
    self:DelaySeconds(5, function()
      if self.isClick then
        self.isClick = false
      end
    end)
  end
end

function UMG_PVP_ModeSelection_C:OnTwoPVPClick()
  if not self.isClick and not self.isClose then
    self.isClick = true
    local req = ProtoMessage:newZoneGmMatchReq()
    req.act_id = 307002
    req.team_aim_num = 1
    req.rand_pet = false
    req.pve = false
    _G.ZoneServer:Send(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_MATCH_REQ, req)
    _G.DelayManager:DelaySeconds(5, function()
      if self.isClick then
        self.isClick = false
      end
    end)
  end
end

function UMG_PVP_ModeSelection_C:OnDestruct()
  self:RemoveAllButtonListener()
end

function UMG_PVP_ModeSelection_C:OnAnimationFinished(Animation)
  if Animation == self.Close_ then
    self:DoClose()
  end
end

return UMG_PVP_ModeSelection_C
