local NPCModuleData = _G.NRCData:Extend("NPCModuleData")

function NPCModuleData:Ctor()
  _G.NRCData.Ctor(self)
  self.npcDict = {}
end

function NPCModuleData:GetAllNPC()
  return self.npcDict
end

function NPCModuleData:UpdateNPC(npc)
  if not npc then
    return
  end
  if not self.npcDict then
    return
  end
  self.npcDict[npc.base.actor_id] = npc
end

function NPCModuleData:AddNPC(npc)
  if not npc then
    return
  end
  if not self.npcDict then
    return
  end
  self.npcDict[npc.base.actor_id] = npc
end

function NPCModuleData:RemoveNPC(id)
  if not self.npcDict then
    return
  end
  self.npcDict[id] = nil
end

function NPCModuleData:Clear()
  self.npcDict = {}
end

return NPCModuleData
