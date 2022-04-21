class AdvancedTab : Tab {
    string GetLabel() override { return Icons::Cog + " Advanced"; }

    void Render() override
    {
        UI::Text("Delete all custom skid marks and other customizations.");
        UI::Text("Don't forget to restart the game after deleting to apply the changes.");
        if (UI::RedButton(Icons::Trash + " Delete all customizations"))
        {
            Skids::DeleteAll();
        }
    }
}