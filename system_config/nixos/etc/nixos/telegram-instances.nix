{ config, lib, pkgs, ... }:

let

  homePath = "${config.users.users.<username>.home}" ;  #put here your username instead of <username>

  mkIconPackage = { name, iconsDir }:
    pkgs.runCommand "${name}-icons" {} ''
      mkdir -p $out
      echo "$out"
      for size in 16 24 32 48 64 128 256; do
        if [ -f ${iconsDir}/''${size}x''${size}.png ]; then
          install -Dm644 ${iconsDir} $out/share/icons
        fi
      done
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
      name = "telegram-personal";
      displayName = "Telegram (Personal)";
      workdir = lib.strings.join "/" ["${homePath}" ".local/share/TelegramDesktop"];
      iconsDir = lib.strings.join "/" ["${homePath}" "Pictures/icons/telegram-desktop"];
      #workdir = lib.path.append "${config.users.users.<username>.home}" ".local/share/TelegramDesktop";
      #workdir = "${HOME}/.local/share/TelegramDesktopWorking";
      #iconsDir = "$HOME/Pictures/icons/telegram-desktop";
    })

    (mkTelegramInstance {
      name = "telegram-work";
      displayName = "Telegram (Work)";
      workdir = lib.strings.join "/" ["${homePath}" ".local/share/TelegramDesktopWorking"];
      iconsDir = lib.strings.join "/" ["${homePath}" "Pictures/icons/telegram-desktop"];
      #workdir = lib.path.append "${config.users.users.<username>.home}" ".local/share/TelegramDesktopWorking";
      #workdir = "${HOME}/.local/share/TelegramDesktopWorking";
      #iconsDir = "$HOME/Pictures/icons/telegram-desktop";
    })
  ];
}
