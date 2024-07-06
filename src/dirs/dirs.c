#include "dirs.h"

void DirInit(const char* dir_path)
{
    assert(dir_path != NULL);

    static char command[PATH_MAX] = {};
    sprintf(command, "mkdir -p %s", dir_path);
    system(command);
}

void DirFileInit(const char* file_path)
{
    assert(file_path != NULL);

    static char dir_path[PATH_MAX] = {};
    sprintf(dir_path, "%s", file_path);

    size_t dir_path_len = strlen(dir_path);

    if(dir_path_len <= 2)
    {
        return;
    }

    size_t slash_pos = 0;

    for(size_t pos = 0; pos < dir_path_len - 1; pos++)
    {
        if(dir_path[pos] == '/')
        {
            slash_pos = pos;
        }
    }

    if(slash_pos == 0)
    {
        return;
    }

    dir_path[slash_pos] = '\0';

    DirInit(dir_path);
}

Dir* DirCtor(const char* dir_path)
{
    assert(dir_path != NULL);

    DirInit(dir_path);

    Dir* dir = calloc(1, sizeof(Dir));
    assert(dir != NULL);

    dir->dir = opendir(dir_path);
    dir->dir_path = strdup(dir_path);
    assert(dir->dir_path != NULL);

    /*
        Remove the unnecessary bracket if there is one
    */
    size_t dir_path_sze = strlen(dir_path);
    assert(dir_path_sze > 0);
    if(dir_path[dir_path_sze - 1] == '/')
    {
        dir->dir_path[dir_path_sze - 1] = '\0';
    }

    return dir;
}

char* DirGetNextFileName(Dir* dir)
{
    assert(dir != NULL);
    assert(dir->dir != NULL);
    assert(dir->dir_path != NULL);

    static char file_pwd[PATH_MAX] = {};

    struct dirent* file_object = NULL;
    struct stat file_stat = {};

    char* outfilename = NULL;

    while ((file_object = readdir(dir->dir)) != NULL)
    {
        sprintf(
            file_pwd      ,
            "%s/%s"       ,
            dir->dir_path , 
            file_object->d_name
        );

        int stat_status = stat(
            file_pwd,
            &file_stat
        );
    
        /*there is no access to the file*/
        assert(stat_status == 0);

        if(S_ISDIR(file_stat.st_mode))
        {
            /*We were counting the folder*/
            continue;
        }

        /*
            It feels like it's possible to do better
        */

        outfilename = strdup(file_pwd);
        
        /*
            We are getting out of the cycle, 
            we have achieved our goal
        */
        break;
    }

    return outfilename;
}

void DirDtor(Dir* dir)
{
    assert(dir != NULL);
    assert(dir->dir != NULL);
    assert(dir->dir_path != NULL);

    closedir(dir->dir);

    free(dir->dir_path);
    free(dir);
}