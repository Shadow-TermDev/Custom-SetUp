#!/usr/bin/env bash
# ╔═══════════════════════════════════════════════════════════╗
# ║   Custom-SetUp v2.0.0 – Ultra Aesthetic for Termux       ║
# ║   by Shadow-TermDev | 100% Zsh + Oh My Zsh               ║
# ╚═══════════════════════════════════════════════════════════╝

set -e

# -------------------------------------------------------------------------
# COLORES Y CONSTANTES
# -------------------------------------------------------------------------

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

readonly PKG_MANAGER="pkg"
readonly PYTHON_CMD="python"
readonly PREFIX="/data/data/com.termux/files/usr"
readonly ZSH_PATH="$PREFIX/bin/zsh"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_DIR="$SCRIPT_DIR/config"

# Usar directorio seguro para logs
mkdir -p "$HOME/.cache"
readonly LOG_FILE="$HOME/.cache/custom-setup.log"

# -------------------------------------------------------------------------
# VERIFICACIÓN TERMUX
# -------------------------------------------------------------------------

if [[ -z "$TERMUX_VERSION" ]]; then
    echo -e "${RED}✗ Este script SOLO funciona en Termux.${NC}"
    echo -e "${YELLOW}  Descarga Termux desde F-Droid: https://f-droid.org/en/packages/com.termux/${NC}"
    exit 1
fi

# -------------------------------------------------------------------------
# FUNCIONES DE LOGGING
# -------------------------------------------------------------------------

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE" 2>/dev/null || true
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" >> "$LOG_FILE" 2>/dev/null || true
}

# -------------------------------------------------------------------------
# FUNCIONES DE MENSAJES (SIN DEPENDENCIAS EXTERNAS)
# -------------------------------------------------------------------------

msg() {
    echo -e "\n${CYAN}[→]${NC} ${PURPLE}$1${NC}"
    log "MSG: $1"
}

success() {
    echo -e "${GREEN}[✓]${NC} $1"
    log "SUCCESS: $1"
}

error() {
    echo -e "${RED}[✗]${NC} $1"
    log_error "$1"
}

warning() {
    echo -e "${YELLOW}[!]${NC} $1"
    log "WARNING: $1"
}

info() {
    echo -e "${BLUE}[i]${NC} $1"
}

# Banner simple para inicio (sin dependencias)
simple_banner() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════╗"
    echo "║                                                       ║"
    echo "║              CUSTOM-SETUP v2.0.0                      ║"
    echo "║        Ultra Aesthetic Configuration for Termux      ║"
    echo "║                                                       ║"
    echo "╚═══════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Banner mejorado (con figlet y lolcat)
fancy_banner() {
    local text="$1"
    
    if command -v figlet >/dev/null 2>&1 && command -v lolcat >/dev/null 2>&1; then
        figlet -f standard "$text" 2>/dev/null | lolcat -f 2>/dev/null
    elif command -v figlet >/dev/null 2>&1; then
        echo -e "${CYAN}"
        figlet -f standard "$text" 2>/dev/null || simple_banner
        echo -e "${NC}"
    else
        echo -e "${CYAN}"
        echo "╔═══════════════════════════════════════════════════════╗"
        echo "║          $text"
        echo "╚═══════════════════════════════════════════════════════╝"
        echo -e "${NC}"
    fi
}

spinner_chars="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"

show_spinner() {
    local pid=$1
    local text=$2
    local i=0
    
    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i+1) % 10 ))
        printf "\r${YELLOW}[%s]${NC} %s..." "${spinner_chars:$i:1}" "$text"
        sleep 0.1
    done
    
    wait "$pid"
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        printf "\r${GREEN}[✓]${NC} %s completado!          \n" "$text"
        return 0
    else
        printf "\r${RED}[✗]${NC} %s falló!          \n" "$text"
        return 1
    fi
}

# -------------------------------------------------------------------------
# FUNCIONES DE INSTALACIÓN
# -------------------------------------------------------------------------

install_pkg() {
    local pkg=$1
    local name=${2:-$pkg}
    
    if command -v "$pkg" >/dev/null 2>&1; then
        success "$name ya está instalado"
        return 0
    fi
    
    msg "Instalando $name..."
    if pkg install -y "$pkg" >> "$LOG_FILE" 2>&1; then
        success "$name instalado correctamente"
        return 0
    else
        error "Fallo al instalar $name"
        return 1
    fi
}

install_pip() {
    local pkg=$1
    
    if $PYTHON_CMD -m pip show "$pkg" >/dev/null 2>&1; then
        success "$pkg (pip) ya está instalado"
        return 0
    fi
    
    msg "Instalando $pkg vía pip..."
    if $PYTHON_CMD -m pip install --user "$pkg" >> "$LOG_FILE" 2>&1; then
        success "$pkg (pip) instalado correctamente"
        return 0
    else
        error "Fallo al instalar $pkg (pip)"
        return 1
    fi
}

install_gem() {
    local pkg=$1
    
    if command -v "$pkg" >/dev/null 2>&1; then
        success "$pkg (gem) ya está instalado"
        return 0
    fi
    
    msg "Instalando $pkg vía gem..."
    if gem install "$pkg" --no-document >> "$LOG_FILE" 2>&1; then
        success "$pkg (gem) instalado correctamente"
        return 0
    else
        error "Fallo al instalar $pkg (gem)"
        return 1
    fi
}

# -------------------------------------------------------------------------
# HEADER INFORMATIVO (CON BANNERS MEJORADOS)
# -------------------------------------------------------------------------

show_header() {
    clear
    
    if command -v figlet >/dev/null 2>&1 && command -v lolcat >/dev/null 2>&1; then
        echo "CUSTOM SETUP" | figlet -f standard 2>/dev/null | lolcat -f 2>/dev/null || simple_banner
    else
        simple_banner
    fi
    
    echo -e "${WHITE}                    Custom-SetUp v2.0.0${NC}"
    echo -e "${PURPLE}            Ultra Aesthetic Configuration for Termux${NC}"
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}  Características:${NC}"
    echo -e "${WHITE}    • Zsh + Oh My Zsh con plugins esenciales${NC}"
    echo -e "${WHITE}    • Configuración estética y productiva${NC}"
    echo -e "${WHITE}    • Estructura de proyectos organizada${NC}"
    echo -e "${WHITE}    • Soporte para múltiples lenguajes${NC}"
    echo ""
    echo -e "${YELLOW}  Creado por:${NC} ${GREEN}Shadow-TermDev${NC}"
    echo -e "${YELLOW}  GitHub:${NC} ${BLUE}https://github.com/Shadow-TermDev/Custom-SetUp${NC}"
    echo -e "${YELLOW}  Web:${NC} ${BLUE}https://Shadow-TermDev.github.io${NC}"
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    read -p "$(echo -e ${GREEN}Presiona ENTER para continuar...${NC})" 
}

# -------------------------------------------------------------------------
# INICIO
# -------------------------------------------------------------------------

# Limpiar log anterior
> "$LOG_FILE" 2>/dev/null || touch "$LOG_FILE"
log "=== Custom-SetUp v2.0.0 - Inicio de instalación ==="

# Mostrar banner simple inicial
clear
simple_banner
echo ""
echo -e "${YELLOW}Iniciando instalación...${NC}"
echo ""

# -------------------------------------------------------------------------
# FASE 1: RECURSOS BÁSICOS (PRIORIDAD MÁXIMA)
# -------------------------------------------------------------------------

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}FASE 1: Instalando recursos básicos necesarios...${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

msg "Actualizando repositorios..."
pkg update -y >> "$LOG_FILE" 2>&1 &
show_spinner $! "Actualización de repositorios"

# Paquetes esenciales para banners y estética
msg "Instalando herramientas de visualización..."

install_pkg python "Python"
install_pkg ruby "Ruby"
install_pkg figlet "Figlet"
install_pkg bc "BC"

# Instalar dependencias Python y Ruby para banners
if command -v python >/dev/null 2>&1; then
    install_pip pyfiglet
fi

if command -v ruby >/dev/null 2>&1 && command -v gem >/dev/null 2>&1; then
    install_gem lolcat
fi

success "¡Recursos básicos instalados!"
echo ""
echo -e "${GREEN}Ahora el instalador se verá más bonito 🎨${NC}"
sleep 2

# -------------------------------------------------------------------------
# ACTUALIZACIÓN DEL SISTEMA
# -------------------------------------------------------------------------

clear
fancy_banner "ACTUALIZACION"
echo ""

msg "Actualizando paquetes del sistema..."
pkg upgrade -y >> "$LOG_FILE" 2>&1 &
show_spinner $! "Actualización de paquetes"

success "Sistema actualizado correctamente"
sleep 1

# -------------------------------------------------------------------------
# AHORA SÍ, MOSTRAR HEADER COMPLETO
# -------------------------------------------------------------------------

show_header

# -------------------------------------------------------------------------
# FASE 2: PAQUETES ESENCIALES
# -------------------------------------------------------------------------

clear
fancy_banner "PAQUETES CORE"
echo ""

install_pkg git "Git"
install_pkg curl "Curl"
install_pkg wget "Wget"
install_pkg zsh "Zsh Shell"
install_pkg nano "Nano Editor"

success "Todos los paquetes esenciales instalados"
sleep 1

# -------------------------------------------------------------------------
# ESTRUCTURA DE PROYECTOS
# -------------------------------------------------------------------------

clear
fancy_banner "DIRECTORIOS"
echo ""

msg "Creando estructura de proyectos..."

PROJECTS_BASE="$HOME/Practice_Projects"
PROJECT_DIRS=(
    "Python_Projects"
    "Nodejs_Projects"
    "Java_Projects"
    "C++_Projects"
    "Ruby_Projects"
    "Web_Projects"
    "Scripts"
    "Tools"
)

for dir in "${PROJECT_DIRS[@]}"; do
    if mkdir -p "$PROJECTS_BASE/$dir" 2>/dev/null; then
        info "  ✓ $dir"
    fi
done

success "Estructura de proyectos creada en ~/Practice_Projects"
sleep 1

# -------------------------------------------------------------------------
# OH MY ZSH
# -------------------------------------------------------------------------

clear
fancy_banner "OH MY ZSH"
echo ""

ZSH_DIR="$HOME/.oh-my-zsh"

if [ -d "$ZSH_DIR" ]; then
    success "Oh My Zsh ya está instalado"
else
    msg "Instalando Oh My Zsh..."
    
    if git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$ZSH_DIR" >> "$LOG_FILE" 2>&1; then
        success "Oh My Zsh instalado correctamente"
        
        if [ -f "$ZSH_DIR/templates/zshrc.zsh-template" ]; then
            cp "$ZSH_DIR/templates/zshrc.zsh-template" "$HOME/.zshrc"
            info "  Archivo .zshrc creado"
        fi
    else
        error "Fallo al instalar Oh My Zsh"
    fi
fi

sleep 1

# -------------------------------------------------------------------------
# PLUGINS ZSH
# -------------------------------------------------------------------------

clear
fancy_banner "PLUGINS ZSH"
echo ""

PLUGINS_DIR="$ZSH_DIR/custom/plugins"

declare -A plugins=(
    ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions"
    ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting"
)

for plugin in "${!plugins[@]}"; do
    plugin_path="$PLUGINS_DIR/$plugin"
    
    if [ -d "$plugin_path" ]; then
        success "$plugin ya está instalado"
    else
        msg "Instalando $plugin..."
        if git clone --depth=1 "${plugins[$plugin]}" "$plugin_path" >> "$LOG_FILE" 2>&1; then
            success "$plugin instalado correctamente"
        else
            error "Fallo al instalar $plugin"
        fi
    fi
done

success "Todos los plugins instalados"
sleep 1

# -------------------------------------------------------------------------
# CONFIGURACIONES PERSONALIZADAS
# -------------------------------------------------------------------------

clear
fancy_banner "CONFIGURACION"
echo ""

msg "Aplicando configuraciones personalizadas..."

# Copiar .zshrc personalizado
if [ -f "$CONFIG_DIR/copia_zshrc.txt" ]; then
    cp "$CONFIG_DIR/copia_zshrc.txt" "$HOME/.zshrc"
    success "Configuración .zshrc aplicada"
else
    warning "Archivo copia_zshrc.txt no encontrado"
    
    # Configurar plugins manualmente
    if [ -f "$HOME/.zshrc" ]; then
        if grep -q "^plugins=" "$HOME/.zshrc"; then
            sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$HOME/.zshrc"
        else
            echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' >> "$HOME/.zshrc"
        fi
        info "  Plugins configurados manualmente"
    fi
fi

# Copiar .nanorc personalizado
if [ -f "$CONFIG_DIR/copia_nanorc.txt" ]; then
    cp "$CONFIG_DIR/copia_nanorc.txt" "$HOME/.nanorc"
    success "Configuración nano aplicada"
else
    warning "Archivo copia_nanorc.txt no encontrado"
fi

# Limpiar MOTD
if [ -f "$PREFIX/etc/motd" ]; then
    > "$PREFIX/etc/motd" 2>/dev/null && info "  MOTD limpiado" || true
fi

sleep 1

# -------------------------------------------------------------------------
# WEBSERVE
# -------------------------------------------------------------------------

clear
fancy_banner "WEBSERVE"
echo ""

echo -e "${CYAN}El comando 'webserve' permite iniciar un servidor HTTP + túnel público.${NC}"
echo -e "${WHITE}Útil para desarrollo web rápido.${NC}"
echo ""

read -p "$(echo -e ${YELLOW}¿Instalar comando webserve? [Y/n]: ${NC})" ans

if [[ "$ans" =~ ^[Yy]$ ]] || [[ -z "$ans" ]]; then
    if [ -f "$CONFIG_DIR/copia_webserve.txt" ]; then
        if cp "$CONFIG_DIR/copia_webserve.txt" "$PREFIX/bin/webserve" && chmod +x "$PREFIX/bin/webserve"; then
            success "Comando webserve instalado"
            info "  Uso: webserve [puerto]"
        else
            error "Fallo al instalar webserve"
        fi
    else
        warning "Archivo copia_webserve.txt no encontrado"
    fi
else
    info "Instalación de webserve omitida"
fi

sleep 1

# -------------------------------------------------------------------------
# LENGUAJES DE PROGRAMACIÓN
# -------------------------------------------------------------------------

clear
fancy_banner "LENGUAJES"
echo ""

echo -e "${CYAN}Instalación de lenguajes de programación adicionales${NC}"
echo ""

declare -A languages=(
    ["PHP"]="php"
    ["Node.js"]="nodejs"
    ["Java (OpenJDK 17)"]="openjdk-17"
    ["C/C++ (Clang)"]="clang"
    ["Go"]="golang"
)

for lang in "${!languages[@]}"; do
    echo ""
    read -p "$(echo -e ${YELLOW}¿Instalar $lang? [y/N]: ${NC})" ans
    
    if [[ "$ans" =~ ^[Yy]$ ]]; then
        install_pkg "${languages[$lang]}" "$lang"
    else
        info "$lang omitido"
    fi
done

sleep 1

# -------------------------------------------------------------------------
# PAQUETES EXTRAS ÚTILES
# -------------------------------------------------------------------------

clear
fancy_banner "UTILIDADES"
echo ""

echo -e "${CYAN}Paquetes adicionales recomendados${NC}"
echo ""

declare -A extras=(
    ["Vim"]="vim"
    ["Htop"]="htop"
    ["Tmux"]="tmux"
    ["Tree"]="tree"
    ["Eza (ls mejorado)"]="eza"
    ["Bat (cat mejorado)"]="bat"
)

read -p "$(echo -e ${YELLOW}¿Instalar paquetes de utilidades recomendados? [Y/n]: ${NC})" ans

if [[ "$ans" =~ ^[Yy]$ ]] || [[ -z "$ans" ]]; then
    for name in "${!extras[@]}"; do
        install_pkg "${extras[$name]}" "$name"
    done
else
    info "Instalación de utilidades omitida"
fi

sleep 1

# -------------------------------------------------------------------------
# CONFIGURAR ZSH COMO SHELL PREDETERMINADO
# -------------------------------------------------------------------------

clear
fancy_banner "SHELL CONFIG"
echo ""

msg "Configurando Zsh como shell predeterminado..."

mkdir -p "$HOME/.termux"

if echo "$ZSH_PATH" > "$HOME/.termux/shell" 2>/dev/null; then
    success "Zsh configurado como shell predeterminado"
else
    # Método alternativo
    if printf "shell=%s\n" "$ZSH_PATH" > "$HOME/.termux/termux.properties" 2>/dev/null; then
        success "Zsh configurado vía termux.properties"
    else
        warning "No se pudo configurar Zsh automáticamente"
        info "  Ejecuta manualmente: chsh -s zsh"
    fi
fi

sleep 1

# -------------------------------------------------------------------------
# FINALIZACIÓN
# -------------------------------------------------------------------------

clear

if command -v figlet >/dev/null 2>&1 && command -v lolcat >/dev/null 2>&1; then
    echo "COMPLETADO" | figlet -f standard 2>/dev/null | lolcat -f 2>/dev/null
else
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════════════════════╗"
    echo "║                                                       ║"
    echo "║              ✨ INSTALACIÓN COMPLETADA ✨             ║"
    echo "║                                                       ║"
    echo "╚═══════════════════════════════════════════════════════╝"
    echo -e "${NC}"
fi

echo ""
echo -e "${WHITE}  ✨ ¡Instalación completada exitosamente! ✨${NC}"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}  PRÓXIMOS PASOS:${NC}"
echo ""
echo -e "${WHITE}  1. ${GREEN}CIERRA TERMUX COMPLETAMENTE${NC}"
echo -e "${WHITE}     (No uses 'exit', cierra la app desde el sistema)${NC}"
echo ""
echo -e "${WHITE}  2. ${GREEN}VUELVE A ABRIR TERMUX${NC}"
echo -e "${WHITE}     Zsh + Oh My Zsh se cargarán automáticamente${NC}"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${PURPLE}  📁 Tus proyectos: ${WHITE}~/Practice_Projects/${NC}"
echo -e "${PURPLE}  📝 Log completo: ${WHITE}$LOG_FILE${NC}"
echo -e "${PURPLE}  🌐 Documentación: ${BLUE}https://Shadow-TermDev.github.io${NC}"
echo -e "${PURPLE}  💻 GitHub: ${BLUE}https://github.com/Shadow-TermDev${NC}"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}  ¡Gracias por usar Custom-SetUp! 🚀${NC}"
echo ""

log "=== Instalación completada exitosamente ==="

sleep 5

# Iniciar Zsh
if [ -f "$ZSH_PATH" ]; then
    exec "$ZSH_PATH" -l
fi
