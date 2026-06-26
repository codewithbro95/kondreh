# Kondreh UI Test Plan

Use a clean macOS user account or reset local preferences before first-launch testing.

1. First launch: open Kondreh, confirm no Dock icon remains during normal menu-bar use, complete or skip onboarding, and verify the menu-bar icon appears.
2. Permission granted: click the menu-bar icon, choose Allow Camera Access, and confirm the live preview appears with the green Live indicator.
3. Permission denied: reset camera permission, deny access, reopen preview, and confirm the denied screen opens System Settings.
4. No camera connected: test on a Mac with camera disabled or unavailable and confirm the no-camera empty state is shown.
5. Open and close preview: click the status item, press Escape, and use Close; confirm clicking outside does not close the preview and the camera indicator turns off immediately only when explicitly closed.
6. Switching cameras: connect a USB or Continuity Camera, select it, disconnect it, and confirm fallback to the default camera.
7. Aspect ratio: verify Camera Native, 16:9, 4:3, and 1:1 do not stretch the video.
8. Mirror mode: toggle mirroring and confirm only the preview changes.
9. Settings: open every Settings tab and verify changes persist after relaunch.
10. Global shortcut: record a new shortcut, toggle the preview from another app, disable the shortcut, and confirm it no longer toggles.
11. Quit: right-click the menu-bar icon, choose Quit Kondreh, and confirm the capture session stops.
