local EventDispatcher = require("Common.EventDispatcher")
local SkillPlayer = NRCClass()

function SkillPlayer:Ctor(comp, caster, config)
  EventDispatcher():Attach(self)
  self.Config = config
  self.SkillComponent = comp
  self.Caster = caster
  self.DynamicParams = nil
  self.Characters = nil
  self.Skills = {}
  self.Objects = {}
  self.Current = nil
  self.isPlaying = false
  self.CurrentState = nil
  self.eventDict = {}
  self.promisePlayClassTable = {}
  self.pendingPlayName = nil
  self.EnterEnd = false
  self.unluaRef = {}
end

function SkillPlayer:OnSkillDestroy(name, skill)
  if name and self.promisePlayClassTable[name] then
    self.promisePlayClassTable[name]:CancelLoad()
    self.promisePlayClassTable[name] = nil
    Log.Info("[SkillPlayer] cancel loading class", name)
  end
  if not skill then
    return
  end
  local config = self.Config.States[name] or {}
  local destroy = config.Destroy or {}
  local type = destroy.Type or "Cancel"
  local preDestroy = destroy.PreDestroy
  local postDestroy = destroy.PostDestroy
  local continue = true
  if preDestroy then
    continue = not preDestroy(name, skill)
  end
  if continue and "Cancel" == type then
    local reason = destroy.Reason or UE4.ESkillActionResult.SkillActionResultInterrupted
    if UE4.UObject.IsValid(self.SkillComponent) then
      self.SkillComponent:CancelSkill(skill, reason)
    end
  end
  if postDestroy then
    postDestroy(name, skill)
  end
end

function SkillPlayer:Destroy()
  self:ClearCachedObjects()
  for k, v in pairs(self.Skills) do
    self:OnSkillDestroy(k, v)
    self.Skills[k] = nil
  end
  if self.Current and UE.UObject.IsValid(self.Current) then
    self:OnSkillDestroy(self.Current:GetName(), self.Current)
    self.Current = nil
  end
  self.isPlaying = false
  for k, v in pairs(self.promisePlayClassTable) do
    v:CancelLoad()
  end
  self.promisePlayClassTable = {}
end

function SkillPlayer:Play(name)
  if self.isPlaying and self.Current then
    Log.WarningFormat("[SkillPlayer] There's a skill playing %s, %s won't be played", self.Name, name)
    return
  end
  self.EnterEnd = false
  self:InternalPlay(name)
end

function SkillPlayer:InternalPlay(name)
  if self.pendingPlayName then
    if not self.promisePlayClassTable[self.pendingPlayName] then
      Log.Error("[SkillPlayer] LogicalError!!! cannot found invalid loading context", self.pendingPlayName)
    else
      self.promisePlayClassTable[self.pendingPlayName]:CancelLoad()
    end
  end
  Log.Info("[SkillPlayer] InternalPlay", name)
  self.pendingPlayName = name
  local promise = BattleResourceManager:LoadUClassAsync(self, name, FPartial(self.DoInternalPlay, self, name))
  self.promisePlayClassTable[name] = promise
end

function SkillPlayer:DoInternalPlay(name, class)
  if not name then
    Log.WarningFormat("[SkillPlayer] Can't find skill state with name %s", name)
    return
  end
  if name ~= self.pendingPlayName then
    Log.ErrorFormat("[SkillPlayer] SkillPlayer::DoInternalPlay expected %s but got %s", self.pendingPlayName, name)
    self.pendingPlayName = nil
    return
  end
  self.pendingPlayName = nil
  Log.Debug("[SkillPlayer] SkillPlayer Play skill:", class)
  if not class then
    Log.WarningFormat("[SkillPlayer] Can't load skill class %s", name)
    return
  end
  if not self.SkillComponent or not UE.UObject.IsValid(self.SkillComponent) then
    Log.WarningFormat("[SkillPlayer] skill component has been released", name)
    return
  end
  table.insert(self.unluaRef, UnLua.Ref(class))
  local skill = self.SkillComponent:AddSkillObjFromClassAndReturn(class)
  if not skill then
    Log.WarningFormat("[SkillPlayer] Can't find or load skill object %s %s", class, name)
    return
  end
  table.insert(self.unluaRef, UnLua.Ref(skill))
  local config = self.Config.States or {}
  self.CurrentState = config[name] or {}
  local PutVars = self.CurrentState.PutVars
  if PutVars then
    local bb = skill:GetBlackboard()
    for k, v in pairs(PutVars) do
      local obj = self.Objects[k]
      if obj then
        Log.DebugFormat("[SkillPlayer] Pushing %s into %s with name %s", obj, skill, v.Name)
        bb:SetValueAsObject(v.Name, obj)
        self.Objects[k] = nil
      end
    end
  end
  if self.DynamicParams then
    if not self.DynamicParams.Caster then
      self.DynamicParams.Caster = self.Caster
    end
    skill:SetDynamicData(self.DynamicParams)
  end
  if self.Caster then
    skill:SetCaster(self.Caster)
  end
  if self.Characters then
    skill:SetCharacters(self.Characters)
  end
  if self.Targets then
    skill:SetTargets(self.Targets)
  end
  if self.Config.IsPassive ~= true then
    local result = self.SkillComponent:CanActivateSkill(skill)
    if result ~= UE4.ESkillStartResult.Success then
      Log.WarningFormat("[SkillPlayer] There will be a problem starting skill %s, Reason %d", name, result)
      Log.DebugFormat("[SkillPlayer] Active Skill Information %s", self.SkillComponent:GetActiveSkill())
      if result == UE4.ESkillStartResult.CantInterruptSkill then
        Log.DebugFormat("[SkillPlayer] Try to kill current skill")
        local activeSkill = self.SkillComponent:GetActiveSkill()
        self.SkillComponent:CancelSkill(activeSkill, UE4.ESkillActionResult.SkillActionResultInterrupted)
      end
    end
  end
  skill:RegisterRawCallback(self, self.EventHandler)
  skill:SetPassive(self.Config.IsPassive == true)
  skill.CleanupMaterials = false
  self.Name = name
  if not self.EnterEnd then
    self.Current = skill
  end
  self.SkillComponent:LoadAndPlaySkill(skill)
  table.insert(self.Skills, skill)
end

function SkillPlayer:EventHandler(event, skill)
  if not self.CurrentState then
    Log.Warning("SkillPlayer:EventHandler \230\138\128\232\131\189\229\183\178\231\187\143\232\176\131\231\148\168\228\186\134END")
    return
  end
  local CurrentState = self.CurrentState
  local Blackboard = skill:GetBlackboard()
  local SaveVars = CurrentState.SaveVars
  if SaveVars then
    for k, v in pairs(SaveVars) do
      local Trigger = v.Trigger or {"End"}
      if self:Contains(Trigger, event) then
        local key = v.Name
        local value = Blackboard:GetValueAsObject(key)
        if key and value then
          Log.DebugFormat("Saving var %s at %s, event %s, skill %s", v.Name, k, event, skill:GetName())
          if self.Objects[k] ~= value then
            self:DestroyObject(self.Objects[k])
          end
          self.Objects[k] = value
          if v.Keep then
            Blackboard:RemoveObjectValue(key)
          end
        end
      end
    end
  end
  local ClearVars = CurrentState.ClearVars
  if ClearVars then
    for k, v in pairs(ClearVars) do
      local Trigger = v.Trigger or {"Interrupt"}
      if self:Contains(Trigger, event) then
        local key = v.Name
        if key then
          local value = Blackboard:GetValueAsObject(key)
          self:DestroyObject(value)
          self.Objects[k] = nil
        end
      end
    end
  end
  if "End" == event then
    if CurrentState.Next then
      self.Current = nil
      self.CurrentState = nil
      self:Play(CurrentState.Next)
    end
  elseif self.eventDict[event] and self.eventDict[event].callback then
    self.eventDict[event].callback(self.eventDict[event].caller, self)
  end
end

function SkillPlayer:Stop()
  if not self.Current then
    return
  end
  if self.pendingPlayName and not self.promisePlayClassTable[self.pendingPlayName] then
    Log.Error("LogicalError!!! cannot found invalid loading context", self.pendingPlayName)
  end
  self:UnBindRef()
  self:OnSkillDestroy(self.Name, self.Current)
  self.Current = nil
  self.Name = nil
  local EndName = self.Config.End
  if EndName then
    self.EnterEnd = true
    self:InternalPlay(EndName)
    self.Current = nil
  end
end

function SkillPlayer:Toggle(needPlay)
  if needPlay == self.isPlaying then
    return
  end
  self.isPlaying = needPlay
  if self.isPlaying then
    if not self.Config.Start then
      Log.Error("You have to specify a start state")
    end
    self:Play(self.Config.Start)
  else
    self:Stop()
  end
end

function SkillPlayer:SetDynamicParams(params)
  self.DynamicParams = params
end

function SkillPlayer:SetCharacters(characters)
  self.Characters = characters
end

function SkillPlayer:SetTargets(targets)
  self.Targets = targets
end

function SkillPlayer:ClearCachedObjects()
  for k, v in pairs(self.Objects) do
    self:DestroyObject(v)
    self.Objects[k] = nil
  end
end

function SkillPlayer:DestroyObject(v)
  self:UnBindRef()
  if not v then
    return
  end
  if v.K2_DestroyActor then
    v:K2_DestroyActor()
  end
end

function SkillPlayer:UnBindRef()
  for _, objRef in pairs(self.unluaRef) do
    if UE.UObject.IsValid(objRef) then
      UnLua.Unref(objRef)
    end
  end
  self.unluaRef = {}
end

function SkillPlayer:Contains(array, key)
  if not key then
    return false
  end
  if not array then
    return false
  end
  for _, v in ipairs(array) do
    if v == key then
      return true
    end
  end
  return false
end

function SkillPlayer:SetEventCallback(eventName, callback, caller)
  self.eventDict[eventName] = {}
  self.eventDict[eventName].callback = callback
  self.eventDict[eventName].caller = caller
end

function SkillPlayer:ClearEventCallback(eventName)
  self.eventDict[eventName] = nil
end

return SkillPlayer
