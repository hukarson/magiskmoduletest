MODULEPROP=$MODPATH/module.prop
MODULEVER=$(grep -w version $MODULEPROP | cut -c9-)-$(grep versionCode $MODULEPROP | cut -c13-)

if [ "$(grep metamodule $MODULEPROP)" ]; then
	ui_print "*****************************"
	ui_print " The module not is metamodule"
	abort "*****************************"
fi

if [ "$KSU_KERNEL_VER_CODE" -gt 0 ]; then
	GETROOTINFO=kernelsu
    elif [ "$APATCH_VER_CODE" -gt 0 ]; then
	GETROOTINFO=apatch
    elif [ "$MAGISK_VER_CODE" -gt 0 ]; then
	 GETROOTINFO=magisk
    else
	 GETROOTINFO=unknown
fi

ui_print "******************************************"
ui_print "	ROOT Manager: $GETROOTINFO	"
ui_print "	Module Versions: $MODULEVER	"
ui_print "******************************************"
ui_print "#####################################################"
ui_print "The module developed based on the Magisk and KernelSU"
ui_print "Further update will be improve the module"
ui_print "#####################################################"
