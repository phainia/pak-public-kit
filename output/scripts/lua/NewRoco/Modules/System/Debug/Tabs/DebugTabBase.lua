local Class = _G.MakeSimpleClass
local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local DebugTabOptionData = {
  name = "",
  showName = "",
  show = false
}
local DebugTabOptions = {
  callbackOwner = nil,
  onCheckStateChangedCallback = nil,
  optionData = {}
}
local DebugTabBase = Class("DebugTabBase")

function DebugTabBase:SetupTabs()
end

function DebugTabBase:AddSecondTab()
end

function DebugTabBase:Ctor(...)
  self.items = {}
  self.itemsMap = {}
  self.module = NRCModuleManager:GetModule("DebugModule")
  self:LoadDataFromExcel()
  self:SetupTabs()
  self.needRefresh = false
end

function DebugTabBase:LoadDataFromConfig()
end

function DebugTabBase:SetPanel(inPanel)
  self.Panel = inPanel
end

function DebugTabBase:Add(name, callback, owner, ShortcutKeyName, Instruction, UseType, Order, Describe, Dynamic, funcName, GMCommandGroupName)
  local item = {
    name,
    callback,
    owner,
    ShortcutKeyName,
    Instruction,
    UseType,
    Order,
    Describe,
    Dynamic,
    LuaFileName = owner.name,
    funcName = funcName,
    GMCommandGroupName = GMCommandGroupName
  }
  table.insert(self.items, item)
  self.itemsMap[name] = item
  if not self.module.data.hasBuildGMItemData then
    self.module.data:InsertGMItemData(item)
  end
end

function DebugTabBase:RemoveAll()
  for i = #self.items, 1, -1 do
    self:RemoveGMItemData(self.items[i][1], self.items[i][2], self.items[i][3])
  end
  self.items = {}
  self.itemsMap = {}
  self.options = DebugTabOptions
end

function DebugTabBase:RemoveGMItemData(name, callback, owner, ShortcutKeyName, Instruction, UseType, Order, Describe, Dynamic, funcName, GMCommandGroupName)
  local item = {
    name,
    callback,
    owner,
    ShortcutKeyName,
    Instruction,
    UseType,
    Order,
    Describe,
    Dynamic,
    LuaFileName = owner.name,
    funcName = funcName,
    GMCommandGroupName = GMCommandGroupName
  }
  if not self.module.data.hasBuildGMItemData then
    self.module.data:RemoveGMItemData(item)
  end
end

function DebugTabBase:ShowDialog(Content)
  local Ctx = DialogContext()
  Ctx:SetContent(Content)
  Ctx:SetButtonText("\231\161\174\229\174\154")
  Ctx:SetMode(DialogContext.Mode.OK)
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Dialog_OpenDialog, Ctx)
end

function DebugTabBase:ShowTips(Content)
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, Content)
end

function DebugTabBase:ClosePanel()
  if not self.Panel then
    return
  end
  self.Panel:DoClose()
end

function DebugTabBase:Inspect(Data, Name)
  _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.ShowTable, Data, Name or "Root")
end

function DebugTabBase:InspectOpenCached(Data, Name)
  _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.OpenCachedDebugData, Data, Name or "Root")
end

function DebugTabBase:InspectAddCached(Data, Name)
  _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.AddCachedDebugData, Data, Name or "Root")
end

function DebugTabBase:GetPlayer()
  return _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
end

function DebugTabBase:GetController()
  local Player = self:GetPlayer()
  return Player.viewObj:GetController()
end

function DebugTabBase:ConsoleCommand(command)
  self:GetController():SendToConsole(command)
end

function DebugTabBase:SetPlayerLocation(X, Y, Z, SyncPos)
  local Player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if Player then
    local oldPos = Player:GetActorLocation()
    local newPos = UE4.FVector(X, Y, Z)
    _G.NRCProfilerLog:NRCTeleportProfilerLog(true, oldPos, newPos)
    Player:SetActorLocation(newPos)
    _G.NRCProfilerLog:NRCTeleportProfilerLog(false)
    Player.isTeleporting = false
    if SyncPos then
      Player:Check2SyncPos()
    end
    NRCEventCenter:DispatchEvent(SceneEvent.PlayerTeleportFinish)
    DelayManager:DelayFrames(1, function()
      Player:SendEvent(PlayerModuleEvent.ON_STOP_PASSIVE_FALLING)
    end)
  end
end

function DebugTabBase:PlayerTeleport(X, Y, Z)
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "n.NRCTransportOptimize 0")
  local Player = UE4.UGameplayStatics.GetPlayerCharacter(UE4Helper.GetCurrentWorld(), 0)
  if Player then
    local newPos = UE4.FVector(X, Y, Z)
    Player:Abs_K2_SetActorLocation_WithoutHit(newPos)
  end
end

function DebugTabBase:GetNearestNpc()
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  local Player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local NPC
  local Dist = math.huge
  local PlayerPos = Player:GetActorLocationFrameCache()
  for _, npc in pairs(NPCModule._npcDic) do
    if npc.viewObj then
      local d = UE4.FVector.DistSquared2D(npc:GetActorLocation(), PlayerPos)
      if Dist > d then
        NPC = npc
        Dist = d
      end
    end
  end
  return NPC
end

function DebugTabBase:GetInputString()
  return self.Panel.InputBox:GetText()
end

function DebugTabBase:GetInputNumber(Default)
  Default = Default or 0
  if not self.Panel then
    local panel = NRCModuleManager:GetModule("DebugModule"):GetPanel("DebugPanel")
    if not panel then
      Log.Error("\230\178\161\230\156\137\230\137\190\229\136\176DebugPanel\229\149\138")
      return Default
    else
      self.Panel = panel
    end
  end
  if self.Panel.InputBox then
    return tonumber(self.Panel.InputBox:GetText()) or Default
  else
    return Default
  end
end

function DebugTabBase:GetModule(ModuleName)
  return _G.NRCModuleManager:GetModule(ModuleName)
end

function DebugTabBase:GetWorld()
  return _G.UE4Helper.GetCurrentWorld()
end

function DebugTabBase:LoadDataFromExcel()
  local name = self.className
  local GMMainTabDataConf, maxMainTabIndex = self.module.data:GetMainTabConf()
  local GMMainTabName_IDMap = self.module.data:GetGMMainTabName_IDMap()
  local GMTabID
  if GMMainTabName_IDMap[name] then
    GMTabID = GMMainTabName_IDMap[name]
  else
    local GMSubTabName_IDMap = self.module.data:GetGMSubTabName_IDMap()
    if GMSubTabName_IDMap[name] then
      GMTabID = GMSubTabName_IDMap[name]
    end
  end
  if not GMTabID then
    return
  end
  local TabCommands = {}
  local GMGroupData = self.module.data:GetGMGroupDataMap()
  if GMGroupData[GMTabID] then
    TabCommands = GMGroupData[GMTabID]
  else
    return
  end
  for i, TabCommand in ipairs(TabCommands) do
    local buttonName = TabCommand.button_name
    local ExecFunc = TabCommand.ExecFunc
    if TabCommand.GMCommandGroupName then
      self:Add(buttonName, ExecFunc, self, nil, nil, nil, nil, nil, nil, nil, TabCommand.GMCommandGroupName)
    else
      self:Add(buttonName, ExecFunc, self)
    end
  end
end

return DebugTabBase
