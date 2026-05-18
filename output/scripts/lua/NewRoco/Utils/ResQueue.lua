local ResObjectBase = require("NewRoco.Utils.ResObjectBase")
local ResObjectState = require("NewRoco.Utils.ResObjectState")
local NPCResObject = require("NewRoco.Modules.Core.NPC.NPCResObject")
local EQSResObject = require("NewRoco.Modules.Core.NPC.EQSResObject")
local ThrowResObject = require("NewRoco.Modules.Core.NPC.ThrowResObject")
local SyncPetResObject = require("NewRoco.Modules.Core.NPC.SyncPetResObject")
local ModelResObject = require("NewRoco.Modules.Core.NPC.ResObjects.ModelResObject")
local ResObject = require("NewRoco.Utils.ResObject")
local Base = ResObjectBase
local RunMode = {Concurrent = 1, Sequential = 2}
local ResQueue = Base:Extend("ResQueue")
ResQueue.RunMode = RunMode

function ResQueue:Ctor(Timeout, Mode, Priority)
  self.ResMap = {}
  self.ResList = {}
  self.Timeout = Timeout or 30
  self.TimeoutHandler = -1
  self.State = ResObjectState.Init
  self.Mode = Mode or RunMode.Concurrent
  self.CurrentIndex = 0
  self._fakeDelay = 0
  self._fakeDelayHandler = -1
  self.Priority = Priority or -1
end

function ResQueue:InsertClass(Name, Path, Priority)
  if self.ResMap[Name] then
    Log.Error("\233\135\141\229\164\141\230\183\187\229\138\160", Name, Path)
    return
  end
  Priority = math.max(Priority or -1, self.Priority or -1)
  local Object = ResObject.MakeUClass(Path, Priority)
  if not Object then
    return
  end
  return self:InsertResObject(Name, Object)
end

function ResQueue:InsertObject(Name, Path, Priority)
  if self.ResMap[Name] then
    Log.Error("\233\135\141\229\164\141\230\183\187\229\138\160", Name, Path)
    return
  end
  Priority = math.max(Priority or -1, self.Priority or -1)
  local Object = ResObject.MakeUObject(Path, Priority)
  if not Object then
    return
  end
  return self:InsertResObject(Name, Object)
end

function ResQueue:InsertNPC(Name, ConfID, Position, Dir, PetGID, Priority)
  if self.ResMap[Name] then
    Log.Error("\233\135\141\229\164\141\230\183\187\229\138\160", Name, Path)
    return
  end
  Priority = math.max(Priority or -1, self.Priority or -1)
  local Object = NPCResObject.MakeNPC(ConfID, Position, Dir, PetGID, Priority)
  if not Object then
    return
  end
  return self:InsertResObject(Name, Object)
end

function ResQueue:InsertPet(Name, Session, Priority)
  if self.ResMap[Name] then
    Log.Error("\233\135\141\229\164\141\230\183\187\229\138\160", Name)
    return
  end
  Priority = math.max(Priority or -1, self.Priority or -1)
  local Object = NPCResObject.MakeLocalPet(Session, Priority)
  if not Object then
    return
  end
  return self:InsertResObject(Name, Object)
end

function ResQueue:InsertSenseRelease(Name, PetData)
  if self.ResMap[Name] then
    Log.Error("\233\135\141\229\164\141\230\183\187\229\138\160", Name)
    return
  end
  local Object = EQSResObject.MakeSenseReleaseQuery(PetData)
  if not Object then
    return
  end
  return self:InsertResObject(Name, Object)
end

function ResQueue:InsertStandRelease(Name, QueryType, PetData, ModelID, Querier, Inner, Outer)
  local Object = EQSResObject.MakeStandReleaseQuery(QueryType, PetData, ModelID, Querier, Inner, Outer)
  if not Object then
    return
  end
  return self:InsertResObject(Name, Object)
end

function ResQueue:InsertPetBlessing(Name, Querier, PlayerId1, PlayerId2, PetId)
  local EqsObj = EQSResObject.MakeBlessingQuery(Querier, PlayerId1, PlayerId2, PetId)
  if not EqsObj then
    return
  end
  return self:InsertResObject(Name, EqsObj)
end

function ResQueue:InsertSessionThrowBegin(Name, Session)
  if not Session then
    return
  end
  local Object = ThrowResObject(Session)
  if not Object then
    return
  end
  return self:InsertResObject(Name, Object)
end

function ResQueue:InsertSyncPet(Name, Pet)
  if not Pet then
    return
  end
  local Object = SyncPetResObject(Pet)
  if not Object then
    return
  end
  return self:InsertResObject(Name, Object)
end

function ResQueue:InsertResObject(Name, Object)
  if not Object then
    Log.Error("\228\184\141\229\133\129\232\174\184\230\143\146\229\133\165\231\169\186\231\154\132\229\175\185\232\177\161", Name)
    return
  end
  if self.ResMap[Name] then
    Log.Error("\233\135\141\229\164\141\230\183\187\229\138\160", Name)
    return
  end
  if self.State ~= ResObjectState.Init then
    Log.Error("\229\189\147\229\137\141\231\138\182\230\128\129\228\184\141\229\133\129\232\174\184\229\138\160\229\133\165\230\150\176\231\154\132\232\138\130\231\130\185", table.getKeyName(ResObjectState, self.State))
    return
  end
  self:Add(Name, Object)
  return Object
end

function ResQueue:InsertModel(Name, ConfID, Position, Dir, Priority)
  if self.ResMap[Name] then
    Log.Error("\233\135\141\229\164\141\230\183\187\229\138\160", Name, ConfID)
    return
  end
  Priority = math.max(Priority or -1, self.Priority or -1)
  local Object = ModelResObject.MakeModel(ConfID, Position, Dir, Priority)
  if not Object then
    return
  end
  return self:InsertResObject(Name, Object)
end

function ResQueue:GetResObject(Name)
  return self.ResMap[Name]
end

function ResQueue:DoLoad()
  if 0 == table.len(self.ResMap) then
    self:CheckQueueReady(nil, true)
    return
  end
  self.TimeoutHandler = _G.DelayManager:DelaySeconds(self.Timeout, self.OnTimeout, self)
  if self.Mode == RunMode.Concurrent then
    for _, Object in pairs(self.ResMap) do
      Object:StartLoad(self, self.CheckQueueReady)
    end
  elseif self.Mode == RunMode.Sequential then
    self:StartLoadNext(nil, true)
  else
    Log.Error("\232\191\153\230\152\175\228\184\170\229\149\165\229\147\159?", table.getKeyName(RunMode, self.Mode))
    self:FireCallback(false)
  end
end

function ResQueue:DoGet(Name, ...)
  local Object = self.ResMap[Name]
  if not Object then
    Log.Error("\229\176\157\232\175\149\232\142\183\229\143\150\228\184\141\229\173\152\229\156\168\231\154\132\232\181\132\230\186\144", Name)
    return
  end
  return Object:Get(...)
end

function ResQueue:DoRelease()
  for _, Object in pairs(self.ResMap) do
    Object:Release()
  end
  table.clear(self.ResMap)
  table.clear(self.ResList)
  self:ClearTimeout()
  self.CurrentIndex = 0
end

function ResQueue:StartLoadNext(Object, Success)
  if not Success then
    self:FireCallback(false, self.CurrentIndex, Object)
    return
  end
  if #self.ResList == self.CurrentIndex then
    if self._fakeDelay > 0 then
      self._fakeDelayHandler = _G.DelayManager:DelaySeconds(self._fakeDelay, self.FireCallback, self, true)
    else
      self:FireCallback(true)
    end
    return
  end
  if self.CurrentIndex < #self.ResList then
    self.CurrentIndex = self.CurrentIndex + 1
    local Next = self.ResList[self.CurrentIndex]
    if Next then
      Next:StartLoad(self, self.StartLoadNext)
    else
      Log.Error("ResQueue\229\135\186\233\151\174\233\162\152\228\186\134\239\188\140\232\191\153\233\135\140\229\186\148\232\175\165\232\131\189\230\139\191\229\136\176\228\184\139\228\184\128\228\184\170\232\166\129\230\137\167\232\161\140\231\154\132\232\138\130\231\130\185\239\188\140\232\175\183\232\129\148\231\179\187poanshen\230\159\165bug")
      self:FireCallback(false)
    end
  end
end

function ResQueue:ClearTimeout()
  if self.TimeoutHandler > 0 then
    _G.DelayManager:CancelDelayById(self.TimeoutHandler)
    self.TimeoutHandler = -1
  end
  if self._fakeDelayHandler > 0 then
    _G.DelayManager:CancelDelayById(self._fakeDelayHandler)
    self._fakeDelayHandler = -1
  end
end

function ResQueue:CheckQueueReady(CurrentObject, Success)
  local AllSuccess = true
  for Name, Object in pairs(self.ResMap) do
    if Object.State == ResObjectState.Loaded then
      if AllSuccess then
        AllSuccess = Object.bSuccess
      end
    else
      Log.Debug("[ResQueue] CheckQueueReady", Name, Object.CallbackOwner and Object.CallbackOwner.className or "Unknown")
      return
    end
  end
  self:ClearTimeout()
  if self._fakeDelay > 0 then
    self._fakeDelayHandler = _G.DelayManager:DelaySeconds(self._fakeDelay, self.FireCallback, self, AllSuccess)
  else
    self:FireCallback(AllSuccess)
  end
end

function ResQueue:OnTimeout()
  Log.Warning("ResQueue:OnTimeout")
  self:ClearTimeout()
  self:FireCallback(false)
end

function ResQueue:Add(Name, Object)
  self.ResMap[Name] = Object
  table.insert(self.ResList, Object)
end

return ResQueue
