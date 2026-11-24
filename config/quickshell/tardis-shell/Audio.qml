import QtQuick
import Quickshell.Services.Pipewire

QtObject {
    id: audio

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var channel: sink ? sink.audio : null
    readonly property bool available: Pipewire.ready && channel !== null
    readonly property real volume: available ? channel.volume : 0
    readonly property bool muted: available ? channel.muted : false
    readonly property string name: available
        ? (sink.description || sink.nickname || sink.name || "Audio output")
        : "No audio output"

    property PwObjectTracker tracker: PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    function setVolume(value: real): void {
        if (!available) return
        channel.volume = Math.max(0, Math.min(1, value))
    }

    function toggleMute(): void {
        if (!available) return
        channel.muted = !channel.muted
    }
}
