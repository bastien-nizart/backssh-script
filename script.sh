#!bin/bash
#
# This script is a minimalist backup script to 
# back up a remote folder list via the scp protocol.
#
# For ease of use, sshpass can be activated if 
# it is installed from the config.ini.
#
# It also manages the deletion of backups
# too old (adjustable).
#
# The only variables you need to change are in 
# the config.ini. If you change anything in this 
# script. It could be that nothing works properly anymore
#
# @author : Bastien Nizart
# @license : MIT
# ---------------------------------------------------

# --------------
# CONFIGURATION
# --------------
source ./config.ini
i=1
date=$(date +%F)
destinationCurrent="${destination}/${date}"
nbSources=${#dossierSources[@]}
dateBeforeDelete=$(date -r $(($(date +"%s")-$(($dayBeforeDelete*86400)))) +%F)

# -----------------
# CREATING FOLDERS 
# ----------------- 
if [ ! -d "$destination" ];
then
    mkdir "$destination"
fi

if [ -d "$destinationCurrent" ];
then
    sudo rm -Rf "$destinationCurrent"
fi

for backup in $(ls $destination)
do
    if [[ "${backup%%.*}" < "$dateBeforeDelete" ]]; then
        rm -rf "${destination}/${backup}"
    fi
done

mkdir "$destinationCurrent"

# ----------
# EXECUTION
# ----------
for source in ${dossierSources[*]}
do
    echo "Stage $i / $nbSources"
    echo "backing up the folder : ${source} \n"
    mkdir "$destinationCurrent"/"${source//\//-}"

    if [ "$sshpassActive" = true ] ; then
        sshpass -f "$passwordLocation" scp -r "$sshUser@$sshHost":"${source}" "$destinationCurrent"/"${source//\//-}"
    else
        scp -r "$sshUser@$sshHost":"${source}" "$destinationCurrent"/"${source//\//-}"
    fi

    i=$((i+1))
done

# ------------
# COMPRESSION
# ------------
echo "compression in progress ...\n"

tar -cjf "$destinationCurrent".tar.tbz "$destinationCurrent"
sudo rm -Rf "$destinationCurrent"

echo "success !"