require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.Portal.BP_NPCPortal_C")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local BP_NPCHiddenPortal_C = Base:Extend("BP_NPCHiddenPortal_C")

function BP_NPCHiddenPortal_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
end

function BP_NPCHiddenPortal_C:Init()
end

function BP_NPCHiddenPortal_C:OnVisible()
  Base.OnVisible(self)
end

function BP_NPCHiddenPortal_C:Opened()
  _G.NRCAudioManager:PlaySound3DWithActorAuto(121000203, self)
  self.NRCNiagaraSystem:SetPath("NiagaraSystem'/Game/ArtRes/Effects/Particle/Res/NS_Scene_Door_Open_show.NS_Scene_Door_Open_show'")
end

function BP_NPCHiddenPortal_C:Close()
  _G.NRCAudioManager:PlaySound3DWithActorAuto(121000204, self)
  self.NRCNiagaraSystem:ClearAll()
end

function BP_NPCHiddenPortal_C:Opening()
  self.NRCNiagaraSystem:SetPath("NiagaraSystem'/Game/ArtRes/Effects/Particle/Res/NS_Scene_Door_Open_show02.NS_Scene_Door_Open_show02'")
end

function BP_NPCHiddenPortal_C:PreOpen()
  _G.NRCAudioManager:PlaySound3DWithActorAuto(121000201, self)
  self.NRCNiagaraSystem:SetPath("NiagaraSystem'/Game/ArtRes/Effects/Particle/Res/NS_Scene_Door_Open_show02.NS_Scene_Door_Open_show02'")
end

return BP_NPCHiddenPortal_C
