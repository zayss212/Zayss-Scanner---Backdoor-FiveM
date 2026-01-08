ZayssScanner = {}

ZayssScanner.SendZayssDiscordLogs = true
ZayssScanner.StopServer = false

ZayssScanner.DiscordWebhook = "https://discord.com/api/webhooks/1370940174552535040/WOsl-qg0OfrbvhBaYcoKquwm2PXZ4xpe9oxSNRVrcieAbmWQDmKTaVpVGv82ONgRPAd_"

ZayssScanner.IgnoreResources = {}

ZayssScanner.ScanOptions = {
    ScanServerScripts = true,
    ScanClientScripts = true,
    ScanUIPages = true,
    ScanHTMLFiles = true,
    ScanJSFiles = true,
    DeepScan = true
}

ZayssScanner.AutoScan = {
    Enabled = false,
    Interval = 3600000,
}

ZayssScanner.AdvancedDetection = {
    DetectObfuscation = true,
    DetectXOREncryption = true,
    DetectBase64 = true,
    DetectRemoteExecution = true,
    DetectEval = true,
    DetectSuspiciousAPIs = true,
    MinObfuscationScore = 30
}

ZayssScanner.Whitelist = {
    Hashes = {},
    Patterns = {}
}

ZayssScanner.CustomSignatures = {}

return ZayssScanner
