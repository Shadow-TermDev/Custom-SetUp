#!/usr/bin/env bash
# ╔═══════════════════════════════════════════════════════════╗
# ║   Custom-SetUp v1.5.0 – ULTRA ESTÉTICO para Termux        ║
# ║   by Grok + Shadow-TermDev | 100% Zsh + Oh My Zsh         ║
# ╚═══════════════════════════════════════════════════════════╝

set -e

# -------------------------------------------------------------------------
# VERIFICACIÓN TERMUX
# -------------------------------------------------------------------------

[[ -z "$TERMUX_VERSION" ]] && { 
    echo -e "\e[31m✗ Este script SOLO funciona en Termux.\e[0m"; exit 1; 
}

PKG_MANAGER="pkg"
PYTHON_CMD="python"
PREFIX="/data/data/com.termux/files/usr"
ZSH_PATH="$PREFIX/bin/zsh"

# -------------------------------------------------------------------------
# EFECTOS VISUALES
# -------------------------------------------------------------------------

banner() {
    $PYTHON_CMD -c "import pyfiglet; print(pyfiglet.figlet_format('$1'))" 2>/dev/null | lolcat -f || echo "=== $1 ==="
}

msg() {
    echo -e "\n\e[36m[#]\e[0m \e[1;35m$1\e[0m" | lolcat -f
}

success() {
    echo -e "\e[32m[✓] $1\e[0m" | lolcat -f
}

spinner="/|\\-/"
show_spinner() {
    local pid=$1 text=$2 i=0
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) % 4 ))
        printf "\r\e[33m[Spinning] %s ${spinner:$i:1}\e[0m" "$text" | lolcat -f
        sleep 0.15
    done
    printf "\r\e[32m[Checkmark] %s completado!          \e[0m\n" "$text" | lolcat -f
}

install_pkg() {
    local pkg=$1 name=${2:-$pkg}
    command -v "$pkg" >/dev/null 2>&1 && { success "$name ya está instalado."; return; }
    msg "Instalando $name..."
    pkg install -y "$pkg" >/dev/null 2>&1 &
    show_spinner $! "$name"
}

install_pip() {
    local pkg=$1
    $PYTHON_CMD -m pip show "$pkg" >/dev/null 2>&1 && { success "$pkg (pip) ya está."; return; }
    msg "Instalando $pkg via pip..."
    $PYTHON_CMD -m pip install --user "$pkg" >/dev/null 2>&1 &
    show_spinner $! "$pkg (pip)"
}

install_gem() {
    local pkg=$1
    command -v "$pkg" >/dev/null 2>&1 && { success "$pkg (gem) ya está."; return; }
    msg "Instalando $pkg via gem..."
    gem install "$pkg" --no-document >/dev/null 2>&1 &
    show_spinner $! "$pkg (gem)"
}

# -------------------------------------------------------------------------
# INICIO ESTÉTICO
# -------------------------------------------------------------------------

clear
banner "CUSTOM SETUP"
echo -e "\e[1;34m      v1.5.0 – Ultra Estético para Termux\e[0m" | lolcat -f
echo -e "\e[1;33m      Iniciando instalación mágica...\e[0m" | lolcat -f
sleep 2

# -------------------------------------------------------------------------
# ACTUALIZACIÓN
# -------------------------------------------------------------------------

clear
banner "UPDATE"
msg "Actualizando sistema Termux..."
pkg update -y >/dev/null 2>&1 &
show_spinner $! "Sistema"
success "¡Sistema actualizado!"

# -------------------------------------------------------------------------
# PAQUETES BÁSICOS
# -------------------------------------------------------------------------

clear
banner "PAQUETES"
install_pkg git "Git"
install_pkg python "Python"
install_pkg ruby "Ruby"
install_pkg figlet "Figlet"
install_pkg bc "BC"
install_pkg curl "Curl"
install_pkg zsh "Zsh"
install_pip pyfiglet
install_gem lolcat

# -------------------------------------------------------------------------
# DIRECTORIOS
# -------------------------------------------------------------------------

msg "Creando carpetas de proyectos..."
mkdir -p ~/Practice_Projects/{Python_Projects,Nodejs_Projects,Java_Projects,C++_Projects,Ruby_Projects,Web_Projects} 2>/dev/null
success "¡Carpetas listas!"

# -------------------------------------------------------------------------
# OH MY ZSH
# -------------------------------------------------------------------------

clear
banner "OH MY ZSH"
ZSH="$HOME/.oh-my-zsh"
if [ ! -d "$ZSH" ]; then
    msg "Clonando Oh My Zsh..."
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$ZSH" >/dev/null 2>&1 &
    show_spinner $! "Oh My Zsh"
    cp "$ZSH/templates/zshrc.zsh-template" "$HOME/.zshrc"
    success "¡Oh My Zsh instalado!"
else
    success "Oh My Zsh ya está listo."
fi

# -------------------------------------------------------------------------
# PLUGINS
# -------------------------------------------------------------------------

msg "Instalando plugins mágicos..."
PLUG_DIR="$ZSH/custom/plugins"
for p in zsh-autosuggestions zsh-syntax-highlighting; do
    [ ! -d "$PLUG_DIR/$p" ] && git clone https://github.com/zsh-users/$p "$PLUG_DIR/$p" >/dev/null 2>&1 &
done
wait
sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$HOME/.zshrc" 2>/dev/null || \
    echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' >> "$HOME/.zshrc"
success "¡Plugins activados!"

# -------------------------------------------------------------------------
# CONFIGURACIONES
# -------------------------------------------------------------------------

CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/config"
[ -f "$CONFIG_DIR/copia_zshrc.txt" ] && cp "$CONFIG_DIR/copia_zshrc.txt" "$HOME/.zshrc"
[ -f "$CONFIG_DIR/copia_nanorc.txt" ] && cp "$CONFIG_DIR/copia_nanorc.txt" "$HOME/.nanorc"
[ -f "$PREFIX/etc/motd" ] && > "$PREFIX/etc/motd" 2>/dev/null
success "Configuraciones aplicadas."

# -------------------------------------------------------------------------
# WEBSERVE
# -------------------------------------------------------------------------

read -p $'\e[36m[#] ¿Instalar comando webserve? [Y/n]: \e[0m' ans
if [[ "$ans" =~ ^[Yy]$ || -z "$ans" ]]; then
    if [ -f "$CONFIG_DIR/copia_webserve.txt" ]; then
        cp "$CONFIG_DIR/copia_webserve.txt" "$PREFIX/bin/webserve" && chmod +x "$PREFIX/bin/webserve"
        success "¡webserve instalado!"
    else
        echo -e "\e[31m[Cross] copia_webserve.txt no encontrado.\e[0m" | lolcat -f
    fi
fi

# -------------------------------------------------------------------------
# LENGUAJES
# -------------------------------------------------------------------------

clear
banner "LENGUAJES"
declare -A langs=(
    ["PHP"]="php"
    ["Node.js"]="nodejs"
    ["Java"]="openjdk-17"
    ["C/C++"]="clang"
    ["Ruby"]="ruby"
)
for name in "${!langs[@]}"; do
    read -p $'\e[36m[#] ¿Instalar \e[1m'"$name"$'?\e[0m [Y/n]: \e[0m' ans
    if [[ "$ans" =~ ^[Yy]$ || -z "$ans" ]]; then
        for pkg in ${langs[$name]}; do
            install_pkg "$pkg" "$name"
        done
    else
        echo -e "\e[33m[Cross] $name omitido.\e[0m" | lolcat -f
    fi
done

# -------------------------------------------------------------------------
# ZSH POR DEFECTO (RUTA COMPLETA)
# -------------------------------------------------------------------------

msg "Configurando Zsh como shell predeterminado..."
mkdir -p ~/.termux
printf "shell=%s\n" "$ZSH_PATH" > ~/.termux/termux.properties
success "¡Zsh configurado!"

# -------------------------------------------------------------------------
# FINAL ESTÉTICO
# -------------------------------------------------------------------------

clear
banner "COMPLETADO"
echo -e "\e[1;32m      ¡Instalación mágica finalizada!\e[0m" | lolcat -f
echo
echo -e "\e[1;36m╔═══════════════════════════════════════════╗\e[0m" | lolcat -f
echo -e "\e[1;36m║   CIERRA TERMUX COMPLETAMENTE (Salir)     ║\e[0m" | lolcat -f
echo -e "\e[1;36m║   LUEGO ÁBRELO DE NUEVO                   ║\e[0m" | lolcat -f
echo -e "\e[1;36m║   Zsh + Oh My Zsh SE CARGARÁ AUTOMÁTICO   ║\e[0m" | lolcat -f
echo -e "\e[1;36m╚═══════════════════════════════════════════╝\e[0m" | lolcat -f
echo
echo -e "\e[1;33m      ¡Disfruta tu nuevo Termux! ✨\e[0m" | lolcat -f

sleep 6

# Iniciar Zsh
exec "$ZSH_PATH" -l
