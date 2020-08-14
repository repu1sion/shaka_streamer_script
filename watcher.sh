#!/bin/bash

# ------------------------------------------------------------------------------
# when we cp file - we have 'CREATE' event
# when we mv file - we have 'DELETE' event
# if we copy the same file - no event happens, because nothing copied

# after copying 1.mkv into dir we have event: ./ CREATE 1.mkv 

# format. %w - current watching dir name, %f - filename of new event

# ------------------------------------------------------------------------------



VER="0.2"

INPUT_CONFIG="input_vod_config"
PIPELINE_CONFIG="pipeline_vod_config"
NAME=""					# store new filename here
NEW_INPUT_CONFIG=""
NEW_PIPELINE_CONFIG=""


while true; do
	echo "[checking for new files]"

	#while inotifywait -r -e modify,create,delete,move .; do

	# we get the file name in list.txt. overwrite list.txt after
	while inotifywait -r -e create,delete,move --format '%f'  . > list.txt; do
		echo "[new file appeared]"
		if [ -e list.txt ]; then
                	while read FNAME; do
				echo "[$FNAME]"
				NAME=$FNAME
			done < list.txt
        	fi

		if [ ! -z "$NAME" ]; then
			echo "[new file name is: $NAME]"
			NEW_INPUT_CONFIG=${INPUT_CONFIG}_${NAME}.yaml
			NEW_PIPELINE_CONFIG=${PIPELINE_CONFIG}_${NAME}.yaml

			echo "ic: $NEW_INPUT_CONFIG"
			echo "pc: $NEW_PIPELINE_CONFIG"

			cp $INPUT_CONFIG.yaml "$NEW_INPUT_CONFIG"
			cp $PIPELINE_CONFIG.yaml "$NEW_PIPELINE_CONFIG"

			# edit new input config
			sed -i "s/\(name: \)\(.*\)/\1${NAME}/g" "$NEW_INPUT_CONFIG"

			# shaka-streamer upload
			#shaka-streamer -i $NEW_INPUT_CONFIG -p $NEW_PIPELINE_CONFIG  -c s3://my_s3_bucket/folder/
			shaka-streamer -i "$NEW_INPUT_CONFIG" -p "$NEW_PIPELINE_CONFIG" -o /media/NAS/EditHouse\ Encode
		fi

	done


	sleep 1
done

