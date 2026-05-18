local UMG_Tab2Template_C = _G.NRCPanelBase:Extend("UMG_Tab2Template_C")

function UMG_Tab2Template_C:OnConstruct()
  Log.Debug("UMG_Tab2Template_C:OnConstruct")
  self:OnActive()
end

function UMG_Tab2Template_C:OnDestruct()
end

function UMG_Tab2Template_C:OnActive()
  Log.Debug("UMG_Tab2Template_C:OnActive")
  self.uidata = {
    {key = "Yuzuru", color = "#ffffff"},
    {key = "HANYU", color = "#cacaca"},
    {key = "Yuzuru", color = "#b9ffb0"},
    {key = "HANYU", color = "#b0ddff"},
    {key = "Yuzuru", color = "#ffffff"},
    {key = "HANYU", color = "#b9ffb0"},
    {key = "Yuzuru", color = "#cacaca"},
    {key = "HANYU", color = "#ffffff"},
    {key = "Yuzuru", color = "#b0ddff"},
    {key = "HANYU", color = "#ffffff"},
    {key = "Yuzuru", color = "#cacaca"},
    {key = "HANYU", color = "#ffffff"},
    {key = "Yuzuru", color = "#b9ffb0"},
    {key = "HANYU", color = "#cacaca"},
    {key = "Yuzuru", color = "#ffffff"},
    {key = "HANYU", color = "#b0ddff"},
    {key = "Yuzuru", color = "#b9ffb0"}
  }
  self.GridView1:InitGridView(self.uidata)
  self.NRCScrollView0:InitList(self.uidata)
  self.NRCScrollView1:InitList(self.uidata)
end

function UMG_Tab2Template_C:OnDeactive()
end

function UMG_Tab2Template_C:OnDestruct()
  Log.Error("UMG_Tab2Template_C:OnDestruct")
end

return UMG_Tab2Template_C
