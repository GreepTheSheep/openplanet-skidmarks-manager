class SkidTypeTab : Tab {

    SkidType@ skidType;

    string selectedSkidName;
    Skid@ selectedSkid;

    bool isSkidApplied = false;
    bool isSkidDeleted = false;
    bool isSkidInProgress = false;
    bool needGameRestart = false;

    bool dirtSkidDisableSmoke = false;

    SkidTypeTab(SkidType@ type) {
        super();
        @skidType = type;
    }

    string GetLabel() override { return skidType.name; }

    vec4 GetColor() override {
        if (skidType.name == "Asphalt") return vec4(0.5,0.5,0.6,1);
        else if (skidType.name == "Dirt") return vec4(1.0, 0.5, 0.0, 1.0);
        else if (skidType.name == "Grass") return vec4(0.0, 0.5, 0.0, 1.0);

        else return vec4(0.2f, 0.4f, 0.8f, 1);
    }

    void Render() override
    {
        float width = UI::GetWindowSize().x*0.6;
        vec2 posTop = UI::GetCursorPos();

        UI::BeginChild("Selector", vec2(width,0));

        UI::Text("Select a skid color for " + skidType.name + ".");
        if (UI::BeginCombo("##Select"+skidType.name, selectedSkidName.Replace(".dds", ''))){
            for (uint i = 0; i < skidType.skids.Length; i++) {
                Skid@ skid = skidType.skids[i];

                if (UI::Selectable(skid.name.Replace(".dds", ''), selectedSkidName == skid.name)) {
                    selectedSkidName = skid.name;
                    @selectedSkid = @skid;
                }

                if (selectedSkidName == skid.name) {
                    UI::SetItemDefaultFocus();
                }
            }
            UI::EndCombo();
        }
        if (!isSkidInProgress) {
            if (skidType.name == "Dirt") {
                dirtSkidDisableSmoke = UI::Checkbox("Disable Dirt Smoke", dirtSkidDisableSmoke);
            }
            if (selectedSkidName.Length > 0) {
                if (UI::GreenButton(Icons::Check + " Apply")) {
                    Skids::ApplyToGame(skidType, selectedSkid, this);
                }
                UI::SameLine();
            }
            if (UI::RedButton(Icons::Times + " Delete Custom Skid")) {
                Skids::Delete(skidType, this);
            }
        } else {
            int HourGlassValue = Time::Stamp % 3;
            string Hourglass = (HourGlassValue == 0 ? Icons::HourglassStart : (HourGlassValue == 1 ? Icons::HourglassHalf : Icons::HourglassEnd));
            UI::Text("\\$f20" + Hourglass + " \\$zApplying selected skid to " + skidType.name + ", please wait...");
        }

        if (isSkidApplied) {
            UI::NewLine();
            UI::Text("\\$0f0"+Icons::Check+" \\$zYour Skid is Applied!");
        }
        if (isSkidDeleted) {
            UI::NewLine();
            UI::Text("\\$0f0"+Icons::Check+" \\$zYour Skid is Deleted!");
        }
        if (needGameRestart) {
            UI::Text(Icons::ExclamationTriangle + " Don't forget to restart the game to apply the changes.");
        }
        UI::EndChild();

        UI::SetCursorPos(posTop + vec2(width + 8, 0));
        UI::BeginChild("ImageChild");
        if (selectedSkid !is null) {
            auto skidImg = Images::CachedFromURL(selectedSkid.downloadUrl);
            if (skidImg.m_texture !is null){
                vec2 imageSize = skidImg.m_texture.GetSize();
                float imgWidth = UI::GetWindowSize().x * 0.4;
                UI::Image(skidImg.m_texture, vec2(
                    imgWidth,
                    imageSize.y / (imageSize.x / imgWidth)
                ));
            }
        }
        UI::EndChild();
    }
}