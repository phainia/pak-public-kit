local UMG_PVP_Matching_Bigpic_C = _G.NRCViewBase:Extend("UMG_PVP_Matching_Bigpic_C")

function UMG_PVP_Matching_Bigpic_C:OnConstruct()
  self.BeforePath = nil
  self.AfterPath = nil
  self.BeforeText = nil
  self.AfterText = nil
  self.canNormal = false
  self.canChange = false
end

function UMG_PVP_Matching_Bigpic_C:OnActive()
end

function UMG_PVP_Matching_Bigpic_C:OnDeactive()
end

function UMG_PVP_Matching_Bigpic_C:OnDestruct()
end

function UMG_PVP_Matching_Bigpic_C:OnAddEventListener()
end

function UMG_PVP_Matching_Bigpic_C:SetPic1Path(Path, Text)
  self.BigPic:SetPath(Path)
  self.Title_3:SetText(Text)
end

function UMG_PVP_Matching_Bigpic_C:SetPic2Path(Path, Text)
  self.BigPic_1:SetPath(Path)
  self.Title:SetText(Text)
end

function UMG_PVP_Matching_Bigpic_C:OnSelectChange(beforePath, afterPath, beforeText, afterText)
  self.canChange = true
  self:PlayAnimation(self.normal)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1272, "UMG_PVP_Matching_Bigpic_C:OnSelectChange")
  self.BeforePath = beforePath
  self.AfterPath = afterPath
  self.BeforeText = beforeText
  self.AfterText = afterText
  self:SetPic1Path(beforePath, beforeText)
  self:SetPic2Path(afterPath, afterText)
end

function UMG_PVP_Matching_Bigpic_C:OnAnimationFinished(animation)
  if animation == self.change1 then
    self:SetPic1Path(self.AfterPath, self.AfterText)
    self:PlayAnimation(self.reload)
    self.canNormal = true
  elseif animation == self.normal then
    if self.canChange then
      self:PlayAnimation(self.change1)
      self.canChange = false
    end
  elseif animation == self.reload and self.canNormal then
    self:PlayAnimation(self.normal)
    self.canNormal = false
  end
end

return UMG_PVP_Matching_Bigpic_C
