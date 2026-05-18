SCENE_RES_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.editor_name = r.editor_name
  if r.editor_name == "" then
    lua_record.editor_name = nil
  end
  lua_record.source = r.source
  if "" == r.source then
    lua_record.source = nil
  end
  lua_record.main_source = r.main_source
  if "" == r.main_source then
    lua_record.main_source = nil
  end
  lua_record.minimap_texture_path = r.minimap_texture_path
  if "" == r.minimap_texture_path then
    lua_record.minimap_texture_path = nil
  end
  lua_record.world_width = r.world_width
  lua_record.world_top_left_x = r.world_top_left_x
  lua_record.world_top_left_y = r.world_top_left_y
  lua_record.minimap_zoom = r.minimap_zoom
  lua_record.x_size = r.x_size
  lua_record.y_size = r.y_size
  lua_record.offset_x = r.offset_x
  lua_record.offset_y = r.offset_y
  lua_record.tile_size = r.tile_size
  SCENE_RES_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = SCENE_RES_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("SCENE_RES_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return SCENE_RES_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("SCENE_RES_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #SCENE_RES_CONF then
    return SCENE_RES_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return SCENE_RES_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("SCENE_RES_CONF")
end

return dataTable
