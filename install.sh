#!/usr/bin/env bash
# Universal Setup Script - Works on Termux, Linux, macOS, WSL
# by Shadow-TermDev (adaptado por Grok)

set -e

# ---------------------------
# DETECCIÓN DE ENTORNO
# ---------------------------

IS_TERMUX=false
IS_MAC=false
IS_WSL=false
PKG_MANAGER=""
PYTHON_CMD=""
GEM_CMD=""

if [[ -n "$ANDROID_ROOT" ]] && [[ -d "/data/data/com.termux" ]]; then
    IS_TERMUX=true
    PKG_MANAGER="pkg"
    PYTHON_CMD="python"
    GEM_CMD="gem"
    PREFIX="/data/data/com.termux/files/usr"
elif [[ "$(uname)" == "Darwin" ]]; then
    IS_MAC=true
    if ! command -v brew >/dev/null; then
        echo "Instalando Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
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
        echo "Gestor de paquetes no soportado."
        exit 1
    fi
    PYTHON_CMD="python3"
    GEM_CMD="gem"
fi

# ---------------------------
# FUNCIONES
# ---------------------------

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
        printf "\r[ 🔄 ] %s ${spinner:$i:1}" "$text"
        sleep 0.2
    done
    printf "\r[ ✔ ] %s completado.          \n"
}

install_pkg() {
    local pkg=$1
    local name=${2:-$pkg}

    if command -v "$pkg" >/dev/null 2>&1; then
        echo "[ ✔ ] $name ya está instalado."
        return
    fi

    msg "Instalando $name..."

    case $PKG_MANAGER in
        pkg)
            pkg install -y "$pkg" > /dev/null 2>&1 &
            ;;
        apt)
            sudo apt update -qq > /dev/null 2>&1
            sudo apt install -y "$pkg" > /dev/null 2>&1 &
            ;;
        pacman)
            sudo pacman -Sy --noconfirm "$pkg" > /dev/null 2>&1 &
            ;;
        dnf)
            sudo dnf install -y "$pkg" > /dev/null 2>&1 &
            ;;
        zypper)
            sudo zypper install -y "$pkg" > /dev/null 2>&1 &
            ;;
        brew)
            brew install "$pkg" > /dev/null 2>&1 &
            ;;
    esac

    show_spinner $! "Instalación de $name"
}

install_pip() {
    local pkg=$1
    if $PYTHON_CMD -m pip show "$pkg" >/dev/null 2>&1; then
        echo "[ ✔ ] $pkg (pip) ya está instalado."
    else
        msg "Instalando $pkg via pip..."
        $PYTHON_CMD -m pip install --user "$pkg" > /dev/null 2>&1 &
        show_spinner $! "Instalación de $pkg (pip)"
    fi
}

install_gem() {
    local pkg=$1
    if command -v "$pkg" >/dev/null 2>&1; then
        echo "[ ✔ ] $pkg (gem) ya está instalado."
    else
        msg "Instalando $pkg via gem..."
        $GEM_CMD install "$pkg" --no-document > /dev/null 2>&1 &
        show_spinner $! "Instalación de $pkg (gem)"
    fi
}

# ---------------------------
# INICIO
# ---------------------------

clear
echo "[ # ] Actualizando sistema..."
case $PKG_MANAGER in
    pkg) pkg update -y > /dev/null 2>&1 ;;
    apt) sudo apt update -qq > /dev/null 2>&1 ;;
    pacman) sudo pacman -Sy --noconfirm > /dev/null 2>&1 ;;
    dnf) sudo dnf check-update > /dev/null 2>&1 ;;
    zypper) sudo zypper refresh > /dev/null 2>&1 ;;
    brew) brew update > /dev/null 2>&1 ;;
esac

# ---------------------------
# PAQUETES BÁSICOS
# ---------------------------

install_pkg git "Git"
install_pkg python3 "Python" || install_pkg python "Python"
install_pkg ruby "Ruby"
install_pkg figlet "Figlet"
install_pkg bc "BC"
install_pkg curl "Curl"

# pyfiglet
install_pip pyfiglet

# lolcat
if [[ "$IS_MAC" == true ]] || [[ "$IS_TERMUX" == true ]]; then
    install_gem lolcat
else
    # En Linux, lolcat suele estar en repos
    install_pkg lolcat "lolcat" 2>/dev/null || install_gem lolcat
fi

# ---------------------------
# VISUAL
# ---------------------------

clear
if command -v pyfiglet >/dev/null && command -v lolcat >/dev/null; then
    $PYTHON_CMD -m pyfiglet "Custom-SetUp" 2>/dev/null | lolcat
else
    echo "=== Custom-SetUp ==="
fi
echo "Entorno base listo, iniciando instalación..." | lolcat 2>/dev/null || echo "Entorno base listo..."

# ---------------------------
# DIRECTORIOS
# ---------------------------

msg "Creando carpetas de proyectos..."
mkdir -p ~/Practice_Projects/{Python_Projects,Nodejs_Projects,Java_Projects,C++_Projects,Ruby_Projects,Web_Projects}
echo "[ ✔ ] Directorios creados."

# ---------------------------
# OH MY ZSH
# ---------------------------

if [[ -z "$ZSH" ]]; then
    ZSH="$HOME/.oh-my-zsh"
fi

msg "Instalando Oh My Zsh..."
if [ ! -d "$ZSH" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended > /dev/null 2>&1
    echo "[ ✔ ] Oh My Zsh instalado."
else
    echo "[ ✔ ] Oh My Zsh ya está instalado."
fi

msg "Instalando plugins de Zsh..."
for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
    if [ ! -d "$ZSH/custom/plugins/$plugin" ]; then
        git clone "https://github.com/zsh-users/$plugin" "$ZSH/custom/plugins/$plugin" > /dev/null 2>&1
    fi
done
echo "[ ✔ ] Plugins instalados."

# ---------------------------
# CONFIGURACIONES
# ---------------------------

msg "Copiando configuraciones..."
CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/config"

if [ -f "$CONFIG_DIR/copia_zshrc.txt" ]; then
    cp "$CONFIG_DIR/copia_zshrc.txt" "$HOME/.zshrc"
fi
if [ -f "$CONFIG_DIR/copia_nanorc.txt" ]; then
    cp "$CONFIG_DIR/copia_nanorc.txt" "$HOME/.nanorc"
fi
echo "[ ✔ ] Configuraciones copiadas."

# ---------------------------
# LIMPIAR MOTD (solo Termux)
# ---------------------------

if [[ "$IS_TERMUX" == true ]] && [[ -f "$PREFIX/etc/motd" ]]; then
    msg "Limpiando MOTD de Termux..."
    > "$PREFIX/etc/motd"
    echo "[ ✔ ] MOTD limpiado."
fi

# ---------------------------
# WEBSERVE
# ---------------------------

read -p "[ # ] ¿Desea instalar el comando 'webserve'? [Y/n]: " install_webserve
if [[ "$install_webserve" =~ ^[Yy]$ || -z "$install_webserve" ]]; then
    BIN_DIR="$HOME/.local/bin"
    mkdir -p "$BIN_DIR"
    if [[ "$IS_TERMUX" == true ]]; then
        cp "$CONFIG_DIR/copia_webserve.txt" "$PREFIX/bin/webserve"
        chmod +x "$PREFIX/bin/webserve"
    else
        cp "$CONFIG_DIR/copia_webserve.txt" "$BIN_DIR/webserve"
        chmod +x "$BIN_DIR/webserve"
        [[ ":$PATH:" != *":$BIN_DIR:"* ]] && echo "export PATH=\"\$PATH:$BIN_DIR\"" >> "$HOME/.zshrc"
    fi
    echo "[ ✔ ] webserve instalado."
else
    echo "[ ✖ ] webserve omitido."
fi

# ---------------------------
# LENGUAJES
# ---------------------------

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
        echo "[ ✖ ] $name omitido."
    fi
done

# ---------------------------
# FINAL
# ---------------------------

clear
if command -v pyfiglet >/dev/null; then
    $PYTHON_CMD -m pyfiglet "Setup Complete" 2>/dev/null | lolcat 2>/dev/null || echo "=== Setup Complete ==="
else
    echo "=== Setup Complete ==="
fi

echo "Instalación finalizada."
echo "Reiniciando shell en 3 segundos..."

sleep 3

# Reiniciar shell si es posible
if [[ -n "$ZSH_VERSION" ]]; then
    exec zsh
elif [[ -n "$BASH_VERSION" ]]; then
    exec bash
else
    echo "Por favor, reinicia tu terminal."
fi
