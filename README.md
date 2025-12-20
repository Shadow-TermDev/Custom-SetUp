# 🎨 Custom-SetUp

<div align="center">

![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)
![Termux](https://img.shields.io/badge/termux-only-green.svg)
![License](https://img.shields.io/badge/license-MIT-purple.svg)
![Shell](https://img.shields.io/badge/shell-zsh-orange.svg)

**Ultra Aesthetic Configuration for Termux**

Una configuración completamente personalizada y estética para Termux con Zsh, Oh My Zsh y múltiples optimizaciones.

[Características](#-características) •
[Instalación](#-instalación) •
[Configuración](#-configuración) •
[Uso](#-uso) •
[FAQ](#-faq)

</div>

---

## 📖 Descripción

Custom-SetUp es un script de instalación automatizado que transforma tu Termux en un entorno de desarrollo poderoso, organizado y visualmente atractivo. Incluye configuraciones preestablecidas, estructura de proyectos y herramientas esenciales.

## ✨ Características

### 🎯 Configuración Principal

- ✅ **Zsh + Oh My Zsh** - Shell moderna con autocompletado inteligente
- ✅ **Plugins Esenciales** - Autosuggestions y Syntax Highlighting
- ✅ **Tema Personalizado** - Interfaz limpia y colorida
- ✅ **Aliases Útiles** - Comandos optimizados para productividad

### 📁 Estructura de Proyectos

Crea automáticamente carpetas organizadas en `~/Practice_Projects/`:

```
Practice_Projects/
├── Python_Projects/
├── Nodejs_Projects/
├── Java_Projects/
├── C++_Projects/
├── Ruby_Projects/
├── Web_Projects/
├── Scripts/
└── Tools/
```

### 🛠️ Herramientas Incluidas

**Esenciales:**
- Git - Control de versiones
- Python - Con pip configurado
- Ruby - Con gems
- Curl/Wget - Descarga de archivos
- Figlet + Lolcat - Banners coloridos

**Opcionales:**
- PHP
- Node.js
- Java (OpenJDK 17)
- C/C++ (Clang)
- Go
- Vim/Nano
- Htop/Tree/Eza

### 🎨 Mejoras Visuales

- Interface colorida con códigos ANSI
- Spinners animados durante instalaciones
- Banners ASCII artísticos
- Logs limpios y organizados
- Mensajes informativos claros

## 🚀 Instalación

### Requisitos Previos

- **Termux** instalado (descarga desde [F-Droid](https://f-droid.org/en/packages/com.termux/))
- Conexión a Internet
- ~500MB de espacio libre

### Instalación Rápida

```bash
# 1. Actualiza Termux
pkg update && pkg upgrade -y

# 2. Instala Git
pkg install git -y

# 3. Clona el repositorio
git clone https://github.com/Shadow-TermDev/Custom-SetUp.git

# 4. Entra al directorio
cd Custom-SetUp

# 5. Da permisos de ejecución
chmod +x install.sh

# 6. Ejecuta el instalador
./install.sh
```

### Post-Instalación

1. **Cierra Termux completamente** (no uses `exit`, cierra la app)
2. **Vuelve a abrir Termux**
3. Zsh se cargará automáticamente
4. ¡Disfruta tu nuevo entorno!

## ⚙️ Configuración

### Archivos de Configuración

El script copia automáticamente las configuraciones desde `config/`:

| Archivo | Destino | Descripción |
|---------|---------|-------------|
| `copia_zshrc.txt` | `~/.zshrc` | Configuración de Zsh |
| `copia_nanorc.txt` | `~/.nanorc` | Configuración de Nano |
| `copia_webserve.txt` | `/usr/bin/webserve` | Servidor HTTP simple |

### Personalización

#### Cambiar Tema de Zsh

Edita `~/.zshrc` y modifica:

```bash
ZSH_THEME="robbyrussell"  # Cambia a tu tema favorito
```

Temas populares: `agnoster`, `powerlevel10k`, `spaceship`

#### Añadir Aliases

Edita `~/.zshrc` y añade:

```bash
alias mi_comando='comando_largo --con --opciones'
```

#### Instalar Plugins Adicionales

```bash
cd ~/.oh-my-zsh/custom/plugins
git clone https://github.com/usuario/plugin-name
```

Luego edita `~/.zshrc`:

```bash
plugins=(git zsh-autosuggestions zsh-syntax-highlighting plugin-name)
```

## 💻 Uso

### Comandos Principales

```bash
# Servidor web simple
webserve 8080

# Listar archivos estéticamente
ls
ll

# Actualizar Termux
update

# Limpiar cache
clean

# Ver tu IP pública
myip

# Crear directorio y entrar
mkcd nombre_carpeta
```

### Estructura de Trabajo

Organiza tus proyectos en las carpetas creadas:

```bash
cd ~/Practice_Projects/Python_Projects
# Trabaja en tus proyectos Python

cd ~/Practice_Projects/Web_Projects
# Desarrolla tus sitios web
```

## 📝 Logs

Los logs de instalación se guardan en:

```
~/.cache/custom-setup.log
```

Para ver errores:

```bash
cat ~/.cache/custom-setup.log | grep ERROR
```

Para ver todo el log:

```bash
cat ~/.cache/custom-setup.log
```

## 🔧 Solución de Problemas

### Zsh no se inicia automáticamente

```bash
# Verifica la configuración
cat ~/.termux/shell

# Si está vacío, ejecuta:
echo "/data/data/com.termux/files/usr/bin/zsh" > ~/.termux/shell
```

### Plugins no funcionan

```bash
# Reinstala los plugins
cd ~/.oh-my-zsh/custom/plugins
rm -rf zsh-*
git clone https://github.com/zsh-users/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting

# Recarga la configuración
source ~/.zshrc
```

### Errores de permisos

```bash
# Da permisos al script
chmod +x install.sh

# Si persiste el error
termux-setup-storage
```

### Lolcat/Figlet no funcionan

```bash
# Reinstala las dependencias
pkg install ruby python -y
gem install lolcat
pip install pyfiglet
```

## 🤝 Contribuir

¡Las contribuciones son bienvenidas!

1. Fork el proyecto
2. Crea una rama (`git checkout -b feature/mejora`)
3. Commit tus cambios (`git commit -m 'Añadir mejora'`)
4. Push a la rama (`git push origin feature/mejora`)
5. Abre un Pull Request

### Reportar Bugs

Abre un [Issue](https://github.com/Shadow-TermDev/Custom-SetUp/issues) con:

- Descripción del problema
- Pasos para reproducir
- Logs relevantes
- Versión de Termux

## 📚 Recursos Adicionales

- [Documentación de Termux](https://wiki.termux.com/)
- [Oh My Zsh Docs](https://github.com/ohmyzsh/ohmyzsh/wiki)
- [Zsh Guide](https://zsh.sourceforge.io/Guide/)
- [Shadow-TermDev GitHub](https://github.com/Shadow-TermDev)

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo [LICENSE](LICENSE) para más detalles.

## 👤 Autor

**Shadow-TermDev**

- 🌐 Website: [Shadow-TermDev.github.io](https://Shadow-TermDev.github.io)
- 💻 GitHub: [@Shadow-TermDev](https://github.com/Shadow-TermDev)
- 📧 Issues: [Reportar problema](https://github.com/Shadow-TermDev/Custom-SetUp/issues)

## 🌟 Soporte

Si este proyecto te ayudó, considera:

- ⭐ Dar una estrella al repositorio
- 🐛 Reportar bugs
- 💡 Sugerir mejoras
- 🤝 Contribuir con código

## 📊 Estadísticas

![GitHub stars](https://img.shields.io/github/stars/Shadow-TermDev/Custom-SetUp?style=social)
![GitHub forks](https://img.shields.io/github/forks/Shadow-TermDev/Custom-SetUp?style=social)
![GitHub issues](https://img.shields.io/github/issues/Shadow-TermDev/Custom-SetUp)
![GitHub last commit](https://img.shields.io/github/last-commit/Shadow-TermDev/Custom-SetUp)

---

<div align="center">

**Hecho con ❤️ por Shadow-TermDev**

[⬆ Volver arriba](#-custom-setup)

</div>
