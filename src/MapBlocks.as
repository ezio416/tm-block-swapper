// c 2024-03-19
// m 2024-03-19

bool        loadingMapBlocks = false;
dictionary@ mapBlocks        = dictionary();

void LoadMapBlocks() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CGameCtnEditorFree@ Editor = cast<CGameCtnEditorFree>(App.Editor);
    if (Editor is null)
        return;

    CGameCtnChallenge@ Map = Editor.Challenge;
    if (Map is null)
        return;

    ;
}