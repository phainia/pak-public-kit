local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local EffectsNPCGenerator = Class()

function EffectsNPCGenerator:Ctor()
end

function EffectsNPCGenerator:Show(npc)
end

function EffectsNPCGenerator:SetCreateNPC(npc)
  Log.Debug("EffectsNPCGenerator:SetCreateNPC")
  self:Show(npc)
end

return EffectsNPCGenerator
