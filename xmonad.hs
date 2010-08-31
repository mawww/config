import XMonad
import XMonad.Util.Run
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog
import XMonad.Layout.NoBorders
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
        , layoutHook         = smartBorders (avoidStruts $ layoutHook defaultConfig)
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
         _ -> x
        )
    , ppOutput = hPutStrLn h
    }
    where
    dropIx wsId = if (':' `elem` wsId) then drop 2 wsId else wsId

newKeys x = Map.union (Map.fromList (myKeys x)) (keys defaultConfig x)

myKeys conf@(XConfig {XMonad.modMask = modm }) =
    [ ((modm .|. shiftMask, xK_p), spawn ("exe=`dmenu_path | " ++ dmenuCmd "terminal launch:" ++ "` && urxvt -e \"$exe\""))
    , ((modm              , xK_p), spawn ("exe=`dmenu_path | " ++ dmenuCmd "launch:"++ "` && $exe")) ]
