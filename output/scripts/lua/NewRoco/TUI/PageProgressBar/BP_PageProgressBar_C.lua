require("UnLuaEx")
local BP_PageProgressBar_C = NRCClass()

function BP_PageProgressBar_C:Construct()
  self.Length = 1
  self.Progress = 1
end

function BP_PageProgressBar_C:SetLength(length)
  self.Length = length
  self.Length = math.ceil(self.Length)
  self:RefreshProgress()
end

function BP_PageProgressBar_C:SetProgress(progress)
  self.Progress = progress
  self.Progress = math.round(self.Progress)
  self.Progress = math.clamp(self.Progress, 0, self.Length)
  self:RefreshProgress()
end

function BP_PageProgressBar_C:RefreshProgress()
  local emptyData = {}
  for i = 1, self.Length do
    local emptyItem = {}
    table.insert(emptyData, emptyItem)
  end
  self.ProgressScrollView:SetDatas(emptyData)
  self.ProgressScrollView:SetItemSelected(self.Progress)
end

return BP_PageProgressBar_C
