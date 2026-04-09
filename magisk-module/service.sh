MODDIR=${0%/*}
MODROOTDIR=$(dirname $MODDIR)

#get root manager info
MAGISK_VER_CODE=$(magisk -V)
if [ -z "$KSU_KERNEL_VER_CODE" ]; then
	KSU_KERNEL_VER_CODE=$(ksud debug version | cut -c17-)
fi

if [ "$KSU_KERNEL_VER_CODE" -gt 0 ]; then
	isROOT=KernelSU
elif [ "$APATCH_VER_CODE" -gt 0 ]; then
	isROOT=APatch
elif [ "$MAGISK_VER_CODE" -gt 0 ]; then
	isROOT=Magisk
else
	isROOT=Unknown
fi

MOUNTLIST="
mi_ext
odm
product
system
system_dlkm
system_ext
vendor
vendor_dlkm
"

for ModuleID in $(ls $MODROOTDIR); do
	if [ "$(grep metamodule $MODROOTDIR/$ModuleID/module.prop)" ]; then
		MetaMID=$ModuleID
		MetaMName=$(grep name $MODROOTDIR/$ModuleID/module.prop | cut -c6-)
		trueMetaM=1
	fi
	for MountName in $MOUNTLIST; do
		if [ -d "$MODROOTDIR/$ModuleID/$MountName" ]; then
			for MountFile in $(find $MODROOTDIR/$ModuleID/$MountName -type f); do
				if [ -f "$MountFile" ] && [ -f "$(ls "$MountFile" | sed "s|$MODROOTDIR/$ModuleID||g")" ]; then
					trueMOUNT=1
					break
				fi
			done
		fi
		if [ "$trueMOUNT" ]; then
			break
		fi
	done
	if [ "$trueMOUNT" ]; then
		break
	fi
done

if [ "$trueMOUNT" ]; then
	trueMOUNT=Yes
else
	trueMOUNT="Cannot Find"
fi

#get env
cat /proc/$$/environ | tr '\000' '\n' > $MODDIR/get_porc_env
env > $MODDIR/get_env

#process module.prop
cp $MODDIR/module.prop $MODDIR/new.prop
getROOT="ROOT: $isROOT,"
if [ "$KSU_KERNEL_VER_CODE" -gt "22098" ] && [ "$trueMetaM" ]; then
	if [ -f $MODROOTDIR/$MetaMID/disable ]; then
		isMetaM="Meta Module: $MetaMName(stop)"
	else
	isMetaM="Meta Module: $MetaMName,"
	fi
fi
getMount="Mount Success: $trueMOUNT"
if [ "$KSU_KERNEL_VER_CODE" -gt "22098" ] && [ "$trueMetaM" ] && [ -f $MODROOTDIR/$MetaMID/disable ]; then
	MESSAGE="$getROOT $isMetaM"
else
	MESSAGE=$(echo "$getROOT $isMetaM $getMount" | tr -s [:blank:])
fi
sed -Ei "s/^description=(\[.*][[:space:]]*)?/description=[ $MESSAGE ] /g" $MODDIR/new.prop
mount --bind $MODDIR/new.prop $MODDIR/module.prop
rm $MODDIR/new.prop
#sorry i want new.prop see goodbye
