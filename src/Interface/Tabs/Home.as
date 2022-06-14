class HomePageTab : Tab {
    UI::Font@ t_fontHeader = UI::LoadFont("DroidSans-Bold.ttf", 18, -1, -1, true, true, true);

    string GetLabel() override { return Icons::Home; }
    vec4 GetColor() override { return vec4(1,0.5,0,1); }

    void Render() override
    {
        auto headerImg = Images::CachedFromURL("https://github.com/"+SKIDS_GITHUB_REPO+"/raw/master/Images/header.png");
        if (headerImg.m_texture !is null){
            vec2 imageSize = headerImg.m_texture.GetSize();
            float width = UI::GetWindowSize().x;
            UI::Image(headerImg.m_texture, vec2(
                width,
                imageSize.y / (imageSize.x / width)
            ));
        }

        UI::PushFont(t_fontHeader);
        UI::TextWrapped("This plugin will helps you easily install custom colored skid marks on your game");
        UI::TextWrapped("\\$fa0" + Icons::ExclamationTriangle + " \\$zKeep in mind that custom skid marks will override map mods (custom map textures)");
        UI::NewLine();
        UI::Text("To get started, select a surface type from the tabs.");
        UI::PopFont();
    }
}