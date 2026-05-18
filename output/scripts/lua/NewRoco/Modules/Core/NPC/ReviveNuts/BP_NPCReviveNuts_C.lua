require("UnLuaEx")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local Delegate = require("Utils.Delegate")
local NPCModuleEnum = require("NewRoco.Modules.Core.NPC.NPCModuleEnum")
local BP_NPCReviveNuts_C = Base:Extend("BP_NPCReviveNuts_C")

function BP_NPCReviveNuts_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
end

function BP_NPCReviveNuts_C:Init()
  self:FillUpSocketNames()
  self.ActivateFinishDelegate = Delegate()
  self.ActivatePet = false
  self.fruits_for_show = {}
end

function BP_NPCReviveNuts_C:OnVisible()
  Base.OnVisible(self)
  if not self.sceneCharacter then
    Log.Error(string.format("\230\136\145\230\152\175%s\239\188\140\230\136\145\230\178\161\230\156\137sceneCharacter\239\188\140\228\184\141\230\152\175\228\184\170\230\173\163\231\187\143NPC\239\188\140\229\166\130\230\158\156\229\143\145\231\142\176\230\136\145\232\175\183\229\145\138\232\175\137marvynwang", self.GetFullName and self:GetFullName() or "BP_NPCReviveNuts_C"))
    return
  end
  if self.sceneCharacter.luaObj.IsActivate then
    self:SetGrowedState()
  else
    self:SetSeedlingState()
  end
end

function BP_NPCReviveNuts_C:CanEnterThrowInter(Comp)
  return Comp == self.NRCStaticMeshCollision
end

function BP_NPCReviveNuts_C:AddFruit(fruit)
  if 0 == #self.sockets_for_fruits then
    self:FillUpSocketNames()
  end
  if #self.sockets_for_fruits > 0 then
    if fruit.viewObj then
      local socket_name = table.remove(self.sockets_for_fruits, math.random(1, #self.sockets_for_fruits))
      fruit.viewObj:K2_AttachToComponent(self.NRCStaticMesh, socket_name, UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget, false)
      fruit.viewObj:K2_DetachFromActor(UE4.EDetachmentRule.KeepWorld, UE4.EDetachmentRule.KeepWorld, UE4.EDetachmentRule.KeepWorld)
      fruit:ReportPosition(_G.ProtoEnum.SetNpcPosType.SNPT_ITEM_DROP)
    else
      Log.Error("fruit do not have viewObj")
    end
  else
    Log.Error("\232\191\153\230\156\137\233\151\174\233\162\152\231\154\132\239\188\140\228\184\156\232\165\191\229\164\170\229\164\154\228\186\134\230\140\130\228\184\141\228\184\138")
  end
end

function BP_NPCReviveNuts_C:FillUpSocketNames()
  self.sockets_for_fruits = {}
  table.insert(self.sockets_for_fruits, "Fruit01")
  table.insert(self.sockets_for_fruits, "Fruit02")
  table.insert(self.sockets_for_fruits, "Fruit03")
  table.insert(self.sockets_for_fruits, "Fruit04")
  table.insert(self.sockets_for_fruits, "Fruit05")
end

function BP_NPCReviveNuts_C:StateChange()
end

function BP_NPCReviveNuts_C:SetChildNPC(npcs)
  for _, NPC in ipairs(npcs) do
    self:AddFruit(NPC)
  end
end

function BP_NPCReviveNuts_C:Show()
  self:SetCreateFruits(self.sceneCharacter.luaObj.createdNPC)
end

function BP_NPCReviveNuts_C:SetCreateFruits(fruits)
  self.fruits_for_show = {}
  for _, fruit in ipairs(fruits) do
    table.insert(self.fruits_for_show, fruit.sceneCharacter)
  end
  if self.resourceLoaded then
    for _, fruit in ipairs(self.fruits_for_show) do
      self:AddFruit(fruit)
      fruit.viewObj:SetActorHiddenInGame(true)
    end
    local SkillClass = self:GetUnLockSkillByType()
    if not SkillClass then
      Log.Warning("BP_NPCBox_C:PlayUnlockEffect skill not found")
    end
    local Skill
    if self.ActivatePet and self.ActivatePet.viewObj then
      Skill = RocoSkillProxy.Create(SkillClass, self.ActivatePet.viewObj.RocoSkill, PriorityEnum.Active_Player_Action)
    else
      self:PetShowFinish()
      return
    end
    if not Skill then
      return
    end
    Skill:SetCaster(self.ActivatePet.viewObj)
    Skill:SetTargets({self})
    Skill:RegisterEventCallback("PetSkillEnd", self, self.PetShowFinish)
    Skill:PlaySkill()
  end
end

function BP_NPCReviveNuts_C:PetShowFinish()
  self:PlayActivatedSkill()
  self:PlayGrowSkill()
end

function BP_NPCReviveNuts_C:PlayGrowSkill()
  local SkillClass = self:GetGrowSkill()
  if not SkillClass then
    Log.Warning("BP_NPCBox_C:PlayUnlockEffect skill not found")
  end
  local Skill = RocoSkillProxy.Create(SkillClass, self.RocoSkill, PriorityEnum.Active_Player_Action)
  if not Skill then
    return
  end
  Skill:SetCaster(self)
  local targets = {}
  for _, fruit in ipairs(self.fruits_for_show) do
    table.insert(targets, fruit.viewObj)
  end
  Skill:SetTargets(targets)
  Skill:SetPassive(true)
  Skill:RegisterEventCallback("PreEnd", self, self.RealShowFinish)
  Skill:RegisterEventCallback("End", self, self.RealShowFinish)
  Skill:RegisterEventCallback("Fruit_Appear_1", self, self.FruitAppear)
  Skill:RegisterEventCallback("Fruit_Appear_2", self, self.FruitAppear)
  Skill:RegisterEventCallback("Fruit_Appear_3", self, self.FruitAppear)
  Skill:RegisterEventCallback("Fruit_Appear_4", self, self.FruitAppear)
  Skill:RegisterEventCallback("Fruit_Appear_5", self, self.FruitAppear)
  Skill:PlaySkill()
end

function BP_NPCReviveNuts_C:PlayActivatedSkill()
  local SkillClass = self:GetActivatedSkill()
  if not SkillClass then
    Log.Warning("BP_NPCReviveNuts_C:PlayActivatedSkill skill not found")
  end
  local Skill = RocoSkillProxy.Create(SkillClass, self.RocoSkill, PriorityEnum.Active_Player_Action)
  if not Skill then
    return
  end
  Skill:SetCaster(self)
  Skill:SetPassive(true)
  Skill:PlaySkill()
end

function BP_NPCReviveNuts_C:RealShowFinish()
  self.NRCStaticMeshCollision:SetWorldScale3D(UE4.FVector(1, 1, 1))
  self.ActivateFinishDelegate:Invoke(self)
end

function BP_NPCReviveNuts_C:GetUnLockSkillByType()
  local skill_path = NPCModuleEnum.UnLockSkillPathMap[self.interact_type]
  if not string.IsNilOrEmpty(skill_path) then
    return string.format("/Game/ArtRes/Effects/G6Skill/Xibiejiaohu/%s", skill_path)
  end
  return nil
end

function BP_NPCReviveNuts_C:GetActivatedSkill()
  local skill_path = NPCModuleEnum.UnLockSkillPathMap[self.interact_type]
  if not string.IsNilOrEmpty(skill_path) then
    return string.format("/Game/ArtRes/Effects/G6Skill/Xibiejiaohu/%s01", skill_path)
  end
  return nil
end

function BP_NPCReviveNuts_C:GetGrowSkill()
  return "/Game/ArtRes/Effects/G6Skill/QiMiaoDouMiao/G6_QiMiaoDouMiao.G6_QiMiaoDouMiao"
end

function BP_NPCReviveNuts_C:FruitAppear(Name, Skill)
  local last_char = Name:sub(-1)
  local fruit_appear_index = tonumber(last_char)
  if 1 == fruit_appear_index then
    if self.interact_type == _G.Enum.SkillDamType.SDT_GRASS then
      _G.NRCAudioManager:PlaySound3DWithActorAuto(1201512202, self, "BP_NPCReviveNuts_C:FruitAppear")
    elseif self.interact_type == _G.Enum.SkillDamType.SDT_LIGHT then
      _G.NRCAudioManager:PlaySound3DWithActorAuto(1201512205, self, "BP_NPCReviveNuts_C:FruitAppear")
    elseif self.interact_type == _G.Enum.SkillDamType.SDT_WATER then
      _G.NRCAudioManager:PlaySound3DWithActorAuto(1201512204, self, "BP_NPCReviveNuts_C:FruitAppear")
    end
  end
  if fruit_appear_index <= #self.fruits_for_show then
    self.fruits_for_show[fruit_appear_index].viewObj:Grow()
    self.fruits_for_show[fruit_appear_index]:ChangeNeedPosAdjust(false, true)
  end
end

return BP_NPCReviveNuts_C
