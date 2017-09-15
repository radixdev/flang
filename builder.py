# creates a release
import json
import os,sys
import shutil

curDir = os.path.dirname(os.path.abspath(sys.argv[0]))

# join some folder/file from the root to it's full path
def local_file_path(filename):
    return os.path.join(curDir, filename)

def release_file_path(filename):
    return os.path.join(curDir, os.path.join("releases", filename))

# read the info.json for the release name
def get_version():
    filename = "info.json"
    fileAbsolutePath = local_file_path(filename)
    with open(fileAbsolutePath) as data_file:
    	config = json.load(data_file)
        return config["version"]

version = get_version()

# make the release
release_folder_path = local_file_path(os.path.join("releases", "flang" + "_" + version))
print release_folder_path

if (os.path.exists(release_folder_path)):
    print "Release already exists at " + release_folder_path
    exit(0)

os.mkdir(release_folder_path)

# copy the files to releases
whitelisted_files = ["lang", "locale", "prototypes", "control.lua", "data.lua", "info.json"]

for file in whitelisted_files:
    shutil.copy(local_file_path(file), release_file_path(file))

# test line, rm later!
# os.rmdir(release_folder_path)
