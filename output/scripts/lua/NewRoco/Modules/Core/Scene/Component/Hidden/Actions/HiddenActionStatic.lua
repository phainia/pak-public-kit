local SKILL_PATH = "/Game/ArtRes/Effects/G6Skill/Pet_Hide/Pet_Static"
local Base = require("NewRoco.Modules.Core.Scene.Component.Hidden.Actions.HiddenActionDrill")
local HiddenActionStatic = Base:Extend("HiddenActionStatic")

function HiddenActionStatic:Init(comp)
  Base.Init(self, comp)
  self.skillPath = _G.NRCUtils.FormatBlueprintAssetPath(SKILL_PATH)
end

function HiddenActionStatic:LoopAnim()
  local animComp = self.owner:GetAnimComponent()
  if animComp and UE.UObject.IsValid(animComp) then
    animComp:PlayAnimByName("StaticLoop", 1, 0, 0, 0.2, -1)
  end
end

function HiddenActionStatic:StopAnim()
  local animComp = self.owner:GetAnimComponent()
  if animComp and UE.UObject.IsValid(animComp) then
    animComp:StopAnimByName("StaticLoop", 0.2)
  end
end

return HiddenActionStatic
