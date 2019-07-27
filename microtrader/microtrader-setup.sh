#!/bin/sh #for POSIX-compliant Bourne shell that runs cross-platform

# MICROTRADER_setup.sh in https://github.com/wilsonmar/DevSecOps/docker-production-aws
# as described in https://wilsonmar.github.io/docker-production-aws

# This script builds from source the microtrader sample app used in 
# Justin Menga's course released 10 May 2016 on Pluralsight at:
# https://app.pluralsight.com/library/courses/docker-production-using-amazon-web-services/table-of-contents
# which shows how to install a "microtraders" Java app in aws using Docker, ECS, CloudFormation, etc.

# This script is run by this command on MacOS/Linux Terminal:
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/docker-production-aws/MICROTRADER_setup.sh)"

# This is free software; see the source for copying conditions. There is NO
# warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

# CURRENT STATUS: under construction, with TODO items.

### 1. Run Parameters controlling this run:

set -e  # stop when $? returned non-zero.
set -o pipefail

FEATURE_INSTALL_UTILITIES="no"  # or yes
WORK_FOLDER="docker-production-aws"  # as specified in course materials.
FEATURE_REMOVE_AT_END="yes"  # or no


### 2. Context: Starting time stamp, OS versions, command attributes:

clear  # screen
# For Git on Windows, see http://www.rolandfg.net/2014/05/04/intellij-idea-and-git-on-windows/
TIME_START="$(date -u +%s)"
FREE_DISKBLOCKS_START="$(df | awk '{print $4}' | cut -d' ' -f 6)"
THISPGM="$0"
# ISO-8601 plus RANDOM=$((1 + RANDOM % 1000))  # 3 digit random number.
LOG_DATETIME=$(date +%Y-%m-%dT%H:%M:%S%z)-$((1 + RANDOM % 1000))
LOGFILE="$HOME/$THISPGM.$LOG_DATETIME.log"
SSH_USER="$USER@$( uname -n )"  # computer node name.
#TO_PRINT="$THISPGM on machine $USER starting with logging to file:"
#echo ">>> $LOGFILE"
#echo "$TO_PRINT" >$LOGFILE  # single > for new file
echo "$TO_PRINT"  # to screen
# uname -a  # operating sytem

### OS detection to PLATFORM variable:
PLATFORM='unknown'
unamestr=$( uname )
if [ "$unamestr" == 'Darwin' ]; then
             PLATFORM='macos'
elif [ "$unamestr" == 'Linux' ]; then
             PLATFORM='linux'
elif [ "$unamestr" == 'FreeBSD' ]; then
             PLATFORM='freebsd'
elif [ "$unamestr" == 'Windows' ]; then
             PLATFORM='windows'
fi
if [ $PLATFORM != 'macos' ]; then
   echo ">>> This script is not designed for $unamestr = $PLATFORM."
   exit
else
   echo ">>> Platform = \"$PLATFORM\" "
fi

### 3. Shell utility functions:

cleanup() {
    err=$?
    fancy_echo "At cleanup() LOGFILE=$LOGFILE"
    #open -a "Atom" $LOGFILE
    open -e $LOGFILE  # open for edit using TextEdit
    #rm $LOGFILE
   FREE_DISKBLOCKS_END=$( df | awk '{print $4}' | cut -d' ' -f 6 ) 
#   DIFF=$(((FREE_DISKBLOCKS_START-FREE_DISKBLOCKS_END)/2048))
#   fancy_echo "$DIFF MB of disk space consumed during this script run." >>$LOGFILE
      # 380691344 / 182G = 2091710.681318681318681 blocks per GB
      # 182*1024=186368 MB
      # 380691344 / 186368 G = 2042 blocks per MB

   TIME_END=$( date -u +%s );
   DIFF=$(( TIME_END - TIME_START ))
   MSG="End of script $THISPGM after $(( DIFF/60 ))m $(( DIFF%60 ))s seconds elapsed."
   fancy_echo "$MSG"
   echo -e "\n$MSG" >>$LOGFILE

   #say "script ended."  # through speaker on Mac.

   trap '' EXIT INT TERM
   exit $err 
}

command_exists() {  # in /usr/local/bin/... if installed by brew
  command -v "$@" > /dev/null 2>&1
}

### 4. Delete local repository if it's there (for idempotency):

cd "$HOME"
   if [ ! -d "projects" ]; then # NOT found:
      echo "\n>>> Creating folder $HOME/projects since it's not there:"
      mkdir projects
   fi
         cd projects
   echo "PWD=$PWD"

   if [ ! -d "$WORK_FOLDER" ]; then # NOT found:
      echo "\n>>> Creating folders $HOME/project/$WORK_FOLDER ..."
      mkdir "$WORK_FOLDER"
   fi
          cd "$WORK_FOLDER"

echo "PWD=$PWD"


### 5. Pre-requisites installation

if [[ "$FEATURE_INSTALL_UTILITIES" == "yes" ]]; then

   # Install OSX

   if ! command_exists brew ; then
      fancy_echo "Installing homebrew using Ruby..."
      ruby -e "$( curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install) "
      brew tap caskroom/cask
   fi
   
   if ! command_exists tree ; then
      brew install tree
   fi
   
   if ! command_exists gradle ; then
      brew install gradle
   fi
   
   if ! command_exists jq ; then
      brew install jq  # to handle JSON
   fi
   
   if ! command_exists nodejs ; then
      brew install nodejs
   fi

   # To avoid error at 1:14 into https://app.pluralsight.com/player?course=docker-production-using-amazon-web-services&author=justin-menga&name=docker-production-using-amazon-web-services-m2&clip=3&mode=live
   node --version
   # brew install nodejs  # v9.11.1
   npm install bower --global  # bower@1.8.8
   npm install mocha --global  # mocha@6.1.4

   #brew install vert.x   # 3.5.4
      # https://en.wikipedia.org/wiki/Vert.x - a polyglot event-driven app framework on JVM
		# /usr/local/Cellar/vert.x/3.5.4: 134 files, 109MB, built in 32 seconds

   # https://github.com/lightbend/config
   # Typesafe configuration library for JVM languages using HOCON files https://lightbend.github.io/config/
   # for friendlier 12-factor environment variable based configuration support.

   ## Per https://github.com/wilsonmar/aws-starter
   pip install ansible awscli boto3 netaddr

fi


### 6. Fork and Download dependencies

   WORK_REPO="microtrader"
   # 1:23 into https://app.pluralsight.com/player?course=docker-production-using-amazon-web-services&author=justin-menga&name=docker-production-using-amazon-web-services-m2&clip=2&mode=live
   echo "\n>>> Creating folder $HOME/project/$WORK_FOLDER/$WORK_REPO if it's not there:"
   if [  -d "$WORK_REPO" ]; then # found:
      echo "\n>>> AtRemoving ~/projects/$WORK_FOLDER/$WORK_REPO from previous run:"
      rm -rf "$WORK_REPO"
   fi
   git clone "https://github.com/docker-production-aws/$WORK_REPO.git"
   cd "$WORK_REPO"
   echo "PWD=$PWD"

git checkout final  # rather than master branch.
git branch

echo "PWD=$PWD"


### 7. Build fat jars and run tests 

GRADLE_VERSION="$( gradle --version | grep Gradle | awk '{print $2}' | head -n 1 )"
if [ "$GRADLE_VERSION" = "4.10.2" ]; then
   echo "\n>>> Using gradle version $GRADLE_VERSION ..."
else
   echo "\n>>> Install Wrapping gradle to 4.10.2 to avoid version issues at too new gradle 5.4.1 built 019-04-26 08:14:42 UTC"
   # https://sdkman.io/install to /.sdkman folder:
   if ! command_exists sdk ; then
      curl -s "https://get.sdkman.io" | bash
      source "$HOME/.sdkman/bin/sdkman-init.sh"
      SDK_VERSION=$(sdk version)  # SDKMAN 5.7.3+337
      # sdk list gradle 
   fi
   sdk install gradle 4.10.2
   sdk default gradle 4.10.2
      # Setting gradle 4.10.2 as default.

   # Did not work: #gradle wrapper --gradle-version 4.10.2
      # This updates gradle/wrapper/gradle-wrapper.properties
   chmod +x gradlew
   echo "$(gradle --version)"
fi

echo "\n>>> ./gradlew clean test shadowJar"
# 1:17 into https://app.pluralsight.com/player?course=docker-production-using-amazon-web-services&author=justin-menga&name=docker-production-using-amazon-web-services-m2&clip=3&mode=live
./gradlew clean test shadowJar -Xlint:deprecation
      # SAMPLE RESPONSE:
      # Downloading https://services.gradle.org/distributions/gradle-4.10.2-bin.zip
      # BUILD SUCCESSFUL in 32s
      # In build-grade, function browser
      # results at: file:///Users/wilsonmar/projects/docker-production-aws/microtrader/build/test-results/junit/
   # 4:05 into https://app.pluralsight.com/player?course=docker-production-using-amazon-web-services&author=justin-menga&name=docker-production-using-amazon-web-services-m2&clip=3&mode=live
      # output from within build.gradle:
   # TODO: Python capture output into an array for individual files:
echo ">>> set -e  # Stop if RETURN=$? (1 = bad/STOP, 0 = good)"


### 8. Get rid of processes (run creates new ones):"

echo "\n>>> Remove disowned processes running from previous run (run creates new ones):"
jobs  # list processes disowned.
kill_microtrader_pids() {
   # ps -al yields: PID 32874 for CMD: /usr/bin/java -jar build/jars/MICROTRADER_quote-2019042115340
   echo "\n>>> Killing microtrader processes running in background from previous run:"
   ps -al | grep "microtrader"
   MICROTRADER_QUOTE_PSID=$(ps aux | grep 'MICROTRADER_quote' | awk '{print $2}' | head -n 1 )
   if [ -z ${MICROTRADER_QUOTE_PSID+x} ]; then kill "$MICROTRADER_QUOTE_PSID"; fi
   MICROTRADER_DASHBOARD_PSID=$(ps aux | grep 'MICROTRADER_dashboard' | awk '{print $2}' | head -n 1 )
   if [ -z ${MICROTRADER_QUOTE_PSID+x} ]; then kill "$MICROTRADER_DASHBOARD_PSID"; fi
   MICROTRADER_PORTFOLIO_PSID=$(ps aux | grep 'MICROTRADER_portfolio' | awk '{print $2}' | head -n 1 )
   if [ -z ${MICROTRADER_QUOTE_PSID+x} ]; then kill  "$MICROTRADER_PORTFOLIO_PSID"; fi
   MICROTRADER_AUDIT_PSID=$(ps aux | grep 'MICROTRADER_audit' | awk '{print $2}' | head -n 1 )
   if [ -z ${MICROTRADER_QUOTE_PSID+x} ]; then kill "$MICROTRADER_AUDIT_PSID"; fi
}
kill_microtrader_pids
   # "No such process" is expected when run the first time.

### 9. Prepare path to each Fat Jar in a different instance in & background: 

# See 1:20 into https://app.pluralsight.com/player?course=docker-production-using-amazon-web-services&author=justin-menga&name=docker-production-using-amazon-web-services-m3&clip=3&mode=live
MAKE_VERSION=$( make version )
   # VERBOSE: echo "\n>>> MAKE_VERSION=$MAKE_VERSION"  #  MAKE_VERSION={"Version": "20190421153402.a295436"}
# Remove leading {"Version": " (13 characters):
MAKE_VERSION=$( echo "${MAKE_VERSION:13}" )
# Remove trailing "}" using POSIX command ? substitution wildcard:
MAKE_VERSION=$( echo "${MAKE_VERSION%??}" )
echo "\n>>> MAKE_VERSION=$MAKE_VERSION"  # example: 20190421153402.a295436

# Prepare variables containing 
   AUDIT_JAR="MICROTRADER-audit-$MAKE_VERSION-fat.jar"          # 21,775,871
   DASHBOARD_JAR="MICROTRADER-dashboard-$MAKE_VERSION-fat.jar"  # 17,972,432
   PORTFOLIO_JAR="MICROTRADER-portfolio-$MAKE_VERSION-fat.jar"  # 17,722,025
   QUOTE_JAR="MICROTRADER-quote-$MAKE_VERSION-fat.jar"          # 16,723,780

echo "\n>>> ls -l build/jars  ..."
echo "$PWD ..."
ls build/jars
      # SAMPLE RESPONSE:
      # -rw-r--r--  1 wilsonmar  staff  21775871 Jun 19 18:55 MICROTRADER_audit-20190421153402.a295436-fat.jar
      # where "20190421153402" is Git's commitTimestamp and ".a295436" is the commitId (hash).


echo "\n>>> ### 10. Run microtrader apps in & background: "

# Referenced: https://www.maketecheasier.com/run-bash-commands-background-linux/
# Described in Chapter 3: Creating the Sample App:
# 0 into https://app.pluralsight.com/player?course=docker-production-using-amazon-web-services&author=justin-menga&name=docker-production-using-amazon-web-services-m2&clip=4&mode=live

echo "\n>>> Creating HSQLDB schema within ./audit-db.* for Audit service:"
# 4:29 into https://app.pluralsight.com/player?course=docker-production-using-amazon-web-services&author=justin-menga&name=docker-production-using-amazon-web-services-m2&clip=4&mode=live
#chmod +s "build/jars/$AUDIT_JAR" 
java -cp "build/jars/$AUDIT_JAR" com.pluralsight.dockerproductionaws.admin.Migrate
   # SAMPLE RESPONSE:
   # Jul 26, 2019 6:57:39 AM org.flywaydb.core.internal.util.VersionPrinter printVersion
   # INFO: Flyway 4.2.0 by Boxfuse
# The above is supposed to create audit-db.script/.tmp/.log/.properties in root:
echo "\n>>> ls audit-db.*  ..."
ls audit-db.*

echo ">>> Start Quote Generator in background (through nohup)"
# PROTIP: Background programs are invoked together in one command combined with continuation character \ :
 chmod +s "build/jars/$QUOTE_JAR" 
java -jar "build/jars/$QUOTE_JAR" --cluster & \
java -jar "build/jars/$DASHBOARD_JAR" --cluster & \
java -jar "build/jars/$PORTFOLIO_JAR" --cluster & \
java -jar "build/jars/$AUDIT_JAR" com.pluralsight.dockerproductionaws.admin.Migrate & 
### This will keep generating Bought and Sold lines. 
# Every 3 seconds by default.
   # SAMPLE RESPONSE:
   # responses: $ Jun 20, 2019 2:13:32 AM io.vertx.core.impl.launcher.commands.RunCommand
   # Jun 20, 2019 7:51:06 AM com.hazelcast.internal.partition.impl.PartitionStateManager
   # INFO: [127.0.0.1]:5701 [dev] [3.10.5] Initializing cluster partition table arrangement...
   # Jun 20, 2019 7:51:06 AM io.vertx.core.impl.launcher.commands.VertxIsolatedDeployer
   # INFO: Succeeded in deploying verticle
   # Market data service published : true
   # Quotes (Rest endpoint) service published : true
   # Server started
   # appending output to nohup.out
# Ocassionally:
# D'oh, failed to buy 6 of Black Coat : (RECIPIENT_FAILURE,-1) Cannot buy 6 of Black Coat - not enough money, need 4242.0, has 4074.0

echo "\n>>> Lines below are not invoked because --cluster tells vert.x to restart automatically."
echo $(ps aux | grep 'MICROTRADER_quote' | awk '{print $2}' | head -n 1 )
echo "\n>>> So control+C doesn't work. Manually close terminal session by clicking on the green icon."

### Manually verify current stock prices appear in JSON: on MacOS:
# open http://localhost:35000

# fg  # fg=foreground
   # ./MICROTRADER_setup.sh: line 274: fg: no job control

if [[ "$FEATURE_REMOVE_AT_END" == "yes" ]]; then
   echo "\n>>> Killing processes..."
   kill_microtrader_pids

   echo "\n>>> Removing WORK_REPO=$WORK_REPO"
   ls -al
   rm -rf "$WORK_REPO"
fi

echo "\n>>> Done."
#exit 
