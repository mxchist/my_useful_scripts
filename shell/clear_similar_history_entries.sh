function backslash_quantificators () {
    local original_p=$1;
    local p=$(echo "${original_p}" | sed -E 's/\\/\\/g' -);
    p=$(echo "${p}" | sed -E 's/([]\[()^"*?+.])/\\\1/g' -);
    p=$(echo "${p}" | sed -E 's/\$/\\$/g' -);
    echo "$p"
}

function clear_similar_history_entries {
    local unprocessed_history_size=$(history | grep -cE "^[[:space:]]+([[:digit:]]+)[[:space:]]+" -);
    local proceed_loop=1;
    while [[ proceed_loop -eq 1 && unprocessed_history_size -gt 0 ]]; do
    if [[ $(history $unprocessed_history_size | head -n 1) =~ ^[[:space:]]+([[:digit:]]+)[[:space:]]+([[:alnum:][:space:][:punct:]]+)$ ]]; then
        local entry_number=${BASH_REMATCH[1]};
        local original_pattern=${BASH_REMATCH[2]};
        local pattern=$(backslash_quantificators "${original_pattern}");
        local entry_count_in_history=$(history $unprocessed_history_size | grep -cE "^[[:space:]]+([[:digit:]]+)[[:space:]]+${pattern}$" -) || proceed_loop=$(
            echo "exit status: $?, pattern: ${pattern}, original_pattern: ${original_pattern}"
            echo "Fallback to grep -f /tmp/entry_in_history"
            echo "^[[:space:]]+([[:digit:]]+)[[:space:]]+${pattern}$" > /tmp/entry_in_history
            # the entry_count_in_history bellow never affects the same variable outside of the current subshell?
            entry_count_in_history=$(history $unprocessed_history_size | grep -cEf /tmp/entry_in_history -) && echo "entry_count_in_history afer grep -f: ${entry_count_in_history}" && echo -n 1 ||
            echo -n 0
        )   
        if [[ $entry_count_in_history -gt 1 ]]; then
            history -d $entry_number;
        fi;
    fi; 
    echo $(( unprocessed_history_size-- )) > /dev/null;
    done; 
    #unset original_pattern pattern entry_count_in_history entry_number unprocessed_history_size IFS
}


# This function checks how the pattern, processed by the backslash_quantificators above, processed by a grep.
# The list for consumption by the original_pattern variable consists of history entries which caused problems during the execution of clear_similar_history_entries.
function test_backslashes () {
    for original_pattern in 'cargo new test_enum && cd $_' 'journalctl -b -n 1 -r' 'ls -l  .bash_history*' 'docker compose -f postgresql.yml exec postgres psql -ct "\du"' \
    'ssh user@192.168.1.2 "git -C ~/repositories/telegram_bot cat-file blob HEAD^^:./projects/tests/Cargo.toml"'; do
        pattern=$(backslash_quantificators "${original_pattern}");
        entry_count_in_history=$( echo "  990  ${original_pattern}" | grep -cE "^[[:space:]]+([[:digit:]]+)[[:space:]]+${pattern}$" -) || (
            echo "exit status: $?, pattern: ${pattern}, original_pattern: ${original_pattern}";
            echo "Fallback to grep -f /tmp/entry_in_history"
            echo "^[[:space:]]+([[:digit:]]+)[[:space:]]+${pattern}$" > /tmp/entry_in_history;
            entry_count_in_history=$(echo "  990  ${original_pattern}" | grep -cEf /tmp/entry_in_history -) || echo "Failed to grep -f /tmp/entry_in_history"
            )
    done
}
