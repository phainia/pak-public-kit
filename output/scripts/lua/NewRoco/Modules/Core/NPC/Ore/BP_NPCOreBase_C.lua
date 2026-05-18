require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local BP_NPCOreBase_C = Base:Extend("BP_NPCOreBase_C")

function BP_NPCOreBase_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
  self.HoldOre = false
  self.isImpacted = true
end

function BP_NPCOreBase_C:Init()
  Base.Init(self)
  self.isImpacted = true
  self.NeedDisappear = false
end

function BP_NPCOreBase_C:Recycle()
  self.NeedDisappear = false
  self.isImpacted = true
  Base.Recycle(self)
end

function BP_NPCOreBase_C:OnVisible()
  Base.OnVisible(self)
  self.Item_Gleam:SetActive(true)
end

function BP_NPCOreBase_C:OnInVisible()
  Base.OnInVisible(self)
  self.Item_Gleam:SetActive(false)
end

local SkillPath = "/Game/ArtRes/Effects/G6Skill/SceneCaiji/G6_Scene_OreShow"

function BP_NPCOreBase_C:Show()
  if not self.isCreatedNPCDone or not self.isImpacted then
    return
  end
  self:PlaySkill(SkillPath, self, nil, nil, nil, true)
  local Children = self.sceneCharacter.luaObj:GetChildrenNPCs()
  if Children then
    table.clear(self.sceneCharacter.luaObj.createdNPC)
    for _, NPC in ipairs(Children) do
      if NPC and NPC.viewObj then
        table.insert(self.sceneCharacter.luaObj.createdNPC, NPC.viewObj)
      end
    end
  end
  local SceneCharacter = self.sceneCharacter
  if SceneCharacter then
    SceneCharacter:SetVisibleForBornDieReason(false)
  end
  Base.Show(self)
end

function BP_NPCOreBase_C:GetExplodeLocation()
  local vec = self:Abs_K2_GetActorLocation()
  return UE4.FVector(vec.X, vec.Y, vec.Z + 70)
end

function BP_NPCOreBase_C:PlayDisappearPerform()
  self.NeedDisappear = true
end

function BP_NPCOreBase_C:CanEnterThrowInter(Comp)
  return Comp and Comp == self.StaticMesh
end

return BP_NPCOreBase_C
