local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local CameraAdditiveParamStatus = require("NewRoco.Modules.Core.Character.WorldCamera.CameraAdditiveParamStatus")
local CameraAdditiveParamType = require("NewRoco.Modules.Core.Character.WorldCamera.CameraAdditiveParamType")
local Base = NPCActionBase
local NPCActionDungeonExit = Base:Extend("NPCActionDungeonExit")

function NPCActionDungeonExit:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionDungeonExit:Execute()
  Base.Execute(self)
  self:Finish(true)
end

function NPCActionDungeonExit:OnSubmit(rsp)
  Base.OnSubmit(self, rsp)
end

return NPCActionDungeonExit
