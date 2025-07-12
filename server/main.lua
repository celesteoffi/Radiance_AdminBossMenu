local ESX
if pcall(function() ESX = exports['es_extended']:getSharedObject() end) and ESX then
else AddEventHandler('esx:getSharedObject', function(o) ESX=o end) while not ESX do Wait(50) end end

-- charge whitelist dans un cache
local WL = {}   -- [discord] = true
MySQL.ready(function()
  for _,row in ipairs(MySQL.query.await('SELECT discord_id FROM admin_whitelist')) do
    WL[row.discord_id] = true
  end
end)

-- renvoie true si le joueur est whiteliste
local function isAllowed(src)
  for _,id in ipairs(GetPlayerIdentifiers(src)) do
    if id:find('discord:') and WL[id] then return true end
  end
  return false
end

-- callback d’accès
ESX.RegisterServerCallback('adminmenu:canOpen', function(src,cb)
  cb(isAllowed(src))
end)

-- création d’un job (table es_extended `jobs`)
RegisterNetEvent('adminmenu:createJob',function(data)
  if not isAllowed(source) then return end
  local name  = data.name:lower():gsub('%s+','')
  local label = data.label
  local salary= tonumber(data.salary) or 0
  local bossG = tonumber(data.bossGrade) or 4

  -- insère dans jobs si pas existant
  local exists = MySQL.scalar.await('SELECT 1 FROM jobs WHERE name=?',{name})
  if not exists then
    MySQL.insert('INSERT INTO jobs (name, label) VALUES (?,?)',{name,label})
  end

  -- grade boss
  MySQL.insert('INSERT IGNORE INTO job_grades (job_name, grade, name, label, salary) VALUES (?,?,?,?,?)',
      {name,bossG,'boss',label..' Boss',salary})

  -- grade 0 employé
  MySQL.insert('INSERT IGNORE INTO job_grades (job_name, grade, name, label, salary) VALUES (?,?,?,?,?)',
      {name,0,'employe',label..' Employé',salary})

  TriggerClientEvent('esx:showNotification', source, ('Job ~b~%s~s~ créé.'):format(label))
end)

-- liste des jobs pour l’UI
ESX.RegisterServerCallback('adminmenu:getJobs', function(src,cb)
  if not isAllowed(src) then cb({}) return end
  local rows = MySQL.query.await('SELECT name,label FROM jobs')
  cb(rows)
end)
