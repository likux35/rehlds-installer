#!/bin/bash
# Counter Strike 1.6 serverio instaliacijos skriptas
# Autorius: aaarnas (nebeaktyvus)
# Isplestinis palaikymas: SAIMON
# amxmodx.lt (nebeaktyvus)
# saimon.lt
# ----- [NEW NEW NEW] ----
# v4.0 rebuid, technical improvements.
# - Packaged versions are downloaded with the latest version automatically.
# v4.1 update for existing version
# v4.2 small improvement for update package.

VERSION=4.2

SCRIPT_NAME=`basename $0`
MAIN_DIR=$( getent passwd "$USER" | cut -d: -f6 )

STEAMCMD_URL="http://media.steampowered.com/installer/steamcmd_linux.tar.gz"
STEAMCMD_DIR="$MAIN_DIR/steamcmd"
STEAMCMD_CMD="steamcmd.sh"

SERVER_DIR="rehlds"
INSTALL_DIR="$MAIN_DIR/$SERVER_DIR"

echo "-------------------------------------------------------------------------------"
echo "SAIMON.lt Counter Strike 1.6 serverio instaliacija"
echo "-------------------------------------------------------------------------------"

check_version() {
	echo "Tikrinama diegimo irankio versija..."
	LATEST_VERSION=`wget -qO - https://raw.githubusercontent.com/likux35/rehlds-installer/main/rehlds.sh | grep "VERSION=[0-9]"`
	
	if [ -z $LATEST_VERSION ]; then
		echo "Klaida: Nepavyko patikrinti naujausios versijos is serverio. Nutraukiama..."
		exit 1
	fi
	
	if [ "VERSION=$VERSION" != $LATEST_VERSION ]; then
		echo "Yra nauja diegimo irankio versija. Atsiunciama..."
		wget -q -O installcs.tempfile https://raw.githubusercontent.com/likux35/rehlds-installer/main/rehlds.sh
		if [ ! -e "installcs.tempfile" ]; then
			echo "Klaida: Nepavyko gauti naujos diegimo irankio versijos is serverio..."
			exit 1
		fi
		
		mv $SCRIPT_NAME _installcs.old
		mv installcs.tempfile rehlds.sh
		chmod +x rehlds.sh
		rm _installcs.old
		echo "Atnaujinta i naujausia versija! Paleiskite ./rehlds komanda dar karta"
		exit
	else
		echo "Naudojate naujausia $VERSION versija"
	fi
}
check_packages() {
	
	BIT64_CHECK=false && [ $(getconf LONG_BIT) == "64" ] && BIT64_CHECK=true
	LIB_CHECK=false && [ "`(dpkg --get-selections lib32gcc1 | egrep -o \"(de)?install\") 2> /dev/null`" = "install" ] && LIB_CHECK=true
	SCREEN_CHECK=false && [ "`(dpkg --get-selections screen | egrep -o \"(de)?install\") 2> /dev/null`" = "install" ] && SCREEN_CHECK=true
 	UNZIP_CHECK=false && [ "`(dpkg --get-selections unzip | egrep -o \"(de)?install\") 2> /dev/null`" = "install" ] && UNZIP_CHECK=true
	
        if ($BIT64_CHECK && ! $LIB_CHECK) || ! $SCREEN_CHECK || ! $UNZIP_CHECK; then
		echo "-------------------------------------------------------------------------------"
		echo "Serveryje truksta instaliacijai reikiamu paketu"
				if [[ $(id -u) -ne 0 ]] ; then
                    echo "Kad instaliuoti trukstamus paketus, sis skriptas turi buti paleistas naudojantis"
					echo "root vartotoju arba su sudo komanda:"
					echo "sudo ./$SCRIPT_NAME"
					exit 1
				fi

		echo -e "Bus paleistos sios komandos:\n"
		echo "apt-get update"
		if $BIT64_CHECK && ! $LIB_CHECK; then
                                echo "apt-get -y install lib32gcc1s"
		fi
  
		if ! $SCREEN_CHECK; then
		echo "apt-get -y install screen"
		fi
  
  		if ! $UNZIP_CHECK; then
		echo "apt-get -y install unzip"
		fi
		echo -e "\nInstaliuoti?"
		echo "1. Taip"
		echo "2. Iseiti"
		read -p "Iveskite pasirinkta punkta: " NUMBER
	
		case "$NUMBER" in
		"1")
			if ! $SCREEN_CHECK; then
				apt-get -y install screen
			fi

   			if ! $UNZIP_CHECK; then
				apt-get -y install unzip
			fi
			;;
		*)
			echo "Ate" 
			exit 0
			;;
		esac
	fi
}

check_dir() {
	echo "-------------------------------------------------------------------------------"
	if [ -e $INSTALL_DIR ]; then

 		if [ "$UPDATE" != 1 ] || [ "$UPDATE_RDLL" != 1 ]; then
  		echo "Serveri ketinta instaliuoti i '$INSTALL_DIR' direktorija, bet ji jau sukurta"
    		NUMBER=1
    		until [ ! -e "$INSTALL_DIR" ]; do
        		((NUMBER++))
        		INSTALL_DIR="$MAIN_DIR/$SERVER_DIR$NUMBER"
    		done
      		fi
      
		echo "Instaliuoti i '$INSTALL_DIR'?"
		echo "1. Taip"
		echo "2. Noriu nurodyti kita direktorija"
		read -p "Iveskite pasirinkta punkta: " MENU_NUMBER
	
		case "$MENU_NUMBER" in
		"1")
			SERVER_DIR="$SERVER_DIR$NUMBER"
			return 0
			;;
		"2")
			read -p "Norima direktorija: $MAIN_DIR/" SERVER_DIR
			INSTALL_DIR="$MAIN_DIR/$SERVER_DIR"
			check_dir
			;;
   		*)
			echo "Ate" 
			exit 0
			;;
		esac
	else
		echo "Instaliuoti serveri i '$INSTALL_DIR'?"
		echo "1. Taip"
		echo "2. Noriu nurodyti kita direktorija"
		echo "3. Iseiti"
		read -p "Iveskite pasirinkta punkta: " MENU_NUMBER
		
		case "$MENU_NUMBER" in
		"1")
			return 0
			;;
		"2")
			read -p "Norima direktorija: $MAIN_DIR/" SERVER_DIR
			INSTALL_DIR="$MAIN_DIR/$SERVER_DIR"
			check_dir
			;;
		*)
			echo "Ate" 
			exit 0
			;;
		esac
	fi
}
alternative_install() {
	echo "-------------------------------------------------------------------------------"
	echo "Instaliuojama alternatyviu metodu..."
	cd $INSTALL_DIR
	wget -O _hlds.tar.gz "https://www.dropbox.com/scl/fi/xrwzeoe9ousxmzs90xa28/hlds.tar.gz?rlkey=ft280kq2o031auxse6s9djnw4&dl=1"
	if [ ! -e "_hlds.tar.gz" ]; then
		echo "Klaida: Nepavyko gauti failu is serverio. Nutraukiama..."
		exit 1
	fi
	tar zxvf _hlds.tar.gz
	rm _hlds.tar.gz
	chmod +x hlds_run hlds_linux
}

check_version
check_packages

#------------
UPDATE=0
UPDATE_RDLL=0

echo "Pasirinkite:"
echo "1. Serverio instaliacija [SERVER INSTALL]"
echo "2. Serverio atnaujinimas [SERVER UPDATE]"
echo "3. Iseiti"
read -p "Iveskite pasirinkta punkta: " MENU_NUMBER

case "$MENU_NUMBER" in
"1")
	check_dir
	;;
"2")
	UPDATE=1
	UPDATE_RDLL=1
 	check_dir
	;;
	
*)
	echo "Ate" 
	exit 0
	;;
esac


METAMOD=$((1<<0))
DPROTO=$((1<<1))
AMXMODX=$((1<<2))
CHANGES=$((1<<3))
REGAMEDLL=$((1<<4))

if [ "$UPDATE" -eq 0 ] || [ "$UPDATE_RDLL" -eq 0 ]; then
echo "-------------------------------------------------------------------------------"
echo "Pasirinkite modifikacijas, kurios bus instaliuotos."
echo "-------------------------------------------------------------------------------"
echo "([modifikacija] | (serverio tipas)):"
echo "1. [rehlds][metamod-r][reunion][amxmodx] | (steam / nosteam) (Rekomenduojama)"
echo "2. [rehlds][metamod-r][reunion][amxmodx] + ReGameDLL | (steam / nosteam)"
echo "-------------------------------------------------------------------------------"
else
echo "--- Pasirinkite modifikacijas, kurios bus atnaujintos: ------------------------"
echo "([modifikacija] | (serverio tipas)):"
echo "1. [--> UPDATE <-- ] [rehlds][metamod-r][reunion][amxmodx] | (steam / nosteam)"
echo "2. [--> UPDATE <-- ] [rehlds][metamod-r][reunion][amxmodx] + ReGameDLL | (steam / nosteam)"
echo "-------------------------------------------------------------------------------"
fi
read -p "Iveskite pasirinkta punkta: " NUMBER

INSTALL_TYPE=0
case "$NUMBER" in
"1")
	if [ "$UPDATE" -eq 0 ] || [ "$UPDATE_RDLL" -eq 0 ]; then
	INSTALL_TYPE=$(($INSTALL_TYPE|$METAMOD))
	INSTALL_TYPE=$(($INSTALL_TYPE|$DPROTO))
	INSTALL_TYPE=$(($INSTALL_TYPE|$AMXMODX))
	INSTALL_TYPE=$(($INSTALL_TYPE|$CHANGES))
 	else
  	UPDATE=1
   	INSTALL_TYPE=$(($INSTALL_TYPE|$METAMOD))
	INSTALL_TYPE=$(($INSTALL_TYPE|$DPROTO))
	INSTALL_TYPE=$(($INSTALL_TYPE|$AMXMODX))
 	fi
	;;
 "2")
 	if [ "$UPDATE" -eq 0 ] || [ "$UPDATE_RDLL" -eq 0 ]; then
	INSTALL_TYPE=$(($INSTALL_TYPE|$METAMOD))
	INSTALL_TYPE=$(($INSTALL_TYPE|$DPROTO))
 	INSTALL_TYPE=$(($INSTALL_TYPE|$AMXMODX))
	INSTALL_TYPE=$(($INSTALL_TYPE|$CHANGES))
 	INSTALL_TYPE=$(($INSTALL_TYPE|$REGAMEDLL))
  	else
     	UPDATE_RDLL=1
   	INSTALL_TYPE=$(($INSTALL_TYPE|$METAMOD))
	INSTALL_TYPE=$(($INSTALL_TYPE|$DPROTO))
 	INSTALL_TYPE=$(($INSTALL_TYPE|$AMXMODX))
 	INSTALL_TYPE=$(($INSTALL_TYPE|$REGAMEDLL))
  	fi
	;;
  "9")
	;;
*)
	echo "Ate"
	exit 0
	;;
esac
#------------
mkdir $INSTALL_DIR
cd $INSTALL_DIR

cd $MAIN_DIR
if [ ! -e "$STEAMCMD_DIR/$STEAMCMD_CMD" ]; then
	if [ ! -e $STEAMCMD_DIR ]; then
		mkdir $STEAMCMD_DIR
	fi
	cd $STEAMCMD_DIR
	wget $STEAMCMD_URL
	tar -xzf steamcmd_linux.tar.gz
	rm steamcmd_linux.tar.gz
fi

echo "-------------------------------------------------------------------------------"

	if [ "$UPDATE" -eq 0 ] || [ "$UPDATE_RDLL" -eq 0 ]; then
	echo "Instaliuojama alternatyviu metodu..."
	cd $INSTALL_DIR
	wget -O _hlds.tar.gz "https://www.dropbox.com/scl/fi/xrwzeoe9ousxmzs90xa28/hlds.tar.gz?rlkey=ft280kq2o031auxse6s9djnw4&dl=1"
	if [ ! -e "_hlds.tar.gz" ]; then
		echo "Klaida: Nepavyko gauti failu is serverio. Nutraukiama..."
		exit 1
	fi
	tar zxvf _hlds.tar.gz
	rm _hlds.tar.gz
	chmod +x hlds_run hlds_linux
 	fi

EXITVAL=$?
if [ $EXITVAL -gt 0 ]; then
	echo "-------------------------------------------------------------------------------"
	echo "SteamCMD vidine klaida. Klaidos kodas: $EXITVAL"
	echo "Instaliacija nutraukiama..."
	echo "Isvaloma '$INSTALL_DIR' direktorija..."
	rm -f $INSTALL_DIR/*
	alternative_install
fi

if [ ! -d "$INSTALL_DIR/cstrike" ] || [ ! -f "$INSTALL_DIR/hlds_run" ] || 
[ ! -e "$INSTALL_DIR/cstrike/liblist.gam" ]; then
    echo -e "\nKlaida: Nepavyko atsiusti serverio failu. Prasome pranesti apie si nesklanduma"
	echo "Support discord ID: Lukasenka#9922"
	echo "Taip pat, pateikite terminalo isvesties kopija."
	echo -e "Instaliacija nutraukiama...\n"
	echo "Istrinti nebaigta instaliuoti direktorija $INSTALL_DIR ?"
	read -p "Taip/Ne (t/n):" NUMBER

	shopt -s nocasematch
	if [[ $NUMBER == "t" ]] || [[ $NUMBER == "taip" ]] ; then
		rm -r $INSTALL_DIR
		echo "Direktorija $INSTALL_DIR sunaikinta"
	fi
	shopt -u nocasematch
    exit 1
fi

cd $INSTALL_DIR

if [ "$UPDATE" -ne 0 ]; then
bash stop
fi
echo "-------------------------------------------------------------------------------"
if [ $(($INSTALL_TYPE&$METAMOD)) != 0 ]; then
echo "instaliuojamas Rehlds v. $(wget -T 5 -qO - https://raw.githubusercontent.com/likux35/rehlds-versions/main/rehlds.txt) ir Metamod v. $(wget -T 5 -qO - https://raw.githubusercontent.com/likux35/rehlds-versions/main/metamodr.txt)."
if [ "$UPDATE" -ne 1 ]; then
mkdir -p cstrike/addons
mkdir -p cstrike/addons/metamod
mkdir -p cstrike/addons/metamod/dlls
fi
wget https://github.com/dreamstalker/rehlds/releases/download/$(wget -T 5 -qO - https://raw.githubusercontent.com/likux35/rehlds-versions/main/rehlds.txt)/rehlds-bin-$(wget -T 5 -qO - https://raw.githubusercontent.com/likux35/rehlds-versions/main/rehlds.txt).zip
unzip rehlds-bin-$(wget -T 5 -qO - https://raw.githubusercontent.com/likux35/rehlds-versions/main/rehlds.txt).zip
rm -rf hlsdk

mv $INSTALL_DIR/bin/linux32/valve/dlls/director.so $INSTALL_DIR/valve/dlls/directors.so
cd $INSTALL_DIR/valve/dlls
rm director.so
mv directors.so director.so

cd $INSTALL_DIR/bin/linux32
mv proxy.so $INSTALL_DIR/proxys.so
cd $INSTALL_DIR
rm proxy.so
mv proxys.so proxy.so

cd $INSTALL_DIR/bin/linux32
mv hltv $INSTALL_DIR/hltvs
cd $INSTALL_DIR
rm hltv
mv hltvs hltv

cd $INSTALL_DIR/bin/linux32
mv demoplayer.so $INSTALL_DIR/demoplayers.so
cd $INSTALL_DIR
rm demoplayer.so
mv demoplayers.so demoplayer.so

cd $INSTALL_DIR/bin/linux32
mv core.so $INSTALL_DIR/cores.so
cd $INSTALL_DIR
rm core.so
mv cores.so core.so

cd $INSTALL_DIR/bin/linux32
mv hlds_linux $INSTALL_DIR/hlds_linuxs
cd $INSTALL_DIR
rm hlds_linux
mv hlds_linuxs hlds_linux
chmod +x hlds_linux

cd $INSTALL_DIR/bin/linux32
mv engine_i486.so $INSTALL_DIR/engine_i486s.so
cd $INSTALL_DIR
rm engine_i486.so
mv engine_i486s.so engine_i486.so
rm -rf bin
rm rehlds-bin-$(wget -T 5 -qO - https://raw.githubusercontent.com/likux35/rehlds-versions/main/rehlds.txt).zip
echo "Rehlds v. $(wget -T 5 -qO - https://raw.githubusercontent.com/likux35/rehlds-versions/main/rehlds.txt) diegimas sekmingas."

mkdir $INSTALL_DIR/meta
cd $INSTALL_DIR/meta
wget https://github.com/theAsmodai/metamod-r/releases/download/$(wget -T 5 -qO - https://raw.githubusercontent.com/likux35/rehlds-versions/main/metamodr.txt)/metamod-bin-$(wget -T 5 -qO - https://raw.githubusercontent.com/likux35/rehlds-versions/main/metamodr.txt).zip
unzip metamod-bin-$(wget -T 5 -qO - https://raw.githubusercontent.com/likux35/rehlds-versions/main/metamodr.txt).zip
cd $INSTALL_DIR/meta/addons/metamod
mv metamod_i386.so $INSTALL_DIR/cstrike/addons/metamod/dlls/metamod_i386s.so
mv config.ini $INSTALL_DIR/cstrike/addons/metamod/dlls/config.ini
cd $INSTALL_DIR/cstrike/addons/metamod/dlls
if [ "$UPDATE" -ne 0 ]; then
rm metamod_i386.so
fi
mv metamod_i386s.so metamod_i386.so
cd $INSTALL_DIR
rm -rf meta
echo "Metamod v. $(wget -T 5 -qO - https://raw.githubusercontent.com/likux35/rehlds-versions/main/metamodr.txt) diegimas sekmingas."

if [ ! -e "cstrike/addons/metamod/dlls/metamod_i386.so" ]; then
	echo "Klaida: Nepavyko gauti metamod arba engine failo is serverio. Nutraukiama..."
	exit 1
fi
if [ "$UPDATE" -ne 1 ]; then
sed -r -i s/gamedll_linux.+/"gamedll_linux \"addons\/metamod\/dlls\/metamod_i386.so\""/ cstrike/liblist.gam
fi
fi
if [ $(($INSTALL_TYPE&$DPROTO)) != 0 ]; then
echo "Instaling Reunion..."
if [ "$UPDATE" -ne 1 ]; then
mkdir -p cstrike/addons
mkdir -p cstrike/addons/reunion
fi
if [ "$UPDATE" -ne 0 ]; then
cd $INSTALL_DIR/cstrike/addons/reunion
rm reunion_mm_i386.so
cd $INSTALL_DIR/cstrike
rm reunion.cfg
cd $INSTALL_DIR
fi
wget -q -P cstrike/addons/reunion https://raw.githubusercontent.com/likux35/rehlds-installer/main/reunion_mm_i386.so
wget -q -P cstrike https://raw.githubusercontent.com/likux35/rehlds-installer/main/reunion.cfg
if [ ! -e "cstrike/addons/reunion/reunion_mm_i386.so" ] || [ ! -e "cstrike/reunion.cfg" ]; then
	echo "Klaida: Nepavyko gauti Reunion failu is serverio. Nutraukiama..."
	exit 1
fi
if [ "$UPDATE" -ne 1 ]; then
echo "linux addons/reunion/reunion_mm_i386.so" >> cstrike/addons/metamod/plugins.ini
fi
fi

if [ $(($INSTALL_TYPE&$AMXMODX)) != 0 ]; then
if [ "$UPDATE" -ne 0 ]; then
echo "Isvalomi seni failai ..."
echo "-------------------------------"
echo "Demesio! Reikalingi failai bus pakeisti *-old galune."
echo "--------------------------------"
cd $INSTALL_DIR/cstrike/addons/amxmodx/configs
mv maps.ini maps-old.ini
rm cvars.ini
mv sql.cfg sql-old.cfg
rm cmds.ini
rm clcmds.ini
rm miscstats.ini
rm configs.ini
rm custommenuitems.cfg
mv modules.ini modules-old.ini
rm core.ini
mv plugins.ini plugins-old.ini
rm speech.ini
rm users.ini
mv amxx.cfg amxx-old.cfg
cd $INSTALL_DIR/cstrike/addons/amxmodx/plugins
rm antiflood.amxx
rm scrollmsg.amxx
rm imessage.amxx
rm adminslots.amxx
rm nextmap.amxx
rm multilingual.amxx
rm adminhelp.amxx
rm timeleft.amxx
rm mapchooser.amxx
rm telemenu.amxx
rm statscfg.amxx
rm menufront.amxx
rm adminchat.amxx
rm pausecfg.amxx
rm admin.amxx
rm mapsmenu.amxx
rm admin_sql.amxx
rm cmdmenu.amxx
rm pluginmenu.amxx
rm adminvote.amxx
rm plmenu.amxx
rm admincmd.amxx
cd $INSTALL_DIR/cstrike/addons/amxmodx
rm -rf scripting
cd $INSTALL_DIR/cstrike/addons/amxmodx/dlls
rm amxmodx_mm_i386.so
cd $INSTALL_DIR/cstrike/addons/amxmodx/data
rm -rf gamedata
rm csstats.amxx
rm GeoLite2-Country.mmdb
cd $INSTALL_DIR/cstrike/addons/amxmodx/data/lang
rm admin.txt
rm adminchat.txt
rm admincmd.txt
rm adminhelp.txt
rm adminslots.txt
rm adminvote.txt
rm antiflood.txt
rm cmdmenu.txt
rm common.txt
rm imessage.txt
rm languages.txt
rm mapchooser.txt
rm mapsmenu.txt
rm menufront.txt
rm miscstats.txt
rm multilingual.txt
rm nextmap.txt
rm pausecfg.txt
rm plmenu.txt
rm restmenu.txt
rm scrollmsg.txt
rm stats_dod.txt
rm statscfg.txt
rm statsx.txt
rm telemenu.txt
rm time.txt
rm timeleft.txt
cd $INSTALL_DIR/cstrike/addons/amxmodx/modules
rm cstrike_amxx_i386.so
rm csx_amxx_i386.so
rm engine_amxx_i386.so
rm fakemeta_amxx_i386.so
rm fun_amxx_i386.so
rm geoip_amxx_i386.so
rm hamsandwich_amxx_i386.so
rm json_amxx_i386.so
rm mysql_amxx_i386.so
rm nvault_amxx_i386.so
rm regex_amxx_i386.so
rm sockets_amxx_i386.so
rm sqlite_amxx_i386.so
cd $INSTALL_DIR
fi

echo "instaliuojamas Amxmodx v. $(wget -T 5 -qO - https://raw.githubusercontent.com/likux35/rehlds-versions/main/amxx-version.txt) (Build: $(wget -T 5 -qO - https://raw.githubusercontent.com/likux35/rehlds-versions/main/amxx-build.txt) ..."
wget -q -P cstrike https://www.amxmodx.org/amxxdrop/$(wget -T 5 -qO - https://raw.githubusercontent.com/likux35/rehlds-versions/main/amxx-version.txt)/amxmodx-$(wget -T 5 -qO - https://raw.githubusercontent.com/likux35/rehlds-versions/main/amxx-build.txt)-base-linux.tar.gz
if [ ! -e "cstrike/amxmodx-$(wget -T 5 -qO - https://raw.githubusercontent.com/likux35/rehlds-versions/main/amxx-build.txt)-base-linux.tar.gz" ]; then
	echo "Klaida: Nepavyko amxmodx failu is serverio. Nutraukiama..."
	exit 1
fi
tar -xzf cstrike/amxmodx-$(wget -T 5 -qO - https://raw.githubusercontent.com/likux35/rehlds-versions/main/amxx-build.txt)-base-linux.tar.gz -C cstrike
rm cstrike/amxmodx-$(wget -T 5 -qO - https://raw.githubusercontent.com/likux35/rehlds-versions/main/amxx-build.txt)-base-linux.tar.gz
if [ "$UPDATE" -ne 1 ]; then
echo "linux addons/amxmodx/dlls/amxmodx_mm_i386.so" >> cstrike/addons/metamod/plugins.ini
fi

mkdir $INSTALL_DIR/temp
cd $INSTALL_DIR/temp
wget https://www.amxmodx.org/amxxdrop/$(wget -T 5 -qO - https://raw.githubusercontent.com/likux35/rehlds-versions/main/amxx-version.txt)/amxmodx-$(wget -T 5 -qO - https://raw.githubusercontent.com/likux35/rehlds-versions/main/amxx-build.txt)-cstrike-linux.tar.gz
if [ ! -e "amxmodx-$(wget -T 5 -qO - https://raw.githubusercontent.com/likux35/rehlds-versions/main/amxx-build.txt)-cstrike-linux.tar.gz" ]; then
	echo "Klaida: Nepavyko amxmodx cstrike failu is serverio. Nutraukiama..."
	exit 1
fi
tar -xzf amxmodx-$(wget -T 5 -qO - https://raw.githubusercontent.com/likux35/rehlds-versions/main/amxx-build.txt)-cstrike-linux.tar.gz
cd $INSTALL_DIR/temp/addons/amxmodx/scripting
mv statsx.sma $INSTALL_DIR/cstrike/addons/amxmodx/scripting/statsx.sma
mv stats_logging.sma $INSTALL_DIR/cstrike/addons/amxmodx/scripting/stats_logging.sma
mv restmenu.sma $INSTALL_DIR/cstrike/addons/amxmodx/scripting/restmenu.sma
mv miscstats.sma $INSTALL_DIR/cstrike/addons/amxmodx/scripting/miscstats.sma
mv csstats.sma $INSTALL_DIR/cstrike/addons/amxmodx/scripting/csstats.sma

cd $INSTALL_DIR/temp/addons/amxmodx/plugins
mv statsx.amxx $INSTALL_DIR/cstrike/addons/amxmodx/plugins/statsx.amxx
mv restmenu.amxx $INSTALL_DIR/cstrike/addons/amxmodx/plugins/restmenu.amxx
mv miscstats.amxx $INSTALL_DIR/cstrike/addons/amxmodx/plugins/miscstats.amxx
mv stats_logging.amxx $INSTALL_DIR/cstrike/addons/amxmodx/plugins/stats_logging.amxx

cd $INSTALL_DIR/temp/addons/amxmodx/modules
mv csx_amxx_i386.so $INSTALL_DIR/cstrike/addons/amxmodx/modules/csx_amxx_i386.so
mv cstrike_amxx_i386.so $INSTALL_DIR/cstrike/addons/amxmodx/modules/cstrike_amxx_i386.so

cd $INSTALL_DIR/temp/addons/amxmodx/data
mv csstats.amxx $INSTALL_DIR/cstrike/addons/amxmodx/data/csstats.amxx

cd $INSTALL_DIR/temp/addons/amxmodx/configs
mv stats.ini $INSTALL_DIR/cstrike/addons/amxmodx/configs/statss.ini
mv plugins.ini $INSTALL_DIR/cstrike/addons/amxmodx/configs/pluginss.ini
cd $INSTALL_DIR/cstrike/addons/amxmodx/configs
rm plugins.ini
if [ "$UPDATE" -ne 0 ]; then
rm stats.ini
fi
mv pluginss.ini plugins.ini
mv statss.ini stats.ini
cd $INSTALL_DIR/temp/addons/amxmodx/configs
mv modules.ini $INSTALL_DIR/cstrike/addons/amxmodx/configs/moduless.ini
cd $INSTALL_DIR/cstrike/addons/amxmodx/configs
rm modules.ini
mv moduless.ini modules.ini
cd $INSTALL_DIR/temp/addons/amxmodx/configs
mv maps.ini $INSTALL_DIR/cstrike/addons/amxmodx/configs/mapss.ini
cd $INSTALL_DIR/cstrike/addons/amxmodx/configs
rm maps.ini
mv mapss.ini maps.ini
cd $INSTALL_DIR/temp/addons/amxmodx/configs
mv cvars.ini $INSTALL_DIR/cstrike/addons/amxmodx/configs/cvarss.ini
cd $INSTALL_DIR/cstrike/addons/amxmodx/configs
rm cvars.ini
mv cvarss.ini cvars.ini
cd $INSTALL_DIR/temp/addons/amxmodx/configs
mv core.ini $INSTALL_DIR/cstrike/addons/amxmodx/configs/cores.ini
cd $INSTALL_DIR/cstrike/addons/amxmodx/configs
rm core.ini
mv cores.ini core.ini
cd $INSTALL_DIR/temp/addons/amxmodx/configs
mv cmds.ini $INSTALL_DIR/cstrike/addons/amxmodx/configs/cmdss.ini
cd $INSTALL_DIR/cstrike/addons/amxmodx/configs
rm cmds.ini
mv cmdss.ini cmds.ini
cd $INSTALL_DIR/temp/addons/amxmodx/configs
mv amxx.cfg $INSTALL_DIR/cstrike/addons/amxmodx/configs/amxxs.cfg
cd $INSTALL_DIR/cstrike/addons/amxmodx/configs
rm amxx.cfg
mv amxxs.cfg amxx.cfg

cd $INSTALL_DIR
rm -rf temp
fi

if [ $(($INSTALL_TYPE&$CHANGES)) != 0 ]; then
echo "atliekami pakeitimai..."
wget -q -O cstrike/_server.cfg https://raw.githubusercontent.com/likux35/rehlds-installer/main/server.cfg
if [ ! -e "cstrike/_server.cfg" ]; then
	echo "Klaida: Nepavyko gauti server.cfg failo is serverio. Nutraukiama..."
	exit 1
fi
rm cstrike/server.cfg
mv cstrike/_server.cfg cstrike/server.cfg
fi

if [ $(($INSTALL_TYPE&$REGAMEDLL)) != 0 ]; then
echo "instaliuojamas ReGameDLL v. $(wget -T 5 -qO - https://raw.githubusercontent.com/likux35/rehlds-versions/main/regamedll.txt)..."
cd $INSTALL_DIR
wget https://github.com/s1lentq/ReGameDLL_CS/releases/download/$(wget -T 5 -qO - https://raw.githubusercontent.com/likux35/rehlds-versions/main/regamedll.txt)/regamedll-bin-$(wget -T 5 -qO - https://raw.githubusercontent.com/likux35/rehlds-versions/main/regamedll.txt).zip
if [ ! -e "regamedll-bin-$(wget -T 5 -qO - https://raw.githubusercontent.com/likux35/rehlds-versions/main/regamedll.txt).zip" ]; then
	echo "Klaida: Nepavyko gauti ReGameDLL failu is serverio. Nutraukiama..."
	exit 1
fi
unzip regamedll-bin-$(wget -T 5 -qO - https://raw.githubusercontent.com/likux35/rehlds-versions/main/regamedll.txt).zip
rm -rf cssdk
cd $INSTALL_DIR/bin/linux32/cstrike/dlls
mv cs.so $INSTALL_DIR/cstrike/dlls/css.so
cd $INSTALL_DIR/cstrike/dlls
rm cs.so
mv css.so cs.so
cd $INSTALL_DIR/bin/linux32/cstrike
mv game_init.cfg $INSTALL_DIR/cstrike
mv game.cfg $INSTALL_DIR/cstrike
cd $INSTALL_DIR
rm -rf bin
rm regamedll-bin-$(wget -T 5 -qO - https://raw.githubusercontent.com/likux35/rehlds-versions/main/regamedll.txt).zip
fi

if [ "$UPDATE" -ne 1 ]; then

echo "cd $INSTALL_DIR && screen -A -m -d -S $SERVER_DIR ./hlds_run -game cstrike +ip $(wget -T 5 -qO - https://api.ipify.org) +port 27015 +map cs_assault +maxplayers 32" >> start_line

echo "#!/bin/bash" >> start
echo "SESSION=\$(screen -ls | egrep -o -e [0-9]+\\.$SERVER_DIR | sed -r -e \"s/[0-9]+\\.//\")" >> start
echo "if [ \"\$SESSION\" == \"$SERVER_DIR\" ]; then" >> start
echo "	screen -dr $SERVER_DIR" >> start
echo "else" >> start
echo "	eval \$(cat start_line)" >> start
echo "	sleep 1" >> start
echo "	screen -dr $SERVER_DIR" >> start
echo "fi" >> start
echo "exit" >> start
chmod +x start

echo "#!/bin/bash" >> stop
echo "SESSION=\$(screen -ls | egrep -o -e [0-9]+\\.$SERVER_DIR | sed -r -e \"s/[0-9]+\\.//\")" >> stop
echo "SERVER_NAME=\$(cat cstrike/server.cfg | egrep \"hostname\\s+\\\"[^\\\"]+\\\"\" | sed \"s/hostname //\" | tr -d \"\\\"\\r\")" >> stop
echo "STATUS=\"\"" >> stop
echo "if [ \"\$SESSION\" == \"$SERVER_DIR\" ]; then" >> stop
echo "	screen -S $SERVER_DIR -X stuff $(echo -e "quit\r")" >> stop
echo "	STATUS=\"sustabdytas\"" >> stop
echo "else" >> stop
echo "	STATUS=\"nera ijungtas, tad negalima jo sustabdyti\"" >> stop
echo "fi" >> stop
echo 'echo "-------------------------------------------------------------------------------"' >> stop
echo "echo \"Serveris \$SERVER_NAME \$STATUS\"" >> stop
echo 'echo "-------------------------------------------------------------------------------"' >> stop
echo "exit" >> stop
chmod +x stop

echo "#!/bin/bash" >> restart
echo "SESSION=\$(screen -ls | egrep -o -e [0-9]+\\.$SERVER_DIR | sed -r -e \"s/[0-9]+\\.//\")" >> restart
echo "SERVER_NAME=\$(cat cstrike/server.cfg | egrep \"hostname\\s+\\\"[^\\\"]+\\\"\" | sed \"s/hostname //\" | tr -d \"\\\"\\r\")" >> restart
echo "STATUS=\"\"" >> restart
echo "if [ \"\$SESSION\" == \"$SERVER_DIR\" ]; then" >> restart
echo "	screen -S $SERVER_DIR -X stuff $(echo -e "restart\r")" >> restart
echo "	STATUS=\"perkraunamas...\"" >> restart
echo "else" >> restart
echo "	STATUS=\"nera ijungtas, tad negalima jo perkrauti\"" >> restart
echo "fi" >> restart
echo 'echo "-------------------------------------------------------------------------------"' >> restart
echo "echo \"Serveris \$SERVER_NAME \$STATUS\"" >> restart
echo 'echo "-------------------------------------------------------------------------------"' >> restart
echo "exit" >> restart
chmod +x restart

sed -i s/"if test \$retval -eq 0 && test -z \"\$RESTART\" ; then"/"if test \$retval -eq 0 ; then"/ hlds_run
sed -i s/"debugcore \$retval"/"debugcore \$retval\n\n\t\t\tif test -z \"\$RESTART\" ; then\n\t\t\t\tbreak; # no need to restart on crash\n\t\t\tfi"/ hlds_run
sed -i s/"if test -n \"\$DEBUG\" ; then"/"if test \"\$DEBUG\" -eq 1; then"/ hlds_run

fi

if [ ! -e "$INSTALL_DIR/steam_appid.txt" ]; then
echo "10" >> steam_appid.txt
fi

if [ "$UPDATE" -ne 1 ]; then
mkdir steamcmd
echo "../steamcmd/steamcmd.sh +login anonymous +force_install_dir $INSTALL_DIR +app_update 90 -beta beta validate +quit" > steamcmd/steamcmd.sh
chmod +x steamcmd/steamcmd.sh
fi

echo "-------------------------------------------------------------------------------"
echo "Serveris instaliuotas direktorijoje '$INSTALL_DIR'"
if [ $(($INSTALL_TYPE&$REGAMEDLL)) != 0 ]; then
echo "[INFO] ReHLDS VERSIJA: $(wget -T 5 -qO - https://raw.githubusercontent.com/likux35/rehlds-versions/main/rehlds.txt), AMXX VERSIJA: $(wget -T 5 -qO - https://raw.githubusercontent.com/likux35/rehlds-versions/main/amxx-version.txt) (Build: $(wget -T 5 -qO - https://raw.githubusercontent.com/likux35/rehlds-versions/main/amxx-build.txt)), Metamod-r VERSIJA: $(wget -T 5 -qO - https://raw.githubusercontent.com/likux35/rehlds-versions/main/metamodr.txt), ReGameDLL VERSIJA: $(wget -T 5 -qO - https://raw.githubusercontent.com/likux35/rehlds-versions/main/regamedll.txt)"
echo "-------------------------------------------------------------------------------"
else
echo "[INFO] ReHLDS VERSIJA: $(wget -T 5 -qO - https://raw.githubusercontent.com/likux35/rehlds-versions/main/rehlds.txt), AMXX VERSIJA: $(wget -T 5 -qO - https://raw.githubusercontent.com/likux35/rehlds-versions/main/amxx-version.txt) (Build: $(wget -T 5 -qO - https://raw.githubusercontent.com/likux35/rehlds-versions/main/amxx-build.txt)), Metamod-r VERSIJA: $(wget -T 5 -qO - https://raw.githubusercontent.com/likux35/rehlds-versions/main/metamodr.txt)"
echo "-------------------------------------------------------------------------------"
fi
if [ $(($INSTALL_TYPE&$CHANGES)) != 0 ]; then
echo "$INSTALL_DIR/start - paleisti serveri.
$INSTALL_DIR/stop - sustabdyti serveri.
$INSTALL_DIR/restart - perkrauti serveri."
fi
if $BIT64_CHECK && ! $LIB_CHECK; then
				apt-get -y install lib32gcc1
			fi

exit 0
# Counter Strike 1.6 serverio instaliacijos skriptas
# Autorius: SAIMON (Anksciau - arnas)
# Support discord ID : Lukasenka#9922
