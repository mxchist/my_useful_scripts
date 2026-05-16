{ config, lib, pkgs, ... }:

let

  homePath = "${config.users.users.<username>.home}" ;  #put here your username instead of <username>

  mkIconPackage = { name, iconsDir }:
    pkgs.runCommand "${name}-icons" {} ''
      #echo "out directory is: " $out
      #set -v;
      for size in 16 24 32 48 64 128 256 512; do
	if [ -f ${iconsDir}/''${size}x''${size}/apps/org.telegram.desktop.png ]; then
          mkdir -p $out/share/icons/hicolor/''${size}x''${size}/apps;
          install -Dm644 ${iconsDir}/''${size}x''${size}/apps/org.telegram.desktop.png \
            $out/share/icons/hicolor/''${size}x''${size}/apps/${name}.png;
	fi;
      done;

      mkdir -p $out/share/icons/hicolor/symbolic/apps;
      for suffix in "-attention" "-mute" ""; do
        install -Dm644 ${iconsDir}/symbolic/apps/org.telegram.desktop''${suffix}-symbolic.svg \
          $out/share/icons/hicolor/symbolic/apps/${name}-''${suffix}-symbolic.svg
      done;
    '';

  mkTelegramInstance = { name, displayName, workdir, iconsDir }:
    let
      desktopItem = pkgs.makeDesktopItem {
        name = name;
        desktopName = displayName;
	comment = "New era of messaging";
	tryExec = "Telegram";
        exec = "Telegram -workdir ${workdir} -- %U";
        icon = if name == "telegram-personal" then "org.telegram.desktop" else name;
	terminal = false;
        startupWMClass = name;
        #startupWMClass = "TelegramDesktop";
	type = "Application";
        categories = [ "Chat" "Network" "InstantMessaging" "Qt" ];
        mimeTypes = [ "x-scheme-handler/tg" "x-scheme-handler/tonsite"];
	keywords = ["tg" "chat" "im" "messaging" "messenger" "sms" "tdesktop"];
	actions.quit = {
	  name = "Quit Telegram";
	  exec = "Telegram -quit";
	  icon = "application-exit";
	};
	dbusActivatable = true;
	extraConfig = {
          "DBusActivatable" = "false";
          "SingleMainWindow" = "true";
          "X-GNOME-UsesNotifications" = "true";
          "X-GNOME-SingleWindow" = "true";
        };

      };
    in
    pkgs.symlinkJoin {
      inherit name;
      paths = [
        desktopItem
        (mkIconPackage { inherit name; inherit iconsDir; })
      ];
    };

in
{
  users.users.<username>.packages = with pkgs; [               #put here your username instead of <username>
    telegram-desktop

    (mkTelegramInstance {
      name = "telegram-work";
      displayName = "Telegram (Work)";
      workdir = lib.strings.join "/" ["${homePath}" ".local/share/TelegramDesktopWorking"];
      iconsDir = builtins.path {
        path = lib.strings.join "/" ["${homePath}" "Pictures/icons/hicolor"];
	name = "telegram-icons";
      };
      #iconsDir = lib.strings.join "/" ["${homePath}" "Pictures/icons/hicolor"];
    })

    # This mkTelegramInstance just simply repeats the default telegram configuration, and retained here only for demonstraion purposes:
    # how to handle the several telegram Desktop entities for a Linux applications menu. Its iconsDir field does not have much sence because it is
    # stupidly repeats the telegram-work path, and will be discarded later in pkgs.makeDesktopItem.
    (mkTelegramInstance {
      name = "telegram-personal";
      displayName = "Telegram (Personal)";
      workdir = lib.strings.join "/" ["${homePath}" ".local/share/TelegramDesktop"];
      iconsDir = builtins.path {
        path = lib.strings.join "/" ["${homePath}" "Pictures/icons/hicolor"];
	name = "telegram-icons";
      };
    })
  ];
}
