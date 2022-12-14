class GameSkidApply
{
    Skid@ skid;
    SkidType@ type;
    SkidTypeTab@ tab;

    void Apply()
    {
        string stadiumDir = IO::FromUserGameFolder("Skins/Stadium");
        if (!IO::FolderExists(stadiumDir)) IO::CreateFolder(stadiumDir);
        string modWorkDir = stadiumDir + "/ModWork";
        if (!IO::FolderExists(modWorkDir)) {
            tab.needGameRestart = true;
            IO::CreateFolder(modWorkDir);
        }
        if (type.name != "Dirt") {
            string fxImageDir = IO::FromUserGameFolder("Skins/Stadium/ModWork/CarFxImage");
            if (!IO::FolderExists(fxImageDir)) IO::CreateFolder(fxImageDir);
            auto req = API::Get(skid.downloadUrl);
            while (!req.Finished()) {
                yield();
            }
            req.SaveToFile(fxImageDir + "/Car"+type.name+"Marks.dds");
        } else {
            auto req = API::Get(skid.downloadUrl);
            while (!req.Finished()) {
                yield();
            }
            req.SaveToFile(modWorkDir + "/DirtMarks.dds");
            if (tab.dirtSkidDisableSmoke) {
                auto reqSmoke = API::Get("https://raw.githubusercontent.com/"+SKIDS_GITHUB_REPO+"/master/"+SKIDS_GITHUB_LIST_PATH+"/Dirt/DirtSmoke.dds");
                while (!reqSmoke.Finished()) {
                    yield();
                }
                reqSmoke.SaveToFile(modWorkDir + "/DirtSmoke.dds");
            }
        }
        tab.isSkidApplied = true;
        tab.isSkidInProgress = false;
    }
}

namespace Skids
{
    void ApplyToGame(SkidType@ type, Skid@ skid, SkidTypeTab@ tab)
    {
        print("Applying skid " + skid.name + " to " + type.name);
        tab.isSkidApplied = false;
        tab.isSkidDeleted = false;
        tab.isSkidInProgress = true;
        GameSkidApply@ apply = GameSkidApply();
        @apply.skid = @skid;
        @apply.type = @type;
        @apply.tab = @tab;
        startnew(CoroutineFunc(apply.Apply));
    }

    void Delete(SkidType@ type, SkidTypeTab@ tab)
    {
        print("Deleting skid to " + type.name);
        tab.isSkidApplied = false;
        tab.isSkidDeleted = false;
        tab.isSkidInProgress = true;

        string modWorkDir = IO::FromUserGameFolder("Skins/Stadium/ModWork");
        if (!IO::FolderExists(modWorkDir)) IO::CreateFolder(modWorkDir);
        if (type.name != "Dirt") {
            string fxImageDir = IO::FromUserGameFolder("Skins/Stadium/ModWork/CarFxImage");
            string file = fxImageDir + "/Car"+type.name+"Marks.dds";
            trace("Deleting " + file);
            if (IO::FileExists(file)) IO::Delete(file);
            array<string> filesInFxImageDir = IO::IndexFolder(fxImageDir, true);
            if (filesInFxImageDir.Length == 0) IO::DeleteFolder(fxImageDir);
        } else {
            string file = modWorkDir + "/DirtMarks.dds";
            trace("Deleting " + file);
            if (IO::FileExists(file)) IO::Delete(file);
            file = modWorkDir + "/DirtSmoke.dds";
            trace("Deleting " + file);
            if (IO::FileExists(file)) IO::Delete(file);
        }
        tab.isSkidDeleted = true;
        tab.isSkidInProgress = false;
        tab.needGameRestart = true;

        // Delete ModWork folder if there are no more skids on this directory
        array<string> files = IO::IndexFolder(modWorkDir, true);
        if (files.Length == 0) IO::DeleteFolder(modWorkDir);
    }

    void DeleteAll()
    {   
        array<SkidTypeTab@> tabs = g_window.skidTabs;
        for(uint i = 0; i < tabs.Length; i++)
        {
            SkidTypeTab@ tab = tabs[i];
            tab.isSkidApplied = false;
            tab.isSkidDeleted = true;
            tab.isSkidInProgress = false;
            tab.needGameRestart = true;
        }
        string modWorkDir = IO::FromUserGameFolder("Skins/Stadium/ModWork");
        IO::DeleteFolder(modWorkDir, true);
        UI::ShowNotification(Icons::Check + " " + Meta::ExecutingPlugin().Name, "All customizations have been deleted.\nPlease rejoin the map to apply changes.");
    }
}