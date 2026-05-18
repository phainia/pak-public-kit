local UMG_BuffTips_C = _G.NRCPanelBase:Extend("UMG_BuffTips_C")

function UMG_BuffTips_C:OnConstruct()
end

function UMG_BuffTips_C:OnDestruct()
end

function UMG_BuffTips_C:OnActive(CurBuffDatas)
  self.Attr:InitGridView(CurBuffDatas)
end

function UMG_BuffTips_C:UpdateBuff(CurBuffDatas)
  self:OnActive(CurBuffDatas)
end

function UMG_BuffTips_C:OnDeactive()
end

function UMG_BuffTips_C:OnAddEventListener()
end

return UMG_BuffTips_C
