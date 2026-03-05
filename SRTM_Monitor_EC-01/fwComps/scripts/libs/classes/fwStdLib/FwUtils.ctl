/**
(c) Copyright CERN 2005. All rights not expressly granted are reserved.
icecontrols.support@cern.ch

SPDX-License-Identifier: LGPL-3.0-only
**/


/** @file
 *  @brief The library implements various utility functions
 *
 * @author Piotr Golonka, CERN BE-ICS
 * @date 2024
 * @copyright (c) CERN All rights reserved
*/

class FwUtils
{

    /** Find the files in all project dirs, sorted by filename

      @param[in] keyword      the structure in the project dir, as defined in getPath(),
                              e.g. CONFIG_REL_PATH
      @param[in] path         the subpath under the one specified by @c keyword
                              that should be searched for files
      @param[in] filter       (optional) filter for file names in the specified path

      @param[in] fullPaths    if @c true (default) then full paths will be returned;
                              otherwise relative paths (excluding the project paths)

      @returns a list of paths with filenames matching the specified criteria,
              searched through all the project folders, and sorts them alphabetically
              according to the file name.

      Example:
    ~~~{.ctl}
        dyn_string appStyleSheets=FwUtils::getFiles(CONFIG_REL_PATH,"fwStdUi/stylesheets","*.css");
    ~~~
      Assuming that the corresponding project folders would be populated with files with names such as
      @c "10-jcopfw.css", @c "20-unicos.css", @c "90-userCustomisation.css" (possibl in various project paths),
      the list of stylesheets could be processed in precise order and customized as necessary by adding new entries.
      In a similar manner the function may be used to find and load on demand (as "plugins") the available implementation
      of an interface that may be extended with implementations in other components or user-defined classes.

      */
    public static dyn_string getFiles(string keyword, string path, string filter="", bool fullPaths=true)
    {
        dyn_string filesFullPathNames; // return value

        // normalize the parameters
        if (filter=="") filter="*";
        path=makeUnixPath(path);
        if (!path.endsWith("/")) path+="/";

        dyn_string fileNamesAllPaths=getFileNamesLocal(keyword+path, filter);

        fileNamesAllPaths.unique();

        // Calling the getFileNamesLocal() without the last param searches all proj paths.
        // In return we get entries such as "data/FwComponent/myFile.dat", ie. with
        // the "keyword" included, with duplicates (if file was found in more than one
        // project path, yet with no indication on which one).
        // in the @c fullPath mode, we want to expand to full paths and sort according to file name
        // (and not the full project path)

        mapping mFNames;
        for (int i=0; i<fileNamesAllPaths.count(); i++) {
            string fNameWithSubPath=fileNamesAllPaths.at(i);
            string fName=getFileNameFromPath(fNameWithSubPath);
            string fNameWithPath=path+fName;
            if (fullPaths) fNameWithPath=getPath(keyword, path+fName);
            mFNames[fName]=fNameWithPath;
        }
        dyn_string sortedFileNames=mappingKeys(mFNames);
        sortedFileNames.sort();
        for (int i=0; i<sortedFileNames.count(); i++) {
            string fName=sortedFileNames.at(i);
            string fFullName=mFNames.value(fName);
            if (fFullName.isEmpty()) continue; // skip in case of problem
            filesFullPathNames.append(fFullName);
        }
        return filesFullPathNames;
    }
};
