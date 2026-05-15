{ pkgs, ... }:

let
  mkIconPackage = { name, iconsDir }:
    pkgs.runCommand "${name}-icons" {} ''
      for size in 16 24 32 48 64 128 256; do
        if [ -f ${iconsDir}/''${size}x''${size}.png ]; then
          install -Dm644 ${iconsDir}/''${size}x''${size}.png \
            $out/share/icons/hicolor/''${size}x''${size}/apps/${name}.png
        fi
      done
    '';

  mkTelegramInstance = { name, displayName, workdir, iconsDir }:
    let
      desktopItem = pkgs.makeDesktopItem {
        name = name;
        desktopName = displayName;
	comment = "New era of messaging";
	tryExec = name;
        exec = "${name} -- %U";
        icon = name;
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
        (pkgs.writeShellScriptBin name ''
        # Подсказка для Qt/Wayland: с каким .desktop ассоциировать окно
        export QT_WAYLAND_DESKTOP_FILE="${name}.desktop"

        if [ "$1" = "-quit" ]; then
          exec ${pkgs.telegram-desktop}/bin/telegram-desktop \
            -workdir "${workdir}" -quit
        fi
        exec ${pkgs.telegram-desktop}/bin/telegram-desktop \
          -workdir "${workdir}" \
          -name "${name}" \
          "$@"
        '')
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
      workdir = "$HOME/.local/share/TelegramDesktop";
      iconsDir = ./icons/personal;
    })

    (mkTelegramInstance {
      name = "telegram-work";
      displayName = "Telegram (Work)";
      workdir = "$HOME/.local/share/TelegramDesktopWorking";
      iconsDir = ./icons/work;
    })
  ];
}
