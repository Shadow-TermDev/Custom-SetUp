#!/usr/bin/env bash
# Custom Setup Script – SOLO TERMUX (ZSH 100% FIJO)
# v1.4.3-termux-clean

set -e

[[ -z "$TERMUX_VERSION" ]] && { echo "Solo para Termux."; exit 1; }

PKG_MANAGER="pkg"
PYTHON_CMD="python"
PREFIX="/data/data/com.termux/files/usr"
ZSH_PATH="$PREFIX/bin/zsh"

msg() { echo -e "\n[#] $1"; }
show_spinner() {
    local pid=$1 text=$2 i=0
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) % 4 ))
        printf "\r[ Spinning ] %s ${spinner:$i:1}" "$text"
        sleep 0.2
    done
    printf "\r[ Checkmark ] %s completado.          \n"
}
spinner="/|\\-/"

install_pkg() {
    local pkg=$1 name=${2:-$pkg}
    command -v "$pkg" >/dev/null 2>&1 && { echo "[ Checkmark ] $name ya está."; return; }
    msg "Instalando $name..."
    pkg install -y "$pkg" >/dev/null 2>&1 &
    show_spinner $! "Instalación de $name"
}

install_pip() {
    local pkg=$1
    $PYTHON_CMD -m pip show "$pkg" >/dev/null 2>&1 && { echo "[ Checkmark ] $pkg (pip) ya está."; return; }
    msg "Instalando $pkg via pip..."
    $PYTHON_CMD -m pip install --user "$pkg" >/dev/null 2>&1 &
    show_spinner $! "Instalación de $pkg"
}

install_gem() {
    local pkg=$1
    command -v "$pkg" >/dev/null 2>&1 && { echo "[ Checkmark ] $pkg (gem) ya está."; return; }
    msg "Instalando $pkg via gem..."
    gem install "$pkg" --no-document >/dev/null 2>&1 &
    show_spinner $! "Instalación de $pkg"
}

clear
echo "[ # ] Actualizando..."
pkg update -y >/dev/null 2>&1 &
show_spinner $! "Actualizando"

install_pkg git
install_pkg python
install_pkg ruby
install_pkg figlet
install_pkg bc
install_pkg curl
install_pkg zsh "Zsh"

install_pip pyfiglet
install_gem lolcat

clear
if command -v pyfiglet >/dev/null; then
    pyfiglet "Custom-SetUp" | lolcat
    echo "v1.4.3-termux" | lolcat -f
else
    echo "=== Custom-SetUp v1.4.3 ==="
fi

msg "Creando carpetas..."
mkdir -p ~/Practice_Projects/{Python_Projects,Nodejs_Projects,Java_Projects,C++_Projects,Ruby_Projects,Web_Projects} 2>/dev/null

ZSH="$HOME/.oh-my-zsh"
if [ ! -d "$ZSH" ]; then
    msg "Instalando Oh My Zsh..."
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$ZSH" >/dev/null 2>&1
    cp "$ZSH/templates/zshrc.zsh-template" "$HOME/.zshrc"
fi

PLUG_DIR="$ZSH/custom/plugins"
for p in zsh-autosuggestions zsh-syntax-highlighting; do
    [ ! -d "$PLUG_DIR/$p" ] && git clone https://github.com/zsh-users/$p "$PLUG_DIR/$p" >/dev/null 2>&1
done

sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$HOME/.zshrc" 2>/dev/null || \
    echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' >> "$HOME/.zshrc"

CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/config"
[ -f "$CONFIG_DIR/copia_zshrc.txt" ] && cp "$CONFIG_DIR/copia_zshrc.txt" "$HOME/.zshrc"
[ -f "$CONFIG_DIR/copia_nanorc.txt" ] && cp "$CONFIG_DIR/copia_nanorc.txt" "$HOME/.nanorc"

[ -f "$PREFIX/etc/motd" ] && > "$PREFIX/etc/motd"

read -p "[ # ] ¿Instalar 'webserve'? [Y/n]: " ans
if [[ "$ans" =~ ^[Yy]$ || -z "$ans" ]]; then
    [ -f "$CONFIG_DIR/copia_webserve.txt" ] && cp "$CONFIG_DIR/copia_webserve.txt" "$PREFIX/bin/webserve" && chmod +x "$PREFIX/bin/webserve" && echo "[ Checkmark ] webserve instalado."
fi

msg "Lenguajes..."
declare -A langs=( ["PHP"]="php" ["Node.js"]="nodejs" ["Java"]="openjdk-17" ["C/C++"]="clang" ["Ruby"]="ruby" )
for name in "${!langs[@]}"; do
    read -p "[#] ¿Instalar $name? [Y/n]: " ans
    [[ "$ans" =~ ^[Yy]$ || -z "$ans" ]] && for pkg in ${langs[$name]}; do install_pkg "$pkg" "$name"; done
done

# ZSH POR DEFECTO (RUTA COMPLETA)
msg "Configurando Zsh como shell predeterminado..."
mkdir -p ~/.termux
printf "shell=%s\n" "$ZSH_PATH" > ~/.termux/termux.properties
echo "[ Checkmark ] Zsh configurado: $ZSH_PATH"

clear
pyfiglet "CIERRA Y ABRE" 2>/dev/null | lolcat 2>/dev/null || echo "=== CIERRA Y ABRE ==="
echo
echo "=============================================="
echo "   CIERRA TERMUX (Salir) → LUEGO ÁBRELO       "
echo "   Zsh + Oh My Zsh SE CARGARÁ AUTOMÁTICO      "
echo "=============================================="
sleep 5

exec "$ZSH_PATH" -l
