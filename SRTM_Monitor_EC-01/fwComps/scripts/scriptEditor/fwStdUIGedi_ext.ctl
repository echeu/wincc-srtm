/**
(c) Copyright CERN 2005. All rights not expressly granted are reserved.
icecontrols.support@cern.ch

SPDX-License-Identifier: LGPL-3.0-only
**/

#uses "CtrlOOUtils"


// NOTE: We want to avoid explicit dependency on FwStdUiTheme class 
// - dynamic loading below

main()
{
    bool isDefault;
    bool stylesEnabled = paCfgReadValueDflt(paCurrentConfigFiles(), "ui", "fwStdUiThemesEnable", false, isDefault);
    if (!stylesEnabled) return;

    _addUiThemeManagement();
}



private vector<shared_ptr<void> > _getStyleList()
{
    // anonymous types, because we do not want a hard dependency on the FwStdUiTheme class
    // (very loose binding)
    
    vector<shared_ptr<void> > styleList;
    function_ptr func_getList =  fwGetFuncPtr("FwStdUi_Theme::getList");
    styleList = callFunction(func_getList);
    return styleList;
}


// list of all themes indexed by actionId (returned by moduleAddAction, and passed implicitly as a param to the callback)
private mapping actionThemeMap; 


private void _addUiThemeManagement()
{
    // dynamic loading of FwStdUiTheme class:
    bool _fwStdUiTheme_loaded = fwGeneral_loadCtrlLib("classes/fwStdUi/FwStdUiTheme.ctl",true,true);

    int idThemeToolbar = moduleAddToolBar("UI Theme");
    int idJcopFwMenu  = moduleAddMenu("JCOP Framework");
    int idThemeMenu = moduleAddSubMenu("UI Theme", idJcopFwMenu);

    // process all themes we have

//    FwStdUi_ThemePVec themeList ;//= FwStdUi_Theme::getList();
      vector<shared_ptr<void> > themeList = _getStyleList();

    for (int i=0;i<themeList.count();i++) {
    
        //FwStdUi_ThemePtr t = themeList.at(i);
        shared_ptr<void> t = themeList.at(i);

        string shortcut="";

        int actionId = moduleAddAction(t.getName(),t.getIcon(),shortcut,idThemeMenu,idThemeToolbar,"_activateUiThemeActionCB");
        moduleSetAction(actionId,"Text",t.getLabel());
        moduleSetAction(actionId,"checkable",true);
        moduleSetAction(actionId,"checked",t.isCurrent());
        moduleSetAction(actionId,"enabled",!t.isCurrent()); // radio-box behavior

        actionThemeMap[actionId]=t;
    }

}

private void _activateUiThemeActionCB(int triggeredActionId)
{    
    //FwStdUi_ThemePtr newTheme=actionThemeMap.value(triggeredActionId,nullptr);
    shared_ptr<void> newTheme=actionThemeMap.value(triggeredActionId,nullptr);
    newTheme.apply();
    
    for (int i=0;i<mappinglen(actionThemeMap);i++) {
        int actionId = actionThemeMap.keyAt(i);
        //FwStdUi_ThemePtr t=actionThemeMap.valueAt(i);
        shared_ptr<void> t=actionThemeMap.valueAt(i);
        bool isNew=(triggeredActionId == actionId);
        moduleSetAction(actionId,"checked",isNew); // uncheck - radio button behaviour
        moduleSetAction(actionId,"enabled",!isNew);  // reenable all others
        moduleSetAction(actionId,"icon",t.getIcon()); // repaint the icon...
    }
}