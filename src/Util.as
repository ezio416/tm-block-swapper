// c 2024-03-19
// m 2024-03-19

void AwaitEditor() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CGameCtnEditorFree@ Editor;

    while ((@Editor = cast<CGameCtnEditorFree@>(App.Editor)) is null)
        yield();

    while (!Editor.PluginMapType.IsEditorReadyForRequest)
        yield();
}

void AwaitReturnToMenu() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    while (
        App.Switcher.ModuleStack.Length == 0
        || cast<CTrackManiaMenus@>(App.Switcher.ModuleStack[0]) is null
    )
        yield();

    while (!App.ManiaTitleControlScriptAPI.IsReady)
        yield();
}

const string IntToHex(const int i) {
    return "0x" + Text::Format("%X", i);
}

const int3 Nat3ToInt3(const nat3 coord) {
    return int3(coord.x, coord.y, coord.z);
}