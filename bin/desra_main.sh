#!/usr/bin/env bash
# main.sh  # main script
#	   # get input: jobid
#	   # run receives jobid as parameter
# usage:
#
# main.sh -j jobid -a ref_assembly
# eg:
#   main.sh -j 00001 -a ref_GRCh37.p13
#
# function:
#  checks that jobid exists in jobs table of deSRA database
#  locates jobid, job files: gene_name, sracond1, sracond2, gene database
#  runs desra_go_mb.sh:
#   desra_go_mb.sh -j jobid -e email_address -d blastdb_dir
#
# technical notes:
# create table:
# sqlite> create table jobs(id varchar(100), start varchar(100), stop varchar(100), email_address, status varchar(100) );

while getopts d:j:e:t: o           # opts followed by ":" will have an argument
do      case "$o" in
        d)      blastdb="$OPTARG";;
        j)      job_id="$OPTARG";;
        e)      email_address="$OPTARG";;
				t)      threads="$OPTARG";;
        [?])    echo >&2 "Usage: $0 -j jobid -e email_address -d blastdb_dir -t number_of_threads"
                exit 1;;
        esac
done

if [ -z ${DATA} ]
then
  DATA="/data"
fi

if [ -z ${BIN} ]
then
  BIN=`echo ~/bin`
fi

if [ -z ${JOBS} ]
then
  JOBS="/data/jobs"
fi

if [ -z ${DB} ]
then
  DB="/data/db.sqlite3"
fi

if [ ! -e ${JOBS}/$job_id
then
	mkdir -p $JOBS/$job_id
fi

threads=""
if [ -z $t ]
then
	threads="-t $t"
fi

line=$(sqlite3 $DB "select * from jobs WHERE jobid = '$job_id'")
# echo "db line is [$line]";
# echo "select * from jobs;" | sqlite3 deSRA

if [ ${line} ]
then
  echo "db line is [$line]";
  id=`echo $line | cut -d\| -f1`;
  echo "id is $id";
  START=`echo $line | cut -d\| -f2`
  echo "START is $START"
  STOP=`echo $line | cut -d\| -f3`
  echo "STOP is $STOP"
  email_address=`echo $line | cut -d\| -f4`
  jobid=`echo $line | cut -d\| -f5`
  echo "jobid is $jobid"
  status=`echo $line | cut -d\| -f6`
  done_status="DONE"
  echo "status is: $status"
  if [ "$status"=="$done_status" ]
  then
    echo "ERROR: status [$status] found for jobid [$jobid] in database, please address and resubmit."
    echo "exiting...."
    exit
  fi
  echo ""
else
  echo "ERROR: jobid [$jobid] is not found in database, please fix and resubmit."
  echo "exiting...."
  exit
fi

sra_list="";
if [ "$job_id" -eq "$jobid" ]
then
    echo "jobid [$jobid] is found in database"

		# cd to jobid directory
    dir="$JOBS/$job_id"
		echo "dir is [$dir]"
		cd $dir

		# get sra accession lists from sra condition files:
		sra_list1=`cat sra_cond1 | tr "\\n" "," | sed -e 's/,$/\n/'`
    echo "sra_list1 is [$sra_list1]"
		sra_list2=`cat sra_cond2 | tr "\\n" "," | sed -e 's/,$/\n/'`
    echo "sra_list2 is [$sra_list2]"

    for gene in `cat gene_name`;
    do
			echo ""
      echo "gene is [$gene]"

			# go to gene directory
			gene_dir="$blastdb/$gene"

			if [ -e ${gene_dir} ]
			then
					echo "gene_dir is [$gene_dir]"

		  	  # get gene_db files from gene_directory
		   	  for gene_db in `ls $gene_dir/*.nhr | sed 's/.nhr//'`;
				  	  do
				  	    # run desra_go_mb.sh for the gene database using sra accession lists
				  	    echo "running cmd: desra_go_mb.sh -d $gene_db -s $sra_list1 -g ${gene} $threads"
		            return_code=`desra_go_mb.sh -d $gene_db -s $sra_list1 -g ${gene} $threads`
		            echo "return_code of cmd: [$return_code]"

				  	    echo "running cmd: desra_go_mb.sh -d $gene_db -s $sra_list2 -g ${gene} $threads"
		            return_code=`desra_go_mb.sh -d $gene_db -s $sra_list2 -g ${gene} $threads`
		            echo "return_code of cmd: [$return_code]"
					    echo ""
					    echo ""
		  	  done
			else
	  	    echo "ERROR: gene dir does NOT exist, continuing with next gene"
			    echo ""
			    echo ""
			    echo ""
			fi
    done

		echo "preparing to run: python3 $BIN/desra_calculate_tpm.py"
		return_code=`python3 $BIN/desra_calculate_tpm.py`

		$stop_date=`date` 2> /dev/null;
		stop_seconds=`date -d "$stop_date" +%s`
		echo "stop is [$stop_seconds]"

		sqlite3 $DB "update jobs SET status='DONE', stop='$stop_seconds' WHERE jobid='$jobid'"
fi
exit;
