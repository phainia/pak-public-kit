local Class = _G.MakeSimpleClass
local tcall = _ENV.tcall
local rapidjson = require("rapidjson")
local InMemoryProtocolPlayer = Class("InMemoryProtocolPlayer")

function InMemoryProtocolPlayer:Ctor()
  self.StartTime = math.mininteger
  self.EndTime = math.maxinteger
  self.Speed = 5
  self.CurrentIndex = -1
  self.CurrentTime = 0
end

function InMemoryProtocolPlayer:Play(FilePath, StartTime, EndTime, Speed)
  if StartTime then
    self.StartTime = StartTime
  end
  if EndTime then
    self.EndTime = EndTime
  end
  if Speed then
    self.Speed = Speed
  end
  self.CurrentIndex = -1
  self.CurrentTime = 0
  local Result, Success = UE.UNRCStatics.LoadToString(FilePath)
  if not Success then
    Log.Error("\230\150\135\228\187\182\229\138\160\232\189\189\229\164\177\232\180\165", FilePath)
    return false
  end
  self.Records = rapidjson.decode(Result)
  if not self.Records or 0 == #self.Records then
    Log.Error("\230\178\161\230\156\137\230\149\176\230\141\174", FilePath)
    return false
  end
  local Found = false
  for Idx, Record in ipairs(self.Records) do
    if Record.Timestamp >= self.StartTime and Record.Timestamp <= self.EndTime then
      Found = true
      self.CurrentTime = Record.Timestamp
      self.CurrentIndex = Idx
      break
    end
  end
  self.MaxTime = self.Records[#self.Records].Timestamp + 1
  if Found then
    _G.UpdateManager:Register(self)
    Log.Error("Start Replay", #self.Records, self.CurrentIndex)
    return true
  end
  return false
end

function InMemoryProtocolPlayer:OnTick(DeltaTime)
  DeltaTime = DeltaTime * self.Speed
  Log.Debug("TimeRange", self.CurrentTime, self.CurrentTime + DeltaTime, self.CurrentIndex)
  for i = self.CurrentIndex, #self.Records do
    local Record = self.Records[i]
    if not Record then
      Log.Error("Getting nil record")
      break
    end
    if Record.Timestamp >= self.CurrentTime and Record.Timestamp < self.CurrentTime + DeltaTime then
      local CMD = Record.CmdID
      local DispatchDict = _G.ZoneServer.protocolEventDic[CMD]
      if DispatchDict then
        Log.Error("Replay", i, Record.Timestamp, Record.Name)
        for ProtoIdx = 1, #DispatchDict do
          local event = DispatchDict[ProtoIdx]
          tcall(event.target, event.handler, Record.Payload)
        end
      end
      self.CurrentIndex = i
    end
  end
  if self.CurrentTime > self.MaxTime then
    self:Stop()
    return
  end
  self.CurrentTime = self.CurrentTime + DeltaTime
end

function InMemoryProtocolPlayer:Stop()
  _G.UpdateManager:UnRegister(self)
  Log.Error("Stop Replay!")
end

return InMemoryProtocolPlayer
