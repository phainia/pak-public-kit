require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local NpcOptionEvent = require("NewRoco.Modules.Core.NPC.Executors.NpcOptionEvent")
local BP_NPCPersistentCollection_C = Base:Extend("BP_NPCPersistentCollection_C")

function BP_NPCPersistentCollection_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

function BP_NPCPersistentCollection_C:Init()
  Base.Init(self)
  self.bActivated = false
end

function BP_NPCPersistentCollection_C:OnOptionChange(Option, Action, BaseData)
  if not Option:IsOptionEnable() then
    local OperatorID = BaseData and BaseData.operator_obj_id
    local Operator = self:GetOperator(OperatorID)
    self:PlayCollectSkill(Operator)
  end
  self:OnStatusChanged()
end

function BP_NPCPersistentCollection_C:SetSceneCharacter(sceneCharacter)
  if sceneCharacter then
    Base.SetSceneCharacter(self, sceneCharacter)
    local Options = self.sceneCharacter.InteractionComponent:GetAllOptions()
    for _, Option in pairs(Options) do
      Option:AddEventListener(self, NpcOptionEvent.OptionChange, self.OnOptionChange)
    end
  else
    local Options = self.sceneCharacter.InteractionComponent:GetAllOptions()
    for _, Option in pairs(Options) do
      Option:RemoveEventListener(self, NpcOptionEvent.OptionChange, self.OnOptionChange)
    end
    Base.SetSceneCharacter(self, sceneCharacter)
  end
end

function BP_NPCPersistentCollection_C:ReceiveDestroyed()
  Base.ReceiveDestroyed(self)
end

function BP_NPCPersistentCollection_C:ReceiveBeginPlay()
  Base.ReceiveBeginPlay(self)
end

function BP_NPCPersistentCollection_C:OnVisible()
  if self:CheckIsActivated() then
    self:BornToDie()
  else
    self:DeActivateNPC()
  end
  Base.OnVisible(self)
end

function BP_NPCPersistentCollection_C:UpdateData(ServerData, bIsReconnect)
  if not bIsReconnect then
    return
  end
  if not self.bActivated and self:CheckIsActivated() then
    self:ActivateNPC()
    return
  end
  if not self:CheckIsActivated() and self.bActivated then
    self:DeActivateNPC()
  end
end

function BP_NPCPersistentCollection_C:OnStatusChanged()
  if self:CheckIsActivated() then
    self:ActivateNPC()
  else
    self:DeActivateNPC()
  end
end

function BP_NPCPersistentCollection_C:GetAnimInstance()
  if not self.SkeletalMesh then
    return nil
  end
  return self.SkeletalMesh:GetAnimInstance()
end

function BP_NPCPersistentCollection_C:PlayActiveAnim()
  local AnimInstance = self:GetAnimInstance()
  if not AnimInstance then
    return
  end
  AnimInstance.IsPick = true
  AnimInstance.IsBorn = false
end

function BP_NPCPersistentCollection_C:PlayDeActiveAnim()
  local AnimInstance = self:GetAnimInstance()
  if not AnimInstance then
    return
  end
  AnimInstance.IsPick = false
  AnimInstance.IsBorn = true
end

function BP_NPCPersistentCollection_C:CheckIsActivated()
  local OptionInfos = self.sceneCharacter.serverData.npc_interact.option_infos
  for _, info in ipairs(OptionInfos) do
    if info.enabled ~= true then
      return true
    end
  end
  return false
end

function BP_NPCPersistentCollection_C:ActivateNPC()
  if self.bActivated then
    return
  end
  self:PlayActiveAnim()
  self.bActivated = true
end

function BP_NPCPersistentCollection_C:DeActivateNPC()
  if not self.bActivated then
    return
  end
  self:PlayDeActiveAnim()
  self.bActivated = false
end

function BP_NPCPersistentCollection_C:BornToDie()
  local AnimInstance = self:GetAnimInstance()
  if not AnimInstance then
    return
  end
  AnimInstance.IsBornToDie = true
  self.bActivated = true
end

function BP_NPCPersistentCollection_C:PlayCollectSkill(Operator)
  self:PlaySkill(self.SkillPath, self, Operator and Operator.viewObj)
  _G.NRCAudioManager:PlaySound3DWithActor(self.AudioID, self, "BP_NPCPersistentCollection_C:PlayCollectSkill")
end

function BP_NPCPersistentCollection_C:GetOperator(OperatorID)
  local Operator
  if OperatorID and 0 ~= OperatorID then
    Operator = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, OperatorID) or _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GetPlayerByServerID, OperatorID)
  end
  return Operator
end

return BP_NPCPersistentCollection_C
