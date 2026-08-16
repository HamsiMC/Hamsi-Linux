// SPDX-License-Identifier: MIT
var ds = desktops();
for (var i = 0; i < ds.length; ++i) {
    ds[i].wallpaperPlugin = "org.kde.image";
    ds[i].currentConfigGroup = ["Wallpaper", "org.kde.image", "General"];
    ds[i].writeConfig("Image", "file:///usr/share/wallpapers/Hamsi/contents/images/3840x2160.svg");
    ds[i].writeConfig("FillMode", "2");
}

var existing = panels();
for (var p = 0; p < existing.length; ++p) {
    existing[p].remove();
}

var panel = new Panel;
panel.location = "bottom";
panel.height = 46;
panel.hiding = "normalpanel";
panel.addWidget("org.kde.plasma.kickoff");
panel.addWidget("org.kde.plasma.pager");
var tasks = panel.addWidget("org.kde.plasma.icontasks");
tasks.currentConfigGroup = ["General"];
tasks.writeConfig("launchers", [
    "applications:org.kde.dolphin.desktop",
    "applications:org.kde.konsole.desktop",
    "applications:yandex-browser.desktop",
    "applications:org.kde.discover.desktop"
]);
panel.addWidget("org.kde.plasma.marginsseparator");
panel.addWidget("org.kde.plasma.systemtray");
panel.addWidget("org.kde.plasma.digitalclock");
panel.addWidget("org.kde.plasma.showdesktop");
