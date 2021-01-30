#!/bin/bash
# shellcheck disable=SC1090,SC2086,SC2154,SC2034,SC2012,SC2140

########## Global tasks ###########################################

# General exit handler
cleanup() {
  sleep 0.1
  if { true >&6; } 2<> /dev/null; then
    exec 1>&6 2>&7 3>&- 6>&- 7>&- 8>&- 9>&- # Restore stdout/stderr and close tmp file descriptors
  fi
  [[ -n $1 ]] && err=$1 || err=$?
  [[ $err -eq 0 ]] && clear
  [[ -n ${exit_msg} ]] && echo -e "\n${exit_msg}\n" || echo -e "\nCNTools terminated, cleaning up...\n"
  tput cnorm # restore cursor
  tput sgr0  # turn off all attributes
  exit $err
}
trap cleanup HUP INT TERM
trap 'stty echo' EXIT

# Command     : myExit [exit code] [message]
# Description : gracefully handle an exit and restore terminal to original state
myExit() {
  exit_msg="$2"
  cleanup "$1"
}

clear

<<COMMENT_OUT
usage() {
  cat <<EOF
Usage: $(basename "$0") [-o] [-b <branch name>]
CNTools - The Cardano SPOs best friend

-o    Activate offline mode - run CNTools in offline mode without node access, a limited set of functions available
-b    Run CNTools and look for updates on alternate branch instead of master of guild repository (only for testing/development purposes)
EOF
}
COMMENT_OUT

CNTOOLS_MODE="CONNECTED"
PARENT="$(dirname $0)"
[[ -f "${PARENT}"/.env_branch ]] && BRANCH="$(cat "${PARENT}"/.env_branch)" || BRANCH="master"

while getopts :ob: opt; do
  case ${opt} in
    o ) CNTOOLS_MODE="OFFLINE" ;;
    b ) BRANCH=${OPTARG}; echo "${BRANCH}" > "${PARENT}"/.env_branch ;;
    \? ) myExit 1 "$(usage)" ;;
    esac
done
shift $((OPTIND -1))

URL_RAW="https://raw.githubusercontent.com/cardano-community/guild-operators/${BRANCH}"
URL="${URL_RAW}/scripts/cnode-helper-scripts"
URL_DOCS="${URL_RAW}/docs/Scripts"

[[ ${CNTOOLS_MODE} = "CONNECTED" ]] && env_mode="" || env_mode="offline"

# env version check
if [[ ${CNTOOLS_MODE} = "CONNECTED" ]]; then
  if curl -s -m 10 -o "${PARENT}"/env.tmp ${URL}/env 2>/dev/null && [[ -f "${PARENT}"/env.tmp ]]; then
    if [[ -f "${PARENT}"/env ]]; then
      if [[ $(grep "_HOME=" "${PARENT}"/env) =~ ^#?([^[:space:]]+)_HOME ]]; then
        vname=$(tr '[:upper:]' '[:lower:]' <<< ${BASH_REMATCH[1]})
        sed -e "s@/opt/cardano/[c]node@/opt/cardano/${vname}@g" -e "s@[C]NODE_HOME@${BASH_REMATCH[1]}_HOME@g" -i "${PARENT}"/env.tmp
      else
        myExit 1 "Update for env file failed! Please use prereqs.sh to force an update or manually download $(basename $0) + env from GitHub"
      fi
      TEMPL_CMD=$(awk '/^# Do NOT modify/,0' "${PARENT}"/env)
      TEMPL2_CMD=$(awk '/^# Do NOT modify/,0' "${PARENT}"/env.tmp)
      if [[ "$(echo ${TEMPL_CMD} | sha256sum)" != "$(echo ${TEMPL2_CMD} | sha256sum)" ]]; then
        . "${PARENT}"/env offline &>/dev/null # source in offline mode and ignore errors to get some common functions, sourced at a later point again
        if getAnswer "\nThe static content from env file does not match with guild-operators repository, do you want to download the updated file?"; then
          cp "${PARENT}"/env "${PARENT}/env_bkp$(date +%s)"
          STATIC_CMD=$(awk '/#!/{x=1}/^# Do NOT modify/{exit} x' "${PARENT}"/env)
          printf '%s\n%s\n' "$STATIC_CMD" "$TEMPL2_CMD" > "${PARENT}"/env.tmp
          mv "${PARENT}"/env.tmp "${PARENT}"/env
          echo -e "\nenv update successfully applied!"
          waitToProceed
        fi
      fi
    else
      mv "${PARENT}"/env.tmp "${PARENT}"/env
      myExit 0 "Common env file downloaded: ${PARENT}/env\n\
This is a mandatory prerequisite, please set variables accordingly in User Variables section in the env file and restart CNTools"
    fi
  fi
  rm -f "${PARENT}"/env.tmp
fi
if ! . "${PARENT}"/env ${env_mode}; then
  myExit 1 "ERROR: CNTools failed to load common env file\nPlease verify set values in 'User Variables' section in env file or log an issue on GitHub"
fi

# get cntools config parameters
. "${PARENT}"/cntools.config

# get helper functions from library file
. "${PARENT}"/cntools.library

# create temporary directory if missing & remove lockfile if it exist
mkdir -p "${TMP_FOLDER}" # Create if missing
if [[ ! -d "${TMP_FOLDER}" ]]; then
  myExit 1 "${FG_RED}ERROR${NC}: Failed to create directory for temporary files:\n${TMP_FOLDER}"
fi

archiveLog # archive current log and cleanup log archive folder

exec 6>&1 # Link file descriptor #6 with normal stdout.
exec 7>&2 # Link file descriptor #7 with normal stderr.
[[ -n ${CNTOOLS_LOG} ]] && exec > >( tee >( while read -r line; do logln "INFO" "${line}"; done ) )
[[ -n ${CNTOOLS_LOG} ]] && exec 2> >( tee >( while read -r line; do logln "ERROR" "${line}"; done ) >&2 )
[[ -n ${CNTOOLS_LOG} ]] && exec 3> >( tee >( while read -r line; do logln "DEBUG" "${line}"; done ) >&6 )
exec 8>&1 # Link file descriptor #8 with custom stdout.
exec 9>&2 # Link file descriptor #9 with custom stderr.

# check for required command line tools
<<COMMENT_OUT
if ! need_cmd "curl" || \
   ! need_cmd "jq" || \
   ! need_cmd "bc" || \
   ! need_cmd "sed" || \
   ! need_cmd "awk" || \
   ! need_cmd "column" || \
   ! protectionPreRequisites; then waitForInput "Missing one or more of the required command line tools, press any key to exit"; myExit 1
fi
COMMENT_OUT

if [[ "$CNTOOLS_PATCH_VERSION" -eq 999  ]]; then
  # CNTools was updated using special 999 patch tag, apply correct version in cntools.library and update variables already sourced
  sed -i "s/CNTOOLS_MAJOR_VERSION=[[:digit:]]\+/CNTOOLS_MAJOR_VERSION=$((++CNTOOLS_MAJOR_VERSION))/" "${PARENT}/cntools.library"
  sed -i "s/CNTOOLS_MINOR_VERSION=[[:digit:]]\+/CNTOOLS_MINOR_VERSION=0/" "${PARENT}/cntools.library"
  sed -i "s/CNTOOLS_PATCH_VERSION=[[:digit:]]\+/CNTOOLS_PATCH_VERSION=0/" "${PARENT}/cntools.library"
  # CNTOOLS_MAJOR_VERSION variable already updated in sed replace command
  CNTOOLS_MINOR_VERSION=0
  CNTOOLS_PATCH_VERSION=0
  CNTOOLS_VERSION="${CNTOOLS_MAJOR_VERSION}.${CNTOOLS_MINOR_VERSION}.${CNTOOLS_PATCH_VERSION}"
fi

# Do some checks when run in connected mode
<<COMMENT_OUT
if [[ ${CNTOOLS_MODE} = "CONNECTED" ]]; then
  # check to see if there are any updates available
  clear
  println "DEBUG" "CNTools version check...\n"
  if curl -s -m ${CURL_TIMEOUT} -o "${TMP_FOLDER}"/cntools.library "${URL}/cntools.library" && [[ -f "${TMP_FOLDER}"/cntools.library ]]; then
    GIT_MAJOR_VERSION=$(grep -r ^CNTOOLS_MAJOR_VERSION= "${TMP_FOLDER}"/cntools.library |sed -e "s#.*=##")
    GIT_MINOR_VERSION=$(grep -r ^CNTOOLS_MINOR_VERSION= "${TMP_FOLDER}"/cntools.library |sed -e "s#.*=##")
    GIT_PATCH_VERSION=$(grep -r ^CNTOOLS_PATCH_VERSION= "${TMP_FOLDER}"/cntools.library |sed -e "s#.*=##")
    if [[ "$GIT_PATCH_VERSION" -eq 999  ]]; then
      ((GIT_MAJOR_VERSION++))
      GIT_MINOR_VERSION=0
      GIT_PATCH_VERSION=0
    fi
    GIT_VERSION="${GIT_MAJOR_VERSION}.${GIT_MINOR_VERSION}.${GIT_PATCH_VERSION}"
    if ! versionCheck "${GIT_VERSION}" "${CNTOOLS_VERSION}"; then
      println "DEBUG" "A new version of CNTools is available"
      echo
      println "DEBUG" "Installed Version : ${CNTOOLS_VERSION}"
      println "DEBUG" "Available Version : ${FG_GREEN}${GIT_VERSION}${NC}"
      println "DEBUG" "\nGo to Update section for upgrade\n\nAlternately, follow https://cardano-community.github.io/guild-operators/#/basics?id=pre-requisites to update cntools as well alongwith any other files"
      waitForInput "press any key to proceed"
    else
      # check if CNTools was recently updated, if so show whats new
      if curl -s -m ${CURL_TIMEOUT} -o "${TMP_FOLDER}"/cntools-changelog.md "${URL_DOCS}/cntools-changelog.md"; then
        if ! cmp -s "${TMP_FOLDER}"/cntools-changelog.md "${PARENT}/cntools-changelog.md"; then
          # Latest changes not shown, show whats new and copy changelog
          clear 
          exec >&6 # normal stdout
          sleep 0.1
          if [[ ! -f "${PARENT}/cntools-changelog.md" ]]; then 
            # special case for first installation or 5.0.0 upgrade, print release notes until previous major version
            println "OFF" "~ CNTools - What's New ~\n\n" "$(sed -n "/\[${CNTOOLS_MAJOR_VERSION}\.${CNTOOLS_MINOR_VERSION}\.${CNTOOLS_PATCH_VERSION}\]/,/\[$((CNTOOLS_MAJOR_VERSION-1))\.[0-9]\.[0-9]\]/p" "${TMP_FOLDER}"/cntools-changelog.md | head -n -2)" | less -X
          else
            # print release notes from current until previously installed version
            [[ $(cat "${PARENT}/cntools-changelog.md") =~ \[([[:digit:]])\.([[:digit:]])\.([[:digit:]])\] ]]
            cat <(println "OFF" "~ CNTools - What's New ~\n") <(awk "1;/\[${BASH_REMATCH[1]}\.${BASH_REMATCH[2]}\.${BASH_REMATCH[3]}\]/{exit}" "${TMP_FOLDER}"/cntools-changelog.md | head -n -2 | tail -n +7) <(echo -e "\n [Press 'q' to quit and proceed to CNTools main menu]\n") | less -X
          fi
          exec >&8 # custom stdout
          cp "${TMP_FOLDER}"/cntools-changelog.md "${PARENT}/cntools-changelog.md"
        fi
      else
        println "ERROR" "\n${FG_RED}ERROR${NC}: failed to download changelog from GitHub!"
        waitForInput "press any key to proceed"
      fi
    fi
  else
    println "ERROR" "\n${FG_RED}ERROR${NC}: failed to download cntools.library from GitHub, unable to perform version check!"
    waitForInput "press any key to proceed"
  fi


  # Validate protocol parameters
  if grep -q "Network.Socket.connect" <<< "${PROT_PARAMS}"; then
    myExit 1 "${FG_YELLOW}WARN${NC}: node socket path wrongly configured or node not running, please verify that socket set in env file match what is used to run the node\n\n\
${FG_BLUE}INFO${NC}: re-run CNTools in offline mode with -o parameter if you want to access CNTools with limited functionality"
  elif [[ -z "${PROT_PARAMS}" ]] || ! jq -er . <<< "${PROT_PARAMS}" &>/dev/null; then
    myExit 1 "${FG_YELLOW}WARN${NC}: failed to query protocol parameters, ensure your node is running with correct genesis (the node needs to be in sync to 1 epoch after the hardfork)\n\n\
Error message: ${PROT_PARAMS}\n\n\
${FG_BLUE}INFO${NC}: re-run CNTools in offline mode with -o parameter if you want to access CNTools with limited functionality"
  fi
  echo "${PROT_PARAMS}" > "${TMP_FOLDER}"/protparams.json
fi
COMMENT_OUT
# check if there are pools in need of KES key rotation
<<COMMENT_OUT
clear
kes_rotation_needed="no"
while IFS= read -r -d '' pool; do
  if [[ -f "${pool}/${POOL_CURRENT_KES_START}" ]]; then
    kesExpiration "$(cat "${pool}/${POOL_CURRENT_KES_START}")"
    if [[ ${expiration_time_sec_diff} -lt ${KES_ALERT_PERIOD} ]]; then
      kes_rotation_needed="yes"
      println "\n** WARNING **\nPool ${FG_GREEN}$(basename ${pool})${NC} in need of KES key rotation"
      if [[ ${expiration_time_sec_diff} -lt 0 ]]; then
        println "DEBUG" "${FG_RED}Keys expired!${NC} : ${FG_RED}$(showTimeLeft ${expiration_time_sec_diff:1})${NC} ago"
      else
        println "DEBUG" "Remaining KES periods : ${FG_RED}${remaining_kes_periods}${NC}"
        println "DEBUG" "Time left             : ${FG_RED}$(showTimeLeft ${expiration_time_sec_diff})${NC}"
      fi
    elif [[ ${expiration_time_sec_diff} -lt ${KES_WARNING_PERIOD} ]]; then
      kes_rotation_needed="yes"
      println "DEBUG" "\nPool ${FG_GREEN}$(basename ${pool})${NC} soon in need of KES key rotation"
      println "DEBUG" "Remaining KES periods : ${FG_YELLOW}${remaining_kes_periods}${NC}"
      println "DEBUG" "Time left             : ${FG_YELLOW}$(showTimeLeft ${expiration_time_sec_diff})${NC}"
    fi
  fi
done < <(find "${POOL_FOLDER}" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)
[[ ${kes_rotation_needed} = "yes" ]] && waitForInput "press any key to proceed"
COMMENT_OUT

# Verify shelley transition epoch
if [[ -z ${SHELLEY_TRANS_EPOCH} ]]; then # unknown network
  clear
  SHELLEY_TRANS_EPOCH=$(cat "${SHELLEY_TRANS_FILENAME}" 2>/dev/null)
  if [[ -z ${SHELLEY_TRANS_EPOCH} ]]; then # not yet identified
    if [[ ${CNTOOLS_MODE} = "CONNECTED" ]]; then
      getNodeMetrics
      epoch=$(jq '.cardano.node.metrics.epoch.int.val //0' <<< "${node_metrics}")
      slot_in_epoch=$(jq '.cardano.node.metrics.slotInEpoch.int.val //0' <<< "${node_metrics}")
      slot_num=$(jq '.cardano.node.metrics.slotNum.int.val //0' <<< "${node_metrics}")
      calc_slot=0
      byron_epochs=${epoch}
      shelley_epochs=0
      while [[ ${byron_epochs} -ge 0 ]]; do
        calc_slot=$(( (byron_epochs*BYRON_EPOCH_LENGTH) + (shelley_epochs*EPOCH_LENGTH) + slot_in_epoch ))
        [[ ${calc_slot} -eq ${slot_num} ]] && break
        ((byron_epochs--))
        ((shelley_epochs++))
      done
      node_sync="NODE SYNC: Epoch[${epoch}] - Slot in Epoch[${slot_in_epoch}] - Slot[${slot_num}]\n"
      if [[ ${calc_slot} -ne ${slot_num} ]]; then
        myExit 1 "${FG_YELLOW}WARN${NC}: Failed to calculate shelley transition epoch\n\n${node_sync}"
      elif [[ ${shelley_epochs} -eq 0 ]]; then
        myExit 1 "${FG_YELLOW}WARN${NC}: The network has not reached the hard fork from Byron to shelley, please wait to use CNTools until your node is in shelley era or start it in Offline mode\n\n${node_sync}"
      else
        shelleyTransitionEpoch=${byron_epochs}
      fi
    else
      myExit 1 "${FG_YELLOW}WARN${NC}: Offline mode enabled and this is an unknown network, please manually create and set shelley transition epoch:\nE.g. : ${FG_CYAN}echo 74 > \"${SHELLEY_TRANS_FILENAME}\"${NC}"
    fi
  fi
  echo "${SHELLEY_TRANS_EPOCH}" > "${SHELLEY_TRANS_FILENAME}"
fi

###################################################################

function main {

while true; do # Main loop

# Start with a clean slate after each completed or canceled command excluding .dialogrc from purge
find "${TMP_FOLDER:?}" -type f -not \( -name 'protparams.json' -o -name '.dialogrc' -o -name "offline_tx*" -o -name "*_cntools_backup*" \) -delete

  clear
  println "DEBUG" "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  println " >> BLOCKS"
  println "DEBUG" "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

  if [[ ! -f "${BLOCKLOG_DB}" ]]; then
    println "ERROR" "${FG_RED}ERROR${NC}: blocklog db not found: ${BLOCKLOG_DB}"
    println "ERROR" "please follow instructions at guild website to deploy CNCLI and logMonitor services"
    println "ERROR" "https://cardano-community.github.io/guild-operators/#/Scripts/cncli"
    waitForInput && continue
  elif ! command -v sqlite3 >/dev/null; then
    println "ERROR" "${FG_RED}ERROR${NC}: sqlite3 not found!"
    println "ERROR" "please also follow instructions at guild website to deploy CNCLI and logMonitor services"
    println "ERROR" "https://cardano-community.github.io/guild-operators/#/Scripts/cncli"
    waitForInput && continue
  fi
  current_epoch=$(getEpoch)
  println "DEBUG" "Current epoch: ${FG_CYAN}${current_epoch}${NC}\n"
  println "DEBUG" "Show a block summary for all epochs or a detailed view for a specific epoch?"
  select_opt "[s] Summary" "[e] Epoch" "[Esc] Cancel"
  case $? in
    0) echo && sleep 0.1 && read -r -p "Enter number of epochs to show (enter for 10): " epoch_enter 2>&6 && println "LOG" "Enter number of epochs to show (enter for 10): ${epoch_enter}"
       epoch_enter=${epoch_enter:-10}
       if ! [[ ${epoch_enter} =~ ^[0-9]+$ ]]; then
         println "ERROR" "\n${FG_RED}ERROR${NC}: not a number"
         waitForInput && continue
       fi
       view=1; view_output="${FG_CYAN}[b] Block View${NC} | [i] Info"
       while true; do
         clear
         println "DEBUG" "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
         println " >> BLOCKS"
         println "DEBUG" "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
         current_epoch=$(getEpoch)
         println "DEBUG" "Current epoch: ${FG_CYAN}${current_epoch}${NC}\n"
         if [[ ${view} -eq 1 ]]; then
           [[ $(sqlite3 "${BLOCKLOG_DB}" "SELECT EXISTS(SELECT 1 FROM blocklog WHERE epoch=$((current_epoch+1)) LIMIT 1);" 2>/dev/null) -eq 1 ]] && ((current_epoch++))
           first_epoch=$(( current_epoch - epoch_enter ))
           [[ ${first_epoch} -lt 0 ]] && first_epoch=0
           
           ideal_len=$(sqlite3 "${BLOCKLOG_DB}" "SELECT LENGTH(epoch_slots_ideal) FROM epochdata WHERE epoch BETWEEN ${first_epoch} and ${current_epoch} ORDER BY LENGTH(epoch_slots_ideal) DESC LIMIT 1;")
           [[ ${ideal_len} -lt 5 ]] && ideal_len=5
           luck_len=$(sqlite3 "${BLOCKLOG_DB}" "SELECT LENGTH(max_performance) FROM epochdata WHERE epoch BETWEEN ${first_epoch} and ${current_epoch} ORDER BY LENGTH(max_performance) DESC LIMIT 1;")
           [[ $((luck_len+1)) -le 4 ]] && luck_len=4 || luck_len=$((luck_len+1))
           printf '|' >&3; printf "%$((5+6+ideal_len+luck_len+7+9+6+7+6+7+27+2))s" | tr " " "=" >&3; printf '|\n' >&3
           printf "| %-5s | %-6s | %-${ideal_len}s | %-${luck_len}s | ${FG_CYAN}%-7s${NC} | ${FG_GREEN}%-9s${NC} | ${FG_RED}%-6s${NC} | ${FG_RED}%-7s${NC} | ${FG_RED}%-6s${NC} | ${FG_RED}%-7s${NC} |\n" "Epoch" "Leader" "Ideal" "Luck" "Adopted" "Confirmed" "Missed" "Ghosted" "Stolen" "Invalid" >&3
           printf '|' >&3; printf "%$((5+6+ideal_len+luck_len+7+9+6+7+6+7+27+2))s" | tr " " "=" >&3; printf '|\n' >&3
           
           while [[ ${current_epoch} -gt ${first_epoch} ]]; do
             invalid_cnt=$(sqlite3 "${BLOCKLOG_DB}" "SELECT COUNT(*) FROM blocklog WHERE epoch=${current_epoch} AND status='invalid';" 2>/dev/null)
             missed_cnt=$(sqlite3 "${BLOCKLOG_DB}" "SELECT COUNT(*) FROM blocklog WHERE epoch=${current_epoch} AND status='missed';" 2>/dev/null)
             ghosted_cnt=$(sqlite3 "${BLOCKLOG_DB}" "SELECT COUNT(*) FROM blocklog WHERE epoch=${current_epoch} AND status='ghosted';" 2>/dev/null)
             stolen_cnt=$(sqlite3 "${BLOCKLOG_DB}" "SELECT COUNT(*) FROM blocklog WHERE epoch=${current_epoch} AND status='stolen';" 2>/dev/null)
             confirmed_cnt=$(sqlite3 "${BLOCKLOG_DB}" "SELECT COUNT(*) FROM blocklog WHERE epoch=${current_epoch} AND status='confirmed';" 2>/dev/null)
             adopted_cnt=$(( $(sqlite3 "${BLOCKLOG_DB}" "SELECT COUNT(*) FROM blocklog WHERE epoch=${current_epoch} AND status='adopted';" 2>/dev/null) + confirmed_cnt ))
             leader_cnt=$(( $(sqlite3 "${BLOCKLOG_DB}" "SELECT COUNT(*) FROM blocklog WHERE epoch=${current_epoch} AND status='leader';" 2>/dev/null) + adopted_cnt + invalid_cnt + missed_cnt + ghosted_cnt + stolen_cnt ))
             IFS='|' && read -ra epoch_stats <<< "$(sqlite3 "${BLOCKLOG_DB}" "SELECT epoch_slots_ideal, max_performance FROM epochdata WHERE epoch=${current_epoch};" 2>/dev/null)" && IFS=' '
             if [[ ${#epoch_stats[@]} -eq 0 ]]; then
               epoch_stats=("-" "-")
             else
               epoch_stats[1]="${epoch_stats[1]}%"
             fi
             printf "| %-5s | %-6s | %-${ideal_len}s | %-${luck_len}s | ${FG_CYAN}%-7s${NC} | ${FG_GREEN}%-9s${NC} | ${FG_RED}%-6s${NC} | ${FG_RED}%-7s${NC} | ${FG_RED}%-6s${NC} | ${FG_RED}%-7s${NC} |\n" "${current_epoch}" "${leader_cnt}" "${epoch_stats[0]}" "${epoch_stats[1]}" "${adopted_cnt}" "${confirmed_cnt}" "${missed_cnt}" "${ghosted_cnt}" "${stolen_cnt}" "${invalid_cnt}" >&3
             ((current_epoch--))
           done
           printf '|' >&3; printf "%$((5+6+ideal_len+luck_len+7+9+6+7+6+7+27+2))s" | tr " " "=" >&3; printf '|\n' >&3
         else
           println "OFF" "Block Status:\n"
           println "OFF" "Leader    - Scheduled to make block at this slot"
           println "OFF" "Ideal     - Expected/Ideal number of blocks assigned based on active stake (sigma)"
           println "OFF" "Luck      - Leader slots assigned vs Ideal slots for this epoch"
           println "OFF" "Adopted   - Block created successfully"
           println "OFF" "Confirmed - Block created validated to be on-chain with the certainty"
           println "OFF" "            set in 'cncli.sh' for 'CONFIRM_BLOCK_CNT'"
           println "OFF" "Missed    - Scheduled at slot but no record of it in cncli DB and no"
           println "OFF" "            other pool has made a block for this slot"
           println "OFF" "Ghosted   - Block created but marked as orphaned and no other pool has made"
           println "OFF" "            a valid block for this slot, height battle or block propagation issue"
           println "OFF" "Stolen    - Another pool has a valid block registered on-chain for the same slot"
           println "OFF" "Invalid   - Pool failed to create block, base64 encoded error message"
           println "OFF" "            can be decoded with 'echo <base64 hash> | base64 -d | jq -r'"
         fi
         echo
         
         println "OFF" "[h] Home | ${view_output} | [*] Refresh"
         read -rsn1 key
         case ${key} in
           h ) continue 2 ;;
           b ) view=1; view_output="${FG_CYAN}[b] Block View${NC} | [i] Info" ;;
           i ) view=2; view_output="[b] Block View | ${FG_CYAN}[i] Info${NC}" ;;
           * ) continue ;;
         esac
       done
       ;;
    1) [[ $(sqlite3 "${BLOCKLOG_DB}" "SELECT EXISTS(SELECT 1 FROM blocklog WHERE epoch=$((current_epoch+1)) LIMIT 1);" 2>/dev/null) -eq 1 ]] && println "DEBUG" "\n${FG_YELLOW}Leader schedule for next epoch[$((current_epoch+1))] available${NC}"
       echo && sleep 0.1 && read -r -p "Enter epoch to list (enter for current): " epoch_enter 2>&6 && println "LOG" "Enter epoch to list (enter for current): ${epoch_enter}"
       [[ -z "${epoch_enter}" ]] && epoch_enter=${current_epoch}
       if [[ $(sqlite3 "${BLOCKLOG_DB}" "SELECT EXISTS(SELECT 1 FROM blocklog WHERE epoch=${epoch_enter} LIMIT 1);" 2>/dev/null) -eq 0 ]]; then
         println "No blocks in epoch ${epoch_enter}"
         waitForInput && continue
       fi
       view=1; view_output="${FG_CYAN}[1] View 1${NC} | [2] View 2 | [3] View 3 | [i] Info"
       while true; do
         clear
         println "DEBUG" "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
         println " >> BLOCKS"
         println "DEBUG" "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
         current_epoch=$(getEpoch)
         println "DEBUG" "Current epoch: ${FG_CYAN}${current_epoch}${NC}\n"
         invalid_cnt=$(sqlite3 "${BLOCKLOG_DB}" "SELECT COUNT(*) FROM blocklog WHERE epoch=${epoch_enter} AND status='invalid';" 2>/dev/null)
         missed_cnt=$(sqlite3 "${BLOCKLOG_DB}" "SELECT COUNT(*) FROM blocklog WHERE epoch=${epoch_enter} AND status='missed';" 2>/dev/null)
         ghosted_cnt=$(sqlite3 "${BLOCKLOG_DB}" "SELECT COUNT(*) FROM blocklog WHERE epoch=${epoch_enter} AND status='ghosted';" 2>/dev/null)
         stolen_cnt=$(sqlite3 "${BLOCKLOG_DB}" "SELECT COUNT(*) FROM blocklog WHERE epoch=${epoch_enter} AND status='stolen';" 2>/dev/null)
         confirmed_cnt=$(sqlite3 "${BLOCKLOG_DB}" "SELECT COUNT(*) FROM blocklog WHERE epoch=${epoch_enter} AND status='confirmed';" 2>/dev/null)
         adopted_cnt=$(( $(sqlite3 "${BLOCKLOG_DB}" "SELECT COUNT(*) FROM blocklog WHERE epoch=${epoch_enter} AND status='adopted';" 2>/dev/null) + confirmed_cnt ))
         leader_cnt=$(( $(sqlite3 "${BLOCKLOG_DB}" "SELECT COUNT(*) FROM blocklog WHERE epoch=${epoch_enter} AND status='leader';" 2>/dev/null) + adopted_cnt + invalid_cnt + missed_cnt + ghosted_cnt + stolen_cnt ))
         IFS='|' && read -ra epoch_stats <<< "$(sqlite3 "${BLOCKLOG_DB}" "SELECT epoch_slots_ideal, max_performance FROM epochdata WHERE epoch=${epoch_enter};" 2>/dev/null)" && IFS=' '
         if [[ ${#epoch_stats[@]} -eq 0 ]]; then
           epoch_stats=("-" "-")
         else
           epoch_stats[1]="${epoch_stats[1]}%"
         fi
         [[ ${#epoch_stats[0]} -gt 5 ]] && ideal_len=${#epoch_stats[0]} || ideal_len=5
         [[ ${#epoch_stats[1]} -gt 4 ]] && luck_len=${#epoch_stats[1]} || luck_len=4
         printf '|' >&3; printf "%$((6+ideal_len+luck_len+7+9+6+7+6+7+24+2))s" | tr " " "=" >&3; printf '|\n' >&3
         printf "| %-6s | %-${ideal_len}s | %-${luck_len}s | ${FG_CYAN}%-7s${NC} | ${FG_GREEN}%-9s${NC} | ${FG_RED}%-6s${NC} | ${FG_RED}%-7s${NC} | ${FG_RED}%-6s${NC} | ${FG_RED}%-7s${NC} |\n" "Leader" "Ideal" "Luck" "Adopted" "Confirmed" "Missed" "Ghosted" "Stolen" "Invalid" >&3
         printf '|' >&3; printf "%$((6+ideal_len+luck_len+7+9+6+7+6+7+24+2))s" | tr " " "=" >&3; printf '|\n' >&3
         printf "| %-6s | %-${ideal_len}s | %-${luck_len}s | ${FG_CYAN}%-7s${NC} | ${FG_GREEN}%-9s${NC} | ${FG_RED}%-6s${NC} | ${FG_RED}%-7s${NC} | ${FG_RED}%-6s${NC} | ${FG_RED}%-7s${NC} |\n" "${leader_cnt}" "${epoch_stats[0]}" "${epoch_stats[1]}" "${adopted_cnt}" "${confirmed_cnt}" "${missed_cnt}" "${ghosted_cnt}" "${stolen_cnt}" "${invalid_cnt}" >&3
         printf '|' >&3; printf "%$((6+ideal_len+luck_len+7+9+6+7+6+7+24+2))s" | tr " " "=" >&3; printf '|\n' >&3
         echo
         # print block table
         block_cnt=1
         status_len=$(sqlite3 "${BLOCKLOG_DB}" "SELECT LENGTH(status) FROM blocklog WHERE epoch=${epoch_enter} ORDER BY LENGTH(status) DESC LIMIT 1;")
         [[ ${status_len} -lt 6 ]] && status_len=6
         block_len=$(sqlite3 "${BLOCKLOG_DB}" "SELECT LENGTH(block) FROM blocklog WHERE epoch=${epoch_enter} ORDER BY LENGTH(slot) DESC LIMIT 1;")
         [[ ${block_len} -lt 5 ]] && block_len=5
         slot_len=$(sqlite3 "${BLOCKLOG_DB}" "SELECT LENGTH(slot) FROM blocklog WHERE epoch=${epoch_enter} ORDER BY LENGTH(slot) DESC LIMIT 1;")
         [[ ${slot_len} -lt 4 ]] && slot_len=4
         slot_in_epoch_len=$(sqlite3 "${BLOCKLOG_DB}" "SELECT LENGTH(slot_in_epoch) FROM blocklog WHERE epoch=${epoch_enter} ORDER BY LENGTH(slot_in_epoch) DESC LIMIT 1;")
         [[ ${slot_in_epoch_len} -lt 11 ]] && slot_in_epoch_len=11
         at_len=23
         size_len=$(sqlite3 "${BLOCKLOG_DB}" "SELECT LENGTH(size) FROM blocklog WHERE epoch=${epoch_enter} ORDER BY LENGTH(size) DESC LIMIT 1;")
         [[ ${size_len} -lt 4 ]] && size_len=4
         hash_len=$(sqlite3 "${BLOCKLOG_DB}" "SELECT LENGTH(hash) FROM blocklog WHERE epoch=${epoch_enter} ORDER BY LENGTH(hash) DESC LIMIT 1;")
         [[ ${hash_len} -lt 4 ]] && hash_len=4
         if [[ ${view} -eq 1 ]]; then
           printf '|' >&3; printf "%$((${#leader_cnt}+status_len+block_len+slot_len+slot_in_epoch_len+at_len+17))s" | tr " " "=" >&3; printf '|\n' >&3
           printf "| %-${#leader_cnt}s | %-${status_len}s | %-${block_len}s | %-${slot_len}s | %-${slot_in_epoch_len}s | %-${at_len}s |\n" "#" "Status" "Block" "Slot" "SlotInEpoch" "Scheduled At" >&3
           printf '|' >&3; printf "%$((${#leader_cnt}+status_len+block_len+slot_len+slot_in_epoch_len+at_len+17))s" | tr " " "=" >&3; printf '|\n' >&3
           while IFS='|' read -r status block slot slot_in_epoch at; do
             at=$(TZ="${BLOCKLOG_TZ}" date '+%F %T %Z' --date="${at}")
             [[ ${block} -eq 0 ]] && block="-"
             printf "| %-${#leader_cnt}s | %-${status_len}s | %-${block_len}s | %-${slot_len}s | %-${slot_in_epoch_len}s | %-${at_len}s |\n" "${block_cnt}" "${status}" "${block}" "${slot}" "${slot_in_epoch}" "${at}" >&3
             ((block_cnt++))
           done < <(sqlite3 "${BLOCKLOG_DB}" "SELECT status, block, slot, slot_in_epoch, at FROM blocklog WHERE epoch=${epoch_enter} ORDER BY slot;" 2>/dev/null)
           printf '|' >&3; printf "%$((${#leader_cnt}+status_len+block_len+slot_len+slot_in_epoch_len+at_len+17))s" | tr " " "=" >&3; printf '|\n' >&3
         elif [[ ${view} -eq 2 ]]; then
           printf '|' >&3; printf "%$((${#leader_cnt}+status_len+slot_len+size_len+hash_len+14))s" | tr " " "=" >&3; printf '|\n' >&3
           printf "| %-${#leader_cnt}s | %-${status_len}s | %-${slot_len}s | %-${size_len}s | %-${hash_len}s |\n" "#" "Status" "Slot" "Size" "Hash" >&3
           printf '|' >&3; printf "%$((${#leader_cnt}+status_len+slot_len+size_len+hash_len+14))s" | tr " " "=" >&3; printf '|\n' >&3
           while IFS='|' read -r status slot size hash; do
             [[ ${size} -eq 0 ]] && size="-"
             [[ -z ${hash} ]] && hash="-"
             printf "| %-${#leader_cnt}s | %-${status_len}s | %-${slot_len}s | %-${size_len}s | %-${hash_len}s |\n" "${block_cnt}" "${status}" "${slot}" "${size}" "${hash}" >&3
             ((block_cnt++))
           done < <(sqlite3 "${BLOCKLOG_DB}" "SELECT status, slot, size, hash FROM blocklog WHERE epoch=${epoch_enter} ORDER BY slot;" 2>/dev/null)
           printf '|' >&3; printf "%$((${#leader_cnt}+status_len+slot_len+size_len+hash_len+14))s" | tr " " "=" >&3; printf '|\n' >&3
         elif [[ ${view} -eq 3 ]]; then
           printf '|' >&3; printf "%$((${#leader_cnt}+status_len+block_len+slot_len+slot_in_epoch_len+at_len+size_len+hash_len+23))s" | tr " " "=" >&3; printf '|\n' >&3
           printf "| %-${#leader_cnt}s | %-${status_len}s | %-${block_len}s | %-${slot_len}s | %-${slot_in_epoch_len}s | %-${at_len}s | %-${size_len}s | %-${hash_len}s |\n" "#" "Status" "Block" "Slot" "SlotInEpoch" "Scheduled At" "Size" "Hash" >&3
           printf '|' >&3; printf "%$((${#leader_cnt}+status_len+block_len+slot_len+slot_in_epoch_len+at_len+size_len+hash_len+23))s" | tr " " "=" >&3; printf '|\n' >&3
           while IFS='|' read -r status block slot slot_in_epoch at size hash; do
             at=$(TZ="${BLOCKLOG_TZ}" date '+%F %T %Z' --date="${at}")
             [[ ${block} -eq 0 ]] && block="-"
             [[ ${size} -eq 0 ]] && size="-"
             [[ -z ${hash} ]] && hash="-"
             printf "| %-${#leader_cnt}s | %-${status_len}s | %-${block_len}s | %-${slot_len}s | %-${slot_in_epoch_len}s | %-${at_len}s | %-${size_len}s | %-${hash_len}s |\n" "${block_cnt}" "${status}" "${block}" "${slot}" "${slot_in_epoch}" "${at}" "${size}" "${hash}" >&3
             ((block_cnt++))
           done < <(sqlite3 "${BLOCKLOG_DB}" "SELECT status, block, slot, slot_in_epoch, at, size, hash FROM blocklog WHERE epoch=${epoch_enter} ORDER BY slot;" 2>/dev/null)
           printf '|' >&3; printf "%$((${#leader_cnt}+status_len+block_len+slot_len+slot_in_epoch_len+at_len+size_len+hash_len+23))s" | tr " " "=" >&3; printf '|\n' >&3
         elif [[ ${view} -eq 4 ]]; then
           println "OFF" "Block Status:\n"
           println "OFF" "Leader    - Scheduled to make block at this slot"
           println "OFF" "Ideal     - Expected/Ideal number of blocks assigned based on active stake (sigma)"
           println "OFF" "Luck      - Leader slots assigned vs Ideal slots for this epoch"
           println "OFF" "Adopted   - Block created successfully"
           println "OFF" "Confirmed - Block created validated to be on-chain with the certainty"
           println "OFF" "            set in 'cncli.sh' for 'CONFIRM_BLOCK_CNT'"
           println "OFF" "Missed    - Scheduled at slot but no record of it in cncli DB and no"
           println "OFF" "            other pool has made a block for this slot"
           println "OFF" "Ghosted   - Block created but marked as orphaned and no other pool has made"
           println "OFF" "            a valid block for this slot, height battle or block propagation issue"
           println "OFF" "Stolen    - Another pool has a valid block registered on-chain for the same slot"
           println "OFF" "Invalid   - Pool failed to create block, base64 encoded error message"
           println "OFF" "            can be decoded with 'echo <base64 hash> | base64 -d | jq -r'"
         fi
         echo
         
         println "OFF" "[h] Home | ${view_output} | [*] Refresh"
         read -rsn1 key
         case ${key} in
           h ) continue 2 ;;
           1 ) view=1; view_output="${FG_CYAN}[1] View 1${NC} | [2] View 2 | [3] View 3 | [i] Info" ;;
           2 ) view=2; view_output="[1] View 1 | ${FG_CYAN}[2] View 2${NC} | [3] View 3 | [i] Info" ;;
           3 ) view=3; view_output="[1] View 1 | [2] View 2 | ${FG_CYAN}[3] View 3${NC} | [i] Info" ;;
           i ) view=4; view_output="[1] View 1 | [2] View 2 | [3] View 3 | ${FG_CYAN}[i] Info${NC}" ;;
           * ) continue ;;
         esac
       done
       ;;
    2) continue ;;
  esac

  waitForInput && continue

  ;; ###################################################################


esac # main OPERATION
done # main loop
}

##############################################################

main "$@"