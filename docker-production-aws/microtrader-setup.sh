#!/bin/sh #for POSIX-compliant Bourne shell that runs cross-platform

# microtrader-setup.sh in https://github.com/wilsonmar/DevSecOps/docker-production-aws
# as described in https://wilsonmar.github.io/docker-production-aws.

# This script builds from source the microtrader sample app used in 
# Justin Menga's course released 10 May 2016 on Pluralsight at:
# https://app.pluralsight.com/library/courses/docker-production-using-amazon-web-services/table-of-contents
# which shows how to install a "microtraders" Java app in aws using Docker, ECS, CloudFormation, etc.

# This script is run by this command on MacOS/Linux Terminal:
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/docker-production-aws/docker-production-aws-setup.sh)"

# This is free software; see the source for copying conditions. There is NO
# warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

# CURRENT STATUS: under construction, with TODO items.

### 1. Run Parameters controlling this run:

INSTALL_UTILITIES="no"  # or yes
WORK_FOLDER="docker-production-aws"  # as specified in course materials.

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
echo ">>> $LOGFILE"
#echo "$TO_PRINT" >$LOGFILE  # single > for new file
echo "$TO_PRINT"  # to screen
uname -a  # operating sytem


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


### 4. Pre-requisites installation

if [[ "$INSTALL_UTILITIES" == "yes" ]]; then

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

### 5. Delete local repository if it's there (for idempotency):

cd "$HOME"
   echo "\n>>> Creating folder $HOME/projects if it's not there:"
   if [ ! -d "projects" ]; then # NOT found:
      mkdir projects
   fi
         cd projects
   echo "PWD=$PWD"

   if [ ! -d "$WORK_FOLDER" ]; then # NOT found:
      echo "\n>>> Creating folders $HOME/project/$WORK_FOLDER if it's not there:"
      mkdir "$WORK_FOLDER"
   fi
          cd "$WORK_FOLDER"

echo "PWD=$PWD"


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

# 1:17 into https://app.pluralsight.com/player?course=docker-production-using-amazon-web-services&author=justin-menga&name=docker-production-using-amazon-web-services-m2&clip=3&mode=live
./gradlew clean test shadowJar
      # Downloading https://services.gradle.org/distributions/gradle-4.10.2-bin.zip
      # BUILD SUCCESSFUL in 32s
      # In build-grade, function borwser
   # 4:05 into https://app.pluralsight.com/player?course=docker-production-using-amazon-web-services&author=justin-menga&name=docker-production-using-amazon-web-services-m2&clip=3&mode=live
      # output from within build.gradle:
   # TODO: Python capture output into an array for individual files:
echo ">>> TODO: Stop if RETURN=$? (1 = bad/STOP, 0 = good)"


### 8. Get rid of processes (run creates new ones):"

echo "\n>>> Remove disowned processes running from previous run (run creates new ones):"
jobs  # list processes disowned.
kill_microtrader_pids() {
   # ps -al yields: PID 32874 for CMD: /usr/bin/java -jar build/jars/microtrader-quote-2019042115340
   echo "\n>>> Killing microtrader processes running in background from previous run:"
   ps -al | grep "microtrader"
   kill $(ps aux | grep 'microtrader-quote' | awk '{print $2}' | head -n 1 )
   kill $(ps aux | grep 'microtrader-dashboard' | awk '{print $2}' | head -n 1 )
   kill $(ps aux | grep 'microtrader-portfolio' | awk '{print $2}' | head -n 1 )
   kill $(ps aux | grep 'microtrader-audit' | awk '{print $2}' | head -n 1 )
}
kill_microtrader_pids


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
   AUDIT_JAR="microtrader-audit-$MAKE_VERSION-fat.jar"          # 21,775,871
   DASHBOARD_JAR="microtrader-dashboard-$MAKE_VERSION-fat.jar"  # 17,972,432
   PORTFOLIO_JAR="microtrader-portfolio-$MAKE_VERSION-fat.jar"  # 17,722,025
   QUOTE_JAR="microtrader-quote-$MAKE_VERSION-fat.jar"          # 16,723,780

ls -l build/jars
      # -rw-r--r--  1 wilsonmar  staff  21775871 Jun 19 18:55 microtrader-audit-20190421153402.a295436-fat.jar
      # where "20190421153402" is Git's commitTimestamp and ".a295436" is the commitId (hash).


### 10. Run microtrader apps in & background: 

# Referenced: https://www.maketecheasier.com/run-bash-commands-background-linux/
# 0 into https://app.pluralsight.com/player?course=docker-production-using-amazon-web-services&author=justin-menga&name=docker-production-using-amazon-web-services-m2&clip=4&mode=live
# Start Quote Generator in background (through nohup)
chmod +s "build/jars/$QUOTE_JAR" 

java -jar "build/jars/$QUOTE_JAR" --cluster & \
java -jar "build/jars/$DASHBOARD_JAR" --cluster & \
java -jar "build/jars/$PORTFOLIO_JAR" --cluster & \
java -jar "build/jars/$AUDIT_JAR" com.pluralsight.dockerproductionaws.admin.Migrate & \
open localhost:35000 \
fg  # fg=foreground

   # responses: $ Jun 20, 2019 2:13:32 AM io.vertx.core.impl.launcher.commands.RunCommand
   # Jun 20, 2019 7:51:06 AM com.hazelcast.internal.partition.impl.PartitionStateManager
   # INFO: [127.0.0.1]:5701 [dev] [3.10.5] Initializing cluster partition table arrangement...
   # Jun 20, 2019 7:51:06 AM io.vertx.core.impl.launcher.commands.VertxIsolatedDeployer
   # INFO: Succeeded in deploying verticle
   # Market data service published : true
   # Quotes (Rest endpoint) service published : true
   # Server started
   # appending output to nohup.out

echo $(ps aux | grep 'microtrader-quote' | awk '{print $2}' | head -n 1 )

### Verify current stock prices appear in JSON: on MacOS:
open localhost:35000

exit

# Start Dashboard
java -jar "build/jars/$DASHBOARD_JAR" --cluster &
# TODO: Open localhost:8000


# Start Portfolio service to manage the stocks traded by each trader:
java -jar "build/jars/$PORTFOLIO_JAR" --cluster &
# View portfolio pane on dashboard localhost:8500 to verify


####    creating HSQLDB schema within ./audit-db.* for Audit service:
# 4:20 into https://app.pluralsight.com/player?course=docker-production-using-amazon-web-services&author=justin-menga&name=docker-production-using-amazon-web-services-m2&clip=4&mode=live
java -jar "build/jars/$AUDIT_JAR" com.pluralsight.dockerproductionaws.admin.Migrate &
      # within Migrate.jar in microtrader-audit/src/main/java/com/pluralsight/dockerproductionaws/admin/...
      # Start Audit service using HSQLDB within ./audit-db.*
    # Oct 11, 2018 5:11:24 AM org.flywaydb.core.internal.util.VersionPrinter printVersion
    # INFO: Flyway 4.2.0 by Boxfuse
# TODO: Open localhost:8500 to verify

# Circuit breaker pattern in 7:05 into https://app.pluralsight.com/player?course=docker-production-using-amazon-web-services&author=justin-menga&name=docker-production-using-amazon-web-services-m2&clip=4&mode=live

### 11. Context: Starting time stamp, OS versions, command attributes:

echo "\n>>> passed"  # DEBUGGING.
exit


### 13. 

echo "\n>>> Running mocha tests on JavaScript:"
mocha --exit
   if [ $? -ne 0 ]; then
      echo "/n>>> RETURN=$? (1 = bad/STOP, 0 = good)"
   fi

exit


### 14. cd microtrader-specs  # contains package.json test



### Test - see https://app.pluralsight.com/player?course=docker-production-using-amazon-web-services&author=justin-menga&name=docker-production-using-amazon-web-services-m3&clip=5&mode=live
   # using task copyDeps in the build.gradle file.
make test

### Clean-up with make clean [1:29]

### See https://app.pluralsight.com/player?course=docker-production-using-amazon-web-services&author=justin-menga&name=docker-production-using-amazon-web-services-m3&clip=8&mode=live
make release
   # Quote REST endpoint is running at <a href="http://localhost:32770/quote/">http://localhost:32770/quote/</a>
   # Audit REST endpoint is running at <a href="http://localhost:32768/audit/">http://localhost:32768/audit/</a>
   # Trader dashboard is running at <a href="http://localhost:32771">http://localhost:32771</a>

### [1:53] into https://app.pluralsight.com/player?course=docker-production-using-amazon-web-services&author=justin-menga&name=docker-production-using-amazon-web-services-m3&clip=8&mode=live
docker ps

### [0:13] https://app.pluralsight.com/player?course=docker-production-using-amazon-web-services&author=justin-menga&name=docker-production-using-amazon-web-services-m3&clip=9&mode=live
# Makefile has: make tag latest $(APP_VERSION) $(COMMIT_ID) $(COMMIT_TAG)

### [1:16] https://app.pluralsight.com/player?course=docker-production-using-amazon-web-services&author=justin-menga&name=docker-production-using-amazon-web-services-m3&clip=9&mode=live
make clean

