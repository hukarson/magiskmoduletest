#!/bin/sh
module_path=magisk-module
module_prop=$module_path/module.prop

#get module.prop
module_id=$(grep id $module_prop | cut -c4-)
module_ver=$(grep -w version $module_prop | cut -c9-)-$(grep versionCode $module_prop | cut -c13-)

cd $module_path
zip -r ../$module_id-$module_ver.zip .
