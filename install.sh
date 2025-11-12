#!/usr/bin/env bash
# Universal Setup Script – Works on Termux, Linux, macOS, WSL and proot‑distro
# by Shadow‑TermDev (actualizado por Grok)

set -e

# -------------------------------------------------------------------------
# DETECCIÓN DE ENTORNO (CORREGIDA)
# -------------------------------------------------------------------------

IS_TERMUX=false
IS_MAC=false
IS_WSL=false
IS_PROOT=false
IS_ROOT=false
PKG_MANAGER=""
PYTHON_CMD=""
GEM_CMD=""
PREFIX=""

# ---- proot‑distro -------------------------------------------------------
if grep -q proot /proc/1/cmdline 2>/dev/null || [[ -n "$PROOT_DISTRO" ]]; then
    IS_PROOT=true
fi

# ---- root ---------------------------------------------------------------
if [[ $(id -u) -eq 0 ]]; then
    IS_ROOT=true
fi

# ---- Termux: solo si estamos en el proceso real -------------------------
if [[ -n "$TERMUX_VERSION" ]] && [[ -d "/data/data/com.termux" ]] && [[ -f "/data/data/com.termux/files/usr/bin/pkg" ]]; then
    IS_TERMUX=true
    PKG_MANAGER="pkg"
    PYTHON_CMD="python"
    GEM_CMD="gem"
    PREFIX="/data/data/com.termux/files/usr"
elif [[ "$(uname)" == "Darwin" ]]; then
    IS_MAC=true
    if ! command -v brew >/dev/null; then
        echo "Instalando Homebrew..." >&2
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" >/dev/null 2>&1
    fi
    PKG_MANAGER="brew"
    PYTHON_CMD="python3"
    GEM_CMD="gem"
elif [[ -f /proc/version ]] && grep -qi microsoft /proc/version; then
    IS_WSL=true
    PKG_MANAGER="apt"
    PYTHON_CMD="python3"
    GEM_CMD="gem"
else
    # Linux genérico
    if command -v apt >/dev/null; then
        PKG_MANAGER="apt"
    elif command -v pacman >/dev/null; then
        PKG_MANAGER="pacman"
    elif command -v dnf >/dev/null; then
        PKG_MANAGER="dnf"
    elif command -v zypper >/dev/null; then
        PKG_MANAGER="zypper"
    else
        echo "Gestor de paquetes no soportado." >&2
        exit 1
    fi
    PYTHON_CMD="python3"
    GEM_CMD="gem"
fi

# ---- Instalar timeout en proot (silencioso) -----------------------------
if [[ "$IS_PROOT" == true ]] && ! command -v timeout >/dev/null; then
    apt update -qq >/dev/null 2>&1 && apt install -y coreutils >/dev/null 2>&1 || true
fi

# -------------------------------------------------------------------------
# FUNCIONES AUXILIARES (SILENCIOSAS)
# -------------------------------------------------------------------------

msg() {
    echo -e "\n[#] $1"
}

spinner="/|\\-/"

show_spinner() {
    local pid=$1
    local text=$2
    local i=0
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) % 4 ))
        printf "\r[ Spinning ] %s ${spinner:$i:1}" "$text"
        sleep 0.2
    done
    printf "\r[ Checkmark ] %s completado.          \n"
}

install_pkg() {
    local pkg=$1
    local name=${2:-$pkg}

    if command -v "$pkg" >/dev/null 2>&1; then
        echo "[ Checkmark ] $name ya está instalado."
        return
    fi

    msg "Instalando $name..."

    case $PKG_MANAGER in
        pkg)
            pkg install -y "$pkg" >/dev/null 2>&1 &
            ;;
        apt)
            if [[ "$IS_PROOT" == true ]] && [[ "$IS_ROOT" == true ]]; then
                timeout 180 apt install -y "$pkg" >/dev/null 2>&1 &
            else
                timeout 180 sudo apt install -y "$pkg" >/dev/null 2>&1 &
            fi
            ;;
        pacman)
            sudo pacman -Sy --noconfirm "$pkg" >/dev/null 2>&1 &
            ;;
        dnf)
            sudo dnf install -y "$pkg" >/dev/null 2>&1 &
            ;;
        zypper)
            sudo zypper install -y --no-confirm "$pkg" >/dev/null 2>&1 &
            ;;
        brew)
            brew install "$pkg" >/dev/null 2>&1 &
            ;;
    esac

    show_spinner $! "Instalación de $name"
}

install_pip() {
    local pkg=$1
    if $PYTHON_CMD -m pip show "$pkg" >/dev/null 2>&1; then
        echo "[ Checkmark ] $pkg (pip) ya está instalado."
    else
        msg "Instalando $pkg via pip..."
        $PYTHON_CMD -m pip install --user "$pkg" >/dev/null 2>&1 &
        show_spinner $! "Instalación de $pkg (pip)"
    fi
}

install_gem() {
    local pkg=$1
    if command -v "$pkg" >/dev/null 2>&1; then
        echo "[ Checkmark ] $pkg (gem) ya está instalado."
    else
        msg "Instalando $pkg via gem..."
        $GEM_CMD install "$pkg" --no-document >/dev/null 2>&1 &
        show_spinner $! "Instalación de $pkg (gem)"
    fi
}

# -------------------------------------------------------------------------
# ACTUALIZACIÓN DEL SISTEMA (SILENCIOSA)
# -------------------------------------------------------------------------

clear
echo "[ # ] Actualizando sistema..."

update_system() {
    case $PKG_MANAGER in
        pkg)
            pkg update -y >/dev/null 2>&1
            ;;
        apt)
            if [[ "$IS_PROOT" == true ]] && [[ "$IS_ROOT" == true ]]; then
                timeout 60 apt update -y >/dev/null 2>&1 || true
            else
                timeout 60 sudo apt update -y >/dev/null 2>&1 || true
            fi
            ;;
        pacman) sudo pacman -Sy --noconfirm >/dev/null 2>&1 ;;
        dnf) sudo dnf check-update >/dev/null 2>&1 ;;
        zypper) sudo zypper refresh --no-confirm >/dev/null 2>&1 ;;
        brew) brew update >/dev/null 2>&1 ;;
    esac
}

update_system &
show_spinner $! "Actualizando sistema"
wait $!

# -------------------------------------------------------------------------
# PAQUETES BÁSICOS (SILENCIOSOS)
# -------------------------------------------------------------------------

install_pkg git "Git"
install_pkg python3 "Python" || install_pkg python "Python"
install_pkg ruby "Ruby"
install_pkg figlet "Figlet"
install_pkg bc "BC"
install_pkg curl "Curl"

install_pip pyfiglet

if [[ "$IS_MAC" == true ]] || [[ "$IS_TERMUX" == true ]]; then
    install_gem lolcat
else
    install_pkg lolcat "lolcat" 2>/dev/null || install_gem lolcat
fi

# -------------------------------------------------------------------------
# VISUAL
# -------------------------------------------------------------------------

clear
if command -v pyfiglet >/dev/null && command -v lolcat >/dev/null; then
    figlet_text=$(pyfiglet "Custom-SetUp" 2>/dev/null)
    echo "$figlet_text" | head -n -1 | lolcat
    last_line=$(echo "$figlet_text" | tail -n 1)
    echo -e "$(echo "$last_line" | lolcat -f) v1.4.0"
else
    echo "=== Custom-SetUp v1.4.0 ==="
fi

if command -v lolcat >/dev/null; then
    echo "Entorno base listo, iniciando instalación..." | lolcat
else
    echo "Entorno base listo, iniciando instalación..."
fi

# -------------------------------------------------------------------------
# DIRECTORIOS
# -------------------------------------------------------------------------

msg "Creando carpetas de proyectos..."
mkdir -p ~/Practice_Projects/{Python_Projects,Nodejs_Projects,Java_Projects,C++_Projects,Ruby_Projects,Web_Projects} 2>/dev/null || true
echo "[ Checkmark ] Directorios creados."

# -------------------------------------------------------------------------
# OH MY ZSH (SILENCIOSO)
# -------------------------------------------------------------------------

ZSH="${ZSH:-$HOME/.oh-my-zsh}"

msg "Instalando Oh My Zsh..."
if [ ! -d "$ZSH" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended >/dev/null 2>&1
    echo "[ Checkmark ] Oh My Zsh instalado."
else
    echo "[ Checkmark ] Oh My Zsh ya está instalado."
fi

msg "Instalando plugins de Zsh..."
for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
    if [ ! -d "$ZSH/custom/plugins/$plugin" ]; then
        git clone "https://github.com/zsh-users/$plugin" "$ZSH/custom/plugins/$plugin" >/dev/null 2>&1
    fi
done
echo "[ Checkmark ] Plugins instalados."

# -------------------------------------------------------------------------
# CONFIGURACIONES
# -------------------------------------------------------------------------

msg "Copiando configuraciones..."
CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/config"

[ -f "$CONFIG_DIR/copia_zshrc.txt" ] && cp "$CONFIG_DIR/copia_zshrc.txt" "$HOME/.zshrc" >/dev/null 2>&1
[ -f "$CONFIG_DIR/copia_nanorc.txt" ] && cp "$CONFIG_DIR/copia_nanorc.txt" "$HOME/.nanorc" >/dev/null 2>&1
echo "[ Checkmark ] Configuraciones copiadas."

# -------------------------------------------------------------------------
# LIMPIAR MOTD (solo Termux)
# -------------------------------------------------------------------------

if [[ "$IS_TERMUX" == true ]] && [[ -f "$PREFIX/etc/motd" ]]; then
    msg "Limpiando MOTD de Termux..."
    > "$PREFIX/etc/motd" 2>/dev/null
    echo "[ Checkmark ] MOTD limpiado."
fi

# -------------------------------------------------------------------------
# WEBSERVE
# -------------------------------------------------------------------------

read -p "[ # ] ¿Desea instalar el comando 'webserve'? [Y/n]: " install_webserve
if [[ "$install_webserve" =~ ^[Yy]$ || -z "$install_webserve" ]]; then
    BIN_DIR="$HOME/.local/bin"
    mkdir -p "$BIN_DIR" 2>/dev/null
    if [[ "$IS_TERMUX" == true ]]; then
        cp "$CONFIG_DIR/copia_webserve.txt" "$PREFIX/bin/webserve" >/dev/null 2>&1
        chmod +x "$PREFIX/bin/webserve"
    else
        cp "$CONFIG_DIR/copia_webserve.txt" "$BIN_DIR/webserve" >/dev/null 2>&1
        chmod +x "$BIN_DIR/webserve"
        [[ ":$PATH:" != *":$BIN_DIR:"* ]] && echo "export PATH=\"\$PATH:$BIN_DIR\"" >> "$HOME/.zshrc"
    fi
    echo "[ Checkmark ] webserve instalado."
else
    echo "[ Cross ] webserve omitido."
fi

# -------------------------------------------------------------------------
# LENGUAJES
# -------------------------------------------------------------------------

msg "Configurando lenguajes..."

declare -A languages=(
    ["PHP"]="php"
    ["Node.js"]="nodejs"
    ["Java"]="openjdk-17 default-jdk"
    ["clang (C/C++)"]="clang gcc"
    ["Ruby"]="ruby"
)

for name in "${!languages[@]}"; do
    pkgs="${languages[$name]}"
    read -p "[#] ¿Instalar $name? [Y/n]: " answer
    if [[ "$answer" =~ ^[Yy]$ || -z "$answer" ]]; then
        for pkg in $pkgs; do
            install_pkg "$pkg" "$name"
        done
    else
        echo "[ Cross ] $name omitido."
    fi
done

# -------------------------------------------------------------------------
# FINAL
# -------------------------------------------------------------------------

clear
if command -v pyfiglet >/dev/null; then
    $PYTHON_CMD -m pyfiglet "Setup Complete" 2>/dev/null | lolcat 2>/dev/null || echo "=== Setup Complete ==="
else
    echo "=== Setup Complete ==="
fi

echo "Instalación finalizada."
echo

# ---- Asegurar zsh -------------------------------------------------------
if ! command -v zsh >/dev/null; then
    msg "Instalando zsh..."
    install_pkg zsh "Zsh"
fi

# ---- Cambiar shell (solo fuera de proot) -------------------------------
if command -v chsh >/dev/null && [[ "$IS_PROOT" == false ]]; then
    chsh -s "$(which zsh)" "$USER" 2>/dev/null || true
fi

# ---- Mensaje final ------------------------------------------------------
echo "=============================================="
if [[ "$IS_PROOT" == true ]]; then
    if [[ "$IS_ROOT" == true ]]; then
        echo "Estás como root. Ejecuta:"
        echo "   zsh"
    else
        echo "Ejecuta:"
        echo "   proot-distro login debian --user $USER --shell zsh"
    fi
else
    echo "Reinicia tu terminal o escribe: zsh"
fi
echo "=============================================="
echo

sleep 2

# ---- Reiniciar shell ----------------------------------------------------
if command -v zsh >/dev/null; then
    exec zsh -l
else
    exec bash -l
fi
