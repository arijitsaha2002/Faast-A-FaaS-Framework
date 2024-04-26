HOST=$1
URL=$2
APP_TYPE=$3
APP_NAME=$4

if [ $# -ne 4 ]; then
	echo "Usage: ./perform_analysis.sh <host> <url> <app-type> <app-name>"
	exit 1
fi

set -m

echo "Sleeping for 10 seconds ..."
sleep 10

echo "Starting the profiling program ..."
python3 profiling_resource.py --$APP_TYPE --app-name $APP_NAME &
child_pid=$!

echo "Starting the requests ..."
python3 get_response_time.py --app-type $APP_TYPE --app-name $APP_NAME --host $HOST --url $URL
echo "Requests done"

echo "Sleeping for 60 seconds ..."
sleep 60
kill -2 $child_pid
echo "Look at response-time-${APP_TYPE}-${APP_NAME}.png for response time of ${APP_NAME}"

fg %1
