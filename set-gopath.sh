#!/bin/bash
#--------------------------------------------
# FUNCTION: bash.utils.quit()
# DESCRIPTION:
# Print EXIT line to console and exit
# Parameters: 
#   $1, string - console message
#--------------------------------------------
function bash.utils.quit() {
  local ln
  ln="${1:?}"
  printf "%s\n" "[EXIT]: ${ln}"

  exit 1
}
#--------------------------------------------
# FUNCTION: bash.utils.find_os()
# DESCRIPTION:
# Use facter to get operatingsystem
# Parameters: 
#   none
#--------------------------------------------
function bash.utils.find_os() {
  if [[ "$(facter)" ]]; then
    # Attempt to detect operating system 
    facter operatingsystem
  else
    printf "%s" "$(uname -s)"
  fi
}
#--------------------------------------------
# FUNCTION: bash.utils.check_exit_status()
# DESCRIPTION:
# Check and handle exit status errors
# check_exit_status $?
# check_exit_status $? [SKIP/IGNORE]
# Parameters: 
#   $1, $?  - ($?)  Expands to the exit status
#   $2, string - Ignore check if exit status is 1
#--------------------------------------------
function bash.utils.check_exit_status() {
    local exit_status
    local test_skip
    exit_status=$1
    test_skip=$2

    if [ "${exit_status}" -ne 0 ]; then # test failed
        if [ -n "${test_skip}" ]; then
          # write test skip to files
          printf "%s" '[CHECK EXIT STATUS]: Skipped [ OK ]'
          return
        else
          # ERROR: Caught a bad exit status.
          # printf "%s" '[CHECK EXIT STATUS]: Status [ Failed ]'
          # Could do error_cleanup here
          exit $?
        fi
    fi
    # printf "%s" '[CHECK EXIT STATUS]: Status [ OK ]'
}
#--------------------------------------------
# FUNCTION: bash.utils.is_empty()
# DESCRIPTION:
# Return true if value empty or unset, else false
# Parameters: 
#   $1, string - variable to check
#--------------------------------------------
function bash.utils.is_empty() {
  # Return true if value empty or unset
  if [[ -z $1 ]]; then
      # return 0, is empty
      return 0
  fi
  # return 1, not empty
  return 1
}
#--------------------------------------------
# FUNCTION: bash.utils.consoleLogDate()
# DESCRIPTION:
# Print INFO line to console with date and newline
# Parameters: 
#   $1, string - Date w/ console message
#--------------------------------------------
function bash.utils.consoleLogDate() {
  local ln
  ln="${1:?}"
  printf "%s%s %s\n" "[$0]" "[$(date +'%a %Y-%m-%d %H:%M:%S %z')]:" "${ln}"
}
#--------------------------------------------
# FUNCTION: bash.utils.consoleLog()
# DESCRIPTION:
# Print INFO line to console with newline
# Parameters: 
#   $1, string - console message
#--------------------------------------------
function bash.utils.consoleLog() {
  local ln
  ln="${1:?}"
  printf "%s\n" "[Info]: ${ln}"
}

#--------------------------------------------
# FUNCTION: main.run()
# DESCRIPTION:
# main run funciton for script
#--------------------------------------------
function main.run() {
  # Export and set variables
  # Important: $GOPATH
  declare -g SCRIPT_SOURCE
  declare -g GO_BIN
  declare -g GOPATH
  declare -g GO_USER_HOME
  declare -g GO_PROJECT_NAME
  declare -g GO_PROJECT_TYPE
  declare -g GO_PROJECT_GROUP
  declare -g GIT_BIN

  SCRIPT_SOURCE=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
  GO_BIN=$(which go)
  GOPATH=$(pwd)
  GO_USER_HOME="${HOME}"
  GO_PROJECT_NAME=$(pwd | awk -F'/' 'NF>1{print $NF}')
  GO_PROJECT_TYPE='vutility'
  GO_PROJECT_GROUP='github.com'
  GIT_BIN=$(which git)

  # EXport variables to shell(s)
  export GOPATH GO_BIN GO_PROJECT_NAME

  # Inform user we are running, timestamp
  bash.utils.consoleLogDate "Run"

  # Enusure go path and sub-directories exist
  # GOPATH, bin, src, pkg 
  printf "[Start]: %s\n%s\n" "Running GO directory check" "=========================================="
  if [[ -f "${GO_BIN}" ]]; then

      # Ensure bin subdirectory
      if [[ -d 'bin' ]]; then
        bash.utils.consoleLog "Found bin directory."
      else
        mkdir bin
        bash.utils.consoleLog "Created bin directory."
      fi

      # Ensure src subdirectory
      if [[ -d 'src' ]]; then
        bash.utils.consoleLog "Found src directory."
      else
        mkdir -p "src/${GO_PROJECT_GROUP}"
        bash.utils.consoleLog "Created src directory."
      fi

      # Ensure pkg subdirectory
      if [[ -d 'pkg' ]]; then
        bash.utils.consoleLog "Found pkg dirctory."
      else
        mkdir pkg
        bash.utils.consoleLog "Created bin directory."
      fi

      printf "[Done]: %s\n%s\n" "Directory check completed." "=========================================="
  fi

  # To-Do:
  # Check for github project
  # Ensure src/github.com/vutility directories
  if [[ -f "${GO_BIN}" ]] && [[ -d "${GOPATH}/src/${GO_PROJECT_GROUP}/" ]]; then
    # Check for GO project work directory
    if [[ -d "${GOPATH}/src/${GO_PROJECT_GROUP}/${GO_PROJECT_TYPE}/${GO_PROJECT_NAME}" ]]; then

      bash.utils.consoleLog "Project found."
      cd "${GOPATH}/src/${GO_PROJECT_GROUP}/${GO_PROJECT_TYPE}/${GO_PROJECT_NAME}" || bash.utils.quit "Could not cd to project path."
      eval "${GIT_BIN} pull" 
      eval "${GO_BIN} get"

    else
        mkdir -p "src/${GO_PROJECT_GROUP}/${GO_PROJECT_TYPE}"
        bash.utils.consoleLog "Created project directory."
    fi
    	
    printf "[Done]: %s\n%s\n" "Project check completed." "=========================================="
  fi

  # Beta - Notify the user of the new GO details
  printf "Script Source: %s\n" "$SCRIPT_SOURCE"
  printf "GO BIN: %s\n" "$GO_BIN"
  printf "GO PATH: %s\n" "$GOPATH"
  printf "GO project: %s\n" "$GO_PROJECT_NAME"
  printf "GO User home: %s\n" "$GO_USER_HOME"
}
main.run
