local infectedResources = {}
local scanStats = {
  totalScanned = 0,
  infected = 0,
  cleaned = 0,
  startTime = 0,
  endTime = 0
}

local function sendDiscordWebhook(infections)
  if not ZayssScanner.SendZayssDiscordLogs or not ZayssScanner.DiscordWebhook then return end

  local embed = {
    embeds = {{
      title = "``🚨`` Détection de backdoor",
      description = string.format("**%d potentiels backdoors ont été détectés, veuillez vérifier les informations ci-dessous :**", #infections),
      color = 32727,
      fields = {},
      footer = {
        text = "ZayssScanner By Zayss | V1"
      },
      timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }}
  }

  for i, infection in ipairs(infections) do
    if i <= 10 then
      table.insert(embed.embeds[1].fields, {
        name = "# ``📃`` Resource: " .. (infection.resource or "Unknown"),
        value = string.format(
          "**File:** ``%s``\n**Type:** ``%s``\n**Level:** ``%s``\n**Score:** ``%d``",
          infection.file or infection.name or "Unknown",
          infection.backdoorType or infection.stringfound or "Unknown",
          infection.suspicionLevel or "Unknown",
          infection.suspicionScore or 0
        ),
        inline = false
      })
    end
  end

  if #infections > 10 then
    table.insert(embed.embeds[1].fields, {
      name = "Additional Infections",
      value = string.format("... and %d more", #infections - 10),
      inline = false
    })
  end

  PerformHttpRequest(ZayssScanner.DiscordWebhook, function(err, text, headers) end, 'POST', json.encode(embed), { ['Content-Type'] = 'application/json' })
end

local function isResourceIgnored(resourceName)
  for _, ignored in ipairs(ZayssScanner.IgnoreResources) do
    if resourceName == ignored then
      return true
    end
  end
  return false
end

local function analyzeObfuscationLevel(content)
  if not ZayssScanner.AdvancedDetection.DetectObfuscation then
    return 0, "Low", {}
  end

  local score = 0
  local details = {}

  if ZayssScanner.AdvancedDetection.DetectEval and string.find(content, "eval") then
    score = score + 10
    table.insert(details, "eval() detected")
  end

  if string.find(content, "fromCharCode") then
    score = score + 15
    table.insert(details, "fromCharCode encoding")
  end

  local unicodeCount = 0
  for _ in content:gmatch("\\u%x%x%x%x") do
    unicodeCount = unicodeCount + 1
  end
  if unicodeCount > 50 then
    score = score + 20
    table.insert(details, unicodeCount .. " unicode sequences")
  end

  if ZayssScanner.AdvancedDetection.DetectXOREncryption and string.find(content, "charCodeAt%(0%)%^") then
    score = score + 25
    table.insert(details, "XOR encryption")
  end

  if ZayssScanner.AdvancedDetection.DetectRemoteExecution and string.find(content, "PerformHttpRequest") and string.find(content, "eval") then
    score = score + 30
    table.insert(details, "Remote code execution")
  end

  if ZayssScanner.AdvancedDetection.DetectBase64 and string.find(content, "atob%(") then
    score = score + 15
    table.insert(details, "Base64 decoding")
  end

  if ZayssScanner.AdvancedDetection.DetectSuspiciousAPIs then
    if string.find(content, "ExecuteCommand") or string.find(content, "TriggerServerEvent") then
      score = score + 10
      table.insert(details, "Suspicious API usage")
    end
  end

  local suspicionLevel = "Low"
  if score > 50 then
    suspicionLevel = "CRITICAL"
  elseif score > 30 then
    suspicionLevel = "High"
  elseif score > 15 then
    suspicionLevel = "Medium"
  end

  if score < ZayssScanner.AdvancedDetection.MinObfuscationScore then
    return score, "Low", details
  end

  return score, suspicionLevel, details
end

local function checkForBackdoor(content, resourceName, scriptPath)
  local backdoorPatterns = {
    {pattern = "cipher%-panel", name = "cipher-panel", type = "[[CIPHER BACKDOOR]]"},
    {pattern = "Enchanced_Tabs", name = "Enchanced_Tabs", type = "[[CIPHER BACKDOOR]]"},
    {pattern = "eszjqvpjhiou%.mom", name = "Cipher Backdoor new version", type = "[[CIPHER BACKDOOR]]"},
    {pattern = "cfx%.re", name = "cipher-panel([cfx.re])", type = "[CIPHER BACKDOOR]"},
    {pattern = "pqzskjptss", name = "pqzskjptss", type = "[CIPHER BACKDOOR]"},
    {pattern = "/stage3?", name = "/stage3?", type = "[CIPHER BACKDOOR]"},
    {pattern = "abxcgraovp", name = "abxcgraovp", type = "[CIPHER BACKDOOR]"},
    {pattern = "eszjqvpjhiou", name = "eszjqvpjhiou", type = "[CIPHER BACKDOOR]"},
    {pattern = "rpserveur%.fr", name = "rpserveur.fr", type = "[CIPHER BACKDOOR]"},
    {pattern = "KjnUNXqPtJIgEvURPelSeeNlHRsEvwXhUUjttMNBPYbBHoycMcfTcfpLYTYussggrdtEyi", name = "Cipher Backdoor", type = "[CIPHER BACKDOOR]"},
    {pattern = "helperServer", name = "helperServer", type = "[[CIPHER BACKDOOR]]"},
    {pattern = "ketamin%.cc", name = "ketamin.cc", type = "[[KETAMIN BACKDOOR]]"},
    {pattern = "cipher%-panel%.me", name = "cipher-panel.me", type = "[[CIPHER BACKDOOR]]"},
    {pattern = "blum-panel.me", name = "blum-panel", type = "[[BLUM-PANEL BACKDOOR]]"},
    {pattern = "blum%-panel%.me", name = "blum-panel", type = "[[BLUM-PANEL BACKDOOR]]"},
    {pattern = "blum%-panel%", name = "blum-panel", type = "[[BLUM-PANEL BACKDOOR]]"},
    {pattern = "blum-panel", name = "blum-panel", type = "[[BLUM-PANEL BACKDOOR]]"},
    {pattern = "MpWxwQeLMRJaDFLKmxVIFNeVfzVKaTBiVRvjBoePYciqfpJzxjNPIXedbOtvIbpDxqdoJR", name = "MpWxwQeLMRJaDFLKmxVIFNeVfzVKaTBiVRvjBoePYciqfpJzxjNPIXedbOtvIbpDxqdoJR", type = "[[CIPHER BACKDOOR]]"}
  }

  for _, backdoor in ipairs(backdoorPatterns) do
    if string.find(content, backdoor.pattern) then
      return true, backdoor.name, backdoor.type
    end
  end

  if string.find(content, "x=s=>eval%(s%.replace") and string.find(content, "fromCharCode") then
    return true, "XOR Obfuscated Backdoor (eval + fromCharCode)", "[[XOR OBFUSCATION BACKDOOR]]"
  end

  if string.find(content, "String%.fromCharCode") and string.find(content, "eval") then
    return true, "JavaScript Obfuscated eval", "[[OBFUSCATION BACKDOOR]]"
  end

  if string.find(content, "globalThis%[") and string.find(content, "%]%(") then
    return true, "GlobalThis execution backdoor", "[[OBFUSCATION BACKDOOR]]"
  end

  if string.find(content, "charCodeAt%(0%)%^%d") then
    return true, "XOR Character encoding", "[[XOR BACKDOOR]]"
  end

  if string.find(content, "\\u%x%x%x%x") and string.find(content, "eval") then
    local unicodeCount = 0
    for _ in content:gmatch("\\u%x%x%x%x") do
      unicodeCount = unicodeCount + 1
    end
    if unicodeCount > 50 then
      return true, "Unicode Obfuscated Code (Suspected XOR)", "[[UNICODE OBFUSCATION BACKDOOR]]"
    end
  end

  if string.find(content, "%.replace%(") and string.find(content, "split%(") and string.find(content, "eval%(") then
    return true, "String manipulation + eval", "[[OBFUSCATION BACKDOOR]]"
  end

  if (string.find(content, "PerformHttpRequest") or string.find(content, "https?://")) and string.find(content, "eval") then
    return true, "Remote code execution via HTTP", "[[REMOTE EXECUTION BACKDOOR]]"
  end

  if string.find(content, "LoadResourceFile") and string.find(content, "load%(") then
    return true, "Dynamic file loading", "[[SUSPICIOUS CODE LOADING]]"
  end

  return false, nil, nil
end

local function scanResource(resourceName)
  if isResourceIgnored(resourceName) then
    print("(^4ZayssScanner^0): (^6Skip^0) => Ressource whitelist ignorée : ^7" .. resourceName)
    return
  end

  scanStats.totalScanned = scanStats.totalScanned + 1

  local scriptsToScan = {}

  if ZayssScanner.ScanOptions.ScanServerScripts then
    local numServerScripts = GetNumResourceMetadata(resourceName, "server_script")
    for j = 0, numServerScripts - 1 do
      local scriptPath = GetResourceMetadata(resourceName, "server_script", j)
      table.insert(scriptsToScan, {path = scriptPath, type = "server"})
    end
  end

  if ZayssScanner.ScanOptions.ScanClientScripts then
    local numClientScripts = GetNumResourceMetadata(resourceName, "client_script")
    for j = 0, numClientScripts - 1 do
      local scriptPath = GetResourceMetadata(resourceName, "client_script", j)
      table.insert(scriptsToScan, {path = scriptPath, type = "client"})
    end
  end

  if ZayssScanner.ScanOptions.ScanUIPages then
    local numUiPages = GetNumResourceMetadata(resourceName, "ui_page")
    for j = 0, numUiPages - 1 do
      local uiPage = GetResourceMetadata(resourceName, "ui_page", j)
      table.insert(scriptsToScan, {path = uiPage, type = "ui"})
    end
  end

  for _, script in ipairs(scriptsToScan) do
    local scriptPath = script.path
    if scriptPath and not string.find(scriptPath, "*") then
      local content = LoadResourceFile(resourceName, scriptPath)

      if content and content ~= "" then
        local isInfected, backdoorName, backdoorType = checkForBackdoor(content, resourceName, scriptPath)

        if isInfected then
          scanStats.infected = scanStats.infected + 1

          local score, level, details = analyzeObfuscationLevel(content)

          local infectedResource = {
            resource = resourceName,
            file = scriptPath,
            backdoorType = backdoorType,
            backdoorName = backdoorName,
            suspicionScore = score,
            suspicionLevel = level,
            details = details,
            deleted = false
          }

          print("[^4RESSOURCE INFECTÉE DÉTECTÉE^0] - " .. resourceName)
          print("^5  └─ Fichier^0: " .. scriptPath)
          print("^5  └─ Type^0: " .. backdoorType)
          print("^5  └─ Niveau de menace^0: " .. level .. " (Score: ^5" .. score .. "^0)")

          table.insert(infectedResources, infectedResource)
        end
      end
    end
  end
end

local function startScan()
  infectedResources = {}
  scanStats.startTime = os.clock()
  scanStats.totalScanned = 0
  scanStats.infected = 0
  scanStats.cleaned = 0

  print("(^4ZayssScanner^0): (^3Scan^0) => Début de l'analyse approfondie de toutes les ressources...")

  for i = 0, GetNumResources() - 1 do
    local resourceName = GetResourceByFindIndex(i)
    scanResource(resourceName)
  end

  scanStats.endTime = os.clock()

  if #infectedResources > 0 then
    print("^5========================================^0")
    print("(^4ZayssScanner^0): (^3Scan^0) => Des backdoors potentielles ont été détectées !")
    print("(^4ZayssScanner^0): (^3Scan^0) => Veuillez vérifier les print ou logs discord si actif pour plus d'informations.")
    print("^5========================================^0")

    for _, infection in ipairs(infectedResources) do
        print("^5+^0 ^1" .. infection.resource .. "/" .. infection.file .. "^0")
      print("Type: [^1" .. infection.backdoorType .. "^0]")
    end

    print("^5========================================^0")
    print("(^4ZayssScanner^0): (^3Scan^0) => Informations du scan")
    print("(^4ZayssScanner^0): (^3Scan^0) =>  Total Scanné: ^3" .. scanStats.totalScanned .. " ^0")
    print("(^4ZayssScanner^0): (^3Scan^0) =>  Potentiellement infectés: ^1" .. scanStats.infected .. " ^0")
    print("(^4ZayssScanner^0): (^3Scan^0) =>  Durée du scan: ^3" .. string.format("%.2f", scanStats.endTime - scanStats.startTime) .. "s^0")
    print("^5========================================^0")

    if ZayssScanner.SendZayssDiscordLogs then
      sendDiscordWebhook(infectedResources)
    end

    if ZayssScanner.StopServer and scanStats.infected > 0 and scanStats.cleaned == 0 then
      print("(^4ZayssScanner^0): (^3Scan^0) => Backdoors non éliminées détectées !")
      print("(^4ZayssScanner^0): (^3Scan^0) => Le serveur s'arrêtera dans 5 secondes....")
      Citizen.Wait(5000)
      os.exit()
    end
  else
    print("^5========================================^0")
    print("(^4ZayssScanner^0): (^3Scan^0) => Aucune backdoor detecté ")
    print("(^4ZayssScanner^0): (^3Scan^0) => Votre serveur est clean mais veuillez quand meme verifier a la main si vous trouvez des fichiers suspects.")
    print("^5========================================^0")
  end
end

AddEventHandler("onResourceStart", function(resourceName)
  if resourceName == GetCurrentResourceName() then
      print([[
^5          __________                            _________
^5          \____    /____  ___.__. ______ ______/   _____/ ____ _____    ____
^5            /     /\__  \<   |  |/  ___//  ___/\_____  \_/ ___\\__  \  /    \
^5           /     /_ / __ \\___  |\___ \ \___ \ /        \  \___ / __ \|   |  \
^5          /_______ (____  / ____/____  >____  >_______  /\___  >____  /___|  /
^5                  \/    \/\/         \/     \/        \/     \/     \/     \/^0
  ]])
    print("^5=============================================^0")
    print("(^4ZayssScanner^0): Commandes disponibles: ^6scan-backdoor^0 - Lance une analyse dans tous les repertoires du serveur.")
    print("(^4ZayssScanner^0): ZayssScanner By ^5Zayss^0 : https://github.com/zayss212/Zayss-Scanner---Backdoor-FiveM")
    print("(^4ZayssScanner^0): N'hésitez pas à rejoindre mon discord : ^5https://discord.gg/RPsJneRd9V^0")
  end

  if ZayssScanner.AutoScan.Enabled  and resourceName ~= GetCurrentResourceName() then
    Citizen.SetTimeout(2000, function()
      print("(^4ZayssScanner^0): Nouvelle ressource détectée: ^7" .. resourceName)
      scanResource(resourceName)
    end)
  end
end)

if ZayssScanner.AutoScan.Enabled then
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(ZayssScanner.AutoScan.Interval)
      print("(^4ZayssScanner^0): Exécution de l'analyse planifiée selon la config...")
      startScan()
    end
  end)
end

RegisterCommand("scan-backdoor", function()
    print([[
        __________                            _________
        \____    /____  ___.__. ______ ______/   _____/ ____ _____    ____
          /     /\__  \<   |  |/  ___//  ___/\_____  \_/ ___\\__  \  /    \
         /     /_ / __ \\___  |\___ \ \___ \ /        \  \___ / __ \|   |  \
        /_______ (____  / ____/____  >____  >_______  /\___  >____  /___|  /
                \/    \/\/         \/     \/        \/     \/     \/     \/
]])
  print("^5=============================================^0")
  Wait(1000)
  print("(^4ZayssScanner^0): ^0Recherche de ^6Cipher^0 backdoors...")
  Wait(1000)
  print("(^4ZayssScanner^0): ^0Recherche de ^6Ketamin^0 backdoors...")
  Wait(1000)
  print("(^4ZayssScanner^0): ^0Recherche de ^6XOR obfuscated^0 backdoors...")
  Wait(1000)
  print("(^4ZayssScanner^0): ^0Recherche de ^6remote execution^0 backdoors...")
  Wait(1000)
  print("(^4ZayssScanner^0): ^0Analyse des niveaux de menace...")
  Wait(1000)
  print("^5=============================================^0")

  startScan()
end)
