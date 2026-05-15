{ pkgs, ... }:

let
  mkTelegramInstance = { name, displayName, workdir, iconName }:
    let
      desktopItem = pkgs.makeDesktopItem {
        name = name;                      # имя .desktop-файла (без расширения)
        desktopName = displayName;        # видимое имя в меню GNOME
        exec = "${name} %U";              # команда запуска
        icon = iconName;                  # имя иконки (резолвится через icon theme)
        categories = [ "Network" "InstantMessaging" ];
        startupWMClass = name;            # для группировки окон в доке
        mimeTypes = [ "x-scheme-handler/tg" ];
      };
    in
    pkgs.symlinkJoin {
      inherit name;
      paths = [
        (pkgs.writeShellScriptBin name ''
          exec ${pkgs.telegram-desktop}/bin/telegram-desktop \
            -workdir "${workdir}" "$@"
        '')
        desktopItem
      ];
    };

in
{
  environment.systemPackages = with pkgs; [
    telegram-desktop  # сам пакет нужен, чтобы был telegram-desktop в стора

    (mkTelegramInstance {
      name = "telegram-personal";
      displayName = "Telegram (Личный)";
      workdir = "$HOME/.telegram-personal";
      iconName = "telegram-personal";
    })

    (mkTelegramInstance {
      name = "telegram-work";
      displayName = "Telegram (Работа)";
      workdir = "$HOME/.telegram-work";
      iconName = "telegram-work";
    })
  ];
}
