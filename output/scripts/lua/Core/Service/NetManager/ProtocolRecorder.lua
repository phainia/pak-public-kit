local Class = _G.MakeSimpleClass
local rapidjson = require("rapidjson")
local FileExtension = "non"
local ProtocolRecorder = Class("ProtocolRecorder")

function ProtocolRecorder:Ctor(AutoStart)
  self.commands = {}
  local Dir = string.format("%s%s", UE4.UBlueprintPathsLibrary.ProjectSavedDir(), "NetRsp/")
  self.SaveDir = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(Dir)
  self.StartTime = os.clock()
  self.CmdIdsToCopy = {}
  local idsToCopy = {
    330,
    258,
    354,
    338
  }
  for _, id in ipairs(idsToCopy) do
    self.CmdIdsToCopy[id] = false
  end
  self.IsFinished = false
end

function ProtocolRecorder:AddCmd(CmdID)
  if not table.contains(self.commands, CmdID) then
    table.insert(self.commands, CmdID)
  end
end

function ProtocolRecorder:Start()
  self.StartTime = os.clock()
  _G.ZoneServer.PostHandleDelegate:Add(self, self.Record)
end

function ProtocolRecorder:Stop()
  _G.ZoneServer.PostHandleDelegate:Remove(self, self.Record)
end

function ProtocolRecorder:MakeFileName(CmdID)
  local Name = string.gsub(ProtoCMD:GetMessageName(CmdID), "%.", "_")
  local TimeDiff = math.round((os.clock() - (self.StartTime or 0)) * 1000)
  return string.format("%s%d_%d%s.%s", self.SaveDir, CmdID, TimeDiff, Name, FileExtension)
end

function ProtocolRecorder:Record(Show, RspMsg, CmdID, SeqID)
  if not table.contains(self.commands, CmdID) then
    return
  end
  local File = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(self:MakeFileName(CmdID))
  local Content = rapidjson.encode(RspMsg)
  UE4.UNRCStatics.WriteToFile(File, Content)
  if self.CmdIdsToCopy[CmdID] ~= nil then
    self.CmdIdsToCopy[CmdID] = true
    self.CopyRecordedWithPrefix(CmdID .. "_")
  end
  local allCopied = false
  for _, copied in pairs(self.CmdIdsToCopy) do
    if not copied then
      allCopied = false
      break
    end
    allCopied = true
  end
  if allCopied then
    self.IsFinished = true
  end
end

function ProtocolRecorder.GetJsonFile(Name)
  local File = string.format("%sNetRsp/%s.%s", UE4.UBlueprintPathsLibrary.ProjectSavedDir(), Name, FileExtension)
  Log.InfoFormat("GetJsonFile: %s", File)
  local Result, Success = UE4.UNRCStatics.LoadToString(File)
  if Success then
    return rapidjson.decode(Result)
  else
    File = string.format("%sData/Record/%s.%s", UE4.URocoBlueprintPathsLibrary.ScriptDir(), Name, FileExtension)
    File = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(File)
    Result, Success = UE4.UNRCStatics.LoadToString(File)
    if Success then
      return rapidjson.decode(Result)
    else
      Log.Error("Load fail")
    end
  end
end

function ProtocolRecorder.CopyRecordedWithPrefix(Prefix)
  local SrcDir = string.format("%s%s", UE4.UBlueprintPathsLibrary.ProjectSavedDir(), "NetRsp/")
  SrcDir = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(SrcDir)
  local DstDir = string.format("%s%s", UE4.URocoBlueprintPathsLibrary.ScriptDir(), "Data/Record/")
  DstDir = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(DstDir)
  local filenameRegex = string.format("%s(.*)\\.%s", Prefix, FileExtension)
  local Files, Success = UE4.UNRCStatics.GetFileNameMatchRegex(SrcDir, filenameRegex)
  if Success then
    Files = Files:ToTable()
    table.sort(Files, function(a, b)
      local aTime = tonumber(string.match(a, "%d+_(%d+)_"))
      local bTime = tonumber(string.match(b, "%d+_(%d+)_"))
      if aTime and bTime then
        return aTime > bTime
      end
    end)
    for _, File in ipairs(Files) do
      File = string.format("%s%s", SrcDir, File)
      local Content = UE4.UNRCStatics.LoadToString(File)
      if Content then
        local NewFileName = string.gsub(File, Prefix .. "[^_]+_", Prefix)
        local DstFile = string.format("%s%s", DstDir, UE4.UBlueprintPathsLibrary.GetCleanFilename(NewFileName))
        UE4.UNRCStatics.WriteToFile(DstFile, Content)
        break
      end
    end
  end
end

return ProtocolRecorder
