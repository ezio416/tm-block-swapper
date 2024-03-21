// c 2024-03-19
// m 2024-03-20

dictionary@ cpLut         = dictionary();
dictionary@ finLut        = dictionary();
bool        replacing     = false;
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

    finLut["RoadTechFinish"       ] = "RoadTechStraight"   ;
    finLut["RoadDirtFinish"       ] = "RoadDirtStraight"   ;
    finLut["RoadBumpFinish"       ] = "RoadBumpStraight"   ;
    finLut["RoadIceFinish"        ] = "RoadIceStraight"    ;
    finLut["RoadWaterFinish"      ] = "RoadWaterStraight"  ;
    finLut["PlatformWaterFinish"  ] = "PlatformWaterBase"  ;
    finLut["PlatformTechFinish"   ] = "PlatformTechBase"   ;
    finLut["PlatformDirtFinish"   ] = "PlatformDirtBase"   ;
    finLut["PlatformIceFinish"    ] = "PlatformIceBase"    ;
    finLut["PlatformGrassFinish"  ] = "PlatformGrassBase"  ;
    finLut["PlatformPlasticFinish"] = "PlatformPlasticBase";
}

void ReplaceCpBlocks() {
    if (replacing)
        return;

    replacing = true;

    const uint64 start = Time::Now;
    trace("replacing CP blocks");

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CGameCtnEditorFree@ Editor = cast<CGameCtnEditorFree@>(App.Editor);
    if (Editor is null) {
        warn("can't replace CP blocks - Editor is null");
        replacing = false;
        return;
    }

    CGameCtnChallenge@ Map = Editor.Challenge;
    if (Map is null) {
        warn("can't replace CP blocks - Map is null");
        replacing = false;
        return;
    }

    CSmEditorPluginMapType@ PMT = cast<CSmEditorPluginMapType@>(Editor.PluginMapType);
    if (PMT is null) {
        warn("can't replace CP blocks - PMT is null");
        removing = false;
        return;
    }

    uint total = 0;

    LoadMapBlocks();

    for (uint i = 0; i < mapBlocksCp.Length; i++) {
        YieldIfNeeded();

        trace("replacing CP block (" + (i + 1) + " / " + mapBlocksCp.Length + ")");

        Block@ block = mapBlocksCp[i];

        const bool airBlockModePre = AirBlockModeActive(Editor);
        const CGameEditorPluginMap::EMapElemColor colorPre = PMT.NextMapElemColor;

        if (ReplaceBlock(block, Editor, PMT, cpLut, airBlockModePre))
            total++;

        if (airBlockModePre != AirBlockModeActive(Editor))
            Editor.ButtonAirBlockModeOnClick();

        PMT.NextMapElemColor = colorPre;

        if (stopReplacing) {
            stopReplacing = false;
            break;
        }
    }

    const uint64 dif = Time::Now - start;
    trace("replaced " + total + " CP block" + (total == 1 ? "" : "s") + " after " + dif + "ms (" + Time::Format(dif) + ")");

    if (total > 0)
        PMT.AutoSave();  // usually doesn't save but at least fixes undo

    replacing = false;
}

bool ReplaceBlock(Block@ block, CGameCtnEditorFree@ Editor, CSmEditorPluginMapType@ PMT, dictionary@ lut, bool airBlockModePre) {
    if (block is null || PMT is null || lut is null)
        return false;

    const string name = block.name;

    CGameCtnBlockInfo@ replacement = PMT.GetBlockModelFromName(string(lut[name]));
    if (replacement is null) {
        warn("replacement not found for " + name);
        return false;
    }

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

    const bool fullPillar = pillars > 0 && pillars == block.coord.y - 9;

    if ((!fullPillar && !airBlockModePre) || (fullPillar && airBlockModePre))
        Editor.ButtonAirBlockModeOnClick();

    PMT.NextMapElemColor = CGameEditorPluginMap::EMapElemColor(block.color);

    const CGameEditorPluginMap::ECardinalDirections dir = CGameEditorPluginMap::ECardinalDirections(block.direction);

    if (block.block is null || block.block.BlockModel is null) {
        warn("can't replace block - something is null");
        return false;
    }

    if (block.ghost) {
        if (!PMT.RemoveGhostBlock(block.block.BlockModel, block.coord, dir)) {
            warn("failed to remove ghost block at " + tostring(block.coord));
            return false;
        }

        if (!PMT.PlaceGhostBlock(replacement, block.coord, dir)) {
            warn("failed to place replacement ghost block at " + tostring(block.coord));
            return false;
        }
    } else {
        if (!PMT.RemoveBlockSafe(block.block.BlockModel, block.coord, dir)) {
            warn("failed to remove block at " + tostring(block.coord));
            return false;
        }

        if (!PMT.PlaceBlock(replacement, block.coord, dir)) {
            warn("failed to place replacement block at " + tostring(block.coord));
            return false;
        }

        if (fullPillar) {
            CGameCtnBlockInfo@ pillarReplacement = PMT.GetBlockModelFromName(nonPillarName);

            if (pillarReplacement !is null) {
                const int3 pillarCoord = block.coord - int3(0, 1, 0);

                if (!PMT.PlaceBlock(pillarReplacement, pillarCoord, dir)) {
                    warn("failed to place pillar replacement block at " + tostring(pillarCoord));
                    return false;
                }
            } else
                warn("pillar replacement block not found: " + nonPillarName);

        } else if (pillars > 0) {
            CGameCtnBlockInfo@ pillarReplacement = PMT.GetBlockModelFromName(nonPillarName);

            if (pillarReplacement !is null) {
                for (int j = block.coord.y - 1; j >= block.coord.y - pillars; j--) {
                    // YieldIfNeeded();  // yielding here helps with framerate slightly but greatly increases total time

                    const int3 pillarCoord = int3(block.coord.x, j, block.coord.z);

                    if (!PMT.PlaceBlock(pillarReplacement, pillarCoord, dir)) {
                        warn("failed to place pillar replacement block at " + tostring(pillarCoord));
                        return false;
                    }
                }
            } else {
                warn("pillar replacement block not found: " + nonPillarName);
                return false;
            }
        }
    }

    return true;
}