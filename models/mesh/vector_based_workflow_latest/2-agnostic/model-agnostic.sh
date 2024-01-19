#!/bin/bash    
# Credit to be mentioned here

# input variables
conf="$1"

# global variables
log="$(dirname $0)/model-agnostic.log"

# Main message
echo "$(basename $0): Model-agnostic workflow job submission to SLURM" \
    "scheduler on DRA HPC."

# create log file
if [[ -e $log ]]; then
  rm $log
fi
# create log file
touch "$log"
# the header is the date the script is run
date >> $log
echo "$(basename $0): details are logged in $log"


#####################################
# Necessary functions and definitions
#####################################
jqScript="$(dirname $0)/assets/json-funcs.jq"

extract () {
  local func=$1
  jq -r "$(cat $jqScript) $func" $conf;
}

array_to_csv() {
  # ChatGPT prompt: Give me a bash function to convert a bash array to
  # comma-delimited strings
  local array=("$@")     # Get all arguments as an array
  local IFS=','          # Set the Internal Field Separator to a comma
  local result="${array[*]}"
  echo "$result"
}

# the `model-agnostic.json` file consists of three main sections
#   1. exec: where the executable paths are defined,
#   2. args: where the arguments to the executables are iterated.
#   3. order: where the order of each section for execution is given

# Register the main keys of $conf: `exec`, `args`, and `order`
mainKeys=("exec" "args" "order")
# Reading the sub-keys from any element of $mainKeys 
mapfile -t subKeys < <(jq -r ".${mainKeys[0]} | keys[]" ${conf})


################################
# Checking requirements of $conf
################################
# Check the `length` of each key and if unequal, throw an error
initCount=$(extract "count(.${mainKeys[0]})")
for key in "${mainKeys[@]}"; do
  c=$(extract "count(.${key})")
  if [[ $c -ne $initCount ]]; then
    echo "$(basename $0): ERROR! The arguments provided in main arrays"
      "are not equal"
      exit 1;
  fi
done

# Check if the $mainKeys are provided in $conf
mapfile -t derivedKeys< <(jq -r "keys[]" ${conf})

for key in "${derivedKeys[@]}"; do
  for mainKey in "${mainKeys[@]}"; do
    if [[ "${key,,}" == "${mainKey,,}" ]]; then
      break 2
    fi
  done

  # if break does not happen, throw an error
  echo "$(basename $0): ERROR! \`$key\` is not found in $conf"
  echo "key is ${key} and mainKey is ${mainKey}"
  exit 1;

done


#####################
# Running executables 
#####################
# first execute those with `order` value of `-1` (i.e., independant)
# Tip: `indeps` is an array containing "independant" processes
mapfile -t indeps < <(extract "select_independants(.order)")

for sec in "${indeps[@]}"; do

  # select the executable and related arguments
  executable=$(extract ".exec.${sec}")
  # check how many sets of `args` are provided for each `section`
  iters=$(extract "count(.args.${sec})")

  # iterate over the `args` provided in each `section`
  for i in $(seq 1 $iters); do
    # index
    idx=$(( i - 1 )) # since JSON/jq array indices start from 0
    # argument value
    arg=$(extract "parse_args(.args.${sec}[$idx])")
    # executing
    $executable $arg >> $log 2>&1;
    # relevant message
    echo "$(basename $0): Script for independant :${sec}:#${i} process" \
    	"is executed"
  done
done


# second execute those with `order` value of greater than 1 (i.e.,
# dependant) and ordered monotonically
# Tip: `deps` is in array containing "dependant" processes 
mapfile -t deps < <(extract "select_dependants(.order)")

# number of iterations needed, with each iterations being the parent
# process of the next one
dep_iters="${#deps[@]}"

# make an empty ID array to keep track of submitted SLURM jobs
ID=()

for iter in $(seq 1 $dep_iters); do
  # index in Bash arrays start from 0 
  idx=$(( $iter - 1 ))
  # make the $sec variable based on $idx and $deps
  sec="${deps[$idx]}"

  # select executable and run the process
  executable=$(extract ".exec.${sec}")
  
  # check number of iterations required for each `$deps` process
  sub_iters=$(extract "count(.args.${sec})")

  for sub_iter in $(seq 1 $sub_iters); do
    # jq array index starts from 0
    sub_idx=$(( $sub_iter - 1 ))

    # argument
    arg=$(extract "parse_args(.args.${sec}[$sub_idx])")

    # executation part 
    # if parent process
    if [[ $idx -eq 0 ]]; then
      # argument value
      # save SLURM submission ID(s)
      ID+=$($executable $arg)

      # print parent message
      echo "$(basename $0): Script for :${sec}:#${sub_iter} process" \
    	  "is executed for the parent process"

    # if child process
    else
      
      # make comma delimited values of SLURM batch IDs
      csvID=$(array_to_csv ${ID[@]})
 
      # submit child jobs dependant on the parent
      $executable $arg --dependency=$csvID >> $log 2>&1

      # print child message
      echo "$(basename $0): Script for :${sec}: for the #${sub_iter}" \
        "process is executed for the child process with parent ID(s) of" \
        "${ID[@]}"
    fi

  done
done
