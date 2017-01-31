#!/bin/sh

# Alexander Powell
# Systems Programming - CSCI 515
# Programming Assignment # 6

# Initializing the archive
if test $# -eq 2 && test $1 = "-c"
	then
	if test -d $2
		then
		echo "The directory already exists."
		exit 1
	else
		mkdir $2
		echo "0:0" > $2/bounds
		exit 1
	fi

# Adding a message to the archive
# ./archive.sh dir -a filename -s subject
elif test $# -eq 5 && test -d $1 && test $2 = "-a" && test $4 = "-s"
	then
	if !(test -d $1)
		then
		echo "The directory does not exist. "
		exit 1
	fi
	if !(test -f $3)
		then
		echo "The file does not exist. "
		exit 1
	fi
	if test ${#5} -gt 31
		then
		echo "The subject string can be no longer than 31 characters. "
		exit 1
	fi
	for (( i=0; i<${#5}; i++ )); do
		if !([[ "${5:$i:1}" == [0-9A-Za-z] ]] || [[ "${5:$i:1}" == [,.:\;\!\?\ ] ]]) ;
			then
			echo "Invalid subject string entered. "
			exit 1
		fi
	done
	if test ${#3} -gt 511
		then 
		echo "The filename can be no longer than 511 characters. "
		exit 1
	fi

	read -r boundsString < $1/bounds
	IFS=':' read -a boundsArray <<< "$boundsString"
	lowerBound=`expr ${boundsArray[0]}`
	upperBound=`expr ${boundsArray[1]}`
	newUpperBound=`expr ${boundsArray[1]} + 1`
	rm $1/bounds
	if test $lowerBound -eq $upperBound && test -f $1/$lowerBound
		then
		#echo "here1"
		echo "$lowerBound:$newUpperBound" >> $1/bounds
	elif test $lowerBound -eq $upperBound && !(test -f $1/$lowerBound)
		then
		#echo "here2"
		echo "$newUpperBound:$newUpperBound" >> $1/bounds
	else
		#echo "here3"
		echo "$lowerBound:$newUpperBound" >> $1/bounds
	fi
	messageBody=`cat $3`
	echo "Subject: $5" >> $1/$newUpperBound
	echo "Date: $(date)" >> $1/$newUpperBound
	echo "=====" >> $1/$newUpperBound
	echo "$messageBody" >> $1/$newUpperBound

# ./archive.sh dir -s subject -a filename
elif test $# -eq 5 && test $4 = "-a" && test $2 = "-s" #&& test -d $1
	then
	if !(test -d $1)
		then
		echo "Directory does not exist. "
		exit 1
	fi
	if !(test -f $5)
		then
		echo "The file does not exist. "
		exit 1
	fi
	if test ${#3} -gt 31
		then
		echo "The filename can be no longer than 511 characters. "
		exit 1
	fi
	for (( i=0; i<${#3}; i++ )); do
		if !([[ "${3:$i:1}" == [0-9A-Za-z] ]] || [[ "${3:$i:1}" == [,.:\;\!\?\ ] ]]) ;
			then
			echo "Invalid subject string entered. "
			exit 1
		fi
	done
	if test ${#5} -gt 511
		then 
		echo "The subject string can be no longer than 31 characters. "
		exit 1
	fi

	read -r boundsString < $1/bounds
	IFS=':' read -a boundsArray <<< "$boundsString"
	lowerBound=`expr ${boundsArray[0]}`
	upperBound=`expr ${boundsArray[1]}`
	newUpperBound=`expr ${boundsArray[1]} + 1`
	rm $1/bounds
	if test $lowerBound -eq $upperBound && test -f $1/$lowerBound
		then
		#echo "here1"
		echo "$lowerBound:$newUpperBound" >> $1/bounds
	elif test $lowerBound -eq $upperBound && !(test -f $1/$lowerBound)
		then
		#echo "here2"
		echo "$newUpperBound:$newUpperBound" >> $1/bounds
	else
		#echo "here3"
		echo "$lowerBound:$newUpperBound" >> $1/bounds
	fi
	messageBody=`cat $5`
	echo "Subject: $3" >> $1/$newUpperBound
	echo "Date: $(date)" >> $1/$newUpperBound
	echo "=====" >> $1/$newUpperBound
	echo "$messageBody" >> $1/$newUpperBound

# Deleting a message from the archive
#./archive.sh dir -d 1
elif test $# -eq 3 && test $2 = "-d"
	then
	if !(test -d $1)
		then
		echo "The directory does not exist. "
		exit 1
	fi
	if !(test -f $1/$3)
		then
		echo "File number does not exist. "
		echo "Please try again. "
		exit 1
	fi
	read -r boundsString < $1/bounds
	IFS=':' read -a boundsArray <<< "$boundsString"
	lowerBound=`expr ${boundsArray[0]}`
	upperBound=`expr ${boundsArray[1]}`
	if test $lowerBound -eq $upperBound
		then #this is the only file in the directory
		rm $1/$3 # delete the file
		exit 1
	fi
	if test $3 -eq $lowerBound
		then #simply delete the file and update bounds
		rm $1/$3
		newLowerBound=`expr ${boundsArray[0]} + 1`
		rm $1/bounds
		echo "$newLowerBound:$upperBound" >> $1/bounds
		exit
	fi
	if test $3 -lt $lowerBound
		then
		echo "Unable to remove file"
		exit 1
	fi
	if test $3 -gt $upperBound
		then
		echo "Unable to remove file"
		exit 1
	fi
	rm $1/$3
	for ((i = $(($3-1)); i >= $lowerBound; i--)); do
		mv $1/$i $1/$(($i+1))
	done
	# Update the bounds file
	rm $1/bounds
	newLowerBound=`expr ${boundsArray[0]} + 1`
	echo "$newLowerBound:$upperBound" >> $1/bounds

# Getting a subject list from an archive
elif test $# -eq 2 && test $2 = "-S"
	then
	if !(test -d $1)
		then
		echo "The directory does not exist. "
		exit 1
	fi
	read -r boundsString < $1/bounds
	IFS=':' read -a boundsArray <<< "$boundsString"
	lowerBound=`expr ${boundsArray[0]}`
	upperBound=`expr ${boundsArray[1]}`
	if !(test -f $1/$lowerBound)
		then
		exit 1
	fi
	for ((i = $lowerBound; i <= $upperBound; i++)); do
		subjectLine=`sed -n '1p' $1/$i`
		subjectLine=${subjectLine#*:}
		dateLine=`sed -n '2p' $1/$i`
		dateLine=${dateLine#*:}
		echo $i $subjectLine [$dateLine]
	done

# Searching the archive stored in the directory -ss
elif test $# -eq 3 && test $2 = "-ss"
	then
	if !(test -d $1)
		then
		echo "The directory does not exist. "
		exit 1
	fi
	read -r boundsString < $1/bounds
	IFS=':' read -a boundsArray <<< "$boundsString"
	lowerBound=`expr ${boundsArray[0]}`
	upperBound=`expr ${boundsArray[1]}`

	for ((i = $lowerBound; i <= $upperBound; i++)); do
		subjectLine=`sed -n '1p' $1/$i`
		subjectLine=${subjectLine#*:}
		if [[ $subjectLine == *$3* ]]
			then
			echo $i
		fi
	done

# Searching the archive stored in the directory -sb
elif test $# -eq 3 && test $2 = "-sb"
	then
	if !(test -d $1)
		then
		echo "The directory does not exist. "
		exit 1
	fi
	read -r boundsString < $1/bounds
	IFS=':' read -a boundsArray <<< "$boundsString"
	lowerBound=`expr ${boundsArray[0]}`
	upperBound=`expr ${boundsArray[1]}`

	for ((i = $lowerBound; i <= $upperBound; i++)); do
		count=0
		while read p; do
			if test $count -ge 3
				then
				if [[ $p == *$3* ]]
					then
					echo $i
				fi
			fi
			count=$((count+1))
		done <$1/$i
	done

else
	echo "Invalid arguments entered.  Please try again. "
	exit 1
fi






















