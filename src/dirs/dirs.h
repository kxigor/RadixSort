#ifndef DIRS_H
#define DIRS_H

#include <stdlib.h>

#include <assert.h>
#include <dirent.h>
#include <linux/limits.h>
#include <malloc.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>

/*!
    \defgroup dirs Dirs
    \brief This module is designed to work with folders
    @{
*/
/*!
    The main structure
    \param dir The DIR system structure
    \param dir_path The path to the folder
*/
typedef struct Dir
{
    DIR* dir        ;
    char* dir_path  ;
} Dir;
/*!
    The folder does not necessarily exist, 
    we mean that there is a nesting of non-existent folders

    Hardware dependent, calls mkdir -p
    \param dir_path The path to the new folder
*/
void DirInit(const char* dir_path);
/*!
    Similar things happen in Dir Init, 
    but only the file name
    \param file_path path to the file (possibly non-existent)
*/
void DirFileInit(const char* file_path);
/*!
    Create a folder object
    \param dir_path The path to the folder
    \return A pointer to a new object
*/
Dir* DirCtor(const char* dir_path);
/*!
    Get the following file in the folder
    \param dir Pointer Dir 
    \return File name
*/
char* DirGetNextFileName(Dir* dir);
/*!
    If there is a Ctor, 
    there must be a Dtor
    \param dir Pointer Dir 
*/
void DirDtor(Dir* dir);

/*! @} */

#endif // !DIRS_H