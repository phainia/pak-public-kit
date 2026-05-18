local Json = require("Common.JsonUtils")
local Utils = require("CookResourceCollector.Utils")
local Logger = require("CookResourceCollector.Logger")
local PathValidator = require("CookResourceCollector.Validator")
CookResourceCollector = {}

function CookResourceCollector:IsResourceTable(tbl)
  local mt = getmetatable(tbl)
  return mt and mt._isResourceTable
end

function CookResourceCollector:IsReTable(tbl)
  return type(tbl) == "table" and tbl.isRegex
end

function CookResourceCollector:GetLuaModuleNames(search_directory, filename_pattern)
  local module_folder = string.format("%sScript/%s", UE4.UBlueprintPathsLibrary.ProjectContentDir(), search_directory)
  module_folder = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(module_folder)
  local module_names = {}
  local module_paths = UE4.UAssetPipelineHelper.GetFileNamesInDirectoryRecursive(module_folder, filename_pattern):ToTable()
  for _, file_path in pairs(module_paths) do
    local root_folder = string.format("%sScript/", UE4.UBlueprintPathsLibrary.ProjectContentDir())
    root_folder = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(root_folder)
    local module_name = string.gsub(file_path, root_folder, "")
    module_name = string.gsub(module_name, "%.lua$", "")
    module_name = string.gsub(module_name, "/", ".")
    table.insert(module_names, module_name)
  end
  return module_names
end

function CookResourceCollector:GetResourcesInlFiles()
  return CookResourceCollector:GetLuaModuleNames("", "*_ResInl.lua")
end

function CookResourceCollector:GetNewRocoModuleNames()
  return CookResourceCollector:GetLuaModuleNames("NewRoco/Modules/", "*Module.lua")
end

function CookResourceCollector:CollectFromPanels(all_resources)
  print("------ Process Panel Modules Started ------")
  local module_names = CookResourceCollector:GetNewRocoModuleNames()
  NRCModeBase:Ctor()
  NRCModuleBase:Ctor()
  NRCModuleManager:Ctor()
  for _, module_name in ipairs(module_names) do
    local required_module = require(module_name)
    print("handling " .. module_name)
    func_to_call = required_module.OnConstruct
    if func_to_call then
      local status, err = pcall(func_to_call, required_module)
      if not status then
        Logger:LogScreenError(string.format("Calling func error: %s", err))
      end
    else
      Logger:LogScreenError("Function not exist")
    end
    if not required_module.modulePanelDataDict then
      print(string.format("no module panel data found in %s", module_name))
    else
      for _, data in ipairs(required_module.modulePanelDataDict) do
        print("=========================")
        print(data)
        print("=========================")
      end
    end
  end
  print("------ Process Panel Modules Done ------")
end

function CookResourceCollector:CollectFromResInlFiles(all_resources)
  print("------ Process ResInl Modules Started ------")
  local module_names = CookResourceCollector:GetResourcesInlFiles()
  for _, module_name in ipairs(module_names) do
    local required_module = require(module_name)
    if not CookResourceCollector:IsResourceTable(required_module) then
      Logger:LogScreenError(string.format("% is not a Resource Table", module_name))
    end
    print("Processing module: " .. module_name)
    for k, v in pairs(required_module) do
      if "string" == type(v) then
        if PathValidator:ValidatePath(v) then
          if UE4.UAssetPipelineHelper.IsIsValidLongPackageName(v) then
            all_resources[k] = v
          else
            all_resources[k] = UE4.UAssetPipelineHelper.ConvertAnyPathToPackageName(v)
          end
        else
          Logger:LogScreenError(string.format("Module [%s] has invalid path: %s", module_name, v))
        end
      elseif CookResourceCollector:IsReTable(v) then
        local gathered = UE4.UAssetPipelineHelper.GatherResourcePackageNames("/Game", v.pattern):ToTable()
        if 0 == #gathered then
          Logger:LogScreenError(string.format("Module [%s], No asset found in Game Content for pattern: %s", module_name, v.pattern))
        else
          for i, matchedAsset in pairs(gathered) do
            local _k = v.pattern .. i
            all_resources[_k] = matchedAsset
          end
        end
      end
    end
  end
  print("------ Process ResInl Module Done ------")
end

function CookResourceCollector:ExportFilesToCook()
  print("------ Exporting Cook Resource Started ------")
  local start_tick = os.clock()
  local all_resources = {}
  CookResourceCollector:CollectFromResInlFiles(all_resources)
  print("ALL VALID RESOURCE PATHS:")
  local filter_resources = Utils:RemoveDuplicateValuesFromTable(all_resources)
  for _, res in pairs(filter_resources) do
    if CookResourceCollector:IsReTable(res) then
      print(string.format("|-[Re] %s", res.pattern))
    else
      print(string.format("|-     %s", res))
    end
  end
  local files_to_cook = {}
  for _, path in pairs(filter_resources) do
    table.insert(files_to_cook, path)
  end
  if 0 == #files_to_cook then
    Logger.LogScreenError("[CookResourceCollector] No Files To Cook found to export")
    return false
  end
  local json_to_save = string.format("%s/FilesToCook.json", UE4.UAssetPipelineHelper.GetCookResourceCollectorDirectoryPath())
  Utils:DumpJson(json_to_save, files_to_cook)
  print("------ Exporting Cook Resource Done ------")
  print(string.format("Exporting Cook Resource took %.2f sec", os.clock() - start_tick))
  return true
end

return CookResourceCollector
