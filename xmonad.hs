import XMonad
import XMonad.Util.Run
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog
import XMonad.Layout.NoBorders
import XMonad.Layout.Tabbed
import System.IO
import qualified Data.Map as Map

myFont          = "Terminus:pixelsize=14"
myFocusFGColor  = "#ABCDEF"
myFocusBGColor  = "#123456"
myNormalFGColor = "#5678AB"
myNormalBGColor = "#222222"
myIconDir       = "/home/mawww/misc/icons/"

dmenuCmd prompt = "dmenu -fa \"" ++ myFont ++ "\" -p \"" ++ prompt ++
                  "\" -nf \"" ++ myNormalFGColor ++ "\" -nb \"" ++ myNormalBGColor ++
                  "\" -sf \"" ++ myFocusFGColor  ++ "\" -sb \"" ++ myFocusBGColor ++ "\""


main = do
    dzenPipe <- spawnPipe myStatusBar
    xmonad $ defaultConfig
        { borderWidth        = 1
        , terminal           = "urxvt"
        , normalBorderColor  = myNormalBGColor
        , focusedBorderColor = myFocusBGColor
        , modMask            = mod4Mask
        , workspaces         = ["web", "dev", "tmp", "bg"]
        , manageHook         = manageDocks <+> manageHook defaultConfig
        , layoutHook         = smartBorders $ avoidStruts $ layoutHook defaultConfig ||| tabbed shrinkText myTabConfig
        , logHook            = dynamicLogWithPP $ myDzenPP dzenPipe
        , keys               = newKeys
        }

myStatusBar = "dzen2 -x 0 -y 0 -h 16 -w 1000 -ta l -fg '" ++ myNormalFGColor ++
              "' -bg '" ++ myNormalBGColor ++ "' -fn '" ++ myFont ++ "'"

colors fg bg = "^fg(" ++ fg ++ ")^bg(" ++ bg ++ ")"
endcolors = "^fg()^bg()^p()" 
icon name = "^i(" ++ myIconDir ++ "/" ++ name ++ ")"

myDzenPP h = defaultPP
    { ppCurrent = wrap (colors myFocusFGColor myFocusBGColor ++ "^p() ")   (" " ++ endcolors) . \wsId -> dropIx wsId
    , ppVisible = wrap (colors myFocusFGColor myFocusBGColor ++ "^p() ")   (" " ++ endcolors) . \wsId -> dropIx wsId
    , ppHidden  = wrap (colors myNormalFGColor myNormalBGColor ++ "^p() ") (" " ++ endcolors) . \wsId -> dropIx wsId
    , ppSep     = " "
    , ppWsSep   = " "
    , ppTitle   = dzenColor myFocusFGColor ""
    , ppLayout  = dzenColor myNormalFGColor "" .
        (\x -> case x of
         "Tall" -> icon "tall.xbm"
         "Mirror Tall" -> icon "mtall.xbm"
         "Full" -> icon "full.xbm"
         "Tabbed Simplest" -> icon "tabbed.xbm"
         _ -> x
        )
    , ppOutput = hPutStrLn h
    }
    where
    dropIx wsId = if (':' `elem` wsId) then drop 2 wsId else wsId

myTabConfig = defaultTheme
    { activeColor         = myFocusBGColor
    , activeBorderColor   = myFocusBGColor
    , activeTextColor     = myFocusFGColor
    , inactiveColor       = myNormalBGColor
    , inactiveBorderColor = myNormalBGColor
    , inactiveTextColor   = myNormalFGColor
    , urgentColor         = myNormalBGColor
    , urgentBorderColor   = myNormalBGColor
    , urgentTextColor     = myNormalFGColor
    , fontName            = myFont
    , decoHeight          = 16
    }

newKeys x = Map.union (Map.fromList (myKeys x)) (keys defaultConfig x)

myKeys conf@(XConfig {XMonad.modMask = modm }) =
    [ ((modm .|. shiftMask, xK_p), spawn ("exe=`dmenu_path | " ++ dmenuCmd "terminal launch:" ++ "` && urxvt -e \"$exe\""))
    , ((modm              , xK_p), spawn ("exe=`dmenu_path | " ++ dmenuCmd "launch:"++ "` && $exe")) ]
