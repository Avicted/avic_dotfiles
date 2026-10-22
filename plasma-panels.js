// Plasma panel layout, run by init.sh through plasmashell's scripting API.
// One bottom bar: launcher, open windows as icons (plus pinned apps), then
// tray and clock on the right. No global app menu, so apps keep their menus
// in their own windows.
// Panels are rebuilt only when this layout isn't already there, so re-runs never
// clobber later tweaks.
const bar = panels().filter(p =>
  p.location == "bottom" &&
  p.widgets("org.kde.plasma.appmenu").length == 0 &&
  p.widgets("org.kde.plasma.icontasks").length > 0);

if (panels().length == 1 && bar.length == 1) {
  print("kept");
} else {
  panels().forEach(p => p.remove());

  const panel = new Panel;
  panel.location = "bottom";
  panel.height = 44;
  panel.floating = false;
  panel.opacity = "translucent";
  for (const w of ["kickoff", "icontasks", "marginsseparator",
                   "systemtray", "marginsseparator", "digitalclock", "showdesktop"]) {
    panel.addWidget("org.kde.plasma." + w);
  }

  const kickoff = panel.widgets("org.kde.plasma.kickoff")[0];
  kickoff.currentConfigGroup = ["Shortcuts"];
  kickoff.writeConfig("global", "Alt+F1");

  const tasks = panel.widgets("org.kde.plasma.icontasks")[0];
  tasks.currentConfigGroup = ["General"];
  tasks.writeConfig("launchers", [
    "preferred://filemanager",
    "preferred://browser",
    "applications:systemsettings.desktop",
  ]);

  print("rebuilt");
}
