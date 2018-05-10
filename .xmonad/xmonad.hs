-- https://wiki.haskell.org/Xmonad/Config_archive/Template_xmonad.hs_(0.9)
-- https://hackage.haskell.org/package/xmonad-contrib-0.13/docs/XMonad-Actions-Navigation2D.html

-- TODO:
-- i found a gem on their mailing list.  it lets you focus the other screen and change workspaces without losing the fullscreen-ness.
-- import XMonad.Hooks.ManageHelpers
-- import qualified XMonad.StackSet as W

-- --- add the following rule to your manageHook list: isFullscreen --> myDoFullFloat

-- myDoFullFloat :: ManageHook
-- myDoFullFloat = doF W.focusDown <+> doFullFloat

-- TODO: focus stealing: https://github.com/xmonad/xmonad/issues/45

import XMonad
import XMonad.Hooks.ManageDocks (avoidStruts,docks,manageDocks)
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.EwmhDesktops (ewmh, ewmhDesktopsLogHook, ewmhDesktopsEventHook)
import XMonad.Actions.Navigation2D
import XMonad.Layout.Fullscreen
import XMonad.Layout.NoBorders (smartBorders)
import XMonad.Actions.CycleWS
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances
import XMonad.Util.Run (safeSpawn)
import XMonad.Util.NamedWindows (getName)
import Data.Monoid
import Control.Monad
import System.Exit
import Data.List (sortBy)
import Data.Function (on)
import Control.Monad (forM_, join)
import XMonad.Hooks.DynamicLog

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

main = xmonad $ fullscreenSupport $ docks $ ewmh $ withNavigation2DConfig def $ defaults

myTerminal      = "termite"

myFocusFollowsMouse = False

myBorderWidth   = 2

myWorkspaces    = ["1","2","3","4","5","6","7","8","9"]

myNormalBorderColor  = "#dddddd"
myFocusedBorderColor = "#777987"

myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
 
    -- launch a terminal
    [ ((modm,               xK_d), spawn $ XMonad.terminal conf)
    -- , ((modm,               xK_Return     ), spawn $ XMonad.terminal conf)
 
    -- launch dmenu
    , ((modm,               xK_y     ), spawn "launcher")
 
    -- close focused window
    , ((modm, xK_q     ), kill)
    , ((modm, xK_x     ), kill)
    , ((modm, xK_f), sendMessage $ Toggle FULL)
 
     -- Rotate through the available layout algorithms
    , ((modm,               xK_h ), sendMessage NextLayout)
 
    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)
 
    -- Resize viewed windows to the correct size
    -- , ((modm,               xK_n     ), refresh)
 
    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)
   -- Directional navigation of windows
   , ((modm,                 xK_Right), windowGo R False)
   , ((modm,                 xK_Left ), windowGo L False)
   , ((modm,                 xK_Up   ), windowGo U False)
   , ((modm,                 xK_Down ), windowGo D False)
   , ((modm,                 xK_e), windowGo R False)
   , ((modm,                 xK_i ), windowGo L False)
   , ((modm,                 xK_l   ), windowGo U False)
   , ((modm,                 xK_a ), windowGo D False)

   , ((modm .|. shiftMask,                xK_Right), windowSwap R False)
   , ((modm .|. shiftMask,                xK_Left ), windowSwap L False)
   , ((modm .|. shiftMask,                xK_Up   ), windowSwap U False)
   , ((modm .|. shiftMask,                xK_Down ), windowSwap D False)
   , ((modm .|. shiftMask,                xK_e), windowSwap R False)
   , ((modm .|. shiftMask,                xK_i ), windowSwap L False)
   , ((modm .|. shiftMask,                xK_l   ), windowSwap U False)
   , ((modm .|. shiftMask,                xK_a ), windowSwap D False)
 
    -- -- Move focus to the master window
    , ((modm,               xK_i     ), windows W.focusMaster  )
 
    -- -- Swap the focused window and the master window
    -- , ((modm,               xK_Return), windows W.swapMaster)
 
    -- -- Swap the focused window with the next window
    -- , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )
 
    -- -- Swap the focused window with the previous window
    -- , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )
 
    -- Shrink the master area
    , ((modm .|. shiftMask,               xK_n     ), sendMessage Shrink)
 
    -- Expand the master area
    , ((modm .|. shiftMask,               xK_t     ), sendMessage Expand)
 
    -- -- Push window back into tiling
    , ((modm,               xK_h     ), withFocused $ windows . W.sink)
 
    -- -- Increment the number of windows in the master area
    -- , ((modm              , xK_comma ), sendMessage (IncMasterN 1))
 
    -- -- Deincrement the number of windows in the master area
    -- , ((modm              , xK_period), sendMessage (IncMasterN (-1)))
 
    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    -- , ((modm              , xK_b     ), sendMessage ToggleStruts)
    , ((modm,               xK_c),  nextWS)
    , ((modm,               xK_v),    prevWS)
    , ((modm,               xK_w),     toggleWS)
    , ((modm .|. shiftMask, xK_c), shiftToNext >> nextWS)
    , ((modm .|. shiftMask, xK_v),   shiftToPrev >> prevWS)
    -- , ((modm .|. shiftMask, xK_w), shiftToNext >> toggleWS)


    -- , ((modm, xK_ü     ), spawn "playerctl previous  ")
    -- , ((modm, xK_ö     ), spawn "playerctl play      ")
    -- , ((modm, xK_ä     ), spawn "playerctl play-pause")
    , ((modm, xK_p     ), spawn "playerctl stop      ")
    , ((modm, xK_z     ), spawn "playerctl next      ")

    , ((modm, xK_k     ), spawn "xkill")

    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))
    , ((modm .|. shiftMask, xK_x     ), io (exitWith ExitSuccess))
 
    -- Restart xmonad
    , ((modm .|. shiftMask, xK_y     ), spawn "xmonad --recompile && xmonad --restart")

    , ((modm .|. shiftMask .|. controlMask, xK_q     ), spawn "poweroff")
    , ((modm .|. shiftMask .|. controlMask, xK_x     ), spawn "poweroff")
    , ((modm .|. shiftMask .|. controlMask, xK_y     ), spawn "reboot")
    ]
    ++
 
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N and follow
    -- mod-shif-ctrlt-[1..9], Move client to workspace N
    [((m, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [ (W.greedyView, modm)
                    , (liftM2 (.) W.greedyView W.shift, modm .|. shiftMask)
                    , (W.shift, modm .|. shiftMask .|. controlMask)
                    ]
    ]
    -- ++
 
    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    -- [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
    --     | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
    --     , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $
 
    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))
 
    -- mod-button2, Raise the window to the top of the stack
    -- , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))
 
    -- mod-button3, Set the window to floating mode and resize by dragging
    -- , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
    --                                    >> windows W.shiftMaster))
 
    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]


myLayoutHook = smartBorders $ mkToggle ((NOBORDERS ?? FULL ?? EOT)) $ tiled ||| Full
    where
        tiled = Tall nmaster delta ratio
        nmaster = 1				-- # of windows in master pane
        ratio = 1/2				-- ratio master/non-master
        delta = 3/100	-- screen ratio for adjustment


defaults = defaultConfig {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        borderWidth        = myBorderWidth,
        -- modMask            = myModMask,
        -- numlockMask deprecated in 0.9.1
        -- numlockMask        = myNumlockMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,
        clickJustFocuses = False,
 
      -- key bindings
        keys               = myKeys,
        -- mouseBindings      = myMouseBindings,
 
      -- hooks, layouts
        layoutHook         = smartBorders . avoidStruts $ myLayoutHook,
        manageHook         = manageDocks <+> (isFullscreen --> doFullFloat),
        logHook            = dynamicLogWithPP (myPP),
        startupHook        = myStartupHook,
    handleEventHook =  handleEventHook def -- <+> fullscreenEventHook
    }

-- Pipe
myPP = def {
  ppCurrent           = wrap "%{F#fff B#5A5B66} "   " %{F- B-}",
  ppVisible           = wrap "%{F#cc342b}" "%{F-}" . clickable, -- xinerama
  ppHidden            = wrap "%{F#eeeeee}" "%{F-}" . clickable,
  ppHiddenNoWindows   = wrap "%{F#555555}" "%{F-}" . clickable,
  ppUrgent            = wrap "%{F#CE6D00}" "%{F-}" . clickable,
  ppSep               = "",
  ppWsSep             = "",
  ppOrder             = \(ws:_:_:_) -> [ws],
  ppOutput            = \wsStr -> appendFile "/tmp/.xmonad-workspace-log" (wsStr ++ "\n")
} where clickable = \w -> "%{A:xdotool key alt+" ++ w ++ ":} " ++ w ++ " %{A}"


myStartupHook = do
    spawn "nitrogen --set-zoom-fill /home/felix/downloads/wallpapers/wallhaven-48976.jpg"
    safeSpawn "mkfifo" ["/tmp/.xmonad-workspace-log"]
    spawn "statusbar"
