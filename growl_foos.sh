#!/bin/bash

FOOS_PATH="${HOME}/.foos_timestamp"
RESULTS_URL="http://foosaholics.herokuapp.com/results"

latest_timestamp() {
    result=$(curl -s $RESULTS_URL)
    lts=$(echo $result | jsawk 'return $$.results[0].meta.timestamp')
}

stored_timestamp() {
    if [ -f "$FOOS_PATH" ]
    then
         sts=$(head -n 1 "${FOOS_PATH}")
    else
         sts=0
    fi
}

new_game() {
    latest_timestamp
    stored_timestamp

    if [ "$lts" -gt "$sts" ]
    then
        is_new_game=true
    else
        is_new_game=false
    fi
}

new_game
if $is_new_game
then
    t1a=$(echo $result | jsawk 'return $$.results[0].team1.attacker')
    t1d=$(echo $result | jsawk 'return $$.results[0].team1.defender')
    t1score=$(echo $result | jsawk 'return $$.results[0].team1.score')

    t2a=$(echo $result | jsawk 'return $$.results[0].team2.attacker')
    t2d=$(echo $result | jsawk 'return $$.results[0].team2.defender')
    t2score=$(echo $result | jsawk 'return $$.results[0].team2.score')

    status_msg="$t1a and $t1d $t1score - $t2score $t2a and $t2d"

    growlnotify -m "$status_msg"

    echo $lts > $FOOS_PATH
fi


