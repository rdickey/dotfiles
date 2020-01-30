alias dm="docker-machine"
alias d="docker"
alias dc="docker-compose"
 
# Helper functions used by main functions
function _d.get.header() {
    d ps | head -1
}
function _d.get.image.header() {
    d images | head -1
}
 
# list docker process by grep
function d.ps() {
    _d.get.header
    if [ "$#" -eq 1 ]; then
        d ps | grep $1 | sort -k2
    else
        d ps | grep -v "CONTAINER ID" | sort -k2
    fi
}
 
# show disk usage
function d.disk() {
    d system df -v
}
 
# get stats
function d.stats() {
    if [ "$#" -eq 1 ]; then
        d stats $(d ps | grep $1 | grep -v "NAMES"|awk '{ print $NF }'|tr "\n" " ")
    else
        d stats $(d ps|grep -v "NAMES"|awk '{ print $NF }'|tr "\n" " ")
    fi
}
 
# list images in your local docker. Provide a name and it will be grepped for.
# The filtering is done across all fields returned from 'docker images'
#
# This returns the images sorted.
# example: d.images http
function d.images() {
    if [ "$#" -eq 1 ]; then
        _d.get.image.header
        d images | grep $1 | sort
    else
        d images | grep -v REPOSITORY | sort
    fi
}
 
 
# list tags for a given image from the tahoma repo
# example: d.tags https://tahoma-1.us.oracle.com nimbula.base
function d.tags() {
    where=$1
    what=$2
    echo "Getting tags for '$what' from '${where}'"
    curl -s -q -k -X GET "${where}/v2/${what}/tags/list" | python -mjson.tool
}
 
 
# list the images from tahoma repo
# example: d.repo http://tahoma-1.us.oracle.com:5000
function d.repo() {
    where=$1
    echo "Getting image list from '${where}'"
    curl -s -q -k -X GET ${where}/v2/_catalog  | python -mjson.tool
}
 
 
# Find children for a specified image
function d.find.children() {
    image=$1
    docker inspect --format='{{.Id}} {{.Parent}}' $(docker images --filter since=$image -q)
}
 
 
# Get 'version' from image.
# If the image doesn't org.label-schema it will return empty string
function d.get.version() {
    image=$1
    d inspect -f "{{index .Config.Labels \"org.label-schema.version\"}}" $image
}
 
 
########## Remove containers
 
# remove container by name
function d.rm.by.name() {
    name=$1
    d.ps $name | grep -v "CONTAINER ID" | awk '{print $1}' | xargs -I % docker rm -f %
}
 
# remove old containers that have exited
function d.rm.old() {
    echo "--- Removing old containers ---"
    d rm $(d ps -af status=exited | grep -v data | grep -v CONTAINER | awk '{print $1}')
}
 
# remove old containers that have just been created
function d.rm.created() {
    echo "--- Removing created containers ---"
    d rm $(d ps -af status=created | grep -v data | grep -v CONTAINER | awk '{print $1}')
}
 
########## Remove images
 
 
# Remove images by tag. This will remove all images that match the incoming param against the tag, but not the name
function d.rmi.by.tag() {
    tag=$1
    # get images, removing the header, use awk to grep on the 2nd column (the tag), print the name, then remove name:tag
    d images | grep -v REPOSI | awk -v awkname=$tag '$2 ~ awkname' | awk '{print $1}' | xargs -I % docker rmi %:$tag
}
 
# Remove images by name. This will remove all images that match the incoming param against the name, but not the tag
function d.rmi.by.name() {
    name=$1
 
    # get images, removing the header, use awk to grep on the 1st column (the name), print the name:tag, then remove it
   d images | grep -v REPOSI | awk -v awkname=$name '$1 ~ awkname' | awk '{print $1":"$2}' | xargs -I % docker rmi %
}
 
 
# remove old images (dangling=true)
function d.rmi.old() {
    echo "--- Removing unused images ---"
    d rmi $(docker images --filter "dangling=true" -q --no-trunc)
}
 
# remove untagged images
function d.rmi.untagged {
    echo "--- Removing untagged images ---"
    d rmi $(d images | grep "^<none>" | awk "{print $3}")
}
 
# remove old volumes
function d.rm.volume() {
    echo "--- Removing old volumes ---"
    d volume rm $(docker volume ls -qf dangling=true)
}

function docker-space() {
    docker rm -f $(docker ps -a -q)
    docker images | awk '/registry.oracledx.com\/oke/ { print $3 }' | xargs docker rmi
    docker images | awk '/none/ { print $3 }' | xargs docker rmi
    docker rmi -f $(docker images --format '{{.Repository}}:{{.Tag}}' | grep 'wcr.io')
}
