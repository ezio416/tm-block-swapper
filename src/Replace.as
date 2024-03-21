// c 2024-03-19
// m 2024-03-21

Json::Value@ LUT;
bool         replacing     = false;
bool         stopReplacing = false;

void InitLUT() {
    @LUT = Json::FromFile("src/LUT.json");

    if (
        LUT.GetType() != Json::Type::Object
        || !LUT.HasKey("checkpoint")
        || !LUT.HasKey("finish")
        || !LUT.HasKey("multilap")
        || !LUT.HasKey("start")
    ) {
        error("LUT.json is invalid or missing!");
        @LUT = null;
    }
}

void ReplaceCheckpointBlocks() {
    ReplaceBlocks(mapBlocksCp, "checkpoint");
}

void ReplaceFinishBlocks() {
    ReplaceBlocks(mapBlocksFin, "finish");
}

void ReplaceMultilapBlocks() {
    ReplaceBlocks(mapBlocksMultilap, "multilap");
}

void ReplaceStartBlocks() {
    ReplaceBlocks(mapBlocksStart, "start");
}

void ReplaceBlocks(Block@[]@ blocks, const string &in type) {
    if (replacing)
        return;

    replacing = true;

    const uint64 start = Time::Now;
    trace("replacing " + type + " blocks");

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CGameCtnEditorFree@ Editor = cast<CGameCtnEditorFree@>(App.Editor);
    if (Editor is null) {
        warn("can't replace " + type + " blocks - Editor is null");
        replacing = false;
        return;
    }

    CSmEditorPluginMapType@ PMT = cast<CSmEditorPluginMapType@>(Editor.PluginMapType);
    if (PMT is null) {
        warn("can't replace " + type + " blocks - PMT is null");
        replacing = false;
        return;
    }

    uint total = 0;

    LoadMapBlocks();

    for (uint i = 0; i < blocks.Length; i++) {
        YieldIfNeeded();

        trace("replacing " + type + " block (" + (i + 1) + " / " + blocks.Length + ")");

        Block@ block = blocks[i];

        const bool airBlockModePre = AirBlockModeActive(Editor);
        const CGameEditorPluginMap::EMapElemColor colorPre = PMT.NextMapElemColor;

        if (ReplaceBlock(block, Editor, PMT, LUT[type], airBlockModePre))
            total++;

        if (AirBlockModeActive(Editor) != airBlockModePre)
            Editor.ButtonAirBlockModeOnClick();

        PMT.NextMapElemColor = colorPre;

        if (stopReplacing) {
            stopReplacing = false;
            break;
        }
    }

    const uint64 dif = Time::Now - start;
    trace("replaced " + total + " " + type + " block" + (total == 1 ? "" : "s") + " after " + dif + "ms (" + Time::Format(dif) + ")");

    if (total > 0)
        PMT.AutoSave();  // usually doesn't save but at least fixes undo

    replacing = false;
}

bool ReplaceBlock(Block@ block, CGameCtnEditorFree@ Editor, CSmEditorPluginMapType@ PMT, Json::Value@ lut, bool airBlockModePre) {
    if (block is null || PMT is null || lut is null || lut.GetType() == Json::Type::Null)
        return false;

    const string name = block.name;

    CGameCtnBlockInfo@ replacement = PMT.GetBlockModelFromName(string(lut[name]["replace"]));
    const int rotate = lut[name]["rotate"];

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

            if (pillar is null) {
                // warn("null pillar at " + tostring(coordsCheck));  // don't need to warn here, just means pillar is not full
                break;
            }

            const string pillarName = pillar.DescId.GetName();

            if (!pillarName.EndsWith("Pillar")) {
                if (pillarName != "Grass")  // special case for Platform____WallCheckpoint____
                    warn("block at " + tostring(coordsCheck) + " (" + pillarName + ") is not a pillar");

                break;
            }

            if (
                int(pillar.BlockDir) % 2 != int(block.direction) % 2
                && pillarName != "DecoWallBasePillar"  // special case for Platform____CheckpointSlope2Down blocks - these place pillars 90° to the block
            ) {
                warn("pillar facing wrong way: is " + tostring(pillar.BlockDir) + " instead of " + tostring(block.direction));
                break;
            }

            if (nonPillarName.Length == 0)
                nonPillarName = pillarName.Replace("Pillar", "");

            pillars++;
        }
    }

    const bool fullPillar = pillars > 0 && pillars == block.coord.y - 9;

    if (!airBlockModePre)
        Editor.ButtonAirBlockModeOnClick();

    PMT.NextMapElemColor = CGameEditorPluginMap::EMapElemColor(block.color);

    const CGameEditorPluginMap::ECardinalDirections dirOld = CGameEditorPluginMap::ECardinalDirections(block.direction);
    const CGameEditorPluginMap::ECardinalDirections dirNew = CGameEditorPluginMap::ECardinalDirections((int(block.direction) + rotate) % 4);

    if (block.block is null || block.block.BlockModel is null) {
        warn("can't replace block - something is null");
        return false;
    }

    if (block.ghost) {
        if (!PMT.RemoveGhostBlock(block.block.BlockModel, block.coord, dirOld)) {
            warn("failed to remove ghost block facing " + tostring(dirOld) + " at " + tostring(block.coord));
            return false;
        }

        if (!PMT.PlaceGhostBlock(replacement, block.coord, dirNew)) {
            warn("failed to place replacement ghost block facing " + tostring(dirNew) + " at " + tostring(block.coord));
            return false;
        }
    } else {
        if (!PMT.RemoveBlockSafe(block.block.BlockModel, block.coord, dirOld)) {
            warn("failed to remove block facing " + tostring(dirOld) + " at " + tostring(block.coord));
            return false;
        }

        if (!PMT.PlaceBlock(replacement, block.coord, dirNew)) {
            warn("failed to place replacement block facing " + tostring(dirNew) + " at " + tostring(block.coord));
            return false;
        }

        if (fullPillar) {
            CGameCtnBlockInfo@ pillarReplacement = PMT.GetBlockModelFromName(nonPillarName);

            if (pillarReplacement !is null) {
                if (AirBlockModeActive(Editor))
                    Editor.ButtonAirBlockModeOnClick();

                const int3 pillarCoord = block.coord - int3(0, 1, 0);

                if (!PMT.PlaceBlock(pillarReplacement, pillarCoord, dirNew))
                    warn("failed to place top pillar replacement block facing " + tostring(dirNew) + " at " + tostring(pillarCoord));
            } else
                warn("top pillar replacement block not found: " + nonPillarName);

        } else if (pillars > 0) {
            CGameCtnBlockInfo@ pillarReplacement = PMT.GetBlockModelFromName(nonPillarName);

            if (pillarReplacement !is null) {
                for (int j = block.coord.y - 1; j >= block.coord.y - pillars; j--) {
                    // YieldIfNeeded();  // yielding here helps with framerate slightly but greatly increases total time

                    const int3 pillarCoord = int3(block.coord.x, j, block.coord.z);

                    if (!PMT.PlaceBlock(pillarReplacement, pillarCoord, dirNew))
                        warn("failed to place pillar replacement block facing " + tostring(dirNew) + " at " + tostring(pillarCoord));
                }
            } else
                warn("pillar replacement block not found: " + nonPillarName);
        }
    }

    return true;
}