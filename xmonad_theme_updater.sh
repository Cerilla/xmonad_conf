#!/bin/bash

# Color Definition

config_folder="/home/lily/.xmonad/"

myBgColor="#000000"
myFgColor="#ffffff"
myHiddenColor="#404040"
myAccentColorA="#cc3300"
myAccentColorB="#3300cc"

sed -i "s/^\(myBgColor *= \).*/\1\"${myBgColor}\"/" ${config_folder}xmonad.hs
sed -i "s/^\(myFgColor *= \).*/\1\"${myFgColor}\"/" ${config_folder}xmonad.hs 
sed -i "s/^\(myHiddenColor *= \).*/\1\"${myHiddenColor}\"/" ${config_folder}xmonad.hs
sed -i "s/^\(myAccentColorA *= \).*/\1\"${myAccentColorA}\"/" ${config_folder}xmonad.hs
sed -i "s/^\(myAccentColorB *= \).*/\1\"${myAccentColorB}\"/" ${config_folder}xmonad.hs 


cat > ${config_folder}dzConky1 << EOF

out_to_x no
out_to_console yes
background no
update_interval 2
format_human_readable yes
override_utf8_locale yes

TEXT
\${exec /home/lily/.xmonad/script/volbar}  \
^fg(\\${myAccentColorA})^i(/home/lily/.xmonad/icon/cpu.xbm) ^fg(\\${myFgColor})\${cpu}% \
^fg(\\${myAccentColorA})^i(/home/lily/.xmonad/icon/mem.xbm) ^fg(\\${myFgColor})\${mem} \
^fg(\\${myAccentColorA})^i(/home/lily/.xmonad/icon/bat_full_01.xbm) ^fg(\\${myFgColor})\${battery_percent}% \
^fg(\\${myAccentColorA})^i(/home/lily/.xmonad/icon/clock.xbm) ^fg(\\${myFgColor})\${time %a, %d %b} ^fg(\\${myAccentColorB})- ^fg(\\${myFgColor})\${time %H:%M} 

EOF

cat > ${config_folder}script/volbar << EOF
#!/bin/bash

myvol() {

    percentage=`amixer |grep -A 6 \'PCM\' |awk {'print \$5'} |grep -m 1 % |sed -e 's/[][%]//g'`
    ismute=`amixer |grep -A 6 \'Master\'|awk {'print \$6'} |grep -m 1 "[on|off]" | sed -e 's/[][]//g'`

    if [[ \$ismute == "off" ]]; then
echo -n "^fg(${myAccentColorA})^i(/home/lily/.xmonad/icon/spkr_02.xbm) \$(echo "0" | gdbar -fg '${myAccentColorB}' -bg '${myHiddenColor}' -h 6 -w 50)"
    else
echo -n "^fg(${myAccentColorA})^i(/home/lily/.xmonad/icon/spkr_01.xbm) \$(echo \$percentage | gdbar -fg '${myAccentColorB}' -bg '${myHiddenColor}' -h 6 -w 50)"
    fi
}

while true; do
echo "\$(myvol)"
    sleep 1
done

EOF

cat > ${config_folder}script/mydmenu << EOF
#! /bin/bash

normal_bg_color="${myBgColor}"
normal_fg_color="${myFgColor}"
selected_bg_color="${myBgColor}"
selected_fg_color="${myAccentColorA}"

dmenu_run -i -l 0 \
  -nb \${normal_bg_color} -nf \${normal_fg_color} \
  -sb \${selected_bg_color} -sf \${selected_fg_color}

EOF

cat > ${config_folder}dzConky3 << EOF
out_to_x no
out_to_console yes
background no
update_interval 2
format_human_readable yes
override_utf8_locale yes
mpd_host 0.0.0.0
mpd_port 6600
use_xft yes


TEXT
^fg(\\${myAccentColorA})^i(/home/lily/.xmonad/icon/net_up_03.xbm) ^fg(\\${myFgColor})\${upspeed enp7s0f5}\
^fg(\\${myAccentColorA})^i(/home/lily/.xmonad/icon/net_down_03.xbm) ^fg(\\${myFgColor})\${downspeed enp7s0f5} \

EOF

cat > ${config_folder}script/dropbox_stat << EOF
#!/bin/bash

mypacman() {
    echo `/home/lily/.xmonad/script/pac_check`    
}
mydropbox() {
    echo `dropbox status | head -n 1`
}

while true; do
    echo " ^fg(${myAccentColorA})^i(/home/lily/.xmonad/icon/arch.xbm) ^fg(${myFGColor})\$(mypacman) ^fg(${myAccentColorA}) ^i(/home/lily/.xmonad/icon/cat.xbm) ^fg(${myFGColor})\$(mydropbox)"
    sleep 1
done
EOF
