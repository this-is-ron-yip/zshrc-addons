# Docker CLI helper commands


# Variables
DOCKER_CURRENT="No container is selected"
declare -a DOCKER_ALL=("my_container")
DES_title="========================General Command Manual========================"
DESCRIPTION=("$DES_title")
DES_template="
------------------------------docker----------------------------------
SYNOPSIS
\t
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX70
\tXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX70
DESCRIPTION
\t"
#DESCRIPTION+=("$DES_template")


# A function to wake docker daemon from CLI
DES_dockerwake="
------------------------------dockerwake------------------------------

SYNOPSIS
\tdockerwake

DESCRIPTION
\tdockerwake wakes the docker daemon in the background.\n"
DESCRIPTION+=("$DES_dockerwake")

dockerwake() {

  open -a Docker

  while ! docker system info >/dev/null 2>&1; do
    echo -en " Initializing Docker   \r"
    sleep 0.5
    echo -en " Initializing Docker.  \r"
    sleep 0.5
    echo -en " Initializing Docker.. \r"
    sleep 0.5
    echo -en " Initializing Docker...\r"
    sleep 0.5
  done

  echo "Docker is online       "

}


# A function to change the current working container
DES_dockerset="
------------------------------dockerset-------------------------------

SYNOPSIS
\tdockerset [container]

DESCRIPTION
\tFor the operand that names a Docker container, dockerset set 
\tthe current working container to the selected container.\n"
DESCRIPTION+=("$DES_dockerset")

dockerset() {
 
  if [[ -n "$1" && "${DOCKER_ALL[@]}" =~ "$1" ]]; then
    DOCKER_CURRENT="$1"
 
  else
    echo "Container $1 does not exist"
  fi

}


# A function to check which container is currently being pointed
DES_dockercurrent="
-----------------------------dockercurrent----------------------------

SYNOPSIS
\tdockercurrent

DESCRIPTION
\tdockercurrent prints the CURRENT container that is being
\tselected from dockerset.\n"
DESCRIPTION+=("$DES_dockercurrent")

dockercurrent() {

  echo $DOCKER_CURRENT

}


# A function to start a container, with an option to copy folders into it together
DES_dockerstart="
------------------------------dockerstart-----------------------------

SYNOPSIS
\tdockerstart [path]

DESCRIPTION
\tFor the path to the directory or the file given, dockerstart 
\tstarts the current container, copys the selected documents
\tinto the directory 'projects' of the current container, and 
\truns a compatible shell inside the current container.

\tIf no paths are given, dockerstart runs a compatible shell 
\tinside the current container.\n"
DESCRIPTION+=("$DES_dockerstart")

# add multiple path
dockerstart() {

  docker start "$DOCKER_CURRENT" > /dev/null

  docker exec $DOCKER_CURRENT  sh -c 'if [ ! -d "/projects" ]; then mkdir /projects; fi'

  if [ -n "$1" ]; then
    docker cp "$1" "$DOCKER_CURRENT:/projects/"
  fi 

  os=$(docker exec "$DOCKER_CURRENT" sh -c 'cat /etc/os-release | grep "^ID="')

  if [[ "$os" == *"ubuntu"* ]]; then
    command="bash"
  else
    command="sh"
  fi

  docker exec -it "$DOCKER_CURRENT" sh -c "cd /projects && ls && $command"

}


# A function to stop containers
DES_dockerend="
-------------------------------dockerend------------------------------

SYNOPSIS
\tdockerend [-all] [container]

DESCRIPTION
\tFor each operand that names a Docker container, dockerend 
\tstops them from running. 

\tIf the special operand "-all" is given, dockerend stops all 
\trunning containers from running.

\tIf no operands are given, dockerend stops the CURRENT 
\tcontainer as selected by dockerset.\n"
DESCRIPTION+=("$DES_dockerend")
# Usage: dockerend <optional: container_name / "all">
dockerend() {

  if [ -z "$1" ]; then
    docker stop "$DOCKER_CURRENT" > /dev/null
    echo "Stopped $DOCKER_CURRENT"

  elif [[ "$1" == "-all" ]]; then
    docker ps --format "{{.Names}}" | xargs docker stop > /dev/null
    echo "Stopped all containers"

  elif [[ -n "$1" && "${DOCKER_ALL[@]}" =~ "$1" ]]; then
    docker stop "$1" > /dev/null
    echo "Stopped $1"

  else
    echo "Container $1 does not exist"
  fi

}

# A function that list all commands and usage
# DESCRIPTION=("$DES_dockerwake")
dockerhelp() {

  for DES in "${DESCRIPTION[@]}"
  do
    echo -e "$DES"
  done | less

}