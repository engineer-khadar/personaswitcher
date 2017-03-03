; Persona Switcher Testing Library

#include <FF V0.6.0.1b-15.au3>
#include <Array.au3>

; ==========================================================
; Name ..........: InitializeFirefox
; Description ...: Starts Firefox Developer Edition,
;                  connects to it through MozRepl, then
;                  pauses the script until the Firefox
;                  window is active.
; Return Value ..: The process ID of the started Firefox window.
; ==============================================================================
Func InitializeFirefox()
   $FF = @ProgramFilesDir & "\Firefox Developer Edition\firefox.exe"
   If FileExists($FF) Then
	  Local $PID = Run($FF, "", @SW_SHOWMAXIMIZED)
   Else
	  MsgBox(64, $FF, "Does not exists. Aborting tests.")
	  Exit(1)
   EndIf

   ; Wait for the Firefox window to load
   ProcessWait($PID)
   WinWaitActive("[CLASS:MozillaWindowClass]")

   ; connect to a running Firefox with MozRepl
   If _FFConnect(Default, Default, 10000) Then
	  ; ensure firefox window is active before proceeding
	  _FFLoadWait()
	  ResetPersonaSwitcherPrefs()
	  WinWaitActive("[CLASS:MozillaWindowClass]")
	  Return $PID
   Else
     MsgBox(64, "", "Can't connect to Firefox. Aborting tests.")
	 Exit(1)
   EndIf
EndFunc


; ==========================================================
; Name ..........: EndFirefox
; Description ...: Closes and disconnects from Firefox
; ==============================================================================
Func EndFirefox()
   _FFWindowClose()
   _FFDisConnect()
EndFunc


; ==========================================================
; Name ..........: RestartFirefox
; Description ...: Closes Firefox and starts a new session
; Return Value ..: The process ID of the started Firefox window.
; ==============================================================================
Func RestartFirefox()
   EndFirefox()
   WinWaitActive("[CLASS:MozillaWindowClass]")
   return InitializeFirefox()
EndFunc


; ==========================================================
; Name ..........: SaveResultsToFile
; Description ...: Takes an array of test result strings and prints them to a file.
;                  file is saved to same directory this script is ran from
; Parameters ....: $tests - an array of strings that provide test results
;                  $testname - the testing category name
; ==============================================================================
Func SaveResultsToFile(ByRef $tests, ByRef $testname)
   ; set directory to script directory, append "Results .txt" to testname
   Local Const $sFilePath = @ScriptDir & "\PS Automated Tests Results.txt"

   ; open the file for writing and store the handle to a variable
   Local $hFileOpen = FileOpen($sFilePath, 2)

   ; check that file was opened
   If $hFileOpen = -1 Then
       MsgBox(64, "", "An error occurred attempting to write results file.")
       Exit(1)
   EndIf

   ; write file header
   FileWrite($hFileOpen, $testname & " - results" & @CRLF)

   ; write results to file
   For $i = 0 To UBound($tests) - 1
	  FileWrite($hFileOpen, $tests[$i] & @CRLF)
   Next

   ; close the handle returned by FileOpen
   FileClose($hFileOpen)
EndFunc


; ==========================================================
; Name ..........: ResetPersonaSwitcherPrefs
; Description ...: Resets all of Persona Switcher's preferences on the about:config page
; ==============================================================================
Func ResetPersonaSwitcherPrefs()
   _FFPrefReset("extensions.personaswitcher.accesskey")
   _FFPrefReset("extensions.personaswitcher.activateaccel")
   _FFPrefReset("extensions.personaswitcher.activatealt")
   _FFPrefReset("extensions.personaswitcher.activatecontrol")
   _FFPrefReset("extensions.personaswitcher.activatekey")
   _FFPrefReset("extensions.personaswitcher.activatemeta")
   _FFPrefReset("extensions.personaswitcher.activateos")
   _FFPrefReset("extensions.personaswitcher.activateshift")
   _FFPrefReset("extensions.personaswitcher.auto")
   _FFPrefReset("extensions.personaswitcher.autoaccel")
   _FFPrefReset("extensions.personaswitcher.autoalt")
   _FFPrefReset("extensions.personaswitcher.autocontrol")
   _FFPrefReset("extensions.personaswitcher.autokey")
   _FFPrefReset("extensions.personaswitcher.autometa")
   _FFPrefReset("extensions.personaswitcher.autominutes")
   _FFPrefReset("extensions.personaswitcher.autoos")
   _FFPrefReset("extensions.personaswitcher.autoshift")
   _FFPrefReset("extensions.personaswitcher.current")
   _FFPrefReset("extensions.personaswitcher.debug")
   _FFPrefReset("extensions.personaswitcher.defaccel")
   _FFPrefReset("extensions.personaswitcher.defalt")
   _FFPrefReset("extensions.personaswitcher.defcontrol")
   _FFPrefReset("extensions.personaswitcher.defkey")
   _FFPrefReset("extensions.personaswitcher.defmeta")
   _FFPrefReset("extensions.personaswitcher.defos")
   _FFPrefReset("extensions.personaswitcher.defshift")
   _FFPrefReset("extensions.personaswitcher.fastswitch")
   _FFPrefReset("extensions.personaswitcher.icon-preview")
   _FFPrefReset("extensions.personaswitcher.main-menubar")
   _FFPrefReset("extensions.personaswitcher.notification-workaround")
   _FFPrefReset("extensions.personaswitcher.preview")
   _FFPrefReset("extensions.personaswitcher.preview-delay")
   _FFPrefReset("extensions.personaswitcher.random")
   _FFPrefReset("extensions.personaswitcher.rotaccel")
   _FFPrefReset("extensions.personaswitcher.rotalt")
   _FFPrefReset("extensions.personaswitcher.rotcontrol")
   _FFPrefReset("extensions.personaswitcher.rotkey")
   _FFPrefReset("extensions.personaswitcher.rotmeta")
   _FFPrefReset("extensions.personaswitcher.rotos")
   _FFPrefReset("extensions.personaswitcher.rotshift")
   _FFPrefReset("extensions.personaswitcher.startup-switch")
   _FFPrefReset("extensions.personaswitcher.static-popups")
   _FFPrefReset("extensions.personaswitcher.toolbox-maxheight")
   _FFPrefReset("extensions.personaswitcher.toolbox-minheight")
   _FFPrefReset("extensions.personaswitcher.tools-submenu")
EndFunc


; ==========================================================
; Name ..........: OpenPersonaSwitcherPrefs
; Description ...: Opens Persona Switcher's options page
; Return Value ..: Success      - True
;                  Failure      - False
; ==============================================================================
Func OpenPersonaSwitcherPrefs()
   ; open addons page
   _FFTabAdd("about:addons")
   _FFLoadWait()

   ; opens addons in current window, disabled because of timing errors
   ;_FFCmd("openUILinkIn('about:addons', whereToOpenLink())")

   ; get to the extensions menu on the sidebar
   _FFClick("category-extension", "id", 0)
   _FFLoadWait()

   ; send JavaScript to open prefs
   _FFCmd("window.content.document.getElementsByAttribute('name', 'Persona Switcher')[0].showPreferences()", 0)

   ; wait at most 3 seconds for the preferences window to be open
   If WinWaitActive("Persona Switcher preferences", "", 3) Then
	  return True
   Else
	  MsgBox(64, "", "Unable to reach Persona Switcher preferences.")
	  return False
   EndIf
EndFunc


; ==========================================================
; Name ..........: OpenPersonaSwitcherButton
; Description ...: Opens the popup associated with the Persona Switcher button loacted in the navigator toolbar
; Return Value ..: Success      - 1
;                  Failure      - 0
; ==============================================================================
Func OpenPersonaSwitcherButton()
   Local $PSDocument
   Local $PSButton
   Local $PSPopup
   Local $PSmsg = 'try{PSDocument=Components.classes["@mozilla.org/appshell/window-mediator;1"].getService(Components.interfaces.nsIWindowMediator).getMostRecentWindow("navigator:browser").document;PSButton=PSDocument.getElementsByAttribute("id", "personaswitcher-button")[0];PSPopup=PSDocument.getElementsByAttribute("id", "personaswitcher-button-popup")[0];PSPopup.openPopup(PSButton, "after_start", 0,0,false,false,null);}catch(e){"Unable to open Persona Switcher Button";};'
   return __FFSend($PSmsg)
EndFunc


; ==========================================================
; Name ..........: GetListOfThemeIds
; Description ...: Grabs the id's of the installed themes, except the defaults
; Return Value ..: array of theme ids
; ==============================================================================
Func GetListOfThemeIds()
   ; Grab json list from preferences and parse for theme ids
   Local $jsonThemeList = _FFPrefGet("lightweightThemes.usedThemes")
   Local $themeIdList = StringRegExp($jsonThemeList, '("id":"[^\"]*")', 3) ; Regex for format "id":"286995"

   ; Pass in only the id of a theme into the themeIdList array
   For $i = 0 To UBound($themeIdList) - 1
	  $themeIdList[$i] = StringTrimRight(StringTrimLeft($themeIdList[$i], 6), 1)
	  Next
   return $themeIdList
EndFunc


; ==========================================================
; Name ..........: ResetToDefaultTheme
; Description ...: Resets Firefox's theme to the default theme through the appearance page
; Return Value ..: Theme changed to default - True
;                  Theme unchanged          - False
; ==============================================================================
Func ResetToDefaultTheme()
   If _FFPrefGet("lightweightThemes.selectedThemeID") == "" Then
	  return False
   EndIf

   ; open addons page
   _FFTabAdd("about:addons")
   _FFLoadWait()

   ; get to the appearences menu on the sidebar
   _FFClick("category-theme", "id", 0)
   _FFLoadWait()

   ; send JavaScript to disable active themes
   _FFCmd("window.content.document" & _
	  ".getElementsByAttribute('active', 'true')[0]" & _
	  ".userDisabled = true", 0)
   _FFCmd("window.content.document" & _
	  ".getElementsByAttribute('active', 'true')[" & _
		 "window.content.document" & _
		 ".getElementsByAttribute('active', 'true').length - 1" & _
	  "].userDisabled = true", 0)

   Sleep(1000)
   _FFTabClose()
   _FFLoadWait()

   If _FFPrefGet("lightweightThemes.selectedThemeID") == "" Then
	  return True
   Else
	  MsgBox(64, "", "Error, default theme was not enabled.")
	  return False
   EndIf
EndFunc


; ==========================================================
; Name ..........: GetDisplayedThemeBackground
; Description ...: Grabs the local URL of the current displayed Firefox theme's background image
; Return Value ..: Success      - URL for background image of displayed theme
;                  Failure      - False
; ==============================================================================
Func GetDisplayedThemeBackground()
   Local $Cmd = _FFCmd('getComputedStyle(' & _
		 'Components.classes["@mozilla.org/appshell/window-mediator;1"]' & _
		 '.getService(Components.interfaces.nsIWindowMediator)' & _
		 '.getMostRecentWindow("navigator:browser").document' & _
		 '.getElementsByAttribute("id", "main-window")[0]' & _
	  ').backgroundImage', 0)
   return StringTrimRight(StringTrimLeft($Cmd, 5), 2)
EndFunc