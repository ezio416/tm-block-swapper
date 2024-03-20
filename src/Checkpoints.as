// c 2024-03-19
// m 2024-03-19

const dictionary@ cpLut = {
    { "RoadTechCheckpoint", "RoadTechStraight" }
};

void ReplaceCPs() {
    trace("replacing CPs");

    if (catalogObjects.GetSize() == 0)
        LoadCatalogObjects();

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CGameCtnEditorFree@ Editor = cast<CGameCtnEditorFree>(App.Editor);
    if (Editor is null)
        return;

    CGameCtnChallenge@ Map = Editor.Challenge;
    if (Map is null)
        return;

    CGameEditorPluginMapMapType@ PMT = Editor.PluginMapType;
    if (PMT is null)
        return;

    uint total = 0;

    for (int i = Map.Blocks.Length - 1; i >= 0; i--) {
        CGameCtnBlock@ block = Map.Blocks[i];

        if (block.DescId.Value == stadiumGrassId)
            continue;

        if (cpLut.Exists(block.DescId.GetName())) {
            CGameCtnArticle@ article = GetCatalogObject(cpLut[block.DescId.GetName()]);

            if (article !is null) {
                CGameCtnBlockInfo@ replacement = cast<CGameCtnBlockInfo@>(article.LoadedNod);

                if (replacement !is null) {
                    const bool airBlockMode = AirBlockModeActive(Editor);

                    bool airBlock = true;

                    if (!block.IsGround) {
                        const nat3 coordTosearch = block.Coord - nat3(0, 1, 0);

                        for (uint j = 0; j < Map.Blocks.Length; j++) {
                            if (!Nat3EqNat3(Map.Blocks[j].Coord, coordTosearch))
                                continue;

                            if (Map.Blocks[j].DescId.GetName().EndsWith("Pillar") && Map.Blocks[j].BlockDir == block.BlockDir) {
                                airBlock = false;
                                break;
                            }
                        }
                    }

                    if ((airBlock && !airBlockMode) || (!airBlock && airBlockMode))
                            Editor.ButtonAirBlockModeOnClick();

                    if (block.IsGhostBlock()) {
                        PMT.RemoveGhostBlock(block.BlockModel, Nat3ToInt3(block.Coord), CGameEditorPluginMap::ECardinalDirections(block.BlockDir));
                        PMT.PlaceGhostBlock(replacement, Nat3ToInt3(block.Coord), CGameEditorPluginMap::ECardinalDirections(block.BlockDir));
                    } else {
                        PMT.RemoveBlockSafe(block.BlockModel, Nat3ToInt3(block.Coord), CGameEditorPluginMap::ECardinalDirections(block.BlockDir));
                        PMT.PlaceBlock(replacement, Nat3ToInt3(block.Coord), CGameEditorPluginMap::ECardinalDirections(block.BlockDir));
                    }

                    if (airBlockMode != AirBlockModeActive(Editor))
                        Editor.ButtonAirBlockModeOnClick();

                    total++;
                }
            }
        }
    }

    trace("replaced " + total + " blocks");
}

// void RemoveCps() {
//     print("removing CPs");

//     CTrackMania@ App = cast<CTrackMania@>(GetApp());

//     CGameCtnEditorFree@ Editor = cast<CGameCtnEditorFree>(App.Editor);
//     if (Editor is null)
//         return;

//     CGameEditorPluginMapMapType@ PMT = Editor.PluginMapType;
//     if (PMT is null)
//         return;

//     uint total = 0;

//     // CGameCtnChallenge@ Map = App.RootMap;
//     CGameCtnChallenge@ Map = Editor.Challenge;
//     if (Map is null)
//         return;

//     for (uint i = 0; i < blocks.Length; i++) {
//         Block@ block = blocks[i];

//         if (block.block is null)
//             continue;

//         if (block.id.Value == 0x4000488C) {  // ring CP
//             PMT.RemoveBlockSafe(block.block.BlockModel, int3(block.location.x, block.location.y, block.location.z), CGameEditorPluginMap::ECardinalDirections(block.direction));
//             total++;
//         }
//     }

//     print("removed " + total + " blocks");

//     CGameCtnAnchoredObject@[] itemsToKeep;

//     for (int i = Map.AnchoredObjects.Length - 1; i >= 0; i--) {
//         CGameCtnAnchoredObject@ item = Map.AnchoredObjects[i];

//         if (item.ItemModel.WaypointType != CGameItemModel::EnumWaypointType::Checkpoint)
//             itemsToKeep.InsertLast(item);
//     }

//     CMwNod@ bufPtr = Dev::GetOffsetNod(Map, GetMemberOffset(Map, "AnchoredObjects"));

//     for (uint i = 0; i < itemsToKeep.Length; i++)
//         Dev::SetOffset(bufPtr, 0x8 * i, itemsToKeep[i]);

//     Dev::SetOffset(Map, GetMemberOffset(Map, "AnchoredObjects") + 0x8, itemsToKeep.Length);
//     SaveAndReloadMap();
// }

// void SaveAndReloadMap() {
//     print('save and reload map');

//     CTrackMania@ App = cast<CTrackMania@>(GetApp());
//     CGameCtnEditorFree@ Editor = cast<CGameCtnEditorFree>(App.Editor);

//     if (!SaveMapSameName(Editor)) {
//         warn("Map must be saved, first. Please save and reload manually!");
//         return;
//     }

//     string fileName = Editor.Challenge.MapInfo.FileName;
//     while (!Editor.PluginMapType.IsEditorReadyForRequest)
//         yield();

//     App.BackToMainMenu();
//     print('back to menu');
//     AwaitReturnToMenu();
//     App.ManiaTitleControlScriptAPI.EditMap(fileName, "", "");
//     AwaitEditor();
//     startnew(_RestoreMapName);
// }

// bool SaveMapSameName(CGameCtnEditorFree@ Editor) {
//     string fileName = Editor.Challenge.MapInfo.FileName;
//     _restoreMapName = Editor.Challenge.MapName;
//     if (fileName.Length == 0) {
//         warn("Map must be saved, first.");
//         return false;
//     }
//     Editor.PluginMapType.SaveMap(fileName);
//     startnew(_RestoreMapName);
//     print('saved map');
//     return true;
// }

// string _restoreMapName;
// // set after calling SaveMapSameName
// void _RestoreMapName() {
//     yield();

//     if (_restoreMapName.Length == 0)
//         return;

//     CTrackMania@ App = cast<CTrackMania@>(GetApp());

//     CGameCtnEditorFree@ Editor = cast<CGameCtnEditorFree>(App.Editor);
//     Editor.Challenge.MapName = _restoreMapName;
//     print('restored map name: ' + _restoreMapName);
// }