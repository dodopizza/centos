#!/bin/bash

#
# Maintainer: Vitaly Uvarov
# Description: Gh-ost runner
#
set -eu

MYSQL_MASTER_HOST=Your_master_hostname
MYSQL_MASTER_USER=Your_master_username
MYSQL_MASTER_PASS=Your_master_password
MYSQL_READ_HOST=Your_slave_host
MYSQL_READ_USER=Your_slave_username
MYSQL_READ_PASS=Your_slave_password
MYSQL_DATABASE=Database_name
MYSQL_TABLE=Table_name
MYSQL_ALTER_STATEMENT='Alter statement'

#

SCRIPT_DIR=$(cd $(dirname $0); pwd) # without ending /
VARS_FNAME=$(pwd)/ghost-tool.vars
GHOST_LOG_FNAME=/tmp/ghost.script.${MYSQL_TABLE}.log
GHOST_POSTPONE_FNAME=/tmp/ghost.cutover.${MYSQL_TABLE}.flag

#

# Usage: log [msg] ..
function log()       { echo -e "\e[34m${@}\e[39m"; }
function log::green(){ echo -e "\e[32m${@}\e[39m"; }
function log::red()  { echo -e "\e[31m${@}\e[39m"; }

# Usage: mysql::master [mysql options]
function mysql::master(){
    mysql -h ${MYSQL_MASTER_HOST} -u ${MYSQL_MASTER_USER} -p${MYSQL_MASTER_PASS} "$@" 2> >( grep -v "Using a password" 1>&2 )
}

# Usage: mysql::read [mysql options]
function mysql::read(){
    mysql -h ${MYSQL_READ_HOST} -u ${MYSQL_READ_USER} -p${MYSQL_READ_PASS} "$@" 2> >( grep -v "Using a password" 1>&2 )
} 

# Usage: mysql::check_connections
function mysql::check_connections(){
    echo -n "[~] Check mysql connection: "
    mysql::master -e 'EXIT'
    mysql::read   -e 'EXIT'
    log::green "OK"
}

#
function main::onlymaster(){
    if [ "${MYSQL_MASTER_HOST}" == "${MYSQL_READ_HOST}" ]
    then
        echo true
    fi
}

# Usage: mysql::read::check_query_result <query> <result> <title> <fail message>
function mysql::read::check_query_result(){
    local query_=${1}
    local result_=${2}
    local title_=${3}
    local fail_message_=${4}
    local sql_result=$( mysql::read -BNe "${query_}" )
    echo -n  "[~] ${title_}: "
    if [ "${sql_result}" == "${result_}" ]
    then
        log::green 'OK'
    else
        log::red "Fail - ${fail_message_}"
        return 99
    fi
}

# Usage: mysql::read::check_config_option <varible> <value> <message> <fail message>
function mysql::read::check_config_option(){
    local variable_=${1}
    shift
    mysql::read::check_query_result "SELECT @@${variable_};" "$@"
}

# Usage: mysql::read::check_triggers
function mysql::read::check_triggers(){
    local query_="SELECT count(*) FROM information_schema.triggers WHERE trigger_schema = '${MYSQL_DATABASE}' AND event_object_table = '${MYSQL_TABLE}';"
    mysql::read::check_query_result "${query_}" '0' 'Check triggers' 'Ghost require no triggers. You must to delete triggers before run'
}

# Usage: mysql::read::check_slave_is_running
function mysql::read::check_slave_is_running(){
    local slave_sql_running=$( mysql::read -e "SHOW SLAVE STATUS\G" | grep 'Slave_SQL_Running:' | awk '{print $2}' )
    local slave_io_running=$(  mysql::read -e "SHOW SLAVE STATUS\G" | grep 'Slave_IO_Running:'  | awk '{print $2}' )
    echo -n "[~] Check slave is running: "
    if [ "${slave_sql_running}${slave_io_running}" == "YesYes" ]
    then
        log::green "OK"
    else
        log::red "Fail - Slave is not in running state. Please run 'CALL mysql.az_replication_restart;' on slave server to restart replication"
        return 99
    fi
}

# Usage: main::check_mysql_compliance
function main::check_mysql_compliance(){
    mysql::read::check_triggers
    mysql::read::check_config_option 'log_bin' '1' 'Check binary log' 'Binary log (log_bin) must be setted to ON'
    mysql::read::check_config_option 'binlog_format' 'ROW' 'Check binary log format' 'Binary log format (binlog_format) must be ROW'
    mysql::read::check_config_option 'binlog_row_image' 'FULL' 'Check binary log row image' 'Binary log row image (binlog_row_image) must be FULL'
    if [ ! "$(main::onlymaster)" ]
    then
        mysql::read::check_slave_is_running
    fi
}

# Usage: ghost::run
# Usage: ghost::run [--option1] ..
function ghost::run(){
    > ${GHOST_LOG_FNAME}
    > ${GHOST_POSTPONE_FNAME}

    gh-ost \
      --azure \
      --assume-rbr \
      --assume-master-host="${MYSQL_MASTER_HOST}" \
      --master-user="${MYSQL_MASTER_USER}" \
      --master-password="${MYSQL_MASTER_PASS}" \
      --ssl \
      --ssl-allow-insecure \
      --max-load=Threads_running=32 \
      --max-lag-millis=1500 \
      --critical-load=Threads_running=500 \
      --chunk-size=5000 \
      --host="${MYSQL_READ_HOST}" \
      --user="${MYSQL_READ_USER}" \
      --password="${MYSQL_READ_PASS}" \
      --alter="${MYSQL_ALTER_STATEMENT}" \
      --database="${MYSQL_DATABASE}" \
      --table="${MYSQL_TABLE}" \
      --skip-strict-mode \
      --debug \
      --stack \
      --postpone-cut-over-flag-file="${GHOST_POSTPONE_FNAME}" \
      --panic-flag-file="/tmp/ghost.panic.${MYSQL_TABLE}.flag" \
      --initially-drop-ghost-table \
      --initially-drop-socket-file \
      $@
}

# Usage: ghost::sock_actions <action=[status|throttle|no-throttle|panic|unpostpone|chunk-size=1000|..]>
function ghost::sock_actions(){
    command -v nc || yum install -y nc
    echo ${1} | nc -U /tmp/gh-ost.${MYSQL_DATABASE}.${MYSQL_TABLE}.sock
}

# Usage ghost::process_migration
function ghost::process_migration(){

    if ps -C gh-ost >/dev/null
    then
        log::red "[!] Ghost already running in background. Check status"
        return 99
    fi

    mysql::check_connections
    main::check_mysql_compliance

    log '[~] Ghost dry-run'
    if [ "$(main::onlymaster)" ]
    then
        ghost::run --allow-on-master
    else
        ghost::run
    fi

    log::green '[!]Press enter to process Ghost migration'
    read

    log '[~] Ghost execute'
    if [ "$(main::onlymaster)" ]
    then
        ghost_extra_opts="--allow-on-master --execute"
    else
        ghost_extra_opts="--execute"
    fi

    ghost::run ${ghost_extra_opts} &> ${GHOST_LOG_FNAME} &

    log::green '[~] Running ghost in background'
    log "[I] Check status by '$(basename $0) status'."
}

# Usage: main::init_vars_file
function main::init_vars_file(){
cat << EOF > ${VARS_FNAME}
MYSQL_MASTER_HOST=Your_master_hostname
MYSQL_MASTER_USER=Your_master_username
MYSQL_MASTER_PASS=Your_master_password
MYSQL_READ_HOST=Your_slave_host
MYSQL_READ_USER=Your_slave_username
MYSQL_READ_PASS=Your_slave_password
MYSQL_DATABASE=Database_name
MYSQL_TABLE=Table_name
MYSQL_ALTER_STATEMENT='Alter statement'
EOF
}

# Usage: main::get_app_version_info
function main::get_app_version_info(){
    echo 'gh-ost:     ' $(gh-ost --version)
    echo 'ghost-tool: ' 0.1.1
}

# Usage: main $@
function main(){
    if [ $# -lt 1 ]
    then
        log 
        log::green "Info: $(basename $0) was created following this manual"
        log::green '      https://app.nuclino.com/dodopizza/SRE/How-to-run-online-migration-gh-ost-bc25a6b9-cbd0-4663-9c81-fc61631148f7'
        log 
        log "Usage: $(basename $0) <action>"
        log 
        log::green '   <actions>'
        log '       version     -   Print gh-ost and ghost-tool version info'
        log '       init-vars   -   Create "ghost-tool.vars" file near script'
        log '       start       -   Check mysql server, start gh-ost dry-run and execute in background'
        log '       stop        -   Stop gh-ost migration'
        log '       apply       -   Start changing old/new tables'
        log '       status      -   Check migration status'
        log '       log         -   Follow gh-ost log'
        log '       throttle    -   Throttle migration process'
        log '       no-throttle -   Stop to throttle migration process'
        log
        log '       *or change any gh-ost option on-air by passing option=value*'
        log
        log::green '   How to migrate (step-by-step)'
        log
        log "       1) Create a sample config file 'ghost-tool.vars'"
        log "          by typing './$(basename $0) init-vars'"
        log
        log "       2) Edit config file by setting database credentials"
        log "          and migration statement"
        log
        log "       3) Start migration './$(basename $0) start'"
        log "          After all checks, you will be prompted to start migration."
        log
        log "       4) You can check migration status './$(basename $0) status'"
        log
        log "       5) When migration process reached 100%, you can"
        log "          apply changes './$(basename $0) apply'."
        log "          This operation will change old database with new one"
        log
        log "       5) Migration is finished"
        log
        exit 1
    fi

    case ${1} in
        version | --version) main::get_app_version_info ;;
        init-vars) main::init_vars_file ;;
        start) ghost::process_migration ;;
        stop)  ghost::sock_actions panic ;;
        apply) ghost::sock_actions unpostpone ;;
        status) ghost::sock_actions status ;;
        log) tail -f ${GHOST_LOG_FNAME} ;;
        throttle) ghost::sock_actions throttle ;;
        no-throttle) ghost::sock_actions no-throttle ;;
        *) ghost::sock_actions ${1}
    esac
}

if [ -f "${VARS_FNAME}" ]
then
    source "${VARS_FNAME}"
fi

main $@