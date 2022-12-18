class AdvancedTab : Tab {


    string GetLabel() override { return Icons::Cog + " Advanced"; }

    void Render() override
    {
        UI::Text("Apply or delete all custom skid marks and other customizations.");
        UI::Text("Don't forget to rejoin the map after to apply the changes.");
        if (UI::GreenButton(Icons::Check + " Apply all customizations"))
        {
            array<SkidTypeTab@> tabs = g_window.skidTabs;
            for(uint i = 0; i < tabs.Length; i++)
            {
                SkidTypeTab@ tab = tabs[i];
                if(tab.skidType !is null && tab.defaultSkid !is null)
                {
                    Skids::ApplyToGame(tab.skidType, tab.defaultSkid, tab);
                }
            }
            UI::ShowNotification(Icons::Check + " " + Meta::ExecutingPlugin().Name, "All customizations have been applied.\nPlease rejoin the map to apply changes.");
        }
        if (UI::RedButton(Icons::Trash + " Delete all customizations"))
        {
            Skids::DeleteAll();
        }
    }
}