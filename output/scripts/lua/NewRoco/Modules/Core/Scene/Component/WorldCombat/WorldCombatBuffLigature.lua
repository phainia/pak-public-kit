local WorldCombatBuffBase = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatBuffBase")
local LigatureComponent = require("NewRoco.Modules.Core.Scene.Component.Boss.LigatureComponent")
local WorldCombatSkillComponent = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatSkillComponent")
local Base = WorldCombatBuffBase
local WorldCombatBuffLigature = Base:Extend("WorldCombatBuffLigature")

function WorldCombatBuffLigature:Ctor(Parent, Buff, Conf)
  Base.Ctor(self, Parent, Buff, Conf)
end

function WorldCombatBuffLigature:OnInit()
  Base.OnInit(self)
  self:OnCreateLigature()
end

function WorldCombatBuffLigature:OnAdd()
  self:OnCreateLigature()
end

function WorldCombatBuffLigature:OnCreateLigature()
  if self.Parent.owner then
    local OwnerLigatureComponent = self.Parent.owner:EnsureComponent(LigatureComponent)
    local skillComp = self.Parent.owner:EnsureComponent(WorldCombatSkillComponent)
    local playerModule = NRCModuleManager:GetModule("PlayerModule")
    local target = playerModule:GetLocalPlayer()
    if skillComp.currentContext and skillComp.currentContext.target then
      target = skillComp.currentContext.target
    end
    if self.Config.option and #self.Config.option > 0 then
      local CasterBoneAddOnName = self.Config.option[1].link_point
      local TargetBoneAddOnName = self.Config.option[1].line_target_link_point
      OwnerLigatureComponent:PlayLigature(target, CasterBoneAddOnName, TargetBoneAddOnName, self.Config.option[1].particle_name, self.Config.option[1].line_target_particle)
    end
  end
end

function WorldCombatBuffLigature:OnRemove(Reason)
  if self.Parent.owner then
    local OwnerLigatureComponent = self.Parent.owner:EnsureComponent(LigatureComponent)
    OwnerLigatureComponent:StopLigature()
  end
end

return WorldCombatBuffLigature
