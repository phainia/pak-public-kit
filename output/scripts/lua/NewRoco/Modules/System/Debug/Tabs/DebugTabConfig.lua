local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local BinDataUtils = require("Common.BinDataUtils")
local Base = DebugTabBase
local DebugTabConfig = Base:Extend("DebugTabConfig")

function DebugTabConfig:Ctor()
  Base.Ctor(self)
end

function DebugTabConfig:SetupTabs()
  local AllTables = _G.DataConfigManager.__configTableInfo
  for _, Item in ipairs(AllTables) do
    local Name = Item.name
    self:Add(Name, self.ShowConfig, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128")
  end
end

function DebugTabConfig:DoSwitchConfig(useBinConfig, Panel)
  if RocoEnv.IS_SHIPPING then
    _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "\229\189\147\229\137\141\231\137\136\230\156\172\228\184\141\230\148\175\230\140\129\229\136\135\230\141\162!")
    return
  end
  if useBinConfig == not _G.GlobalConfig.DisableBinData then
    if _G.GlobalConfig.DisableBinData then
      _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "\229\189\147\229\137\141\229\183\178\231\187\143\229\164\132\228\186\142lua\233\133\141\231\189\174\232\161\168\230\168\161\229\188\143!")
    else
      _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "\229\189\147\229\137\141\229\183\178\231\187\143\229\164\132\228\186\142Bin\233\133\141\231\189\174\232\161\168\230\168\161\229\188\143!")
    end
    return
  end
  local GameInstance = UE4.UNRCPlatformGameInstance.GetInstance()
  if not GameInstance then
    return
  end
  if useBinConfig then
    GameInstance:SetBackToLoginCustomData("forceUseLuaConfig", "0")
  else
    GameInstance:SetBackToLoginCustomData("forceUseLuaConfig", "1")
  end
  local Ctx = DialogContext()
  Ctx:SetTitle("\229\136\135\230\141\162\233\133\141\231\189\174\232\161\168"):SetContent("\229\136\135\230\141\162\229\174\140\230\136\144\239\188\140\231\130\185\229\135\187\229\133\179\233\151\173\229\189\147\229\137\141\229\175\185\232\175\157\230\161\134\232\191\155\232\161\140\232\191\148\229\155\158\231\153\187\229\189\149\229\144\142\231\148\159\230\149\136"):SetContentTextJustify(UE4.ETextJustify.Center):SetMode(DialogContext.Mode.NotBtn):SetCloseOnOK(true):SetCallback(nil, function()
    _G.AppMain.BackToLogin(true)
  end)
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Ctx)
  if Panel then
    Panel:DoClose()
  end
end

function DebugTabConfig:SwitchToLuaConfig(Name, Panel)
  self:DoSwitchConfig(false, Panel)
end

function DebugTabConfig:SwitchToBinConfig(Name, Panel)
  self:DoSwitchConfig(true, Panel)
end

function DebugTabConfig:ValidBinData(Name, Panel)
  local result = _G.DataConfigManager:ValidAllData()
  self:Inspect(result, "\229\175\185\230\175\148\231\187\147\230\158\156")
  if Panel then
    Panel:DoClose()
  end
end

function DebugTabConfig:LoadAllConfig(Name, Panel)
  for _, _tableId in pairs(_G.DataConfigManager.ConfigTableId) do
    _G.DataConfigManager:GetTable(_tableId)
  end
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "\229\183\178\229\138\160\232\189\189\229\174\140\230\137\128\230\156\137\233\133\141\231\189\174\230\149\176\230\141\174!")
  if Panel then
    Panel:DoClose()
  end
end

function DebugTabConfig:ShowCacheData(Name, Panel)
  local BinDataCacheQuery = {}
  local BinDataCacheMarkAlreadyRef = {}
  if _G.BinDataCache then
    for _, _cache in pairs(_G.BinDataCache) do
      BinDataCacheQuery[_cache] = true
    end
  end
  
  local function splitStr(str, sep)
    local result = {}
    local start_pos = 1
    local sep_start, sep_end = string.find(str, sep, start_pos, true)
    while sep_start do
      local part = string.sub(str, start_pos, sep_start - 1)
      table.insert(result, part)
      start_pos = sep_end + 1
      sep_start, sep_end = string.find(str, sep, start_pos, true)
    end
    table.insert(result, string.sub(str, start_pos))
    return result
  end
  
  local copyCache
  
  function copyCache(cache)
    local ret = {}
    for k, v in pairs(cache) do
      local vType = type(v)
      if "function" ~= vType then
        if BinDataCacheQuery[v] then
          BinDataCacheMarkAlreadyRef[v] = true
        end
        if "table" == vType then
          ret[k] = copyCache(v)
        else
          ret[k] = v
        end
      end
    end
    local binParser = BinDataUtils.GetParserFromBinData(cache)
    if binParser then
      ret.binParser = binParser
    end
    return ret
  end
  
  local function copyCaches(caches)
    if caches and next(caches) then
      local cachesShow = {}
      for k, v in pairs(caches) do
        if BinDataCacheQuery[v] then
          BinDataCacheMarkAlreadyRef[v] = true
        end
        cachesShow[k] = copyCache(v)
      end
      return cachesShow
    end
  end
  
  local result = {}
  local tableCaches = {}
  result.TableCaches = tableCaches
  if not _G.GlobalConfig.DisableBinData then
    local allTables = _G.DataConfigManager.__dataTables
    for _, tableInst in pairs(allTables) do
      local cacheWithKey = copyCaches(tableInst.dataCacheWithKey)
      local cacheWithIndex = copyCaches(tableInst.dataCacheWithIndex)
      if cacheWithKey or cacheWithIndex then
        tableCaches[tableInst.name] = {}
        if cacheWithKey then
          tableCaches[tableInst.name].key = cacheWithKey
        end
        if cacheWithIndex then
          tableCaches[tableInst.name].index = cacheWithIndex
        end
      end
    end
  end
  if next(BinDataCacheQuery) then
    local BinDataCacheResult = {}
    result.BinDataCache = BinDataCacheResult
    for _cache, _ in pairs(BinDataCacheQuery) do
      if BinDataCacheMarkAlreadyRef[_cache] then
      else
        local _binParser = BinDataUtils.GetParserFromBinData(_cache)
        if _binParser then
          local _debugData = UE4.FBinDataUtils.GetBinDataParserDebugData(_binParser)
          if _debugData then
            local structNames = splitStr(_debugData.struct_name, ".")
            local findTable = BinDataCacheResult
            local storeTable
            for _, structName in ipairs(structNames) do
              storeTable = findTable[structName]
              if not storeTable then
                storeTable = {}
                findTable[structName] = storeTable
              end
              findTable = storeTable
            end
            if storeTable then
              table.insert(storeTable, copyCache(_cache))
            end
          end
        end
      end
    end
  end
  self:Inspect(result, "\231\188\147\229\173\152\228\191\161\230\129\175")
  if Panel then
    Panel:DoClose()
  end
end

function DebugTabConfig:ShowConfig(Name, Panel)
  local Raw = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId[Name])
  if not Raw then
    self:ShowTips(string.format("\230\137\190\228\184\141\229\136\176\229\144\141\228\184\186%s\231\154\132\233\133\141\231\189\174", Name))
    return
  end
  local All = Raw:GetAllDatas()
  if not All then
    self:ShowTips(string.format("\230\137\190\228\184\141\229\136\176\229\144\141\228\184\186%s\231\154\132\233\133\141\231\189\174", Name))
    return
  end
  if _G.GlobalConfig.DisableBinData then
    self:Inspect(Raw:GetAllDatas(), Name)
  else
    self:Inspect(Raw:DumpAll(), Name)
  end
  if Panel then
    Panel:DoClose()
  end
end

return DebugTabConfig
