Editor_NPCModule = {}
Editor_NPCModule.actorRef = {}

function Editor_NPCModule.LoadNPCFrame(actor, isInBattle, needFixcoord, glassy)
  Log.Debug("Editor_NPCModule.LoadNPCFrame")
  if actor and actor.OnFrameLoad then
    table.insert(Editor_NPCModule.actorRef, UnLua.Ref(actor))
    actor.runtimeCreate = false
    actor.needFixcoord = true == needFixcoord
    local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
    SceneUtils.IsRuntime = false
    actor.isInBattle = true == isInBattle
    actor.inBattle = actor.isInBattle
    actor:Init()
    actor:LuaBeginPlay()
    if isInBattle then
      Editor_NPCModule.SetAnimConfig(actor, actor.BattleAnim or actor.SceneAnim)
    else
      Editor_NPCModule.SetAnimConfig(actor, actor.AnimConfig or actor.SceneAnim)
    end
    actor.isUnlock = true
    
    local function nullFunction()
    end
    
    if actor.PlayLockLoopEffect then
      actor.PlayLockLoopEffect = nullFunction
    end
    if actor.PlayUnlockLoopEffect then
      actor.PlayUnlockLoopEffect = nullFunction
    end
    actor:BlockLoadResource()
    if actor.OnDistanceOptimize then
      actor:OnDistanceOptimize(0, 1, true)
    else
      Log.Warning("\230\148\190\229\133\165\230\138\128\232\131\189\231\188\150\232\190\145\229\153\168\231\154\132actor\230\178\161\230\156\137OnDistanceOptimize")
    end
    if glassy then
      actor:SetGlassyDiffMutation()
    end
    local Comp = actor:K2_GetRootComponent()
    if Comp and Comp.SetBoundsScale then
      Comp:SetBoundsScale(999)
    end
  end
end

function Editor_NPCModule.SetAnimConfig(actor, AnimConfig)
  if not actor then
    return
  end
  local RocoAnim = actor.RocoAnim
  if not RocoAnim then
    return
  end
  if not AnimConfig then
    return
  end
  local Asset
  local Path = tostring(AnimConfig)
  if string.StartsWith(Path, "/Game/") then
    Asset = UE.UClass.Load(Path)
  else
    Asset = AnimConfig
  end
  if Asset then
    RocoAnim:SetAnimConfig(Asset)
    RocoAnim:InitAnimInstance()
  else
    Log.ErrorFormat("\230\151\160\230\179\149\231\187\153%s\232\174\190\231\189\174\229\138\168\231\148\187", UE.UObject.GetName(actor))
  end
end

function Editor_NPCModule.GetNPCHeight(actor)
  if actor and actor.GetHalfHeight then
    return actor:GetHalfHeight()
  end
  return 0
end

function Editor_NPCModule.ClearRef()
  Editor_NPCModule.actorRef = {}
end

function Editor_NPCModule.GetAllNPC()
  Log.Debug("Editor_NPCModule.GetAllNPC")
  _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.DebugNPCMemInfo, true, true, true)
end

_G.NRCEditorEntranceEnable = true
return Editor_NPCModule
