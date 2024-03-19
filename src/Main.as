// c 2024-03-18
// m 2024-03-18

Block@[]     blocks;
bool         gettingBlocks = false;
const vec4   rowBgAltColor = vec4(0.0f, 0.0f, 0.0f, 0.5f);
const float  scale         = UI::GetScale();
const string title         = "\\$FFF" + Icons::Arrows + "\\$G CP Remover";

[Setting category="General" name="Enabled"]
bool S_Enabled = true;

[Setting category="General" name="Show/hide with game UI"]
bool S_HideWithGame = true;

[Setting category="General" name="Show/hide with Openplanet UI"]
bool S_HideWithOP = false;

void Main() {
}

void RenderMenu() {
    if (UI::MenuItem(title, "", S_Enabled))
        S_Enabled = !S_Enabled;
}

void Render() {
    if (
        !S_Enabled
        || (S_HideWithGame && !UI::IsGameUIVisible())
        || (S_HideWithOP && !UI::IsOverlayShown())
    )
        return;

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CGameCtnEditorFree@ Editor = cast<CGameCtnEditorFree>(App.Editor);
    if (Editor is null) {
        ClearBlocks();
        return;
    }

    CGameCtnChallenge@ Map = App.RootMap;
    if (Map is null) {
        ClearBlocks();
        return;
    }

    if (UI::Begin(title, S_Enabled, UI::WindowFlags::None)) {
        UI::BeginDisabled(gettingBlocks);
        if (UI::Button("get blocks"))
            startnew(GetBlocks);
        UI::EndDisabled();

        UI::SameLine();
        UI::Text("blocks: " + blocks.Length);

        if (UI::BeginTable("##table-blocks", 9, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
            UI::PushStyleColor(UI::Col::TableRowBgAlt, rowBgAltColor);

            UI::TableSetupScrollFreeze(0, 1);
            UI::TableSetupColumn("id");
            UI::TableSetupColumn("id val");
            UI::TableSetupColumn("author", UI::TableColumnFlags::WidthFixed, scale * 50.0f);
            UI::TableSetupColumn("color",  UI::TableColumnFlags::WidthFixed, scale * 50.0f);
            UI::TableSetupColumn("dir",    UI::TableColumnFlags::WidthFixed, scale * 50.0f);
            UI::TableSetupColumn("ghost",  UI::TableColumnFlags::WidthFixed, scale * 50.0f);
            UI::TableSetupColumn("ground", UI::TableColumnFlags::WidthFixed, scale * 50.0f);
            UI::TableSetupColumn("loc",    UI::TableColumnFlags::WidthFixed, scale * 80.0f);
            UI::TableSetupColumn("wp type");
            UI::TableHeadersRow();

            UI::ListClipper clipper(blocks.Length);
            while (clipper.Step()) {
                for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                    Block@ block = blocks[i];

                    UI::TableNextRow();

                    UI::TableNextColumn();
                    if (UI::Selectable(block.id.GetName() + "##" + i, false, UI::SelectableFlags::SpanAllColumns)) {
                        if (block.block !is null)
                            ExploreNod(block.block);
                        else
                            ExploreNod(block.item);
                    }

                    UI::TableNextColumn();
                    UI::Text(tostring(block.id.Value));

                    UI::TableNextColumn();
                    UI::Text(block.author.GetName());

                    UI::TableNextColumn();
                    UI::Text(tostring(block.color));

                    UI::TableNextColumn();
                    UI::Text(tostring(block.direction));

                    UI::TableNextColumn();
                    UI::Text(tostring(block.ghost));

                    UI::TableNextColumn();
                    UI::Text(tostring(block.ground));

                    UI::TableNextColumn();
                    UI::Text(tostring(block.location));

                    UI::TableNextColumn();
                    UI::Text(tostring(block.waypointType));
                }
            }

            UI::PopStyleColor();
            UI::EndTable();
        }
    }

    UI::End();
}