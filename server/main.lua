------------------------------------------------------------------
-- rd_adminmenu – SERVER (refresh auto + restart bossmenu)      --
------------------------------------------------------------------

local ESX
if pcall(function() ESX = exports['es_extended']:getSharedObject() end) and ESX
then else
  AddEventHandler('esx:getSharedObject', function(o) ESX = o end)
  while not ESX do Wait(50) end
end

--------------------------- Whitelist -----------------------------
local WL = {}
MySQL.ready(function()
  for _,r in ipairs(MySQL.query.await('SELECT discord_id FROM admin_whitelist')) do
    WL[r.discord_id] = true
  end
end)
local function isAllowed(src)
  for _,id in ipairs(GetPlayerIdentifiers(src)) do
    if id:find('discord:') and WL[id] then return true end
  end
end

-------------------- envoyer la liste des jobs -------------------
local function fetchJobs()
  return MySQL.query.await('SELECT name,label FROM jobs')
end
local function broadcastJobs()
  local list = fetchJobs()
  TriggerClientEvent('adminmenu:updateJobs', -1, list)   -- diffuse à TOUS
end

------------------------- Callbacks ------------------------------
ESX.RegisterServerCallback('adminmenu:canOpen', function(src, cb)
  cb(isAllowed(src))
end)

ESX.RegisterServerCallback('adminmenu:getJobs', function(src, cb)
  if not isAllowed(src) then cb({}) else cb(fetchJobs()) end
end)

------------------- Création / MAJ d’un job ----------------------
RegisterNetEvent('adminmenu:createJob', function(data)
  local src = source
  if not isAllowed(src) then return end

  local name  = data.name:lower():gsub('%s+','')
  local label = data.label
  local sal   = tonumber(data.salary)    or 0
  local bossG = tonumber(data.bossGrade) or 4

  -- insert job si absent
  if not MySQL.scalar.await('SELECT 1 FROM jobs WHERE name=?',{name}) then
    MySQL.insert('INSERT INTO jobs (name,label) VALUES (?,?)',{name,label})
  end

  -- grades
  MySQL.insert('INSERT IGNORE INTO job_grades (job_name,grade,name,label,salary) VALUES (?,?,?,?,?)',
      {name,bossG,'boss',    label..' Boss',    sal})
  MySQL.insert('INSERT IGNORE INTO job_grades (job_name,grade,name,label,salary) VALUES (?,?,?,?,?)',
      {name,0,'employe',     label..' Employé', sal})

  TriggerClientEvent('esx:showNotification', src,
      ('Job ~b~%s~s~ créé / mis à jour.'):format(label))

  -- rafraîchit la liste pour tous les admins ouverts
  broadcastJobs()

  -- redémarre rd_bossmenu (droits ACL nécessaires)
  CreateThread(function()
      Wait(500)
      StopResource('rd_bossmenu')
      Wait(100)
      StartResource('rd_bossmenu')
  end)
end)
