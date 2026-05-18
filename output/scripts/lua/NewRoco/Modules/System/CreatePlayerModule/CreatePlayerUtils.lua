local CreatePlayerModuleCmd = require("NewRoco.Modules.System.CreatePlayerModule.CreatePlayerModuleCmd")
local CreatePlayerUtils = {}

function CreatePlayerUtils.SendEventToCreatePlayerFsm(InEvent)
  local CreatePlayerFsm = CreatePlayerUtils.GetMainFsm()
  if CreatePlayerFsm then
    CreatePlayerFsm:SendEvent(InEvent)
  end
end

function CreatePlayerUtils.CreateChildrenFsm(ParentFsm, ChildFsmName)
  local ChildFsm = Fsm(ChildFsmName)
  
  function ChildFsm.SendEventToParentFsm(...)
    ParentFsm:SendEvent(...)
  end
  
  ChildFsm.ParentFsm = ParentFsm
  _G.NRCModuleManager:DoCmd(CreatePlayerModuleCmd.InsertChildFsm, ChildFsm)
  return ChildFsm
end

function CreatePlayerUtils.GetLoginController()
  return UE4.UGameplayStatics.GetPlayerController(UE4Helper.GetCurrentWorld(), 0)
end

return CreatePlayerUtils
