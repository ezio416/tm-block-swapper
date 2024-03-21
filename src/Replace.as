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

    CSmEditorPluginMapType@ PMT = cast<CSmEditorPluginMapType@>(Editor.PluginMapType);
    if (PMT is null) {
        warn("can't replace CP blocks - PMT is null");
        replacing = false;
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

        if (ReplaceBlock(block, Editor, PMT, LUT["checkpoint"], airBlockModePre))
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

void ReplaceFinishBlocks() {
    if (replacing)
        return;

    replacing = true;

    const uint64 start = Time::Now;
    trace("replacing finish blocks");

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CGameCtnEditorFree@ Editor = cast<CGameCtnEditorFree@>(App.Editor);
    if (Editor is null) {
        warn("can't replace finish blocks - Editor is null");
        replacing = false;
        return;
    }

    CSmEditorPluginMapType@ PMT = cast<CSmEditorPluginMapType@>(Editor.PluginMapType);
    if (PMT is null) {
        warn("can't replace finish blocks - PMT is null");
        replacing = false;
        return;
    }

    uint total = 0;

    LoadMapBlocks();

    for (uint i = 0; i < mapBlocksFin.Length; i++) {
        YieldIfNeeded();

        trace("replacing finish block (" + (i + 1) + " / " + mapBlocksFin.Length + ")");

        Block@ block = mapBlocksFin[i];

        const bool airBlockModePre = AirBlockModeActive(Editor);
        const CGameEditorPluginMap::EMapElemColor colorPre = PMT.NextMapElemColor;

        if (ReplaceBlock(block, Editor, PMT, LUT["finish"], airBlockModePre))
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
    trace("replaced " + total + " finish block" + (total == 1 ? "" : "s") + " after " + dif + "ms (" + Time::Format(dif) + ")");

    if (total > 0)
        PMT.AutoSave();  // usually doesn't save but at least fixes undo

    replacing = false;
}

void ReplaceMultilapBlocks() {
    if (replacing)
        return;

    replacing = true;

    const uint64 start = Time::Now;
    trace("replacing multilap blocks");

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CGameCtnEditorFree@ Editor = cast<CGameCtnEditorFree@>(App.Editor);
    if (Editor is null) {
        warn("can't replace multilap blocks - Editor is null");
        replacing = false;
        return;
    }

    CSmEditorPluginMapType@ PMT = cast<CSmEditorPluginMapType@>(Editor.PluginMapType);
    if (PMT is null) {
        warn("can't replace multilap blocks - PMT is null");
        replacing = false;
        return;
    }

    uint total = 0;

    LoadMapBlocks();

    for (uint i = 0; i < mapBlocksMultilap.Length; i++) {
        YieldIfNeeded();

        trace("replacing multilap block (" + (i + 1) + " / " + mapBlocksMultilap.Length + ")");

        Block@ block = mapBlocksMultilap[i];

        const bool airBlockModePre = AirBlockModeActive(Editor);
        const CGameEditorPluginMap::EMapElemColor colorPre = PMT.NextMapElemColor;

        if (ReplaceBlock(block, Editor, PMT, LUT["multilap"], airBlockModePre))
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
    trace("replaced " + total + " multilap block" + (total == 1 ? "" : "s") + " after " + dif + "ms (" + Time::Format(dif) + ")");

    if (total > 0)
        PMT.AutoSave();  // usually doesn't save but at least fixes undo

    replacing = false;
}

void ReplaceStartBlocks() {
    if (replacing)
        return;

    replacing = true;

    const uint64 start = Time::Now;
    trace("replacing start blocks");

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CGameCtnEditorFree@ Editor = cast<CGameCtnEditorFree@>(App.Editor);
    if (Editor is null) {
        warn("can't replace start blocks - Editor is null");
        replacing = false;
        return;
    }

    CSmEditorPluginMapType@ PMT = cast<CSmEditorPluginMapType@>(Editor.PluginMapType);
    if (PMT is null) {
        warn("can't replace start blocks - PMT is null");
        replacing = false;
        return;
    }

    uint total = 0;

    LoadMapBlocks();

    for (uint i = 0; i < mapBlocksStart.Length; i++) {
        YieldIfNeeded();

        trace("replacing start block (" + (i + 1) + " / " + mapBlocksStart.Length + ")");

        Block@ block = mapBlocksStart[i];

        const bool airBlockModePre = AirBlockModeActive(Editor);
        const CGameEditorPluginMap::EMapElemColor colorPre = PMT.NextMapElemColor;

        if (ReplaceBlock(block, Editor, PMT, LUT["start"], airBlockModePre))
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
    trace("replaced " + total + " start block" + (total == 1 ? "" : "s") + " after " + dif + "ms (" + Time::Format(dif) + ")");

    if (total > 0)
        PMT.AutoSave();  // usually doesn't save but at least fixes undo

    replacing = false;
}

bool ReplaceBlock(Block@ block, CGameCtnEditorFree@ Editor, CSmEditorPluginMapType@ PMT, Json::Value@ lut, bool airBlockModePre) {
    if (block is null || PMT is null || lut is null)
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

    const CGameEditorPluginMap::ECardinalDirections dirOld = CGameEditorPluginMap::ECardinalDirections(block.direction);
    const CGameEditorPluginMap::ECardinalDirections dirNew = CGameEditorPluginMap::ECardinalDirections((int(block.direction) + rotate) % 4);

    if (block.block is null || block.block.BlockModel is null) {
        warn("can't replace block - something is null");
        return false;
    }

    if (block.ghost) {
        if (!PMT.RemoveGhostBlock(block.block.BlockModel, block.coord, dirOld)) {
            warn("failed to remove ghost block at " + tostring(block.coord));
            return false;
        }

        if (!PMT.PlaceGhostBlock(replacement, block.coord, dirNew)) {
            warn("failed to place replacement ghost block at " + tostring(block.coord));
            return false;
        }
    } else {
        if (!PMT.RemoveBlockSafe(block.block.BlockModel, block.coord, dirOld)) {
            warn("failed to remove block at " + tostring(block.coord));
            return false;
        }

        if (!PMT.PlaceBlock(replacement, block.coord, dirNew)) {
            warn("failed to place replacement block at " + tostring(block.coord));
            return false;
        }

        if (fullPillar) {
            CGameCtnBlockInfo@ pillarReplacement = PMT.GetBlockModelFromName(nonPillarName);

            if (pillarReplacement !is null) {
                const int3 pillarCoord = block.coord - int3(0, 1, 0);

                if (!PMT.PlaceBlock(pillarReplacement, pillarCoord, dirNew)) {  // this usually succeeds but still returns false?
                    // warn("failed to place top pillar replacement block at " + tostring(pillarCoord));
                }
            } else
                warn("top pillar replacement block not found: " + nonPillarName);

        } else if (pillars > 0) {
            CGameCtnBlockInfo@ pillarReplacement = PMT.GetBlockModelFromName(nonPillarName);

            if (pillarReplacement !is null) {
                for (int j = block.coord.y - 1; j >= block.coord.y - pillars; j--) {
                    // YieldIfNeeded();  // yielding here helps with framerate slightly but greatly increases total time

                    const int3 pillarCoord = int3(block.coord.x, j, block.coord.z);

                    if (!PMT.PlaceBlock(pillarReplacement, pillarCoord, dirNew))
                        warn("failed to place pillar replacement block at " + tostring(pillarCoord));
                }
            } else
                warn("pillar replacement block not found: " + nonPillarName);
        }
    }

    return true;
}