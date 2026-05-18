local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Base = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local DebugTabNPCCheck = Base:Extend("DebugTabNPCCheck")

function DebugTabNPCCheck:Ctor()
  Base.Ctor(self)
end

function DebugTabNPCCheck:SetupTabs()
end

function DebugTabNPCCheck:OpenCheckNPCRes()
  SceneUtils.debugOpenCheckRes = true
end

function DebugTabNPCCheck:CheckAllLoadRef()
  Log.Debug("DebugTabNPCCheck:CheckAllLoadRef")
  self:CheckSMLoadRef()
  self:CheckSKMLoadRef()
  self:CheckCascadeLoadRef()
  self:CheckNiagaraLoadRef()
  self:CheckACLoadRef()
  self:CheckABPLoadRef()
  self:CheckActorLoadRef()
end

function DebugTabNPCCheck:CheckSMLoadRef()
  for _, name in pairs(SceneUtils.debugNPCSMResLoads) do
    Log.Debug("DebugTabNPC:CheckSMLoadRef", name)
    if "None" ~= name then
      UE4.UNRCStatics.RefObjByName(name)
    end
  end
end

function DebugTabNPCCheck:CheckSKMLoadRef()
  for _, name in pairs(SceneUtils.debugNPCSKMResLoads) do
    Log.Debug("DebugTabNPC:CheckSMLoadRef", name)
    if "None" ~= name then
      UE4.UNRCStatics.RefObjByName(name)
    end
  end
end

function DebugTabNPCCheck:CheckCascadeLoadRef()
  for _, name in pairs(SceneUtils.debugNPCCascadeResLoads) do
    Log.Debug("DebugTabNPC:CheckCascadeLoadRef", name)
    if "None" ~= name then
      UE4.UNRCStatics.RefObjByName(name)
    end
  end
end

function DebugTabNPCCheck:CheckNiagaraLoadRef()
  for _, name in pairs(SceneUtils.debugNPCNiagaraResLoads) do
    Log.Debug("DebugTabNPC:CheckNiagaraLoadRef", name)
    if "None" ~= name then
      UE4.UNRCStatics.RefObjByName(name)
    end
  end
end

function DebugTabNPCCheck:CheckACLoadRef()
  for _, name in pairs(SceneUtils.debugNPCACResLoads) do
    Log.Debug("DebugTabNPC:CheckACLoadRef", name)
    if "None" ~= name then
      UE4.UNRCStatics.RefObjByName(name)
    end
  end
end

function DebugTabNPCCheck:CheckABPLoadRef()
  for _, name in pairs(SceneUtils.debugNPCABPResLoads) do
    Log.Debug("DebugTabNPC:CheckABPLoadRef", name)
    if "None" ~= name then
      UE4.UNRCStatics.RefObjByName(name)
    end
  end
end

function DebugTabNPCCheck:CheckActorLoadRef()
  for _, name in pairs(SceneUtils.debugNPCActorResLoads) do
    Log.Debug("DebugTabNPC:CheckActorLoadRef", name)
    if "None" ~= name then
      UE4.UNRCStatics.RefObjByName(name)
    end
  end
end

function DebugTabNPCCheck:CheckTickNPCAllComp()
  self:CheckTickNPCComp()
end

function DebugTabNPCCheck:CheckTickNPCMeshComp()
  local check = {}
  check[UE4.USkeletalMeshComponent] = true
  self:CheckTickNPCComp(check)
end

function DebugTabNPCCheck:CheckIfNearestNPCTick()
  local npc = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetNearestNPC)
  if not npc then
    Log.Warning("\230\178\161\230\156\137\230\137\190\229\136\176npc")
    return
  end
  if not npc.viewObj then
    Log.Warning("\230\156\128\232\191\145NPC Actor\229\176\154\230\156\170\229\138\160\232\189\189")
    return
  end
  if npc.viewObj:IsActorTickEnabled() then
    Log.Warning("\230\156\128\232\191\145NPC Actor Tick")
  else
    Log.Warning("\230\156\128\232\191\145NPC Actor\230\178\161\230\156\137Tick")
  end
end

function DebugTabNPCCheck:CheckTickNPCActor()
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  local npcDict = NPCModule._npcDic
  local report = {}
  local inDisplay = 0
  report["Error Name"] = 0
  for id, npc in pairs(npcDict) do
    if npc.viewObj then
      local name = npc.viewObj.Overridden:GetName()
      if name then
        if not report[name] then
          report[name] = 0
        end
        if npc.viewObj:IsActorTickEnabled() then
          report[name] = report[name] + 1
        end
      else
        report["Error Name"] = report["Error Name"] + 1
      end
    end
  end
  local total = 0
  for name, time in pairs(report) do
    if time > 0 then
      Log.Debug(name, time)
      total = total + time
    end
  end
  Log.Debug("NPC TickActor total", total)
end

function DebugTabNPCCheck:CheckTickNPCActorDetail()
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  local npcDict = NPCModule._npcDic
  local report = {}
  local inDisplay = 0
  report["Error Name"] = 0
  for id, npc in pairs(npcDict) do
    if npc.viewObj then
      local name = npc.viewObj:GetDebugInfo()
      if name then
        if not report[name] then
          report[name] = 0
        end
        if npc.viewObj:IsActorTickEnabled() then
          report[name] = report[name] + 1
        end
      else
        report["Error Name"] = report["Error Name"] + 1
      end
    end
  end
  local total = 0
  for name, time in pairs(report) do
    if time > 0 then
      Log.Debug(name, time)
      total = total + time
    end
  end
  Log.Debug("NPC TickActor total", total)
end

function DebugTabNPCCheck:CheckTickNPCComp(checkComp)
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  local npcDict = NPCModule._npcDic
  local report = {}
  local inDisplay = 0
  local errorname = "????"
  report[errorname] = 0
  for id, npc in pairs(npcDict) do
    if npc.viewObj then
      local actorname = npc.viewObj.Overridden:GetName()
      local actorComps = npc.viewObj:K2_GetComponentsByClass(UE4.UActorComponent)
      for idx = 1, actorComps:Length() do
        local comp = actorComps:Get(idx)
        local compname = comp:GetName() or errorname
        local name = actorname .. "-" .. compname
        if comp:IsComponentTickEnabled() then
          if not checkComp then
            report[name] = (report[name] or 0) + 1
          elseif checkComp[UE4.USkeletalMeshComponent] and comp:IsA(UE4.USkeletalMeshComponent) then
            report[name] = (report[name] or 0) + 1
          end
        end
      end
    end
  end
  local total = 0
  for name, time in pairs(report) do
    if time > 0 then
      Log.Debug(name, time)
      total = total + time
    end
  end
  Log.Debug("NPC TickCompos total", total)
end

return DebugTabNPCCheck
