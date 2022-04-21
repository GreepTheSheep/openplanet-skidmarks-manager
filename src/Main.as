Window@ g_window;
Repo@ g_repo;

void Main()
{
    @g_window = Window();
    @g_repo = Repo();
}

void RenderMenu() {
    if (UI::MenuItem(Icons::Car + " Skid Marks Manager", "", g_window.isOpened)) {
        g_window.isOpened = !g_window.isOpened;
    }
}

void RenderInterface()
{
    if (g_window.isOpened) g_window.Render();
}