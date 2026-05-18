local Base = require("NewRoco.Modules.System.MagicReplay.MagicSequence.MagicSequence")
local MagicSeqForReplay = Base:Extend("MagicSeqForReplay")

function MagicSeqForReplay:Ctor(fileName, createPos)
  Base.Ctor(self, fileName, "r", createPos)
end

function MagicSeqForReplay:ReadFromFile()
  if not self:CreateFile() then
    return false
  end
  self:ReadBaseInfo()
  self:ReadSequence()
  self.baseInfoMD5 = self:ComputeBaseInfoMD5()
  if string.IsNilOrEmpty(self.fileMD5) then
    self.fileMD5 = self:ComputeFileMD5()
  end
  Log.Debug("[MagicSequence][Replay] ReadFromFile", self:GetFileName(), self.baseInfoMD5, self.fileMD5)
  return true
end

return MagicSeqForReplay
