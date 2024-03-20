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

const string FormatPointer(uint64 ptr) {
    return "0x" + Text::Format("%llX", ptr);
}

const int3 Nat3ToInt3(const nat3 coord) {
    return int3(coord.x, coord.y, coord.z);
}

bool Nat3EqNat3(const nat3 one, const nat3 two) {
    return one.x == two.x
        && one.y == two.y
        && one.z == two.z;
}