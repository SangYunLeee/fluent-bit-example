
-- 정보 로그 삭제
function cb_drop_info_logs(tag, timestamp, record)
  local log = record["log"]  
  -- 빈값이거나 [숫자]>>> 패턴으로 시작하면 유지
  if log == "" or string.match(log, "^%[%d+%]>>>") then
    return 0, 0, 0  -- 로그 유지
  end
  
  return -1, 0, 0  -- 그 외 로그 삭제
end

-- 빈 로그 삭제
function cb_drop_empty_logs(tag, timestamp, record)
  local log = record["log"]
  if log == nil or log == "" then
    return -1, 0, 0
  end
  return 0, 0, 0  -- 로그 유지
end

-- 특정 단어 제거
function cb_drop_specific_words(tag, timestamp, record)
  local log = record["log"]
  if log ~= nil then
    -- BODY 단어 이후 제거
    -- [31]>>> Body::
    local body_index = string.find(log, "%[%d+%]>>> Body::")
    if body_index ~= nil then
      log = string.sub(log, 1, body_index - 1)
      record["log"] = log
    end
  end
  return 1, timestamp, record
end

-- 조직 코드 추출
function cb_extract_org(tag, ts, record)
  local log = record["log"]
  local org = log:match('"organizationCode"%s*:%s*"([^"]+)"')
  if org then
    record["organization"] = org
  else
    record["organization"] = "nh"
  end
  return 1, ts, record
end

-- URL 추출
function cb_extract_url(tag, ts, record)
  local log = record["log"]
  -- [39]>>> URI:: [POST] /v1/api/ma/analytic/total
  local url = log:match("URI:: %[%w+%]%s+(%S+)")
  if url then
    record["url"] = url
  end
  return 1, ts, record
end
