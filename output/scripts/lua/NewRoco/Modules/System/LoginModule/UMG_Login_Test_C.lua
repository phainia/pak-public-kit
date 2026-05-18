local UMG_Login_Test_C = _G.NRCPanelBase:Extend("UMG_Login_Test_C")

function UMG_Login_Test_C:OnConstruct()
end

function UMG_Login_Test_C:OnDestruct()
end

function UMG_Login_Test_C:OnActive()
  self:Log("OnActive")
end

function UMG_Login_Test_C:OnDeactive()
end

return UMG_Login_Test_C
