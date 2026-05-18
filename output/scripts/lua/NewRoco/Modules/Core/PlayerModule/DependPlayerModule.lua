local DependPlayerModule = NRCModuleBase:Extend("PlayerModule")

function DependPlayerModule:OnActive()
  local playerModule = NRCModuleManager:GetModule("PlayerModule")
  if not playerModule then
    NRCModuleManager:ActiveModule("PlayerModule")
  end
end

function DependPlayerModule:GetLocalPlayer()
  local localPlayer = NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not localPlayer then
    self:LogError("try to visit local player when switch world progress not completed")
  end
  return localPlayer
end

function DependPlayerModule:OnPlayerModuleStart()
end

function DependPlayerModule:OnPlayerModulePause()
end

function DependPlayerModule:OnPlayerModuleResume()
end

function DependPlayerModule:OnPlayerModuleStop()
end

return DependPlayerModule
