# original repo on github - https://github.com/Yalu8162/APM

#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "This script requires root privileges. Please use sudo."
    exit 1
fi

cat > /usr/local/bin/apm << 'EOL'
#!/bin/bash

VERSION="1.0"

LANG_SYSTEM=$(echo $LANG | cut -d'_' -f1)

# [#!/bin/bash

VERSION="1.0"

LANG_SYSTEM=$(echo $LANG | cut -d'_' -f1)

declare -A MSG_USAGE=(
    [ru]="Использование: apm [опции] <имя пакета>
Опции:
  -h, --help     Показать эту справку
  -v, --version  Показать версию
  -n, --no-confirm Установить без подтверждения
  -s, --search   Поиск пакета
  -r, --remove   Удаление пакета"
    [en]="Usage: apm [options] <package name>
Options:
  -h, --help     Show this help
  -v, --version  Show version
  -n, --no-confirm Install without confirmation
  -s, --search   Search for package
  -r, --remove   Remove package"
    [es]="Uso: apm [opciones] <nombre del paquete>
Opciones:
  -h, --help     Mostrar esta ayuda
  -v, --version  Mostrar versión
  -n, --no-confirm Instalar sin confirmación
  -s, --search   Buscar paquete
  -r, --remove   Eliminar paquete"
    [zh]="用法: apm [选项] <软件包名称>
选项:
  -h, --help     显示帮助信息
  -v, --version  显示版本
  -n, --no-confirm 无需确认直接安装
  -s, --search   搜索软件包
  -r, --remove   删除软件包"
)

declare -A MSG_NO_MANAGERS=(
    [ru]="Ни одного пакетного менеджера не обнаружено! Отмена операции."
    [en]="No package managers found! Operation canceled."
    [es]="¡No se encontraron gestores de paquetes! Operación cancelada."
    [zh]="未找到任何包管理器！操作已取消。"
)

declare -A MSG_PKG_NOT_FOUND=(
    [ru]="Ошибка: пакет '%s' не найден в доступных источниках"
    [en]="Error: package '%s' not found in available sources"
    [es]="Error: paquete '%s' no encontrado en fuentes disponibles"
    [zh]="错误：在可用源中找不到软件包 '%s'"
)

declare -A MSG_PKG_FOUND=(
    [ru]="Найден пакет '%s' в %s"
    [en]="Found package '%s' in %s"
    [es]="Paquete '%s' encontrado en %s"
    [zh]="在 %s 中找到软件包 '%s'"
)

declare -A MSG_INSTALL_PROMPT=(
    [ru]="Установить? [Y/n] "
    [en]="Install? [Y/n] "
    [es]="¿Instalar? [Y/n] "
    [zh]="安装？[Y/n] "
)

declare -A MSG_INSTALL_CANCEL=(
    [ru]="Отмена установки"
    [en]="Installation canceled"
    [es]="Instalación cancelada"
    [zh]="安装已取消"
)

declare -A MSG_MULTIPLE_SOURCES=(
    [ru]="Пакет '%s' найден в нескольких источниках:"
    [en]="Package '%s' found in multiple sources:"
    [es]="Paquete '%s' encontrado en múltiples fuentes:"
    [zh]="软件包 '%s' 在多个源中找到:"
)

declare -A MSG_CHOOSE_INSTALL=(
    [ru]="Выберите вариант установки (1-%d): "
    [en]="Choose installation option (1-%d): "
    [es]="Elija la opción de instalación (1-%d): "
    [zh]="选择安装选项 (1-%d): "
)

declare -A MSG_INVALID_CHOICE=(
    [ru]="Неверный выбор, отмена установки"
    [en]="Invalid choice, installation canceled"
    [es]="Opción no válida, instalación cancelada"
    [zh]="选择无效，安装已取消"
)

declare -A MSG_SEARCH_RESULTS=(
    [ru]="Результаты поиска для '%s':"
    [en]="Search results for '%s':"
    [es]="Resultados de búsqueda para '%s':"
    [zh]="'%s' 的搜索结果:"
)

declare -A MSG_REMOVE_PROMPT=(
    [ru]="Удалить пакет '%s'? [Y/n] "
    [en]="Remove package '%s'? [Y/n] "
    [es]="¿Eliminar paquete '%s'? [Y/n] "
    [zh]="删除软件包 '%s'? [Y/n] "
)

declare -A MSG_REMOVING=(
    [ru]="Удаление пакета '%s'..."
    [en]="Removing package '%s'..."
    [es]="Eliminando paquete '%s'..."
    [zh]="正在删除软件包 '%s'..."
)

declare -A MSG_VERSION=(
    [ru]="apm версии %s"
    [en]="apm version %s"
    [es]="apm versión %s"
    [zh]="apm 版本 %s"
)

get_msg() {
    local msg_type=$1
    local lang=${2:-$LANG_SYSTEM}
    
    # Косвенные ссылки для доступа к нужному массиву
    local var_name="MSG_${msg_type}[$lang]"
    local message="${!var_name}"
    
    # Если для текущего языка нет сообщения, используем английский
    if [[ -z "$message" ]]; then
        var_name="MSG_${msg_type}[en]"
        message="${!var_name}"
    fi
    
    echo "$message"
}

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ACTION="install"
NO_CONFIRM=0
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            echo -e "${YELLOW}$(get_msg USAGE)${NC}"
            exit 0
            ;;
        -v|--version)
            printf "${GREEN}$(get_msg VERSION)${NC}\n" "$VERSION"
            exit 0
            ;;
        -n|--no-confirm)
            NO_CONFIRM=1
            shift
            ;;
        -s|--search)
            ACTION="search"
            shift
            ;;
        -r|--remove)
            ACTION="remove"
            shift
            ;;
        -*)
            echo -e "${RED}Неизвестная опция: $1${NC}" >&2
            echo -e "${YELLOW}$(get_msg USAGE)${NC}" >&2
            exit 1
            ;;
        *)
            PACKAGE="$1"
            shift
            ;;
    esac
done

if [ -z "$PACKAGE" ] && [ "$ACTION" != "search" ]; then
    echo -e "${RED}$(get_msg USAGE)${NC}" >&2
    exit 1
fi

check_manager() {
    command -v "$1" &> /dev/null
}

search_package() {
    local found=0

    # APT
    if check_manager apt; then
        if apt-cache search "$PACKAGE" | grep -q "$PACKAGE"; then
            echo -e "${GREEN}APT:${NC}"
            apt-cache search "$PACKAGE" | grep --color=always "$PACKAGE"
            found=1
        fi
    fi
    
    # Pacman
    if check_manager pacman; then
        if pacman -Ss "$PACKAGE" | grep -q "$PACKAGE"; then
            echo -e "${GREEN}Pacman:${NC}"
            pacman -Ss "$PACKAGE" | grep --color=always "$PACKAGE"
            found=1
        fi
    fi
    
    # Yay
    if check_manager yay; then
        if yay -Ss "$PACKAGE" | grep -q "$PACKAGE"; then
            echo -e "${GREEN}AUR (yay):${NC}"
            yay -Ss "$PACKAGE" | grep --color=always "$PACKAGE"
            found=1
        fi
    fi
    
    # DNF
    if check_manager dnf; then
        if dnf search "$PACKAGE" | grep -q "$PACKAGE"; then
            echo -e "${GREEN}DNF:${NC}"
            dnf search "$PACKAGE" | grep --color=always "$PACKAGE"
            found=1
        fi
    fi
    
    # Zypper
    if check_manager zypper; then
        if zypper search -s "$PACKAGE" | grep -q "$PACKAGE"; then
            echo -e "${GREEN}Zypper:${NC}"
            zypper search -s "$PACKAGE" | grep --color=always "$PACKAGE"
            found=1
        fi
    fi
    
    # PKG
    if check_manager pkg; then
        if pkg search "$PACKAGE" | grep -q "$PACKAGE"; then
            echo -e "${GREEN}PKG:${NC}"
            pkg search "$PACKAGE" | grep --color=always "$PACKAGE"
            found=1
        fi
    fi
    
    # Flatpak
    if check_manager flatpak; then
        if flatpak search "$PACKAGE" | grep -q "$PACKAGE"; then
            echo -e "${GREEN}Flatpak:${NC}"
            flatpak search "$PACKAGE" | grep --color=always "$PACKAGE"
            found=1
        fi
    fi
    
    # Snap
    if check_manager snap; then
        if snap find "$PACKAGE" | grep -q "$PACKAGE"; then
            echo -e "${GREEN}Snap:${NC}"
            snap find "$PACKAGE" | grep --color=always "$PACKAGE"
            found=1
        fi
    fi
    
    if [ $found -eq 0 ]; then
        printf "${RED}$(get_msg PKG_NOT_FOUND)${NC}\n" "$PACKAGE"
        exit 1
    fi
}

remove_package() {
    local removed=0
    
    # APT
    if check_manager apt && dpkg -l | grep -q "^ii  $PACKAGE"; then
        if [ $NO_CONFIRM -eq 1 ]; then
            echo "Executing: sudo apt remove $PACKAGE"
            sudo apt remove -y "$PACKAGE"
        else
            printf "${YELLOW}$(get_msg REMOVE_PROMPT)${NC}" "$PACKAGE"
            read -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
                printf "${YELLOW}$(get_msg REMOVING)${NC}\n" "$PACKAGE"
                sudo apt remove -y "$PACKAGE"
            else
                echo -e "${YELLOW}$(get_msg INSTALL_CANCEL)${NC}"
            fi
        fi
        removed=1
    fi
    
    # Pacman
    if check_manager pacman && pacman -Q "$PACKAGE" &>/dev/null; then
        if [ $NO_CONFIRM -eq 1 ]; then
            echo "Executing: sudo pacman -R $PACKAGE"
            sudo pacman -R --noconfirm "$PACKAGE"
        else
            printf "${YELLOW}$(get_msg REMOVE_PROMPT)${NC}" "$PACKAGE"
            read -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
                printf "${YELLOW}$(get_msg REMOVING)${NC}\n" "$PACKAGE"
                sudo pacman -R "$PACKAGE"
            else
                echo -e "${YELLOW}$(get_msg INSTALL_CANCEL)${NC}"
            fi
        fi
        removed=1
    fi
    
    # Yay
    if check_manager yay && yay -Q "$PACKAGE" &>/dev/null; then
        if [ $NO_CONFIRM -eq 1 ]; then
            echo "Executing: yay -R $PACKAGE"
            yay -R --noconfirm "$PACKAGE"
        else
            printf "${YELLOW}$(get_msg REMOVE_PROMPT)${NC}" "$PACKAGE"
            read -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
                printf "${YELLOW}$(get_msg REMOVING)${NC}\n" "$PACKAGE"
                yay -R "$PACKAGE"
            else
                echo -e "${YELLOW}$(get_msg INSTALL_CANCEL)${NC}"
            fi
        fi
        removed=1
    fi
    
    # Flatpak
    if check_manager flatpak && flatpak list | grep -q "$PACKAGE"; then
        if [ $NO_CONFIRM -eq 1 ]; then
            echo "Executing: flatpak uninstall $PACKAGE"
            flatpak uninstall -y "$PACKAGE"
        else
            printf "${YELLOW}$(get_msg REMOVE_PROMPT)${NC}" "$PACKAGE"
            read -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
                printf "${YELLOW}$(get_msg REMOVING)${NC}\n" "$PACKAGE"
                flatpak uninstall "$PACKAGE"
            else
                echo -e "${YELLOW}$(get_msg INSTALL_CANCEL)${NC}"
            fi
        fi
        removed=1
    fi
    
    # Snap
    if check_manager snap && snap list | grep -q "^$PACKAGE"; then
        if [ $NO_CONFIRM -eq 1 ]; then
            echo "Executing: sudo snap remove $PACKAGE"
            sudo snap remove "$PACKAGE"
        else
            printf "${YELLOW}$(get_msg REMOVE_PROMPT)${NC}" "$PACKAGE"
            read -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
                printf "${YELLOW}$(get_msg REMOVING)${NC}\n" "$PACKAGE"
                sudo snap remove "$PACKAGE"
            else
                echo -e "${YELLOW}$(get_msg INSTALL_CANCEL)${NC}"
            fi
        fi
        removed=1
    fi
    
    if [ $removed -eq 0 ]; then
        printf "${RED}$(get_msg PKG_NOT_FOUND)${NC}\n" "$PACKAGE"
        exit 1
    fi
}

install_package() {
    local OPTIONS=()
    local SOURCES=()
    local MANAGERS_FOUND=0

    # APT
    if check_manager apt && apt-cache show "$PACKAGE" &> /dev/null; then
        VERSION=$(apt-cache policy "$PACKAGE" | grep -oP 'Candidate: \K.*' || echo "")
        OPTIONS+=("sudo apt install $PACKAGE")
        SOURCES+=("APT ${VERSION:+($VERSION)}")
        MANAGERS_FOUND=1
    fi

    # Pacman
    if check_manager pacman && pacman -Ss "^$PACKAGE$" &> /dev/null; then
        VERSION=$(pacman -Si "$PACKAGE" 2>/dev/null | grep -oP 'Version\s*:\s*\K.*' || echo "")
        OPTIONS+=("sudo pacman -S --noconfirm $PACKAGE")
        SOURCES+=("Pacman ${VERSION:+($VERSION)}")
        MANAGERS_FOUND=1
    fi

    # Yay
    if check_manager yay && yay -Ss "^$PACKAGE$" &> /dev/null; then
        VERSION=$(yay -Si "$PACKAGE" 2>/dev/null | grep -oP 'Version\s*:\s*\K.*' || echo "")
        OPTIONS+=("yay -S --noconfirm $PACKAGE")
        SOURCES+=("AUR (via yay) ${VERSION:+($VERSION)}")
        MANAGERS_FOUND=1
    fi

    # DNF
    if check_manager dnf && dnf list "$PACKAGE" &> /dev/null; then
        VERSION=$(dnf info "$PACKAGE" 2>/dev/null | grep -oP 'Version\s*:\s*\K.*' || echo "")
        OPTIONS+=("sudo dnf install -y $PACKAGE")
        SOURCES+=("DNF ${VERSION:+($VERSION)}")
        MANAGERS_FOUND=1
    fi

    # Zypper
    if check_manager zypper && zypper search -s "$PACKAGE" &> /dev/null; then
        VERSION=$(zypper info "$PACKAGE" 2>/dev/null | grep -oP 'Version\s*:\s*\K.*' || echo "")
        OPTIONS+=("sudo zypper install -y $PACKAGE")
        SOURCES+=("Zypper ${VERSION:+($VERSION)}")
        MANAGERS_FOUND=1
    fi

    # PKG
    if check_manager pkg && pkg search "^$PACKAGE$" &> /dev/null; then
        VERSION=$(pkg info "$PACKAGE" 2>/dev/null | grep -oP 'Version\s*:\s*\K.*' || echo "")
        OPTIONS+=("sudo pkg install -y $PACKAGE")
        SOURCES+=("PKG ${VERSION:+($VERSION)}")
        MANAGERS_FOUND=1
    fi

    # Flatpak
    if check_manager flatpak && flatpak search "$PACKAGE" --columns=application | grep -q "^$PACKAGE$"; then
        VERSION=$(flatpak info "$PACKAGE" --show-metadata 2>/dev/null | grep -oP 'version=\K.*' || echo "latest")
        OPTIONS+=("flatpak install -y $PACKAGE")
        SOURCES+=("Flatpak ${VERSION:+($VERSION)}")
        MANAGERS_FOUND=1
    fi

    # Snap
    if check_manager snap && snap info "$PACKAGE" &> /dev/null; then
        VERSION=$(snap info "$PACKAGE" | grep -oP 'version: \K.*' || echo "")
        OPTIONS+=("sudo snap install $PACKAGE")
        SOURCES+=("Snap ${VERSION:+($VERSION)}")
        MANAGERS_FOUND=1
    fi

    if [ $MANAGERS_FOUND -eq 0 ]; then
        echo -e "${RED}$(get_msg NO_MANAGERS)${NC}"
        exit 1
    fi

    case ${#OPTIONS[@]} in
        0)
            printf "${RED}$(get_msg PKG_NOT_FOUND)${NC}\n" "$PACKAGE"
            exit 1
            ;;
        1)
            printf "${GREEN}$(get_msg PKG_FOUND)${NC}\n" "$PACKAGE" "${SOURCES[0]}"
            if [ $NO_CONFIRM -eq 1 ]; then
                echo "Executing: ${OPTIONS[0]}"
                eval "${OPTIONS[0]}"
            else
                read -p "$(get_msg INSTALL_PROMPT)" -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
                    echo "Executing: ${OPTIONS[0]}"
                    eval "${OPTIONS[0]}"
                else
                    echo -e "${YELLOW}$(get_msg INSTALL_CANCEL)${NC}"
                fi
            fi
            ;;
        *)
            printf "${GREEN}$(get_msg MULTIPLE_SOURCES)${NC}\n" "$PACKAGE"
            for i in "${!OPTIONS[@]}"; do
                printf "%s) ${YELLOW}%s${NC} - %s\n" "$((i+1))" "${SOURCES[$i]}" "${OPTIONS[$i]% *}"
            done
            if [ $NO_CONFIRM -eq 1 ]; then
                echo "Выбран первый вариант (без подтверждения)"
                echo "Executing: ${OPTIONS[0]}"
                eval "${OPTIONS[0]}"
            else
                read -p "$(printf "$(get_msg CHOOSE_INSTALL)" ${#OPTIONS[@]})" choice
                if [[ $choice =~ ^[1-9]$ ]] && (( choice <= ${#OPTIONS[@]} )); then
                    echo "Executing: ${OPTIONS[$((choice-1))]}"
                    eval "${OPTIONS[$((choice-1))]}"
                else
                    echo -e "${RED}$(get_msg INVALID_CHOICE)${NC}"
                fi
            fi
            ;;
    esac
}

case $ACTION in
    search)
        if [ -z "$PACKAGE" ]; then
            echo -e "${RED}Необходимо указать имя пакета для поиска${NC}" >&2
            echo -e "${YELLOW}$(get_msg USAGE)${NC}" >&2
            exit 1
        fi
        printf "${GREEN}$(get_msg SEARCH_RESULTS)${NC}\n" "$PACKAGE"
        search_package
        ;;
    remove)
        remove_package
        ;;
    install)
        install_package
        ;;
esac

EOL

chmod +x /usr/local/bin/apm

if [ -f /usr/local/bin/apm ] && [ -x /usr/local/bin/apm ]; then
    echo "APM successfully installed to /usr/local/bin/apm. To uninstall - use sudo rm /usr/local/bin/apm"
else
    echo "Advanced Package Manager installation failed!"
    exit 1
fi

if [ ! -f /usr/bin/apm ]; then
    ln -s /usr/local/bin/apm /usr/bin/apm 2>/dev/null
    echo "Created symlink /usr/bin/apm"
fi

echo "Installation complete. Use 'apm --help' for help."
