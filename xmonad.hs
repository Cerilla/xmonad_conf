import XMonad                         -- No this, No XMonad
import Graphics.X11.ExtraTypes.XF86
import XMonad.Hooks.DynamicLog        --
import XMonad.Hooks.ManageDocks       -- Because people love their statusbar
import XMonad.Hooks.UrgencyHook
import XMonad.Layout.NoBorders        -- No Borders, why not?
import XMonad.Util.Run                -- 
import System.Exit                    -- Used for exiting Xmonad
import System.IO
import Data.List

import qualified XMonad.StackSet as W -- Used for Workspace Keybind
import qualified Data.Map        as M -- Used for Keybind



-- Behavior
myTerm         = "urxvt"
myFileMan      = "thunar"
myMouseFocus  :: Bool
myMouseFocus   = False

myRestart :: String
myRestart = "xmonad --recompile && for pid in `pgrep dzen2`; do kill -9 $pid; done && xmonad --restart"

-- Style 
myBgColor       = "#000000"
myFgColor       = "#ffffff"
myHiddenColor   = "#404040"
myAccentColorA  = "#cc3300"
myAccentColorB  = "#ffbb00"
myFonts     = "ProFont-9"

--Border
myNormalBorderColor = myBgColor
myFocusBorderColor  = myAccentColorA
myBorderWidth       = 2 
myBarHeight         = 20
-- Layout
myWorkspaces = clickable . (map dzenEscape) $ ["eins","zwei","drei","vier","funf","sechs","sieben","acht","neun"]

      where clickable l     = [ "^ca(1,xdotool key super+" ++ show (n) ++ ")" ++ ws ++ "^ca()" |
                              (i,ws) <- zip [1..] l,
                              let n = i ]

myLayout = tiled ||| Mirror tiled ||| maximized
   where
      maximized   = noBorders $ Full
      tiled       = smartBorders $ Tall nmaster delta ratio
      nmaster     = 1
      ratio       = 1/2
      delta       = 5/100

-- Keybind
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
    -- Application launching
    [ ((modm,               xK_Return), spawn $ XMonad.terminal conf)
    , ((modm .|. shiftMask, xK_Return), spawn "thunar"                     )              
    , ((modm .|. shiftMask, xK_l     ), spawn "xautolock -locknow"         ) 
    , ((modm,               xK_p     ), spawn "/home/lily/.xmonad/script/appsmenu" )
    , ((modm .|. shiftMask, xK_p     ), spawn "/home/lily/.xmonad/script/musicmenu" )
    , ((modm .|. shiftMask, xK_c     ), kill                               )
    , ((   0,               xK_Print ), spawn "scrot"                      )
    -- XMonad Behaviour
    , ((modm              , xK_r     ), spawn "xmonad --restart"           ) -- Refresh XMonad
    , ((modm              , xK_b     ), sendMessage ToggleStruts           ) -- Toggle status bar
    , ((modm,               xK_space ), sendMessage NextLayout             ) -- Switch to next layout
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf ) -- Reset Layout
    , ((modm .|. shiftMask, xK_t     ), withFocused $ windows . W.sink     ) -- Force window to tile pane
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess)          ) -- Quit XMonad
    , ((modm              , xK_q     ), spawn myRestart                    ) -- Recompile then refresh XMonad
    -- Pane Switching
    , ((modm,               xK_Tab   ), windows W.focusDown    ) -- Focus to next pane
    , ((modm,               xK_Right ), windows W.focusDown    )
    , ((modm .|. shiftMask, xK_Tab   ), windows W.focusUp      ) -- Focus to previous pane
    , ((modm,               xK_Left  ), windows W.focusUp      )
    , ((modm,               xK_Down  ), windows W.focusMaster  ) -- Focus to Master pane
    -- Pane Swapping
    , ((modm .|. shiftMask, xK_Right ), windows W.swapDown     ) -- Swap current with next pane
    , ((modm .|. shiftMask, xK_Left  ), windows W.swapUp       ) -- Swap current with previous pane
    , ((modm .|. shiftMask, xK_Down  ), windows W.swapMaster   ) -- Swap current with master pane
    -- Pane sizing
    , ((modm,               xK_comma ), sendMessage Shrink           ) -- Shrink master pane
    , ((modm,               xK_period), sendMessage Expand           ) -- Expand master pane
    , ((modm .|. shiftMask, xK_comma ), sendMessage (IncMasterN 1)   ) -- Increase number of master pane  
    , ((modm .|. shiftMask, xK_period), sendMessage (IncMasterN (-1))) -- Decrease number of master pane
    -- Laptop key binding 
    --- MPD key binding
    , ((  shiftMask, xF86XK_AudioPlay), spawn "mpc clear && /home/lily/.bin/mpdaddrandom && mpc play"  )
    , ((   0,        xF86XK_AudioPlay), spawn "mpc toggle"  )
    , ((   0,        xF86XK_AudioStop), spawn "mpc stop"    )
    , ((   0,        xF86XK_AudioPrev), spawn "mpc prev"    )
    , ((   0,        xF86XK_AudioNext), spawn "mpc next"    )
    --- Other key binding
    , ((  shiftMask, xF86XK_Display  ), spawn "lxrandr"     )
    , ((   0, xF86XK_AudioMute       ), spawn "amixer set Master toggle_mute"                )
    , ((   0, xF86XK_AudioLowerVolume), spawn "amixer set PCM 3- ;amixer set Master unmute"  )
    , ((   0, xF86XK_AudioRaiseVolume), spawn "amixer set PCM 3+ ;amixer set Master unmute"  )
    ]
    ++
    -- Binding for switching workspaces
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

-- Manage Hook
myManageHook = composeAll
    [ resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore 
    , resource  =? "xvkbd"          --> doFloat ]

-- LogHook
myLogHook h = dynamicLogWithPP $ defaultPP
    { ppCurrent         = dzenColor myAccentColorA "" . pad
    , ppHidden          = dzenColor myFgColor "" . pad
    , ppHiddenNoWindows = dzenColor myHiddenColor "" . pad
    , ppLayout          = dzenColor myAccentColorB "" . pad
    , ppUrgent          = dzenColor myAccentColorB "" . pad . dzenStrip
    , ppTitle           = const "" 
    , ppWsSep           = ""
    , ppSep             = ":"
    , ppOrder           = reverse
    , ppOutput          = hPutStrLn h
    }




--Conky and Statusbar    
myHeight  = show myBarHeight

myPipeA = "dzen2 -p -ta l -h '" ++ myHeight ++ "' -w '500' -e 'onstart=lower' -bg '" ++ myBgColor ++ "' -fg '" ++ myFgColor ++ "' -fn '" ++ myFonts ++"'"
myPipeB = "conky -c ~/.xmonad/dzConky1 | dzen2 -p -ta r -h '" ++ myHeight ++ "' -w '866' -x '500' -e 'onstart=lower' -bg '" ++ myBgColor ++"' -fg '" ++ myFgColor ++"' -fn '" ++ myFonts ++ "'" 
myPipeC = "conky -c ~/.xmonad/dzConky2 | dzen2 -p -ta l -h '" ++ myHeight ++ "' -w '700' -x '0' -y '-" ++ myHeight ++ "' -e 'onstart=lower' -bg '" ++ myBgColor ++ "' -fg '" ++ myFgColor ++ "' -fn '" ++ myFonts ++ "'"
myPipeD = "conky -c ~/.xmonad/dzConky3 | dzen2 -p -ta r -h '" ++ myHeight ++ "' -w '700' -x '666' -y '-" ++ myHeight ++"' -e 'onstart=lower' -bg '" ++ myBgColor ++ "' -fg '" ++ myFgColor ++ "' -fn '" ++ myFonts ++"'"

main = do
   d <- spawnPipe myPipeA
   spawn $ myPipeB 
   spawn $ myPipeC
   spawn $ myPipeD
   xmonad $ withUrgencyHook NoUrgencyHook $ defaultConfig 
      { terminal     = myTerm
      , modMask      = mod4Mask
      , workspaces   = myWorkspaces
      , layoutHook   = avoidStruts myLayout
      , manageHook   = myManageHook <+> manageDocks
      -- Style
      , borderWidth        = myBorderWidth
      , normalBorderColor  = myNormalBorderColor
      , focusedBorderColor = myFocusBorderColor
      , logHook            = myLogHook d
      -- Behavior
      , keys               = myKeys
      , mouseBindings      = myMouseBindings
      , focusFollowsMouse  = myMouseFocus

   }
