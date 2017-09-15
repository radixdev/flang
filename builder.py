# creates a release
import json
import os,sys
import shutil

curDir = os.path.dirname(os.path.abspath(sys.argv[0]))

# join some folder/file from the root to it's full path
def local_file_path(filename):
    return os.path.join(curDir, filename)

def release_file_path(filename):
    return os.path.join(release_folder_path, filename)

# read the info.json for the release name
def get_version():
    filename = "info.json"
    fileAbsolutePath = local_file_path(filename)
    with open(fileAbsolutePath) as data_file:
    	config = json.load(data_file)
        return config["version"]

# make the release
version = get_version()
release_name = "flang" + "_" + version
release_folder_path = local_file_path(os.path.join("releases", release_name))
print "release_folder_path", release_folder_path

if (os.path.exists(release_folder_path)):
    print "Release already exists at " + release_folder_path
    exit(0)

os.mkdir(release_folder_path)

# copy the files to releases
whitelisted_files = ["lang", "locale", "prototypes", "control.lua", "data.lua", "info.json"]

for file in whitelisted_files:
    localpath = local_file_path(file)
    releasepath = release_file_path(file)

    print "localpath", localpath
    print "releasepath", releasepath
    if (os.path.isfile(localpath)):
        shutil.copyfile(localpath, releasepath)
    else:
        shutil.copytree(localpath, releasepath)

# create the zip file
shutil.make_archive(release_folder_path, 'zip', release_folder_path)
