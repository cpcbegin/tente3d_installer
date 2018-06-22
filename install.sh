#!/bin/bash
install_tente3d_utils_from_opensuse() {
    # $1 : distro
    # $2 : architecture
    LDRAWREMOTE="http://download.opensuse.org/repositories/home:/pbartfai/xUbuntu_18.04/amd64/"
    for u in $(cat apps_$1_$2.txt); do
        wget -c $LDRAWREMOTE/$u -O $LDRAWTMP/$u;
        echo "Instalando $LDRAWTMP/$u....."
        dpkg -i $LDRAWTMP/$u
        rm -f $LDRAWTMP/$u
    done
    apt-get install -fy
    exit;
}

if [ "$EUID" -ne 0 ]
  then echo "This script needs root privileges"
  exit
fi

# echo "Actualizamos paquetería"
# apt-get update
# apt-get -y upgrade
# echo "Instalamos wine"
# apt-get install wine
# apt-get install unzip git

LDRAWHOME="/opt/ldraw"
LDRAWTMP="/tmp/ldraw"
DESKTOPPATH=$(xdg-user-dir DESKTOP)
DESKTOPPATHTENTE=$DESKTOPPATH/Tente_Lego
FIRSTSUDOUSER=$(grep sudo /etc/group | head -1 | cut -d ":" -f4)

echo "Creamos las carpetas '$LDRAWHOME' y '$LDRAWTMP'"
if [ -d $LDRAWHOME ]; then
    echo "$LDRAWHOME ya existe."
else
    mkdir -p $LDRAWHOME
    echo "Creando $LDRAWHOME"
fi

if [ -d $LDRAWTMP ]; then
    echo "$LDRAWTMP ya existe."
else
    mkdir -p $LDRAWTMP
    echo "Creando $LDRAWTMP"
fi

echo "Copiamos todo a $LDRAWHOME"
cp -rpu * $LDRAWHOME

echo "Copiamos iconos al Escritorio y al Menú de inicio"
mkdir -p $DESKTOPPATHTENTE
cp -rpu $LDRAWHOME/software/accesos-directos-linux/* $DESKTOPPATHTENTE
chown -R $FIRSTSUDOUSER $DESKTOPPATHTENTE
cp -rpu $LDRAWHOME/software/accesos-directos-linux/* /usr/share/applications/

echo "Copiamos todos los modelos de Tente del repositorio"
git clone https://github.com/cpcbegin/tentemodels $LDRAWHOME/models
chown -R $FIRSTSUDOUSER $DESKTOPPATHTENTE

echo "Todo lo que hay en $LDRAWHOME pertenece al primer usuario '$FIRSTSUDOUSER'"
chown -R $FIRSTSUDOUSER $LDRAWHOME

echo "Instalando la librería de piezas TENTE..."
#wget -c https://www.dropbox.com/s/irba95qphdxtiq7/LDrawTente_Ultima.zip?dl=0 -O $LDRAWTMP/LDrawTente_Ultima.zip
mkdir -p $LDRAWHOME/tente
unzip $LDRAWTMP/LDrawTente_Ultima.zip -d $LDRAWHOME/tente
rm $LDRAWTMP/LDrawTente_Ultima.zip

echo "Instalando MLCad 3.40..."
wget -c http://mlcad.lm-software.com/MLCad_V3.40.zip -O $LDRAWTMP/mlcad.zip
unzip $LDRAWTMP/mlcad.zip -d /opt/ldraw/software/
rm $LDRAWTMP/mlcad.zip

echo "Instalamos LDraw"
if [ $(arch) = "x86_64" ]; then
    install_tente3d_utils_from_opensuse "xUbuntu_18.04" "amd64"
elif [ $(arch) = "x86" ]; then
    install_tente3d_utils_from_opensuse "xUbuntu_16.04" "i386"
else 
    echo "NO PUEDO INSTALAR LDRAW EN ESTA ARQUITECTURA"
fi

