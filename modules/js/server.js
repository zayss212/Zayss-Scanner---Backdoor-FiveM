const fs = require("fs")
const path = require("path")

exports("readDir", function(dir) {
    if (GetInvokingResource() == GetCurrentResourceName()) {
        try { return fs.readdirSync(dir) } catch { return false }
    }
    return false
})

exports("isDir", function(p) {
    if (GetInvokingResource() == GetCurrentResourceName()) {
        try {
            const stats = fs.statSync(p);
            return stats.isDirectory()
        } catch { return false }
    }
    return false
})

exports("readFileContent", function(filePath) {
    if (GetInvokingResource() == GetCurrentResourceName()) {
        try { return fs.readFileSync(filePath, "utf8") } catch { return false }
    }
    return false
})

exports("fileExists", function(filePath) {
    if (GetInvokingResource() == GetCurrentResourceName()) {
        try { return fs.existsSync(filePath) } catch { return false }
    }
    return false
})

exports("getMonitorPath", function() {
    if (GetInvokingResource() == GetCurrentResourceName()) {
        try {
            const resourcePath = GetResourcePath("monitor")
            if (!resourcePath) return false
            const match = resourcePath.match(/^(.*?)[\\/]+monitor$/)
            return match ? match[1] : false
        } catch { return false }
    }
    return false
})

exports("scanDirectoryRecursive", function(dirPath, extensions) {
    if (GetInvokingResource() != GetCurrentResourceName()) return false
    const results = []
    const exts = extensions || [".js", ".lua", ".html"]
    function walk(dir) {
        let items
        try { items = fs.readdirSync(dir) } catch { return }
        for (const item of items) {
            const fullPath = path.join(dir, item)
            let stat
            try { stat = fs.statSync(fullPath) } catch { continue }
            if (stat.isDirectory()) {
                walk(fullPath)
            } else {
                for (const ext of exts) {
                    if (item.endsWith(ext)) {
                        results.push(fullPath)
                        break
                    }
                }
            }
        }
    }
    try { walk(dirPath) } catch {}
    return results
})
