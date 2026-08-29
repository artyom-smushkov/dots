import QtQuick
import Quickshell.Services.Mpris

ModuleBox {
    id: root
    color: "#f9e2af"
    leftMargin16: true
    clickable: true
    wheelable: true

    property var lastActive: null

    readonly property var activePlayer: selectActive(Mpris.players.values, lastActive)

    readonly property string playerIcon: iconFor(activePlayer)
    readonly property string dynamic: dynamicFor(activePlayer)
    readonly property string label: playerIcon + " " + dynamic

    visible: activePlayer !== null && activePlayer.playbackState !== MprisPlaybackState.Stopped

    function selectActive(players, lastActive) {
        for (const p of players) {
            if (p.isPlaying) return p
        }
        if (lastActive !== null && players.includes(lastActive)) return lastActive
        return players.length > 0 ? players[0] : null
    }

    function iconFor(player) {
        if (player === null) return ""
        const id = String(player.identity).toLowerCase()
        const de = String(player.desktopEntry).toLowerCase()
        if (id.includes("spotify") || de.includes("spotify")) return "\u{F04C7} "
        if (id.includes("firefox") || de.includes("firefox")) return "\u{F0239} "
        return ""
    }

    function dynamicFor(player) {
        if (player === null) return ""
        const artist = String(player.trackArtist)
        const title = String(player.trackTitle)
        const sepW = 3
        const dynamicLen = 50 + sepW
        const aW = displayWidth(artist)
        const tW = displayWidth(title)
        const showTitle = tW > 0 && tW <= dynamicLen
        const total = showTitle ? tW : 0
        const showArtist = aW > 0 && total + aW + sepW <= dynamicLen
        const parts = []
        if (showArtist) parts.push(artist)
        if (showTitle) parts.push(title)
        return parts.join(" - ")
    }

    function isZeroWidth(cp) {
        return cp === 0xAD || (cp >= 0x200B && cp <= 0x200F) || (cp >= 0x202A && cp <= 0x202E)
            || cp === 0x2060 || (cp >= 0x2061 && cp <= 0x2064) || cp === 0xFEFF
            || (cp >= 0x0300 && cp <= 0x036F) || (cp >= 0x0483 && cp <= 0x0489)
            || (cp >= 0x0591 && cp <= 0x05BD) || cp === 0x05BF || (cp >= 0x05C1 && cp <= 0x05C2)
            || (cp >= 0x05C4 && cp <= 0x05C5) || cp === 0x05C7 || (cp >= 0x05D4 && cp <= 0x05EA)
            || (cp >= 0x064B && cp <= 0x065F) || cp === 0x0670 || (cp >= 0x06D6 && cp <= 0x06DC)
            || (cp >= 0x0900 && cp <= 0x0903) || (cp >= 0x093A && cp <= 0x094F)
            || (cp >= 0x0951 && cp <= 0x0957) || (cp >= 0x0962 && cp <= 0x0963)
            || (cp >= 0x1AB0 && cp <= 0x1AFF) || (cp >= 0x1DC0 && cp <= 0x1DFF)
            || (cp >= 0x20D0 && cp <= 0x20FF) || (cp >= 0xFE20 && cp <= 0xFE2F)
    }

    function isWide(cp) {
        return (cp >= 0x1100 && cp <= 0x115F) || (cp >= 0x2E80 && cp <= 0x303E)
            || (cp >= 0x3041 && cp <= 0x9FFF) || (cp >= 0xA000 && cp <= 0xA4CF)
            || (cp >= 0xA960 && cp <= 0xA97F) || (cp >= 0xAC00 && cp <= 0xD7A3)
            || (cp >= 0xF900 && cp <= 0xFAFF) || (cp >= 0xFE10 && cp <= 0xFE19)
            || (cp >= 0xFE30 && cp <= 0xFE6F) || (cp >= 0xFF00 && cp <= 0xFF60)
            || (cp >= 0xFFE0 && cp <= 0xFFE6) || (cp >= 0x1F300 && cp <= 0x1FAFF)
            || (cp >= 0x20000 && cp <= 0x3FFFD)
    }

    function displayWidth(s) {
        let w = 0
        for (const ch of s) {
            const cp = ch.codePointAt(0)
            if (isZeroWidth(cp)) continue
            w += isWide(cp) ? 2 : 1
        }
        return w
    }

    Item {
        Repeater {
            model: Mpris.players
            delegate: Item {
                property var player: modelData
                Connections {
                    target: player
                    function onIsPlayingChanged() {
                        if (player.isPlaying) root.lastActive = player
                    }
                }
            }
        }
    }

    onClicked: { if (activePlayer !== null) activePlayer.togglePlaying() }
    onWheelUp: { if (activePlayer !== null) activePlayer.next() }
    onWheelDown: { if (activePlayer !== null) activePlayer.previous() }

    BarText {
        color: root.color
        text: root.label
    }
}
