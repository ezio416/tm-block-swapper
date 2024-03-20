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