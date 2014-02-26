#!/bin/bash

config_folder="/home/lily/.xmonad/"

# Color Definition
myBgColor="#000000"
myFgColor="#ffffff"
myHiddenColor="#404040"
myAccentColorA="#cc3300"
myAccentColorB="#ffbb00"
myFonts="ProFont-9"
myBarHeight=20

# Modify xmonad.hs
sed -i "s/^\(myBgColor *= \).*/\1\"${myBgColor}\"/" ${config_folder}xmonad.hs
sed -i "s/^\(myFgColor *= \).*/\1\"${myFgColor}\"/" ${config_folder}xmonad.hs 
sed -i "s/^\(myHiddenColor *= \).*/\1\"${myHiddenColor}\"/" ${config_folder}xmonad.hs
sed -i "s/^\(myAccentColorA *= \).*/\1\"${myAccentColorA}\"/" ${config_folder}xmonad.hs
sed -i "s/^\(myAccentColorB *= \).*/\1\"${myAccentColorB}\"/" ${config_folder}xmonad.hs 
sed -i "s/^\(myFonts *= \).*/\1\"${myFonts}\"/" ${config_folder}xmonad.hs 
sed -i "s/^\(myBarHeight *= \).*/\1${myBarHeight}/" ${config_folder}xmonad.hs 


cat > ${config_folder}dzConky1 << EOF
out_to_x no
out_to_console yes
background no
update_interval 2
format_human_readable yes
override_utf8_locale yes

TEXT
\${exec ${config_folder}script/volbar}  \\
^fg(\\${myAccentColorA})^i(${config_folder}icon/cpu.xbm) ^fg(\\${myFgColor})\${cpu}% \\
^fg(\\${myAccentColorA})^i(${config_folder}icon/mem.xbm) ^fg(\\${myFgColor})\${mem} \\
^fg(\\${myAccentColorA})^i(${config_folder}icon/bat_full_01.xbm) ^fg(\\${myFgColor})\${battery_percent}% \\
^fg(\\${myAccentColorA})^i(${config_folder}icon/clock.xbm) ^fg(\\${myFgColor})\${time %a, %d %b} ^fg(\\${myAccentColorB})- ^fg(\\${myFgColor})\${time %H:%M} 
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
^fg(\\${myAccentColorA})^i(${config_folder}icon/net_up_03.xbm) ^fg(\\${myFgColor})\${upspeed enp7s0f5} \\
^fg(\\${myAccentColorA})^i(${config_folder}icon/net_down_03.xbm) ^fg(\\${myFgColor})\${downspeed enp7s0f5}
EOF

cat > ${config_folder}script/volbar << EOF
#!/bin/bash

myvol() {

    percentage=`amixer |grep -A 6 \'PCM\' |awk {'print \$5'} |grep -m 1 % |sed -e 's/[][%]//g'`
    ismute=`amixer |grep -A 6 \'Master\'|awk {'print \$6'} |grep -m 1 "[on|off]" | sed -e 's/[][]//g'`

    if [[ \$ismute == "off" ]]; then
        echo -n "^fg(${myAccentColorA})^i(${config_folder}icon/spkr_02.xbm) \$(echo "0" | gdbar -fg '${myAccentColorB}' -bg '${myHiddenColor}' -h 6 -w 50)"
    else
        echo -n "^fg(${myAccentColorA})^i(${config_folder}icon/spkr_01.xbm) \$(echo \$percentage | gdbar -fg '${myAccentColorB}' -bg '${myHiddenColor}' -h 6 -w 50)"
    fi
}

while true; do
echo "\$(myvol)"
    sleep 1
done
EOF

cat > ${config_folder}script/appsmenu << EOF
#! /bin/bash

normal_bg_color="${myBgColor}"
normal_fg_color="${myFgColor}"
selected_bg_color="${myBgColor}"
selected_fg_color="${myAccentColorA}"
bar_height=${myBarHeight}
fonts="${myFonts}"

dmenu_run -i -l 0 -h \${bar_height} \\
  -nb \${normal_bg_color} -nf \${normal_fg_color} \\
  -sb \${selected_bg_color} -sf \${selected_fg_color} \\
  -fn "\${fonts}"
EOF


cat > ${config_folder}script/dropbox_stat << EOF
#!/bin/bash

mypacman() {
    echo `${config_folder}script/pac_check`    
}
mydropbox() {
    echo `dropbox status | head -n 1`
}

while true; do
    echo " ^fg(${myAccentColorA})^i(${config_folder}icon/arch.xbm) ^fg(${myFGColor})\$(mypacman) ^fg(${myAccentColorA}) ^i(${config_folder}icon/cat.xbm) ^fg(${myFGColor})\$(mydropbox)"
    sleep 1
done
EOF

cat > ${config_folder}script/musicmenu << EOF
#!/bin/bash

normal_bg_color="${myBgColor}"
normal_fg_color="${myFgColor}"
selected_bg_color="${myBgColor}"
selected_fg_color="${myAccentColorA}"
bar_height=${myBarHeight}
fonts="${myFonts}"

album=\`mpc list album | dmenu -i -l 5 -h \${bar_height} \\
  -p "Search Album : " \\
  -nb \${normal_bg_color} -nf \${normal_fg_color} \\
  -sb \${selected_fg_color} -sf \${normal_fg_color} \\
  -fn "\${fonts}"\`

album=\`mpc list album | \${dmenu_query}\`
mpc find album "\${album}" | mpc add
EOF
