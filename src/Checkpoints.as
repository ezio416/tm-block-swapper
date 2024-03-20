// c 2024-03-19
// m 2024-03-20

dictionary@ cpLut         = dictionary();
dictionary@ finLut        = dictionary();
bool        replacingCps  = false;
bool        stopReplacing = false;

void InitLUTs() {
    cpLut["RoadTechCheckpoint"               ] = "RoadTechStraight"             ;
    cpLut["RoadTechCheckpointSlopeUp"        ] = "RoadTechSlopeStraight"        ;
    cpLut["RoadTechCheckpointTiltRight"      ] = "RoadTechTiltStraight"         ;
    cpLut["RoadDirtCheckpoint"               ] = "RoadDirtStraight"             ;
    cpLut["RoadDirtCheckpointSlopeUp"        ] = "RoadDirtSlopeStraight"        ;
    cpLut["RoadDirtCheckpointTiltRight"      ] = "RoadDirtTiltStraight"         ;
    cpLut["RoadBumpCheckpoint"               ] = "RoadBumpStraight"             ;
    cpLut["RoadBumpCheckpointSlopeUp"        ] = "RoadBumpSlopeStraight"        ;
    cpLut["RoadBumpCheckpointTiltRight"      ] = "RoadBumpTiltStraight"         ;
    cpLut["RoadIceCheckpoint"                ] = "RoadIceStraight"              ;
    cpLut["RoadIceCheckpointSlopeUp"         ] = "RoadIceSlopeStraight"         ;
    cpLut["RoadIceWithWallCheckpointLeft"    ] = "RoadIceWithWallStraight"      ;
    cpLut["RoadWaterCheckpoint"              ] = "RoadWaterStraight"            ;
    cpLut["PlatformWaterCheckpoint"          ] = "PlatformWaterBase"            ;
    cpLut["PlatformTechCheckpoint"           ] = "PlatformTechBase"             ;
    cpLut["PlatformTechCheckpointSlope2Up"   ] = "PlatformTechSlope2Straight"   ;
    cpLut["PlatformDirtCheckpoint"           ] = "PlatformDirtBase"             ;
    cpLut["PlatformDirtCheckpointSlope2Up"   ] = "PlatformDirtSlope2Straight"   ;
    cpLut["PlatformIceCheckpoint"            ] = "PlatformIceBase"              ;
    cpLut["PlatformIceCheckpointSlope2Up"    ] = "PlatformIceSlope2Straight"    ;
    cpLut["PlatformGrassCheckpoint"          ] = "PlatformGrassBase"            ;
    cpLut["PlatformGrassCheckpointSlope2Up"  ] = "PlatformGrassSlope2Straight"  ;
    cpLut["PlatformPlasticCheckpoint"        ] = "PlatformPlasticBase"          ;
    cpLut["PlatformPlasticCheckpointSlope2Up"] = "PlatformPlasticSlope2Straight";
    cpLut["OpenTechRoadCheckpoint"           ] = "OpenTechRoadStraight"         ;
    cpLut["OpenTechRoadCheckpointSlope2Up"   ] = "OpenTechRoadSlope2Straight"   ;
    cpLut["OpenDirtRoadCheckpoint"           ] = "OpenDirtRoadStraight"         ;
    cpLut["OpenDirtRoadCheckpointSlope2Up"   ] = "OpenDirtRoadSlope2Straight"   ;
    cpLut["OpenIceRoadCheckpoint"            ] = "OpenIceRoadStraight"          ;
    cpLut["OpenIceRoadCheckpointSlope2Up"    ] = "OpenIceRoadSlope2Straight"    ;
    cpLut["OpenGrassRoadCheckpoint"          ] = "OpenGrassRoadStraight"        ;
    cpLut["OpenGrassRoadCheckpointSlope2Up"  ] = "OpenGrassRoadSlope2Straight"  ;

    finLut[""] = "";
}

void ReplaceCPs() {
    if (replacingCps)
        return;

    replacingCps = true;

    const uint64 start = Time::Now;
    trace("removing/replacing CP blocks");

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CGameCtnEditorFree@ Editor = cast<CGameCtnEditorFree>(App.Editor);
    if (Editor is null) {
        replacingCps = false;
        return;
    }

    CGameCtnChallenge@ Map = Editor.Challenge;
    if (Map is null) {
        replacingCps = false;
        return;
    }

    CSmEditorPluginMapType@ PMT = cast<CSmEditorPluginMapType@>(Editor.PluginMapType);
    if (PMT is null) {
        replacingCps = false;
        return;
    }

    uint total = 0;

    LoadMapBlocks();

    for (uint i = 0; i < mapBlocksCpRing.Length; i++) {
        YieldIfNeeded();

        trace("removing ring CP (" + (i + 1) + " / " + mapBlocksCpRing.Length + ")");

        Block@ block = mapBlocksCpRing[i];

        if (block.ghost)
            PMT.RemoveGhostBlock(block.block.BlockModel, block.coord, CGameEditorPluginMap::ECardinalDirections(block.direction));
        else
            PMT.RemoveBlockSafe(block.block.BlockModel, block.coord, CGameEditorPluginMap::ECardinalDirections(block.direction));

        total++;
    }

    for (uint i = 0; i < mapBlocksCp.Length; i++) {
        YieldIfNeeded();

        trace("replacing CP (" + (i + 1) + " / " + mapBlocksCp.Length + ")");

        Block@ block = mapBlocksCp[i];

        const string name = block.id.GetName();

        CGameCtnBlockInfo@ replacement = PMT.GetBlockModelFromName(string(cpLut[name]));
        if (replacement is null) {
            warn("replacement not found for " + name);
            continue;
        }

        const bool airBlockModePre = AirBlockModeActive(Editor);
        const CGameEditorPluginMap::EMapElemColor colorPre = PMT.NextMapElemColor;

        int pillars = 0;
        string nonPillarName;

        if (!block.ground) {
            CGameCtnBlock@ pillar;

            for (int j = block.coord.y - 1; j > 8; j--) {
                YieldIfNeeded();

                const int3 coordsCheck = int3(block.coord.x, j, block.coord.z);
                @pillar = PMT.GetBlock(coordsCheck);

                if (
                    pillar is null
                    || !pillar.DescId.GetName().EndsWith("Pillar")
                    || pillar.BlockDir != block.direction
                )
                    break;

                if (nonPillarName.Length == 0)
                    nonPillarName = pillar.DescId.GetName().Replace("Pillar", "");

                pillars++;
            }
        }

        const bool fullPillar = pillars == block.coord.y - 9;

        if ((!fullPillar && !airBlockModePre) || (fullPillar && airBlockModePre))
            Editor.ButtonAirBlockModeOnClick();

        PMT.NextMapElemColor = CGameEditorPluginMap::EMapElemColor(block.color);

        const CGameEditorPluginMap::ECardinalDirections dir = CGameEditorPluginMap::ECardinalDirections(block.direction);

        if (block.ghost) {
            PMT.RemoveGhostBlock(block.block.BlockModel, block.coord, dir);
            PMT.PlaceGhostBlock(replacement, block.coord, dir);
        } else {
            PMT.RemoveBlockSafe(block.block.BlockModel, block.coord, dir);
            PMT.PlaceBlock(replacement, block.coord, dir);

            if (fullPillar) {
                CGameCtnBlockInfo@ pillarReplacement = PMT.GetBlockModelFromName(nonPillarName);

                if (pillarReplacement !is null)
                    PMT.PlaceBlock(pillarReplacement, block.coord - int3(0, 1, 0), dir);
                else
                    warn("pillar replacement not found: " + nonPillarName);

            } else if (pillars > 0) {
                CGameCtnBlockInfo@ pillarReplacement = PMT.GetBlockModelFromName(nonPillarName);

                if (pillarReplacement !is null) {
                    for (int j = block.coord.y - 1; j >= block.coord.y - pillars; j--) {
                        // YieldIfNeeded();  // yielding here helps with framerate slightly but greatly increases total time
                        PMT.PlaceBlock(pillarReplacement, int3(block.coord.x, j, block.coord.z), dir);
                    }
                } else
                    warn("pillar replacement not found: " + nonPillarName);
            }
        }

        if (airBlockModePre != AirBlockModeActive(Editor))
            Editor.ButtonAirBlockModeOnClick();

        PMT.NextMapElemColor = colorPre;

        total++;

        if (stopReplacing) {
            stopReplacing = false;
            break;
        }
    }

    trace("removed/replaced " + total + " block" + (total == 1 ? "" : "s") + " after " + (Time::Now - start) + "ms (" + Time::Format(Time::Now - start) + ")");

    if (total > 0)
        PMT.AutoSave();  // usually doesn't save but at least fixes undo

    replacingCps = false;
}

// void RemoveCpItems() {
//     print("removing CP items");

//     CTrackMania@ App = cast<CTrackMania@>(GetApp());

//     CGameCtnEditorFree@ Editor = cast<CGameCtnEditorFree>(App.Editor);
//     if (Editor is null)
//         return;

//     CGameEditorPluginMapMapType@ PMT = Editor.PluginMapType;
//     if (PMT is null)
//         return;

//     uint total = 0;

//     LoadMapItems();

//     CGameCtnChallenge@ Map = Editor.Challenge;
//     if (Map is null)
//         return;

//     for (uint i = 0; i < mapItems.Length; i++) {
//         Item@ item = mapItems[i];

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