/**
(c) Copyright CERN 2005. All rights not expressly granted are reserved.
icecontrols.support@cern.ch

SPDX-License-Identifier: LGPL-3.0-only
**/

#uses "CtrlGuiUtils"
#uses "classes/fwStdLib/FwException.ctl"
#uses "classes/fwStdLib/FwUtils.ctl"


private const dyn_string _fwStdUi_paletteColorNames = makeDynString("_3DFace", "_3DText", "_AlternatingRowColorDark", "_AlternatingRowColorLight", "_BrightText",
                                                      "_Button", "_ButtonText", "_ButtonShadow", "_ButtonBarBackground", "_ButtonBarLine",
                                                      "_Highlight", "_HighlightedText", "FwStdUiDisabledFg", "_PlaceholderText",
                                                      "_InputFieldBackground", "_PanelDescriptionBackground", "_PanelDescriptionText",
                                                      "_ToolTip", "_ToolTipText",
                                                      "_Window", "_WindowAlternate", "_WindowText");


// modelled after Qt's QPalette::ColorRole
// to be used with fwGuiFixColorPalette() from CtrlGuiUtils
enum FwStdUi_ColorRole {
    WindowText = 0,
    Foreground = WindowText,
    Button = 1,
    Light = 2,
    MidLight = 3,
    Dark = 4,
    Mid = 5,
    Text = 6,
    BrightText = 7,
    ButtonText = 8,
    Base = 9,
    Window = 10,
    Background = Window,
    Shadow = 11,
    Highlight = 12,
    HighlightedText = 13,
    Link = 14,
    LinkVisited = 15,
    AlternativeBase = 16,
    NoRole = 17,
    ToolTipBase = 18,
    ToolTipText = 19,
    PlaceholderText = 20
};


// modelled after Qt's QPalette::ColorGroup
// to be used with fwGuiFixColorPalette() from CtrlGuiUtils
enum FwStdUi_ColorGroup {
    Active = 0,
    Normal = Active,
    Disabled = 1,
    Inactive = 2
};

/***************************
Through experiments we found the following mapping in the default QtStyle used on Linux:

(we focus only on the "Active:" but one should set "Inactive" to the same (otherwise if a window gets out of focus it changes colors),
and then obviously adjust the "Disabled" too.

Active:Foreground (WindowText) -> arrows in spin button, arrow in cascade button, arrows in scroll bars, 2nd-level arrow in poup menu and cascade button
Active:Background (Window) -> NON-EDITABLE combo-box popup background,  GEDI Menu/Toolbar
Active:Base       -> CheckBox and RadioBox background (only active items!), background of popup menu
Active:Text       -> text of editable and non-editable text field, tickbox/circle in checkbox and radiobox, items color in combobox
Active:PlaceholderText -> if set AFTER Text, then the color of placeholder text in the active/editable, and the text color in non-editable
Active:Highlight  -> frame of currently selected widget, shade of the default button, bgcolor of item selected in the list
Active:Light      -> bottom separator in the tab(!)

What we also see is that these, as well as CSS, will work on the widgets that have STANDARD colors.
If e.g. a textline has custom color then this customization is applied.
There seems to be one exception from this: the background of the disabled text line, which we need to reset via CSS.

Also, there is a peculiarity for the read-only text line: it dims the palette's color contrast (see comment below in the code)


UI Manager makes the following color mapping
---
_Transparent -> Qt::transparent
_3DFace          -> QPalette::Active, QPalette::Window
_3DText          -> QPalette::Active, QPalette::WindowText
_Button          -> QPalette::Active, QPalette::Button
_ButtonText      -> QPalette::Active, QPalette::ButtonText
_ButtonShadow    -> QPalette::Active, QPalette::Shadow
_Window          -> QPalette::Active, QPalette::Base
_WindowText      -> QPalette::Active, QPalette::Text
_WindowAlternate -> QPalette::Active, QPalette::AlternateBase
_BrightText      -> QPalette::Active, QPalette::BrightText
_PlaceholderText -> QPalette::Active, QPalette::PlaceholderText
_Highlight       -> QPalette::Active, QPalette::Highlight
_HighlightedText -> QPalette::Active, QPalette::HighlightedText
_ToolTip         -> QPalette::Inactive, QPalette::ToolTipBase
_ToolTipText     -> QPalette::Inactive, QPalette::_ToolTipText

The way in which system colours are defined on Windows is described at https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getsyscolor
 and it contains the actual colours used by Windows 10/11 these days.

 For Qt it is described in https://doc.qt.io/qt-5/qpalette.html and in particular the color roles https://doc.qt.io/qt-5/qpalette.html#ColorRole-enum

 Notably, for Qt it tells
 - QPalette::Window (QPallette::Background) is a general background color
 - QPalette::WindowText (QPalette::Foreground) is a general foreground color
 - QPalette::Base is the background for text-entry widgets, combobox dropdown lists, toolbar handes. It is usually white or another light color
 - QPalette::AlternateBase - alternative to base for table/list rows, etc
 - QPalette::Text - foreground color to be used with Base. It is usually the same as WindowText and hence must be in good contrast with both Window and Base
 - QPalette::BrightText - should be very different from WindowText and have good constract, typically to use where Text or WindowText would guve poor contract (e.g. pressed buttons)
 - QPalette::PlaceholderText - used for text input widgets; prior to Qt 5.12 the behaviour was to use the Text colour with alpha=128, which is still in place unless one specified an won brush
 - QPalette::ToolTipBase,ToolTipText: NOTE! they always use QPalette::inactive because they are nor active windows!
 - QPalette::Button, QPalette::ButtonText - general buttons; may differ from Window as in some styles buttons have different background
 - QPalette::Light, Midlight, Dark, Mid, Shadow -> all used for 3D bevels and shadow effects; normally derived from Window; Shadow is a very dark one (such as Qt::black)
 - QPalette::Highlight,HighlightedText - to indicate selected or current item; usually Qt::darkBlue/Qt::white
 - QPalette::Link, LinkVisited - not relevant really (links) - not even used by the RichText widget (they use stylesheet)
 - QPalette::NoRole - special ; indicate no role assigned
 */

class FwStdUi_Theme;
using FwStdUi_ThemePtr  = shared_ptr<FwStdUi_Theme>;
using FwStdUi_ThemePVec = vector<FwStdUi_ThemePtr>;

/** FwStdUi Theme

  The class allows to declare instances of UI Themes for fwStdUi, supporting
  adjusting of Qt color palettes, picture (icon) themes and stylesheets.

  */
class FwStdUi_Theme
{

    protected string _name;
    protected string _colorTheme;
    protected string _iconTheme;
    protected string _label;
    protected string _icon; // to be completed...

    protected mapping _colorPalette;

    protected static mapping _fwStdUiThemeMap;
    protected static string _selectedTheme;

    // we return our argument to allow for nice inits
    public static FwStdUi_ThemePtr registerTheme(FwStdUi_ThemePtr newTheme)
    {
        // no check if themes are disabled, as we invoke this function
        // in _fwStdUi_Theme_initializeOnLoad() before the
        // _fwStdUi_themesEnabled is initialized!
        FwException::assertNotNull(newTheme);
        string themeName=newTheme._name;
        FwException::assert(themeName!="", "Theme name must not be empty");

        if (_fwStdUiThemeMap.contains(themeName)) {
            if (!equalPtr(newTheme, _fwStdUiThemeMap.value(themeName))) {
                DebugTN(__FUNCTION__, "WARNING: Theme "+themeName+" already registered; replacing it");
            }
        }
        _fwStdUiThemeMap[themeName]=newTheme;
        return newTheme;
    }

    /* Returns the list of available themes

       so far it is based on available/installed colorDB folders, yet in future we should
       have a plugin-loader capable of loading custom derived classes


       We may want to convert it such that it would contain singletons;

     **/
    public static FwStdUi_ThemePVec getList()
    {
        FwException::assert(_fwStdUi_themesEnabled,"FwStdUi themes are disabled in the config file.");

        FwStdUi_ThemePVec themeList;
        for (int i=0; i<_fwStdUiThemeMap.count(); i++) {
            themeList.append(_fwStdUiThemeMap.valueAt(i));
        }
        return themeList;

        /*
                themeList.append(new FwStdUi_Theme("")); // default one

                // now search for all possible folders under colorDB, in all project folders and create one.
                //
                // for the time being we mock with the two standard ones
                themeList.append(new FwStdUi_Theme("fwStdUi-Light"));
                themeList.append(new FwStdUi_Theme("fwStdUi-Dark"));

                return themeList;
        */
    }

    public static dyn_string getThemeLabels()
    {
        FwException::assert(_fwStdUi_themesEnabled,"FwStdUi themes are disabled in the config file.");
        dyn_string themeLabels;
        for (int i=0; i<_fwStdUiThemeMap.count(); i++) {
            FwStdUi_ThemePtr t=_fwStdUiThemeMap.valueAt(i);
            themeNames.append(t._label);
        }
        return themeLabels;
    }

    public static dyn_string getThemeNames()
    {
        FwException::assert(_fwStdUi_themesEnabled,"FwStdUi themes are disabled in the config file.");
        dyn_string themeNames;
        for (int i=0; i<_fwStdUiThemeMap.count(); i++) {
            FwStdUi_ThemePtr t=_fwStdUiThemeMap.valueAt(i);
            themeNames.append(t._name);
        }
        return themeNames;
    }

    public static FwStdUi_ThemePtr getTheme(string name)
    {
        FwException::assert(_fwStdUi_themesEnabled,"FwStdUi themes are disabled in the config file.");
        FwStdUi_ThemePtr t=_fwStdUiThemeMap.value(name);
        FwException::assertNotNull(t, "Theme "+name+" not found");
        return t;
    }

    public static FwStdUi_ThemePtr getThemeByLabel(string label)
    {
        FwException::assert(_fwStdUi_themesEnabled,"FwStdUi themes are disabled in the config file.");
        for (int i=0; i<_fwStdUiThemeMap.count(); i++) {
            FwStdUi_ThemePtr t=_fwStdUiThemeMap.valueAt(i);
            if (t._label==label) return t;
        }
        FwException::assert(false, "Theme with label "+label+" not found");
        return nullptr;
    }

    /* Create an instance of a theme.

       @param name[in] - the name (id) of the theme;
       @param colorTheme[in] - the name for colorTheme to be applied
       @param iconTheme[in] - the name for the icon theme to be applied; it is a subfolder of
                                the "pictures/" and should contain the "themes/" prefix;
                                e.g. "themes/fwStdUi-Light" ; empty means the default non-themed
                                folder should be used
       @param label[in] - the human-readable name for the theme, as should be displayed in UI
       @param icon[in] - the name of the icon used in the UI to refer to this theme.

     **/
    public FwStdUi_Theme(string name, string colorTheme, string iconTheme, string label, string icon)
    {
        FwException::assert(name!="", "Theme name may not be empty");
        _name=name;
        _colorTheme=colorTheme;
        _iconTheme=iconTheme;
        if (label=="") label=_name;
        _icon=icon;
        initializeColorPalette();
    }

    protected void initializeColorPalette()
    {
        // default implementation is just trivial...
        // it is decoded to RGB after the colorTheme is applied,
        // so that the getColor returns proper colors alrady.
        for (int i=0; i<_fwStdUi_paletteColorNames.count(); i++) {
            string c=_fwStdUi_paletteColorNames.at(i);
            _colorPalette[c]=c;
        }
    }


    public static string getCurrentThemeName()
    {
        return _selectedTheme;
        // we might want to also compare with what colorGetActiveScheme() says...
    }

    public static FwStdUi_ThemePtr getCurrentTheme()
    {
        return getTheme(_selectedTheme);
    }

    public bool isCurrent()
    {
        return this._name==_selectedTheme;
    }

    public string getName()  {return _name;}
    public string getLabel() {return _label;}
    public string getIcon()  {return _icon;}

    public static void applyColorToPalette(FwStdUi_ColorGroup colorGroup, FwStdUi_ColorRole colorRole, string colorName)
    {
        int r, g, b, a;
        int rc=colorToRgb(colorName, r, g, b, a);
        FwException::assert(rc==0, "Could not decode the color "+colorName);
        fwGuiFixColorPalette(colorGroup, colorRole, r, g, b, a); // active button
    }

    public void apply()
    {
        // Certain aspects, such as the bgcolor of disabled line-edit line may only be fixed with CSS.
        // After changing the active color theme and applying the color palette fixes, we should
        // re-apply the application-level CSS, with some extra hints which we define here.
        // Note that at the first time we apply the modified stylesheet we need to set the color palette once
        // again - this is notably for some line-edits or table headers to regain their color.


        _selectedTheme=this._name;
        activateColorTheme();
        activateIconTheme();
        fixColorPalette();

        // we need to reapply to fix customised colors of text lines, etc
        activateColorTheme();
        // and reapply the stylesheets, but after a slight delay
        applyStyleSheetsAsync(this.customStyleSheetFragment());
    }



    protected void activateColorTheme()
    {
        colorSetActiveScheme(_colorTheme);
    }

    protected void activateIconTheme()
    {
        setActiveIconTheme(_iconTheme);
    }

    protected void fixColorPalette()
    {

        applyColorToPalette(FwStdUi_ColorGroup::Active, FwStdUi_ColorRole::Button,            _colorPalette["_Button"]);
        applyColorToPalette(FwStdUi_ColorGroup::Active, FwStdUi_ColorRole::ButtonText,        _colorPalette["_ButtonText"]);
        applyColorToPalette(FwStdUi_ColorGroup::Active, FwStdUi_ColorRole::Shadow,            _colorPalette["_ButtonShadow"]);
        applyColorToPalette(FwStdUi_ColorGroup::Active, FwStdUi_ColorRole::Base,              _colorPalette["_Window"]);    // checkbox bg, combo popup
        applyColorToPalette(FwStdUi_ColorGroup::Active, FwStdUi_ColorRole::Window,            _colorPalette["_3DFace"]); // bg of non-editable combo box and App menu
        applyColorToPalette(FwStdUi_ColorGroup::Active, FwStdUi_ColorRole::AlternativeBase,   _colorPalette["_WindowAlternate"]);
        applyColorToPalette(FwStdUi_ColorGroup::Active, FwStdUi_ColorRole::Text,              _colorPalette["_WindowText"]);
        applyColorToPalette(FwStdUi_ColorGroup::Active, FwStdUi_ColorRole::WindowText,        _colorPalette["_3DText"]);
        applyColorToPalette(FwStdUi_ColorGroup::Active, FwStdUi_ColorRole::BrightText,        _colorPalette["_BrightText"]);
        applyColorToPalette(FwStdUi_ColorGroup::Active, FwStdUi_ColorRole::PlaceholderText,   _colorPalette["_PlaceholderText"]);
        applyColorToPalette(FwStdUi_ColorGroup::Active, FwStdUi_ColorRole::Highlight,         _colorPalette["_Highlight"]);
        applyColorToPalette(FwStdUi_ColorGroup::Active, FwStdUi_ColorRole::HighlightedText,   _colorPalette["_HighlightedText"]);

        applyColorToPalette(FwStdUi_ColorGroup::Inactive, FwStdUi_ColorRole::Button,          _colorPalette["_Button"]);
        applyColorToPalette(FwStdUi_ColorGroup::Inactive, FwStdUi_ColorRole::ButtonText,      _colorPalette["_ButtonText"]);
        applyColorToPalette(FwStdUi_ColorGroup::Inactive, FwStdUi_ColorRole::Shadow,          _colorPalette["_ButtonShadow"]);
        applyColorToPalette(FwStdUi_ColorGroup::Inactive, FwStdUi_ColorRole::Base,            _colorPalette["_Window"]);
        applyColorToPalette(FwStdUi_ColorGroup::Inactive, FwStdUi_ColorRole::Window,          _colorPalette["_3DFace"]); // bg of non-editable combo box and App menu
        applyColorToPalette(FwStdUi_ColorGroup::Inactive, FwStdUi_ColorRole::AlternativeBase, _colorPalette["_WindowAlternate"]);
        applyColorToPalette(FwStdUi_ColorGroup::Inactive, FwStdUi_ColorRole::Text,            _colorPalette["_WindowText"]);
        applyColorToPalette(FwStdUi_ColorGroup::Inactive, FwStdUi_ColorRole::WindowText,      _colorPalette["_3DText"]);
        applyColorToPalette(FwStdUi_ColorGroup::Inactive, FwStdUi_ColorRole::BrightText,      _colorPalette["_BrightText"]);
        applyColorToPalette(FwStdUi_ColorGroup::Inactive, FwStdUi_ColorRole::PlaceholderText, _colorPalette["_PlaceholderText"]);
        applyColorToPalette(FwStdUi_ColorGroup::Inactive, FwStdUi_ColorRole::Highlight,       _colorPalette["_Highlight"]);
        applyColorToPalette(FwStdUi_ColorGroup::Inactive, FwStdUi_ColorRole::HighlightedText, _colorPalette["_HighlightedText"]);

        applyColorToPalette(FwStdUi_ColorGroup::Disabled, FwStdUi_ColorRole::Base,            _colorPalette["_Window"]);
        applyColorToPalette(FwStdUi_ColorGroup::Disabled, FwStdUi_ColorRole::Window,          _colorPalette["_3DFace"]); // bg of non-editable combo box and App menu

        applyColorToPalette(FwStdUi_ColorGroup::Disabled, FwStdUi_ColorRole::AlternativeBase, _colorPalette["_WindowAlternate"]);
        //applyColorToPalette(FwStdUi_ColorGroup::Disabled, FwStdUi_ColorRole::Text, _colorPalette["_WindowText");
        //applyColorToPalette(FwStdUi_ColorGroup::Disabled, FwStdUi_ColorRole::Text, _colorPalette["FwStdUiInputDisabledText");
        applyColorToPalette(FwStdUi_ColorGroup::Disabled, FwStdUi_ColorRole::Text,            _colorPalette["FwStdUiDisabledFg"]); // -> this is also used for the disabled text in the context menu

        applyColorToPalette(FwStdUi_ColorGroup::Disabled, FwStdUi_ColorRole::Button,          _colorPalette["_Button"]);
        //applyColorToPalette(FwStdUi_ColorGroup::Disabled, FwStdUi_ColorRole::ButtonText, _colorPalette["_ButtonText"]);
        applyColorToPalette(FwStdUi_ColorGroup::Disabled, FwStdUi_ColorRole::ButtonText,      _colorPalette["FwStdUiDisabledFg"]); // We need a FwStdUiButtonTextDisabled with a bit more or contrast(?)
        applyColorToPalette(FwStdUi_ColorGroup::Disabled, FwStdUi_ColorRole::Shadow,          _colorPalette["_ButtonShadow"]);




        // and this one is to have a "embossing" around the disabled menu item CE_MenuItem that is implemented in the "fusion" Qt style (qfusionstyle.cpp)
        applyColorToPalette(FwStdUi_ColorGroup::Disabled, FwStdUi_ColorRole::Light,           _colorPalette["_WindowAlternate"]); // we should have "MenuItemDisabledHighlight"
        // however, the Light() is also used in PE_FrameDockWidget, PE_FrameWindow, PE_FrameTabBarBase

        applyColorToPalette(FwStdUi_ColorGroup::Disabled, FwStdUi_ColorRole::WindowText,      _colorPalette["_3DText"]);
        applyColorToPalette(FwStdUi_ColorGroup::Disabled, FwStdUi_ColorRole::BrightText,      _colorPalette["_BrightText"]);
        applyColorToPalette(FwStdUi_ColorGroup::Disabled, FwStdUi_ColorRole::PlaceholderText, _colorPalette["_PlaceholderText"]);
        applyColorToPalette(FwStdUi_ColorGroup::Disabled, FwStdUi_ColorRole::Highlight,       _colorPalette["_Highlight"]);
        applyColorToPalette(FwStdUi_ColorGroup::Disabled, FwStdUi_ColorRole::HighlightedText, _colorPalette["_HighlightedText"]);

        // tooltips are only in the inactive color group
        applyColorToPalette(FwStdUi_ColorGroup::Inactive, FwStdUi_ColorRole::ToolTipBase,     _colorPalette["_ToolTip"]);
        applyColorToPalette(FwStdUi_ColorGroup::Inactive, FwStdUi_ColorRole::ToolTipText,     _colorPalette["_ToolTipText"]);
    }



    /** Custom CSS fragment for the class

      If overriden in the child classes, allows to append a class-specific CSS fragment.

      */
    public string customStyleSheetFragment()
    {
        return "";
    }


    /** Dynamic reload/apply customizable application stylesheets

        The method may be called either as a static, in which case there is no
        custom-fragment being applied - useful for app startup where styles are still
        disabled, or from the apply() method which will specify the custom fragment.


        This method is synchronous, and should not be invoked many times
        (e.g. from reference panels, which are loaded in a large amount); for such
        cases use @ref FwStdUi_Theme::applyStyleSheetsAsync() (which is used e.g. in fwStdUi/fwPanelHeader.pnl )

        @returns true if the stylesheets have effectively been modified, false if there was no
            need to reapply it because there was no change.
     */
    public static synchronized bool applyStyleSheets(string customCssFragment="")
    {

        /*

          Loads all the stylesheets declared in the fwStdUi/stylesheets/ subfolders,
        stitches them together in alphabetic order, combines with the current
        Qt application stylesheet and reapplies.

        Through the file naming convention it is possible to control overriding
        and customize the stylesheets. For instance parts of definitions done in the
        10-jcopfw.css files may be further overriden by the ones in 60-unicosfw.css ,
        and then in 90-cryo.css and then 99-cryoP5.css due to the strict filename sorting
        (each component or application may choose the name and order with
        respect to others, by choosing the number at the beginning of the file name).
        This mechanism of dynamic extension of configuration is well known from e.g. Linux
        configuration mechanisms.

        It is possible to reapply the existing styles dynamically at runtime by invoking
        this method as needed (e.g. after adding or editing a stylesheet file). The method
        makes the effort of identifying the part of the Qt Application stylesheet that it manages,
        and replaces the relevant part of the stylesheet, without overwriting the parts of it
        defined through other methods (such as the main config/stylesheet.css file).

        */


        string currentCss = getApplicationProperty("styleSheet");

        const string cssDelimiterStart = "\n/*=- JCOP/UNICOS FRAMEWORK STYLESHEET START -=*/\n";
        const string cssDelimiterEnd   = "\n/*=- JCOP/UNICOS FRAMEWORK STYLESHEET END -=*/\n";

        string newCss=currentCss;

        // clean up what we have previously added.
        int posStart=newCss.indexOf(cssDelimiterStart);
        if (posStart>=0) {
            int posEnd=newCss.indexOf(cssDelimiterEnd);
            if (posEnd<0) {
                throw (makeError("", PRIO_WARNING, ERR_CONTROL, "Framework stylesheet delimiter not found in the current application style sheet."));
            } else {
                newCss.remove(posStart, posEnd-posStart+cssDelimiterEnd.length());
            }
        }

        dyn_string cssFiles=FwUtils::getFiles(CONFIG_REL_PATH, "fwStdUi/stylesheets", "*.css");
        if (cssFiles.isEmpty()) return false;

        newCss += cssDelimiterStart;

        for (int i=0; i<cssFiles.count(); i++) {
            string cssFileName=cssFiles.at(i);
            string cssFragment;
            bool ok=fileToString(cssFileName, cssFragment);
            if (!ok) {
                throw (makeError("", PRIO_WARNING, ERR_CONTROL, "Could not load framework stylesheet fragment "+cssFileName));
                continue;
            }
            newCss+=cssFragment;
        }

        if (customCssFragment!="") {
            newCss+="\n /* Custom CSS Fragment */\n";
            newCss+=customCssFragment;
            newCss+="\n";
        }

        newCss+=cssDelimiterEnd;

        // there is no point in comparing the new and old CSS because we use the "oa-color" extension in our CSS files
        // while the one returned from the application will be decoded to a argb hex string...
        //DebugFTN("FWSTDUI",__FUNCTION__,"Applying modified stylesheet with files",cssFiles);
        setApplicationProperty("styleSheet", newCss);
        return true;
    }


    // asynchronous execution of applyStyleSheets

    private static bool _applyStyleSheetsPending=false; // semaphor for synchronized section
    public static void _applyStyleSheetsWorker(string customCssFragment="")
    {
        delay(0,10); // how long we should wait to collect requests
        synchronized(_applyStyleSheetsPending) {
            applyStyleSheets(customCssFragment);
            _applyStyleSheetsPending=false;
        }
    }

    /** Asynchronous version of @ref applyStyleSheets

      This method should be used if the applyStyleSheets might need to
      be executed from many sources (e.g. init scripts of many ref panels).

      It will wait 100ms to collect all the execution requests and then
      fire up just once.

      The customCssFragment would be used if we call if from inside the apply()
      method, otherwise (e.g. at startup without themes, but with styles) we
      may still call it.

      Implementation detail: as we want to call it also from the initialisation of the UI,
          (library-initialisation script) we need a separate *script* to run it.
          Having a thread is not sufficient, because it would die together with the script that
          invoked us, ie. immediately. A waitThread() in the invoker would not work either,
          because it is again a waiting function which is not permited in the library-init functions.
          Hence, we will use the startScript(), and invoke the static _applyStyleSheetsWorker, which
          needs to be public. The reason why we want it this way is to protect the state of the
          _applyStyleSheetsPending variable that we use to trace if the execution was already scheduled:
          it is set inside FwStdUi_Theme::applyStyleSheetsAsync() and reset in
          FwStdUi_Theme::_applyStyleSheetsWorker() .

      */
    public static void applyStyleSheetsAsync(string customCssFragment="")
    {
        synchronized(_applyStyleSheetsPending) {
            if (_applyStyleSheetsPending) return;
            _applyStyleSheetsPending=true;
            startScript("void main(string cssFragment) {FwStdUi_Theme::_applyStyleSheetsWorker(cssFragment);}",
                        makeDynString(), // sorry, no dollars :-)
                        "main",
                        makeDynMixed(customCssFragment));
        }
    }



    /** INTERNAL

      Returns a copy of a map with all styles; used internally at initialization.
      @private
      */
    public static mapping _getThemeMap_internal()
    {
        mapping mCopy=_fwStdUiThemeMap;
        return mCopy;
    }

};



//-------------------------------------------------------------------------------------------------------------

/** Specific implementation of the Default UI Theme

  This specialization ensures
  */
class FwStdUi_ThemeDefault : FwStdUi_Theme
{
    public FwStdUi_ThemeDefault(string name, string colorTheme, string iconTheme, string label, string icon):
        FwStdUi_Theme(name, colorTheme, iconTheme, label, icon) {}

    // NOTE this one should be called before any scheme is activated to snapshot standard color definitions
    // as provided by the current QPalette at the application startup
    protected void initializeColorPalette()
    {
        for (int i=0; i<_fwStdUi_paletteColorNames.count(); i++) {
            string c=_fwStdUi_paletteColorNames.at(i);
            int r, g, b, a;
            colorToRgb(c, r, g, b, a);
            string sColor="{"+r+","+g+","+b;
            if (a!=255) sColor+=","+a;
            sColor+="}";
            _colorPalette[c]=sColor;
        }
    }

};



//---------------------------------------------------------------------------------------------------
private bool _fwStdUi_Theme_initializeOnLoad()
{
    bool isDefault;
    bool stylesEnabled = paCfgReadValueDflt(paCurrentConfigFiles(), "ui", "fwStdUiThemesEnable", false, isDefault);

    if (!stylesEnabled) {
        bool disableStylesheetsOnStartup=paCfgReadValueDflt(paCurrentConfigFiles(), "ui", "fwStdUiDisableStylesheetsOnStartup", false, isDefault);
        if (!disableStylesheetsOnStartup) {
            FwStdUi_Theme::applyStyleSheets(); // apply default stylesheets;
            // note! at this point we do not have themes yet, hence no custom CSS fragments, and it is sufficient to call it as is
        }
        return false;
    }


    try {
        // create standard themes
        FwStdUi_ThemePtr defaultTheme = new FwStdUi_ThemeDefault("default",       "",              "",                     "Default", "fwStdUi/actions/redo.svg");
        FwStdUi_ThemePtr lightTheme   = new FwStdUi_Theme("fwStdUi-Light", "fwStdUi-Light", "themes/fwStdUi-Light", "Light",   "fwStdUi/actions/lightMode.svg");
        FwStdUi_ThemePtr darkTheme    = new FwStdUi_Theme("fwStdUi-Dark",  "fwStdUi-Dark",  "themes/fwStdUi-Dark",  "Dark",    "fwStdUi/actions/darkMode.svg");

        FwStdUi_Theme::registerTheme(defaultTheme);
        FwStdUi_Theme::registerTheme(lightTheme);
        FwStdUi_Theme::registerTheme(darkTheme);

        // load custom theme classes; they are supposed to auto-register as shown in the example included with test component
        dyn_string themeLibFiles=FwUtils::getFiles(LIBS_REL_PATH, "classes/fwStdUi/themes", "*.ctl", false);
        for (int i=0; i<themeLibFiles.count(); i++) {
            //DebugTN("FwStdUi: Loading Custom Theme Library", themeLibFiles.at(i));
            fwGeneral_loadCtrlLib(themeLibFiles.at(i), true, true);
        }

        string startupThemeName = paCfgReadValueDflt(paCurrentConfigFiles(), "ui", "fwStdUiStartupTheme", "default", isDefault);

        // we do not use FwStdUi_Theme::getTheme() yet, because we are not fully initialized by that moment (_fwStdUi_themesEnabled not assigned yet).
        mapping themeMap=FwStdUi_Theme::_getThemeMap_internal();
        FwStdUi_ThemePtr startupTheme=themeMap.value(startupThemeName,nullptr);
        if (equalPtr(startupTheme,nullptr)) {
            throwError(makeError("",PRIO_WARNING,ERR_PARAM,0,"FwStdUi Startup Theme "+startupStyleName+" not found; using the default instead."));
            assignPtr(startupTheme,defaultTheme);
        }
        startupTheme.apply();

    } catch {
        // DO NOT USE FwException::handleLast() -> we mat not pop up a dialogusing fwOOPanelOpen()
        // as there is no myModuleName() yet at this stage! Only print out to the log!
        throwError(FwException::last().getErrClass());
        FwException::last().print(true);
    }

    return true;
}


// instead, have a single initializer function which would create these, and do class-loading...
const bool _fwStdUi_themesEnabled=_fwStdUi_Theme_initializeOnLoad();
