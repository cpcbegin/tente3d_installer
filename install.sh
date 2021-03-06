#!/bin/bash
install_tente3d_utils_from_opensuse() {
    # $1 : distro
    # $2 : architecture
    LDRAWREMOTE="http://download.opensuse.org/repositories/home:/pbartfai/$1/$2/"
    for u in $(cat apps_$1_$2.txt); do
        wget -c $LDRAWREMOTE/$u -O $LDRAWTMP/$u;
        echo "Instalando $LDRAWTMP/$u....."
        dpkg -i $LDRAWTMP/$u
        rm -f $LDRAWTMP/$u
    done
    apt-get install -fy
}

if [ "$EUID" -ne 0 ]
  then echo "This script needs root privileges."
  exit
fi

LDRAWHOME="/opt/ldraw"
LDRAWTMP="/tmp/ldraw"
APPSMERGED=$HOME/.config/menus/applications-merged
DESKTOPDIR=$HOME/.local/share/desktop-directories
DESKTOPPATH=$(xdg-user-dir DESKTOP)
DESKTOPPATHTENTE=$DESKTOPPATH/Tente_Lego
FIRSTSUDOUSER=$(grep sudo /etc/group | head -1 | cut -d ":" -f4)

echo "Actualizamos paquetería..."
apt-get update
apt-get -y upgrade
echo "Instalamos wine"
apt-get install wine
apt-get install wine-stable
echo "Instalamos git y descompresores"
apt-get install git unrar unzip

echo "Creamos las carpetas necesarias"
for f in $LDRAWHOME $LDRAWHOME/tente $LDRAWTMP $APPSMERGED $DESKTOPDIR; do
    if [ -d $f ]; then
        echo "$f ya existe."
    else
        mkdir -p $f
        echo "Creando $f"
    fi
done

echo "Copiamos todo a $LDRAWHOME"
cp -rpu * $LDRAWHOME

echo "Copiamos accesos directos al Escritorio y al Menú de inicio..."
mkdir -p $DESKTOPPATHTENTE
cp -rpu $LDRAWHOME/software/accesos-directos-linux/* $DESKTOPPATHTENTE
chown -R $FIRSTSUDOUSER $DESKTOPPATHTENTE
cp -rpu $LDRAWHOME/software/accesos-directos-linux/* /usr/share/applications/

echo "Copiamos todos los modelos de Tente del repositorio"
git clone https://github.com/cpcbegin/tentemodels $LDRAWHOME/models
chown -R $FIRSTSUDOUSER $DESKTOPPATHTENTE

echo "Instalando MLCad 3.40..."
wget -c http://mlcad.lm-software.com/MLCad_V3.40.zip -O $LDRAWTMP/mlcad.zip
unzip -u $LDRAWTMP/mlcad.zip -d $LDRAWHOME/software/
rm $LDRAWTMP/mlcad.zip

echo "Instalamos BMP2LDraw..."
wget -c https://www.dropbox.com/s/a82giwfiof15ld5/bmp2ldraw.zip?dl=0 -O $LDRAWTMP/BMP2LDraw.zip
unzip -u $LDRAWTMP/BMP2LDraw.zip -d $LDRAWHOME/software/
rm $LDRAWTMP/BMP2LDraw.zip

echo "Instalamos LDDesignPad..."
wget -c https://sourceforge.net/projects/lddp/files/LDDP%20Windows%20Binaries/LDDP%202.x/LDDP%202.0.4/LDDP204.zip/download -O $LDRAWTMP/lddp.zip
mkdir $LDRAWHOME/software/lddp
unzip -u $LDRAWTMP/lddp.zip -d $LDRAWHOME/software/lddp
chmod +x $LDRAWHOME/software/lddp//LDDesignPad.exe
rm $LDRAWTMP/lddp.zip

echo "Instalamos LD4DStudio..."
wget -c http://www.ld4dstudio.nl/action/download/LD4DStudio-1-2.rar -O $LDRAWTMP/LD4DStudio.rar
mkdir -p $LDRAWHOME/software/LD4DStudio
echo "unrar x -u $LDRAWTMP/LD4DStudio.rar $LDRAWHOME/software/LD4DStudio"
unrar x -u $LDRAWTMP/LD4DStudio.rar $LDRAWHOME/software/LD4DStudio
rm $LDRAWTMP/LD4DStudio.rar

echo "Instalamos LDCad..."
wget -c http://www.melkert.net/action/download/LDCad-1-6b-Linux.tar.bz2 -O $LDRAWTMP/ldcad.tar.bz2
tar -xjvf $LDRAWTMP/ldcad.tar.bz2 -C /opt/ldraw/software
rm $LDRAWTMP/ldcad.tar.bz2

echo "Instalamos LDraw utils (openSUSE download server)"
if [ $(arch) = "x86_64" ]; then
    install_tente3d_utils_from_opensuse "xUbuntu_18.04" "amd64"
elif [ $(arch | grep 86 | wc -l) > 0 ]; then
    install_tente3d_utils_from_opensuse "xUbuntu_16.04" "i386"
else 
    echo "ERROR: NO PUEDO INSTALAR LAS HERRAMIENTAS LDRAW EN ESTA ARQUITECTURA"
fi

echo "Instalamos Blender y Povray..."
sudo apt-get install povray blender

echo "Instalando la librería de piezas TENTE..."
wget -c https://www.dropbox.com/s/irba95qphdxtiq7/LDrawTente_Ultima.zip?dl=0 -O $LDRAWTMP/LDrawTente_Ultima.zip
unzip -u $LDRAWTMP/LDrawTente_Ultima.zip -d $LDRAWHOME/tente
rm $LDRAWTMP/LDrawTente_Ultima.zip
echo "Renombramos LDCONFIG.LDR por LDConfig.ldr (compatibilidad con software nativo GNU/Linux)"
mv $LDRAWHOME/tente/LDCONFIG.LDR $LDRAWHOME/tente/LDConfig.ldr

echo "Creamos la categoría 'Tente y Lego 3D'"
cp -rpu $LDRAWHOME/software/categorias-linux/user-menulibre-tente-y-lego-3d.menu $APPSMERGED
cp -rpu $LDRAWHOME/software/categorias-linux/menulibre-tente-y-lego-3d.directory $DESKTOPDIR

echo "Todo lo que hay en $LDRAWHOME pertenece al primer usuario '$FIRSTSUDOUSER'"
chown -R $FIRSTSUDOUSER $LDRAWHOME

echo "Creamos enlace blando para la librería LEGO"
ln -svf /usr/share/ldraw $LDRAWHOME/lego

echo "Creamos enlace blando a la configuración de povray"
ln -s /etc/povray/ $HOME/.povray
chown -R $FIRSTSUDOUSER $HOME/.povray