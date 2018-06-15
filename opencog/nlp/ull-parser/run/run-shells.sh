#! /bin/bash
#
# run-shells.sh <mode> <language> [<db_name>] [<username>] [<password>]
#
# Run tmux with byobu to multiplex multiple terminals; start the
# CogServer in one terminal, and suggest which processes to run
# in others.
#
# Use F3 and F4 to switch to the other terminals.
#

# Work around an lxc-attach bug.
if [[ `tty` == "not a tty" ]]
then
	script -c $0 /dev/null
	exit 0
fi

export LD_LIBRARY_PATH=/usr/local/lib/opencog/modules

if [ $# -lt 2 ]
then 
  echo "Usage: ./run-shells.sh <mode> <language> [<db_name>] [<username>] [<password>]"
  exit 0
fi

# Get database credentials according to language
source ./config/det-db-uri.sh $2

# Get port number according to mode and language
source ./config/det-port-num.sh $1 $2

# Start multiple sessions (use byobu so that the scroll bars actually work)
byobu new-session -d -n 'cntl' \
  'echo -e "\nControl shell; you might want to run 'top' here.\n"; $SHELL'

# Start the cogserver
launcher=launch-cogserver.scm
case $# in
   2)
      byobu new-window -n 'cogsrv' "nice guile -l $launcher -- --mode $1 --lang $2 --db $db_name --user $db_user --password $db_pswd; $SHELL"
      ;;
   3)
      byobu new-window -n 'cogsrv' "nice guile -l $launcher -- --mode $1 --lang $2 --db $3; $SHELL"
      ;;
   4)
      byobu new-window -n 'cogsrv' "nice guile -l $launcher -- --mode $1 --lang $2 --db $3 --user $4; $SHELL"
      ;;
   *)
      byobu new-window -n 'cogsrv' "nice guile -l $launcher -- --mode $1 --lang $2 --db $3 --user $4 --password $5; $SHELL"
      ;;
esac
sleep 2;

# Telnet window
tmux new-window -n 'telnet' "rlwrap telnet localhost $PORT; $SHELL"

# Submit counting/parsing scripts
tmux new-window -n 'submit' \
  'echo -e "\nYou might want to run ./process-word-pairs.sh or ./process-text.sh here.\n"; $SHELL'

# Spare
tmux new-window -n 'spare' 'echo -e "\nSpare-use shell.\n"; $SHELL'

# Fix the annoying byobu display
echo "tmux_left=\"session\"" > $HOME/.byobu/status
echo "tmux_right=\"load_average disk_io date time\"" >> $HOME/.byobu/status
tmux attach
