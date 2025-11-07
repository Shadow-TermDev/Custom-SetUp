
#!/data/data/com.termux/files/usr/bin/bash
# 🌌 Termux Setup Script by Erick Córdoba
# Instalador automatizado para entornos de desarrollo en Termux

set -e

# ---------------------------
# FUNCIONES BÁSICAS
# ---------------------------

msg() {
    echo -e "\n[#] $1"
}

safe_install() {
    local pkg=$1
    if ! command -v "$pkg" >/dev/null 2>&1; then
        msg "Instalando $pkg..."
        pkg install -y "$pkg" > /dev/null 2>&1
        echo "[ ✔ ] $pkg instalado correctamente."
    else
        echo "[ ✔ ] $pkg ya está instalado."
    fi
}

spinner="/|\\-/"

show_spinner() {
    local pid=$1
    local text=$2
    local i=0
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) %4 ))
        printf "\r[ 🔄 ] %s ${spinner:$i:1}" "$text"
        sleep 0.2
    done
    echo -e "\r[ ✔ ] $text completado.          "
}

# ---------------------------
# INICIO DE INSTALACIÓN
# ---------------------------

clear
echo "[ # ] Descargando paquetes esenciales..."
pkg update -y > /dev/null 2>&1
pkg upgrade -y > /dev/null 2>&1

safe_install git
safe_install python
safe_install ruby
safe_install figlet
safe_install bc
safe_install curl

# Instalar pyfiglet (Python)
if ! python -m pip show pyfiglet >/dev/null 2>&1; then
    msg "Instalando pyfiglet..."
    python -m pip install pyfiglet > /dev/null 2>&1
    echo "[ ✔ ] pyfiglet instalado correctamente."
else
    echo "[ ✔ ] pyfiglet ya está instalado."
fi

# Instalar lolcat (Ruby)
if ! command -v lolcat >/dev/null 2>&1; then
    msg "Instalando lolcat..."
    gem install lolcat --no-document > /dev/null 2>&1
    echo "[ ✔ ] lolcat instalado correctamente."
else
    echo "[ ✔ ] lolcat ya está instalado."
fi

# ---------------------------
# VISUAL READY
# ---------------------------
clear
python -m pyfiglet "Custom-SetUp" | lolcat
echo "✨ Entorno base listo, iniciando instalación..." | lolcat
echo

# ---------------------------
# CREAR DIRECTORIOS DE PROYECTOS
# ---------------------------
msg "Creando carpetas de proyectos..." | lolcat
mkdir -p ~/Practice_Projects/{Python_Projects,Nodejs_Projects,Java_Projects,C++_Projects,Ruby_Projects,Web_Projects}
echo "[ ✔ ] Directorios creados correctamente."

# ---------------------------
# INSTALAR OH MY ZSH Y PLUGINS
# ---------------------------
msg "Instalando Oh My Zsh..." | lolcat
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended > /dev/null 2>&1
    echo "[ ✔ ] Oh My Zsh instalado."
else
    echo "[ ✔ ] Oh My Zsh ya está instalado."
fi

msg "Instalando plugins de Zsh..." | lolcat
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions > /dev/null 2>&1
fi
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting > /dev/null 2>&1
fi
echo "[ ✔ ] Plugins instalados correctamente."

# ---------------------------
# COPIAR CONFIGURACIONES
# ---------------------------
msg "Copiando configuraciones..." | lolcat
cp config/copia_zshrc.txt ~/.zshrc
cp config/copia_nanorc.txt ~/.nanorc
echo "[ ✔ ] Archivos de configuración copiados."

# ---------------------------
# LIMPIAR MOTD (mensaje de bienvenida de Termux)
# ---------------------------
msg "Limpiando mensaje MOTD..." | lolcat
if [ -f "/data/data/com.termux/files/usr/etc/motd" ]; then
    > /data/data/com.termux/files/usr/etc/motd
    echo "[ ✔ ] MOTD limpiado correctamente."
fi

# ---------------------------
# OPCIÓN DE INSTALAR WEBSERVE
# ---------------------------
read -p "[ # ] ¿Desea instalar el comando 'webserve'? [Y/n]: " install_webserve
if [[ "$install_webserve" =~ ^[Yy]$ || -z "$install_webserve" ]]; then
    cp config/copia_webserve.txt /data/data/com.termux/files/usr/bin/webserve
    chmod +x /data/data/com.termux/files/usr/bin/webserve
    echo "[ ✔ ] webserve instalado correctamente."
else
    echo "[ ✖ ] webserve no instalado (por elección del usuario)."
fi

# ---------------------------
# INSTALACIÓN DE LENGUAJES Y TECNOLOGÍAS
# ---------------------------
msg "Configurando instalación de lenguajes y tecnologías..." | lolcat

declare -A languages=(
    ["PHP"]="php"
    ["Node.js"]="nodejs"
    ["Java"]="openjdk-17"
    ["clang (C/C++)"]="clang"
    ["Ruby"]="ruby"
)

for name in "${!languages[@]}"; do
    pkg_name="${languages[$name]}"
    read -p "[#] ¿Desea instalar $name? [Y/n]: " answer
    if [[ "$answer" =~ ^[Yy]$ || -z "$answer" ]]; then
        msg "Instalando $name..."
        pkg install -y "$pkg_name" > /dev/null 2>&1 &
        show_spinner $! "Instalación de $name" | lolcat
    else
        echo "[ ✖ ] $name omitido por el usuario."
    fi
done

# ---------------------------
# FINALIZACIÓN Y REINICIO
# ---------------------------
clear
python -m pyfiglet "Setup Complete" | lolcat
echo "✅ Instalación finalizada correctamente." | lolcat
echo "♻️  Aplicando cambios y reiniciando shell..." | lolcat
sleep 2
exec zsh
