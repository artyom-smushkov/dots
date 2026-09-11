import QtQuick
import Quickshell.Networking

Item {
    id: utils

    readonly property var wifiIcons: ["\u{F092F}", "\u{F091F}", "\u{F0922}", "\u{F0925}", "\u{F0928}"]

    function signalIcon(pct) {
        const idx = Math.max(0, Math.min(4, Math.floor(pct / 20)))
        return wifiIcons[idx]
    }

    function findConnected(type) {
        for (const d of Networking.devices.values) {
            if (d && d.type === type && d.connected) return d
        }
        return null
    }

    function findDevice(type) {
        let fallback = null
        for (const d of Networking.devices.values) {
            if (!d || d.type !== type) continue
            if (d.connected) return d
            if (!fallback) fallback = d
        }
        return fallback
    }

    function parseNetDev(text) {
        const out = {}
        for (const line of text.split("\n")) {
            const idx = line.indexOf(":")
            if (idx < 0) continue
            const name = line.slice(0, idx).trim()
            const parts = line.slice(idx + 1).trim().split(/\s+/)
            if (parts.length < 9) continue
            out[name] = Number(parts[0])
        }
        return out
    }

    function parseKeyValue(text) {
        const out = {}
        for (const line of String(text).split("\n")) {
            const idx = line.indexOf("\t")
            if (idx < 0) continue
            out[line.slice(0, idx)] = line.slice(idx + 1).trim()
        }
        return out
    }

    function formatBytes(bytes) {
        let n = Number(bytes)
        if (!isFinite(n) || n < 0) n = 0
        if (n < 1024) return Math.round(n) + " B"
        if (n < 1024 * 1024) return (n / 1024).toFixed(1) + " KB"
        if (n < 1024 * 1024 * 1024) return (n / 1024 / 1024).toFixed(1) + " MB"
        return (n / 1024 / 1024 / 1024).toFixed(2) + " GB"
    }

    function formatRate(bps) { return formatBytes(bps) + "/s" }

    function formatPing(v) {
        const n = parseFloat(v)
        if (!isFinite(n) || n < 0) return "--"
        return n.toFixed(n < 10 ? 1 : 0) + " ms"
    }
}
