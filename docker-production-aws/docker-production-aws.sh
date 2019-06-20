#!/bin/sh #for POSIX-complian Bourne shell 

# microtrader-setup.sh in https://github.com/wilsonmar/DevSecOps/docker-production-aws
# as described in https://wilsonmar.github.io/docker-production-aws.
# This script automates Justin Menga's course released 10 May 2016 on Pluralsight at:
# https://app.pluralsight.com/library/courses/docker-production-using-amazon-web-services/table-of-contents
# which shows how to install a "microtraders" Java app in aws using Docker, ECS, CloudFormation, etc.

# sh -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/docker-production-aws/docker-production-aws-setup.sh)"

# This is free software; see the source for copying conditions. There is NO
# warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

# CURRENT STATUS: under construction, with TODO items.

### 1. Parameters Local Info

# TODO: MacOS version:

### 2. Utilities definition

### 3. Pre-requisites installation

# brew install gradle

# To avoid error at 1:14 into https://app.pluralsight.com/player?course=docker-production-using-amazon-web-services&author=justin-menga&name=docker-production-using-amazon-web-services-m2&clip=3&mode=live
node --version
   # brew install nodejs  # v9.11.1
npm install bower --global  # bower@1.8.8
npm install mocha --global  # mocha@6.1.4

#brew install vert.x
   # https://en.wikipedia.org/wiki/Vert.x - a polyglot event-driven app framework on JVM
		# /usr/local/Cellar/vert.x/3.5.4: 134 files, 109MB, built in 32 seconds
# vertx version  # 3.5.4

brew install gradle
brew install jq  # to handle JSON

# https://github.com/lightbend/config
# Typesafe configuration library for JVM languages using HOCON files https://lightbend.github.io/config/
# for friendlier 12-factor environment variable based configuration support.


### 4. Delete local repository if it's there for idempotency:

# Remove processes running from previous run:
ps -al

### 5. Create/cd local repository:

echo "PWD=$PWD"
# TODO: Create folder if it's not there:
cd ~
cd projects
# TODO: Create folder if it's not there:
# mkdir docker-production-aws
cd docker-production-aws
echo "PWD=$PWD"

### 6. Fork and Download dependencies

# Fork https://github.com/docker-production-aws/microtrader
#git clone git@github.com:wilsonmar/microtrader-base.git
#git clone git@github.com:wilsonmar/microtrader.git
   # [1:20] https://app.pluralsight.com/player?course=docker-production-using-amazon-web-services&author=justin-menga&name=docker-production-using-amazon-web-services-m2&clip=2&mode=live

# 1:23 into https://app.pluralsight.com/player?course=docker-production-using-amazon-web-services&author=justin-menga&name=docker-production-using-amazon-web-services-m2&clip=2&mode=live
git clone https://github.com/docker-production-aws/microtrader.git
cd microtrader
git checkout final  # rather than master branch.

echo "PWD=$PWD"


### 7. Build fat jars and run tests 

echo ">>> First, get rid of files from previous run:"
# 1:17 into https://app.pluralsight.com/player?course=docker-production-using-amazon-web-services&author=justin-menga&name=docker-production-using-amazon-web-services-m2&clip=3&mode=live
# ./gradlew clean test shadowJar
      # Downloading https://services.gradle.org/distributions/gradle-4.10.2-bin.zip
      # BUILD SUCCESSFUL in 32s
      # In build-grade, function borwser
# 4:05 into https://app.pluralsight.com/player?course=docker-production-using-amazon-web-services&author=justin-menga&name=docker-production-using-amazon-web-services-m2&clip=3&mode=live
      # output from within build.gradle:
   # TODO: Python capture output into an array for individual files:
ls -l build/jars
      # -rw-r--r--  1 wilsonmar  staff  21775871 Jun 19 18:55 microtrader-audit-20190421153402.a295436-fat.jar
      # where "20190421153402" is Git's commitTimestamp and ".a295436" is the commitId (hash).

### 8. Run each Fat Jar in a different instance: 

MAKE_VERSION=$(make version)
echo ">>> MAKE_VERSION=$MAKE_VERSION"
# TODO: Extract from {"Version": "20190421153402.a295436"}
MAKE_VERSION="20190421153402.a295436"  # Temporary while debugging
   QUOTE_JAR="microtrader-quote-$MAKE_VERSION-fat.jar"
   DASHBOARD_JAR="microtrader-dashboard-$MAKE_VERSION-fat.jar"
   PORTFOLIO_JAR="microtrader-portfolio-$MAKE_VERSION-fat.jar"
   AUDIT_JAR="microtrader-audit-$MAKE_VERSION-fat.jar"
# https://programminghistorian.org/en/lessons/json-and-jq
#TODO: If tests pass, continue.

# ps -al yields: PID 32874 for CMD: /usr/bin/java -jar build/jars/microtrader-quote-2019042115340
echo ">>> WARNING: Processes running in background:"
ps -al | grep "microtrader-"

exit


# 0 into https://app.pluralsight.com/player?course=docker-production-using-amazon-web-services&author=justin-menga&name=docker-production-using-amazon-web-services-m2&clip=4&mode=live
# Start Quote Generator:
java -jar "build/jars/$QUOTE_JAR" --cluster &
### 7.1. Verify current stock prices appear in JSON:
# TODO: Open localhost:35000

# Start Dashboard
java -jar "build/jars/$DASHBOARD_JAR" --cluster &
# TODO: Open localhost:8000

# Start Portfolio service to manage the stocks traded by each trader:
java -jar "build/jars/$PORTFOLIO_JAR" --cluster &
# View portfolio pane on dashboard localhost:8500 to verify

### 8. Create HSQLDB schema within ./audit-db.* for Audit service:
# 4:20 into https://app.pluralsight.com/player?course=docker-production-using-amazon-web-services&author=justin-menga&name=docker-production-using-amazon-web-services-m2&clip=4&mode=live
java -jar "build/jars/$AUDIT_JAR" com.pluralsight.dockerproductionaws.admin.Migrate &
      # within Migrate.jar in microtrader-audit/src/main/java/com/pluralsight/dockerproductionaws/admin/...
      # Start Audit service using HSQLDB within ./audit-db.*
# TODO: Open localhost:8500 to verify

# Circuit breaker pattern in 7:05 into https://app.pluralsight.com/player?course=docker-production-using-amazon-web-services&author=justin-menga&name=docker-production-using-amazon-web-services-m2&clip=4&mode=live


# Run database migration   # [5:16] https://app.pluralsight.com/player?course=docker-production-using-amazon-web-services&author=justin-menga&name=docker-production-using-amazon-web-services-m2&clip=4&mode=live
java -cp "build/jars/$AUDIT_JAR" com.pluralsight.dockerproductionaws.admin.Migrate
    # Oct 11, 2018 5:11:24 AM org.flywaydb.core.internal.util.VersionPrinter printVersion
    # INFO: Flyway 4.2.0 by Boxfuse
ls -l audit-*  # .log, properties, script, .tmp
java -jar "build/jars/$AUDIT_JAR" -cluster &

java -jar "build/jars/$PORTFOLIO_JAR" -cluster &


### 9. cd microtrader-specs  # contains package.json test



### 10. Microtrader-base

# cd ..
# git clone https://github.com/docker-production-aws/microtrader-base.git





##A# Per https://github.com/wilsonmar/aws-starter
pip2 install ansible awscli boto3 netaddr

cd ..
cd microtrader

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

