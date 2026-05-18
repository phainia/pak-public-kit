local rapidjson = require("rapidjson")
local FileExtension = "non"

local function GetRecord()
  return {
    Payload = nil,
    CmdID = 0,
    Name = "Unknown",
    SeqID = 0,
    Timestamp = _G.UpdateManager.Timestamp
  }
end

local InMemoryProtocolRecorder = NRCClass()

function InMemoryProtocolRecorder:Ctor(Name)
  self.SaveDir = UE.UBlueprintPathsLibrary.ConvertRelativePathToFull(UE.UBlueprintPathsLibrary.ProjectLogDir())
  self.Commands = {}
  self.Records = {}
  self.Name = Name
  self.bIsRecording = false
end

function InMemoryProtocolRecorder:Start()
  self.bIsRecording = true
  _G.ZoneServer.PostHandleDelegate:Add(self, self.DoRecord)
end

function InMemoryProtocolRecorder:Stop()
  self.bIsRecording = false
  _G.ZoneServer.PostHandleDelegate:Remove(self, self.DoRecord)
  local File = UE.UBlueprintPathsLibrary.ConvertRelativePathToFull(self:MakeFileName())
  Log.Error("\232\190\147\229\135\186\230\149\176\230\141\174\229\136\176\230\150\135\228\187\182\229\164\185", File)
  local Content = rapidjson.encode(self.Records, {pretty = true, sort_keys = true})
  UE.UNRCStatics.WriteToFile(File, Content)
  table.clear(self.Records)
end

function InMemoryProtocolRecorder:AddCmd(CmdID)
  if table.contains(self.Commands, CmdID) then
    return
  end
  table.insert(self.Commands, CmdID)
end

function InMemoryProtocolRecorder:DoRecord(Show, RspMsg, CmdID, SeqID)
  if not table.contains(self.Commands, CmdID) then
    return
  end
  local Record = GetRecord()
  Record.Payload = RspMsg
  Record.CmdID = CmdID
  Record.SeqID = SeqID
  Record.Name = ProtoCMD:GetMessageName(CmdID) or "Unknown"
  table.insert(self.Records, Record)
end

function InMemoryProtocolRecorder:InsertPayload(Payload, Name)
  local Record = GetRecord()
  Record.Payload = Payload
  Record.CmdID = -1
  Record.SeqID = 0
  Record.Name = Name
  table.insert(self.Records, Record)
end

function InMemoryProtocolRecorder:MakeFileName()
  return string.format("%s%s%d.%s", self.SaveDir, self.Name, os.time(os.date("!*t")), FileExtension)
end

return InMemoryProtocolRecorder
