local Fsm = require("NewRoco.Modules.Core.Fsm.Fsm")
local DoCmdAction = require("NewRoco.Modules.System.LoginModule.Actions.DoCmdAction")
local CinematicEndAction = require("NewRoco.Modules.Core.Cinematic.Fsm.Actions.CinematicEndAction")
local PlayCinematicAction = require("NewRoco.Modules.Core.Cinematic.Fsm.Actions.PlayCinematicAction")
local FsmDelayAction = require("NewRoco.Modules.Core.Fsm.Actions.FsmDelayAction")

local function CreateFsm()
  local FINISHED = "FINISHED"
  local fsm = Fsm("CinematicFsm")
  fsm:CreateVar("Result", true)
  fsm:CreateVar("CinematicConfID", 0)
  local InitState = fsm:CreateSequentialState("InitState")
  InitState:AddAction(FsmDelayAction("DelayAction", {PlayTime = 0.1}))
  local PlayState = fsm:CreateSequentialState("PlayState")
  PlayState:AddAction(PlayCinematicAction())
  local EndState = fsm:CreateSequentialState("EndState")
  EndState:AddAction(CinematicEndAction())
  InitState:AddTransitionToState(FINISHED, PlayState)
  PlayState:AddTransitionToState(FINISHED, EndState)
  fsm:SetInitState(InitState)
  return fsm
end

return CreateFsm
