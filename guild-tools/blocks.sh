#!/bin/bash
# shellcheck disable=SC1090,SC2086,SC2154,SC2034,SC2012

######## Global tasks ###########################################

. /home/<user_name>/cardano-my-node/scripts/env

# get cntools config parameters
. "${CNODE_HOME}"/scripts/cntools.config

# get helper functions from library file
. "${CNODE_HOME}"/scripts/cntools.library


# General exit handler
cleanup() {
  [[ -n $1 ]] && err=$1 || err=$?
  clear
  [[ -n ${exit_msg} ]] && echo -e "\n${exit_msg}\n" || echo -e "\nBLOCK TOOL terminated, cleaning up...\n"
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

# Verify if the combinator network is already on shelley and if so, the epoch of transition
if [[ "${PROTOCOL}" == "Cardano" ]]; then
  shelleyTransitionEpoch=$(cat "${SHELLEY_TRANS_FILENAME}" 2>/dev/null)
  if [[ -z "${shelleyTransitionEpoch}" ]]; then
    clear
    if [[ "${NETWORK_IDENTIFIER}" == "--mainnet" ]]; then
      shelleyTransitionEpoch="208"
    elif [[ ${CNTOOLS_MODE} = "CONNECTED" ]]; then
      getNodeMetrics
      epoch=$(jq '.cardano.node.ChainDB.metrics.epoch.int.val //0' <<< "${node_metrics}")
      slot_in_epoch=$(jq '.cardano.node.ChainDB.metrics.slotInEpoch.int.val //0' <<< "${node_metrics}")
      slot_num=$(jq '.cardano.node.ChainDB.metrics.slotNum.int.val //0' <<< "${node_metrics}")
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
        myExit 1 "${FG_YELLOW}WARN${NC}: The network has not reached the hard fork from Byron to shelley, please wait to use CNTools until your node is in shelley era\n\n${node_sync}"
      else
        shelleyTransitionEpoch=${byron_epochs}
      fi
    else
      myExit 1 "${FG_YELLOW}WARN${NC}: Offline mode enabled and config set to TestNet, please manually create and set shelley transition epoch:\nE.g. : ${FG_CYAN}echo 74 > \"${SHELLEY_TRANS_FILENAME}\"${NC}"
    fi
    echo "${shelleyTransitionEpoch}" > "${SHELLEY_TRANS_FILENAME}"
  fi
fi

function main {

while true; do # Main loop
clear
say " >> BLOCKS TOOL @ Developed by Guild Operators & Cutomized by BTBF" "log"
say "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

  if [[ ! -f "${BLOCKLOG_DB}" ]]; then
    say "${FG_RED}ERROR${NC}: blocklog db not found: ${BLOCKLOG_DB}"
    say "please follow instructions at guild website to deploy CNCLI and logMonitor services"
    say "https://cardano-community.github.io/guild-operators/#/Scripts/cncli"
    waitForInput && continue
  elif ! command -v sqlite3 >/dev/null; then
    say "${FG_RED}ERROR${NC}: sqlite3 not found!"
    say "please also follow instructions at guild website to deploy CNCLI and logMonitor services"
    say "https://cardano-community.github.io/guild-operators/#/Scripts/cncli"
    waitForInput && continue
  fi
  current_epoch=$(getEpoch)
  say "現在のエポック: ${FG_CYAN}${current_epoch}${NC}\n"
  say "すべてのエポックのブロックのサマリー、または特定のエポックのブロック生成実績を表示できます"
  select_opt "[s] Summary" "[e] Epoch" "[Esc] Cancel"
  case $? in
    0) echo && read -r -p "入力した数字分の直近エポックサマリーを表示します (Enterで直近10エポック表示): " epoch_enter
       epoch_enter=${epoch_enter:-10}
       if ! [[ ${epoch_enter} =~ ^[0-9]+$ ]]; then
         say "\n${FG_RED}ERROR${NC}: not a number"
         waitForInput && continue
       fi
       view=1; view_output="${FG_CYAN}[b] Block View${NC} | [i] Info"
       while true; do
         clear
         say " >> BLOCKS TOOL @ Developed by Guild Operators & Cutomized by BTBF "
         say "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
         current_epoch=$(getEpoch)
         say "現在のエポック: ${FG_CYAN}${current_epoch}${NC}\n"
         if [[ ${view} -eq 1 ]]; then
           [[ $(sqlite3 "${BLOCKLOG_DB}" "SELECT EXISTS(SELECT 1 FROM blocklog WHERE epoch=$((current_epoch+1)) LIMIT 1);" 2>/dev/null) -eq 1 ]] && ((current_epoch++))
           first_epoch=$(( current_epoch - epoch_enter ))
           [[ ${first_epoch} -lt 0 ]] && first_epoch=0
           
           ideal_len=$(sqlite3 "${BLOCKLOG_DB}" "SELECT LENGTH(epoch_slots_ideal) FROM epochdata WHERE epoch BETWEEN ${first_epoch} and ${current_epoch} ORDER BY LENGTH(epoch_slots_ideal) DESC LIMIT 1;")
           [[ ${ideal_len} -lt 5 ]] && ideal_len=5
           luck_len=$(sqlite3 "${BLOCKLOG_DB}" "SELECT LENGTH(max_performance) FROM epochdata WHERE epoch BETWEEN ${first_epoch} and ${current_epoch} ORDER BY LENGTH(max_performance) DESC LIMIT 1;")
           [[ $((luck_len+1)) -le 4 ]] && luck_len=4 || luck_len=$((luck_len+1))
           printf '|'; printf "%$((5+6+ideal_len+luck_len+7+9+6+7+6+7+27+2))s" | tr " " "="; printf '|\n'
           printf "| %-5s | %-6s | %-${ideal_len}s | %-${luck_len}s | ${FG_CYAN}%-7s${NC} | ${FG_GREEN}%-9s${NC} | ${FG_RED}%-6s${NC} | ${FG_RED}%-7s${NC} | ${FG_RED}%-6s${NC} | ${FG_RED}%-7s${NC} |\n" "Epoch" "Leader" "Ideal" "Luck" "Adopted" "Confirmed" "Missed" "Ghosted" "Stolen" "Invalid"
           printf '|'; printf "%$((5+6+ideal_len+luck_len+7+9+6+7+6+7+27+2))s" | tr " " "="; printf '|\n'
           
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
             printf "| %-5s | %-6s | %-${ideal_len}s | %-${luck_len}s | ${FG_CYAN}%-7s${NC} | ${FG_GREEN}%-9s${NC} | ${FG_RED}%-6s${NC} | ${FG_RED}%-7s${NC} | ${FG_RED}%-6s${NC} | ${FG_RED}%-7s${NC} |\n" "${current_epoch}" "${leader_cnt}" "${epoch_stats[0]}" "${epoch_stats[1]}" "${adopted_cnt}" "${confirmed_cnt}" "${missed_cnt}" "${ghosted_cnt}" "${stolen_cnt}" "${invalid_cnt}"
             ((current_epoch--))
           done
           printf '|'; printf "%$((5+6+ideal_len+luck_len+7+9+6+7+6+7+27+2))s" | tr " " "="; printf '|\n'
         else
           say "ブロックステータス:\n"
           say "Leader    - ブロック生成予定スロット"
           say "Ideal     - アクティブステーク（シグマ）に基づいて割り当てられたブロック数の期待値/理想値"
           say "Luck      - 期待値における実際に割り当てられたスロットリーダー数のパーセンテージ"
           say "Adopted   - ブロック生成成功"
           say "Confirmed - 生成したブロックのうち確実にオンチェーンであることが検証されたブロック"
           say "            set in 'cncli.sh' for 'CONFIRM_BLOCK_CNT'"
           say "Missed    - スロットでスケジュールされているが、 cncli DB には記録されておらず"
           say "            他のプールがこのスロットのためにブロックを作った可能性"
           say "Ghosted   - ブロックは作成されましたが「Orpah(孤立ブロック)」となっております。"
           say "            スロットバトル・ハイトバトルで敗北したか、ブロック伝播の問題で有効なブロックになっていません"
           say "Stolen    - 別のプールに有効なブロックが登録されているため、スロットバトルに敗北した可能性"
           say "Invalid   - プールはブロックの作成に失敗しました。base64でエンコードされたエラーメッセージ"
           say "            次のコードでデコードできます 'echo <base64 hash> | base64 -d | jq -r'"
         fi
         echo
         
         say "[h] Home | ${view_output} | [*] Refresh"
         read -rsn1 key
         case ${key} in
           h ) continue 2 ;;
           b ) view=1; view_output="${FG_CYAN}[b] Block View${NC} | [i] Info" ;;
           i ) view=2; view_output="[b] Block View | ${FG_CYAN}[i] Info${NC}" ;;
           * ) continue ;;
         esac
       done
       ;;
    1) [[ $(sqlite3 "${BLOCKLOG_DB}" "SELECT EXISTS(SELECT 1 FROM blocklog WHERE epoch=$((current_epoch+1)) LIMIT 1);" 2>/dev/null) -eq 1 ]] && say "\n${FG_YELLOW}Leader schedule for next epoch[$((current_epoch+1))] available${NC}"
       echo && read -r -p "Enter epoch to list (enter for current): " epoch_enter
       [[ -z "${epoch_enter}" ]] && epoch_enter=${current_epoch}
       if [[ $(sqlite3 "${BLOCKLOG_DB}" "SELECT EXISTS(SELECT 1 FROM blocklog WHERE epoch=${epoch_enter} LIMIT 1);" 2>/dev/null) -eq 0 ]]; then
         say "No blocks in epoch ${epoch_enter}"
         waitForInput && continue
       fi
       view=1; view_output="${FG_CYAN}[1] View 1${NC} | [2] View 2 | [3] View 3 | [i] Info"
       while true; do
         clear
         say " >> BLOCKS TOOL @ Developed by Guild Operators & Cutomized by BTBF"
         say "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
         current_epoch=$(getEpoch)
         say "現在のエポック: ${FG_CYAN}${current_epoch}${NC}\n"
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
         printf '|'; printf "%$((6+ideal_len+luck_len+7+9+6+7+6+7+24+2))s" | tr " " "="; printf '|\n'
         printf "| %-6s | %-${ideal_len}s | %-${luck_len}s | ${FG_CYAN}%-7s${NC} | ${FG_GREEN}%-9s${NC} | ${FG_RED}%-6s${NC} | ${FG_RED}%-7s${NC} | ${FG_RED}%-6s${NC} | ${FG_RED}%-7s${NC} |\n" "Leader" "Ideal" "Luck" "Adopted" "Confirmed" "Missed" "Ghosted" "Stolen" "Invalid"
         printf '|'; printf "%$((6+ideal_len+luck_len+7+9+6+7+6+7+24+2))s" | tr " " "="; printf '|\n'
         printf "| %-6s | %-${ideal_len}s | %-${luck_len}s | ${FG_CYAN}%-7s${NC} | ${FG_GREEN}%-9s${NC} | ${FG_RED}%-6s${NC} | ${FG_RED}%-7s${NC} | ${FG_RED}%-6s${NC} | ${FG_RED}%-7s${NC} |\n" "${leader_cnt}" "${epoch_stats[0]}" "${epoch_stats[1]}" "${adopted_cnt}" "${confirmed_cnt}" "${missed_cnt}" "${ghosted_cnt}" "${stolen_cnt}" "${invalid_cnt}"
         printf '|'; printf "%$((6+ideal_len+luck_len+7+9+6+7+6+7+24+2))s" | tr " " "="; printf '|\n'
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
           printf '|'; printf "%$((${#leader_cnt}+status_len+block_len+slot_len+slot_in_epoch_len+at_len+17))s" | tr " " "="; printf '|\n'
           printf "| %-${#leader_cnt}s | %-${status_len}s | %-${block_len}s | %-${slot_len}s | %-${slot_in_epoch_len}s | %-${at_len}s |\n" "#" "Status" "Block" "Slot" "SlotInEpoch" "Scheduled At"
           printf '|'; printf "%$((${#leader_cnt}+status_len+block_len+slot_len+slot_in_epoch_len+at_len+17))s" | tr " " "="; printf '|\n'
           while IFS='|' read -r status block slot slot_in_epoch at; do
             at=$(TZ="${BLOCKLOG_TZ}" date '+%F %T %Z' --date="${at}")
             [[ ${block} -eq 0 ]] && block="-"
             printf "| %-${#leader_cnt}s | %-${status_len}s | %-${block_len}s | %-${slot_len}s | %-${slot_in_epoch_len}s | %-${at_len}s |\n" "${block_cnt}" "${status}" "${block}" "${slot}" "${slot_in_epoch}" "${at}"
             ((block_cnt++))
           done < <(sqlite3 "${BLOCKLOG_DB}" "SELECT status, block, slot, slot_in_epoch, at FROM blocklog WHERE epoch=${epoch_enter} ORDER BY slot;" 2>/dev/null)
           printf '|'; printf "%$((${#leader_cnt}+status_len+block_len+slot_len+slot_in_epoch_len+at_len+17))s" | tr " " "="; printf '|\n'
         elif [[ ${view} -eq 2 ]]; then
           printf '|'; printf "%$((${#leader_cnt}+status_len+slot_len+size_len+hash_len+14))s" | tr " " "="; printf '|\n'
           printf "| %-${#leader_cnt}s | %-${status_len}s | %-${slot_len}s | %-${size_len}s | %-${hash_len}s |\n" "#" "Status" "Slot" "Size" "Hash"
           printf '|'; printf "%$((${#leader_cnt}+status_len+slot_len+size_len+hash_len+14))s" | tr " " "="; printf '|\n'
           while IFS='|' read -r status slot size hash; do
             [[ ${size} -eq 0 ]] && size="-"
             [[ -z ${hash} ]] && hash="-"
             printf "| %-${#leader_cnt}s | %-${status_len}s | %-${slot_len}s | %-${size_len}s | %-${hash_len}s |\n" "${block_cnt}" "${status}" "${slot}" "${size}" "${hash}"
             ((block_cnt++))
           done < <(sqlite3 "${BLOCKLOG_DB}" "SELECT status, slot, size, hash FROM blocklog WHERE epoch=${epoch_enter} ORDER BY slot;" 2>/dev/null)
           printf '|'; printf "%$((${#leader_cnt}+status_len+slot_len+size_len+hash_len+14))s" | tr " " "="; printf '|\n'
         elif [[ ${view} -eq 3 ]]; then
           printf '|'; printf "%$((${#leader_cnt}+status_len+block_len+slot_len+slot_in_epoch_len+at_len+size_len+hash_len+23))s" | tr " " "="; printf '|\n'
           printf "| %-${#leader_cnt}s | %-${status_len}s | %-${block_len}s | %-${slot_len}s | %-${slot_in_epoch_len}s | %-${at_len}s | %-${size_len}s | %-${hash_len}s |\n" "#" "Status" "Block" "Slot" "SlotInEpoch" "Scheduled At" "Size" "Hash"
           printf '|'; printf "%$((${#leader_cnt}+status_len+block_len+slot_len+slot_in_epoch_len+at_len+size_len+hash_len+23))s" | tr " " "="; printf '|\n'
           while IFS='|' read -r status block slot slot_in_epoch at size hash; do
             at=$(TZ="${BLOCKLOG_TZ}" date '+%F %T %Z' --date="${at}")
             [[ ${block} -eq 0 ]] && block="-"
             [[ ${size} -eq 0 ]] && size="-"
             [[ -z ${hash} ]] && hash="-"
             printf "| %-${#leader_cnt}s | %-${status_len}s | %-${block_len}s | %-${slot_len}s | %-${slot_in_epoch_len}s | %-${at_len}s | %-${size_len}s | %-${hash_len}s |\n" "${block_cnt}" "${status}" "${block}" "${slot}" "${slot_in_epoch}" "${at}" "${size}" "${hash}"
             ((block_cnt++))
           done < <(sqlite3 "${BLOCKLOG_DB}" "SELECT status, block, slot, slot_in_epoch, at, size, hash FROM blocklog WHERE epoch=${epoch_enter} ORDER BY slot;" 2>/dev/null)
           printf '|'; printf "%$((${#leader_cnt}+status_len+block_len+slot_len+slot_in_epoch_len+at_len+size_len+hash_len+23))s" | tr " " "="; printf '|\n'
         elif [[ ${view} -eq 4 ]]; then
           say "ブロックステータス:\n"
           say "Leader    - ブロック生成予定スロット"
           say "Ideal     - アクティブステーク（シグマ）に基づいて割り当てられたブロック数の期待値/理想値"
           say "Luck      - 期待値における実際に割り当てられたスロットリーダー数のパーセンテージ"
           say "Adopted   - ブロック生成成功"
           say "Confirmed - 生成したブロックのうち確実にオンチェーンであることが検証されたブロック"
           say "            set in 'cncli.sh' for 'CONFIRM_BLOCK_CNT'"
           say "Missed    - スロットでスケジュールされているが、 cncli DB には記録されておらず"
           say "            他のプールがこのスロットのためにブロックを作った可能性"
           say "Ghosted   - ブロックは作成されましたが「Orpah(孤立ブロック)」となっております。"
           say "            スロットバトル・ハイトバトルで敗北したか、ブロック伝播の問題で有効なブロックになっていません"
           say "Stolen    - 別のプールに有効なブロックが登録されているため、スロットバトルに敗北した可能性"
           say "Invalid   - プールはブロックの作成に失敗しました。base64でエンコードされたエラーメッセージ"
           say "            次のコードでデコードできます 'echo <base64 hash> | base64 -d | jq -r'"
         fi
         echo
         
         say "[h] Home | ${view_output} | [*] Refresh"
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
    2) myExit 0 "BLOCKS TOOL closed!" ;;
  esac

  waitForInput && continue

###################################################################


done # main loop
}

##############################################################

main "$@"
