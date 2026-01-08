# 🛡️ ZayssScanner - Backdoor Detection for FiveM

**Un scanner de backdoors professionnel pour sécuriser votre serveur FiveM**

[📥 Installation](#-installation) • [⚙️ Configuration](#️-configuration) • [🎯 Utilisation](#-utilisation) • [💬 Support](#-support)

---

## 📌 Contexte

Depuis l'explosion des ressources **unlock** et **fxap**, l'écosystème FiveM est devenu un terrain fertile pour les backdoors. Des scripts infectés circulent massivement à travers des ressources "unlockées", revendues ou leakées.

### 🚨 Les conséquences

Des milliers de serveurs ont été victimes :
- **Exécution de code à distance** : Contrôle total du serveur
- **Vol de données** : Base de données, tokens, webhooks Discord
- **Injection de scripts** : Installation automatique de malwares
- **Sabotage** : Destruction de données, bannissements massifs

**Ce problème est toujours d'actualité.** Ce projet est né d'un besoin critique : disposer d'un outil fiable pour analyser ses ressources avant de les utiliser en production.

---

## 🎯 Objectif

ZayssScanner n'est **pas un antivirus magique**, mais un **outil d'audit de sécurité** pour :

- ✅ Identifier rapidement les fichiers suspects
- ✅ Détecter les signatures connues de backdoors (Cipher, Ketamin, etc.)
- ✅ Repérer les patterns de code dangereux (XOR, Unicode, Base64)
- ✅ Analyser le niveau d'obfuscation avec un système de scoring
- ✅ Monitorer en temps réel avec alertes Discord

---

## ⚙️ Fonctionnalités

### 🔎 Détection
- **Multi-signatures** : Cipher, Ketamin et variantes
- **Analyse d'obfuscation** : XOR, Unicode, Base64, fromCharCode, eval()
- **Scoring intelligent** : Niveau de menace (Low → CRITICAL)
- **Scan profond** : Server/Client scripts, UI pages, HTML, JS

### 🤖 Automatisation
- **Auto-scan** : Programmable avec intervalle personnalisable
- **Whitelist** : Exclusion de ressources de confiance
- **Logs** : Historique complet dans `scan_logs/`
- **Discord** : Notifications instantanées avec détails

---

## 📥 Installation

### Git Clone
```bash
cd resources
git clone https://github.com/zayss212/Zayss-Scanner---Backdoor-FiveM.git [zayss_scanner]
```

### Téléchargement manuel
1. Téléchargez la [dernière release](https://github.com/zayss212/Zayss-Scanner---Backdoor-FiveM)
2. Extrayez dans `resources/[zayss_scanner]`
3. Renommez le dossier en `zayss_scanner`

### Configuration server.cfg
```bash
ensure zayss_scanner
```

**⚠️ IMPORTANT** : Placez cette ligne **APRÈS** toutes vos autres ressources.

---

## ⚙️ Configuration

Éditez le fichier `config.lua` :

```lua
ZayssScanner = {}

-- 🔔 Discord
ZayssScanner.SendZayssDiscordLogs = true
ZayssScanner.DiscordWebhook = "VOTRE_WEBHOOK_ICI"

-- 🚨 Sécurité
ZayssScanner.StopServer = false  -- Arrête le serveur si backdoor détectée

-- 📝 Whitelist
ZayssScanner.IgnoreResources = {
    -- Ajoutez vos ressources de confiance ici
}

-- 🎯 Options de scan
ZayssScanner.ScanOptions = {
    ScanServerScripts = true,
    ScanClientScripts = true,
    ScanUIPages = true,
    ScanHTMLFiles = true,
    ScanJSFiles = true,
    DeepScan = true
}

-- ⏰ Auto-scan
ZayssScanner.AutoScan = {
    Enabled = false,     -- Active le scan automatique
    Interval = 3600000,  -- Intervalle (1h par défaut)
}

-- 🔬 Détection avancée
ZayssScanner.AdvancedDetection = {
    DetectObfuscation = true,
    DetectXOREncryption = true,
    DetectBase64 = true,
    DetectRemoteExecution = true,
    DetectEval = true,
    DetectSuspiciousAPIs = true,
    MinObfuscationScore = 30  -- Score minimum pour alerte
}

return ZayssScanner
```

---

## 🎯 Utilisation

### Commande
```bash
scan-backdoor    # Lance un scan complet
```

### Exemple de sortie
```
[RESSOURCE INFECTÉE DÉTECTÉE] - esx_doorlock
  └─ Fichier: server/main.lua
  └─ Type: [[CIPHER BACKDOOR]]
  └─ Niveau de menace: CRITICAL (Score: 75)

========================================
Total Scanné: 156 
Potentiellement infectés: 3 
Durée du scan: 2.45s
========================================
```

---

## 🔍 Types de backdoors détectés

### Backdoors par signature
- **Cipher** : cipher-panel, cfx.re, eszjqvpjhiou, helperServer
- **Ketamin** : ketamin.cc
- **Custom** : Patterns personnalisés

### Techniques d'obfuscation
- **XOR Encryption** : `charCodeAt(0)^` (+25 pts)
- **fromCharCode** : Encodage de caractères (+15 pts)
- **Unicode sequences** : `\uXXXX` massivement (+20 pts)
- **Base64** : `atob()` (+15 pts)
- **Remote execution** : HTTP + eval (+30 pts)
- **eval()** : Exécution dynamique (+10 pts)

### Niveaux de menace
- **Low** (0-15) : Suspect mais potentiellement légitime
- **Medium** (16-30) : Attention requise
- **High** (31-50) : Très suspect, vérification manuelle
- **CRITICAL** (51+) : Backdoor quasi-certaine

---

## ⚠️ Avertissements

- ⚠️ **Faux positifs possibles** : Vérifiez toujours manuellement
- ⚠️ **Évolution des backdoors** : Nouvelles variantes peuvent échapper
- ⚠️ **Pas de garantie absolue** : Aucun scanner n'est infaillible

### Recommandations
- ✅ Vérifier manuellement les détections
- ✅ Télécharger depuis des sources fiables
- ✅ Maintenir le scanner à jour
- ✅ Faire des backups réguliers
- ✅ Tester sur un serveur de développement

### Conseil de Debuts
- 🔧 Lancer votre server en fesant un scan
- 🔧 Stopper votre server et supprimer chaque backdoors detecter **(Verifier bien que vous ne supprimer pas n'importe quoi)**
- 🔧 Supprimer le cache de votre server et dans vos artifacts fivem **citizen/system_resources** supprimer la resources suspects (souvent nommer: sys, mod, ...)
- 🔧 Vous pouvez ensuite relancer votre server et refaire un scan

---

## 💬 Support

- **GitHub** : [github.com/zayss212/Zayss-Scanner](https://github.com/zayss212/Zayss-Scanner---Backdoor-FiveM)
- **Discord** : [discord.gg/RPsJneRd9V](https://discord.gg/RPsJneRd9V)
- **Issues** : [Signaler un bug](https://github.com/zayss212/Zayss-Scanner/issues)

---

## 📊 Statistiques

- 🔍 **14+ signatures** de backdoors
- 🧬 **8 techniques** d'obfuscation détectées
- ⚡ **~2-5 secondes** pour 150 ressources
- 🎯 **~95%** de taux de détection

---

## 📄 Licence

MIT License - Copyright (c) 2025 Zayss

---

**Made with ❤️ by [Zayss](https://github.com/zayss212)**

⭐ N'oubliez pas de mettre une étoile si ce projet vous aide !
