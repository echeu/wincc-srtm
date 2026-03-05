JCOP FRAMEWORK version 9.3 for WinCC OA 3.19
============================================


INSTALLATION
-------------

This version of the Framework requires WinCC OA 3.19.
If your project is using an earlier version of WinCC OA (e.g. 3.19) please have a look at the "Update" section below.

1. Check that your project works (starts) with WinCC OA 3.19.

2. Stop the project. Perform a backup

3. Download the Component Installation Tool
   from https://jcop.web.cern.ch/jcop-framework-component-installation-tool
   It is recommended to use version 9.2.0 or higher

4. Unzip the installation tool on top of your project folder. 
   If your project already contained a previous version of the Component Installation Tool, 
   the unzipping process should overwrite the previous files

5. Download the JCOP Framework distribution from 
   https://jcop.web.cern.ch/jcop-framework-0
   You may also want to download individual distributions of selected components from 
   https://jcop.web.cern.ch/jcop-framework-components

6. Unzip the JCOP Framework distribution in a convenient temporary space. such as /tmp/jcop-framework-9.3.0
   DO NOT unzip it onto your project or component folder.

7. Start the project

8. Run the Component Installation Tool panel, ie. open the following panel in the "Vision" runtime module
       fwInstallation/fwInstallation.pnl
    or simply from the "JCOP Framework" menu in GEDI

9. Follow the standard procedure for using the Component Installation tool
   - If it is the first time you open the Installation panel, it will ask you for a directory where to install the Framework.
   - in principle there has to be a different installation directory for each different PVSS project
     where you are using the Framework). It is recommended to use an empty folder in your system. 
   - For the field "Look for new components in:" select the PVSS\  subdirectory below the Framework unzipped distribution

10. Install the components you require for your system, following given instructions and prompts.
    In particular, pay attention to the prompt that offers to set up a default user name and password in your project.

    NOTE: as of the 9.3.0 release of the framework numerous previously used icons have been replaced with new standard
    ones provided by the fwStdUi component. For compatibility (assure that the previous icons are available) one should
    consider the installation of the new fwCompatArtwork component (which is, however, not available in the "OSS" release
    of the framework).

11. It is recommended that a restart of the project is performed during the installation.
    The installation tool offers the option of running postInstallation procedures without a project restart,
    yet this option is only recommended for advanced users who deeply understand the consequences of such action


UPDATE
------
In the case where you want to update framework components, still for the same version of WinCC OA (3.19), simply use the
Component Installation tool pointing it at the place where you downloaded and unzipped the Framework Distribution.
Remember to update the fwInstallation tool to the latest required version

However, if you want to perform an upgrade from the previous supported version of WinCC OA, 3.16, the sequence of 
actions is more complex, in particular if you want to migrate your project from RAIMA to SQLite based runtime 
database, or from RDB Archiver to NextGen Archiver. For the update of the project itself we recommend 
using the tool and procedure linked at the WinCC OA downloads page.

To assure cleanest update of projects, we recommend uninstalling all the framework components 
(in WinCC OA 3.16) prior to executing the project update. Then, after the project upgrade (see note
above), deploy the new version of the installation tool and then install the components of the
jcop-framework.
This allows to review and manually clean up the project config file or project folders before the project upgrade.

Another approach is to rename the folder that stores the component prior to the project upgrade, and create
an empty one in its place, then proceed with the project upgrade. Note that in this case one may expect 
many errors being reported by CTRL/UI managers complaining about unresolved/missing libraries, which are
not reachable anymore (as they were moved to the renamed component folder, and the new component folder is empty).

NOTE: specifically in this release of the framework: if you configured alarm filters in the 
NextGen Alarm Screen and you uninstall the NGA component then they willbe lost and should be recreated manually
after the new version is installed in WinCC OA 3.19. You may consider ASCII-exporting them, or proceeding with
the procedure without de-installation of the components.

NOTE: as of the 9.3.0 release of the framework numerous previously used icons have been replaced with new standard
      ones provided by the fwStdUi component. For compatibility (assure that the previous icons are available) one should
      consider the installation of the new fwCompatArtwork component (which is, however, not available in the "OSS" release
      of the framework).

The general steps to follow in the procedure that uninstalls the components are the following:

1. Stop the existing WinCC OA 3.16 project, and make a backup of it

2. Start the project again, note the list of installed components, and then un-install all of 
the JCOP Framework ones that refer to WinCC OA 3.16

3. It is strongly recommended to temporary set the root password to empty, and configure the config file of your project
   to use the root username and password by default.

4. Stop the WinCC OA 3.16 project

5. Update the WinCC OA installation on the machine (usually requires a OS update) or copy it to the machine
    where WinCC OA 3.19 is installed.

6. Update the project using the procedure and tooling provided at the WinCC OA 3.19 Downloads Page.

6. Unzip the latest version of fwInstallation tool (9.3.0 or higher) on top of the project folder

7. Start the project with WinCC OA 3.19. It is recommended to start only the Data Manager, Event Manager, Simulation Manager number 1,
   and the CTRL manager that runs the pvss_scripts.lst . Then start a UI, and open the Component Installation Tool

8. Install newest versions of components that you noted down in point 2; those for the JCOP Framework could be downloaded
   from the Framework downloads pages. The 3.19-version of custom components should be delivered by their maintainers.

9. Restart the project at the end of installation to execute the postInstallation steps

10, Make sure the project works correctly.

11. If you reset the root password to empty in point 3, then you may want to set it again to a strong one  now; 
    Once this is done, remember to put a reasonable default userName/password in the config file of the project

--------------------------------------------------------------------------------------------------------------------
Last update: PG, November 2024
