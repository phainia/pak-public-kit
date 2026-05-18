local NPCFinder = require("NewRoco.Modules.Core.NPC.LuaClass.NPCFinder")
local Base = NPCFinder

local function CmpNpcDis(npc1, npc2)
  local dis1 = npc1.squaredDis2LocalIgnoreZ or 1000000
  local dis2 = npc2.squaredDis2LocalIgnoreZ or 1000000
  return dis1 < dis2
end

local NPCBrutalFinder = Base:Extend("NPCBrutalFinder")

function NPCBrutalFinder:Ctor(k, handler1, constValidFunc, handler2, adjustValidFunc, handler3, compareFunc, handler4, changeToValidFunc, handler5, changeToInValidFunc)
  self.k = k
  self.num = 0
  self.constValidHandler = handler1
  self.adjustValidHandler = handler2
  self.compareHandler = handler3
  self.constValidFunc = constValidFunc
  self.adjustValidFunc = adjustValidFunc
  self.compareFunc = compareFunc or CmpNpcDis
  self.toValidHandler = handler4
  self.toValidFunc = changeToValidFunc
  self.toInValidHandler = handler5
  self.toInValidFunc = changeToInValidFunc
  self.LastResults = {}
  self.Results = {}
  self.bIsStepIterating = false
end

function NPCBrutalFinder:StartIterate()
  table.clear(self.Results)
end

function NPCBrutalFinder:CheckNPCValid(NPC)
  if not self:CallFunc(self.constValidFunc, self.constValidHandler, NPC) then
    return false
  end
  if not self:CallFunc(self.adjustValidFunc, self.adjustValidHandler, NPC) then
    return false
  end
  return true
end

function NPCBrutalFinder:Iterate(NPC)
  if not self:CheckNPCValid(NPC) then
    return
  end
  local ValidIndex = 0
  for Index, A in ipairs(self.Results) do
    if self:CallFunc(self.compareFunc, self.compareHandler, A, NPC) then
    else
      ValidIndex = Index
    end
  end
  local CurrentCount = #self.Results
  if 0 == CurrentCount then
    ValidIndex = 1
  end
  if ValidIndex > 0 and ValidIndex <= self.k then
    if CurrentCount >= self.k then
      table.remove(self.Results, CurrentCount)
    end
    table.insert(self.Results, ValidIndex, NPC)
  end
end

function NPCBrutalFinder:StopIterate()
  for _, NPC in ipairs(self.Results) do
    if not table.contains(self.LastResults, NPC) then
      self:CallFunc(self.toValidFunc, self.toValidHandler, NPC)
    end
  end
  for _, NPC in ipairs(self.LastResults) do
    if not table.contains(self.Results, NPC) then
      self:CallFunc(self.toInValidFunc, self.toInValidHandler, NPC)
    end
  end
  table.clear(self.LastResults)
  for i = 1, #self.Results do
    self.LastResults[i] = self.Results[i]
  end
end

function NPCBrutalFinder:StepIterate(npcDict, Index, Owner)
  if not Index then
    self.bIsStepIterating = true
    self:StartIterate()
  elseif not npcDict[Index] then
    self:StopIterate()
    self.bIsStepIterating = false
    return nil
  end
  local CurrentIndex = Index
  local NPC
  for _ = 1, 10 do
    CurrentIndex, NPC = next(npcDict, CurrentIndex)
    if CurrentIndex and NPC then
      if not NPC.isDestroy and not NPC:IsLocal() then
        self:Iterate(NPC)
      end
    else
      break
    end
  end
  if not CurrentIndex then
    self:StopIterate()
    self.bIsStepIterating = false
  end
  return CurrentIndex
end

function NPCBrutalFinder:GetTopK()
  if self.bIsStepIterating then
    return self.LastResults
  else
    return self.Results
  end
end

function NPCBrutalFinder:Add(npc)
end

function NPCBrutalFinder:Adjust(npc)
end

function NPCBrutalFinder:Contains(npc)
end

function NPCBrutalFinder:Remove(npc)
end

return NPCBrutalFinder
