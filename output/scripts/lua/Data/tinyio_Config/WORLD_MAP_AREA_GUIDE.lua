WORLD_MAP_AREA_GUIDE = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.btn_guide_text = r.btn_guide_text
  if r.btn_guide_text == "" then
    lua_record.btn_guide_text = nil
  end
  lua_record.tips = r.tips
  if "" == r.tips then
    lua_record.tips = nil
  end
  _area_func_id = {}
  for i = 0, #r.area_func_id - 1 do
    table.insert(_area_func_id, r.area_func_id[i])
  end
  lua_record.area_func_id = _area_func_id
  lua_record.map_guide_type = r.map_guide_type
  lua_record.title_bg = r.title_bg
  if "" == r.title_bg then
    lua_record.title_bg = nil
  end
  lua_record.png_1 = r.png_1
  if "" == r.png_1 then
    lua_record.png_1 = nil
  end
  lua_record.title_1 = r.title_1
  if "" == r.title_1 then
    lua_record.title_1 = nil
  end
  lua_record.text_1 = r.text_1
  if "" == r.text_1 then
    lua_record.text_1 = nil
  end
  lua_record.png_2 = r.png_2
  if "" == r.png_2 then
    lua_record.png_2 = nil
  end
  lua_record.title_2 = r.title_2
  if "" == r.title_2 then
    lua_record.title_2 = nil
  end
  lua_record.text_2 = r.text_2
  if "" == r.text_2 then
    lua_record.text_2 = nil
  end
  local _stamp_struct = {}
  for i = 0, #r.stamp_struct - 1 do
    local r_2 = r.stamp_struct[i]
    local lua_record_2 = {}
    lua_record_2.stamp_img = r_2.stamp_img
    if "" == r_2.stamp_img then
      lua_record_2.stamp_img = nil
    end
    lua_record_2.is_accum = r_2.is_accum
    table.insert(_stamp_struct, lua_record_2)
  end
  lua_record.stamp_struct = _stamp_struct
  WORLD_MAP_AREA_GUIDE[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = WORLD_MAP_AREA_GUIDE[_key]
  if nil == r then
    local r = TinyData.GetRecord("WORLD_MAP_AREA_GUIDE", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return WORLD_MAP_AREA_GUIDE[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("WORLD_MAP_AREA_GUIDE", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #WORLD_MAP_AREA_GUIDE then
    return WORLD_MAP_AREA_GUIDE
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return WORLD_MAP_AREA_GUIDE
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("WORLD_MAP_AREA_GUIDE")
end

return dataTable
