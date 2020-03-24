#!/usr/bin/env bash

# secrets.sh in https://github.com/wilsonmar/DevSecOps
# referenced by macos-install-all.sh in the same repo.
# This file name secrets.sh should be specified in .gitignore so 
#    it doesn't upload to a public GitHub/GitLab/BitBucket/etc.
# Run command source secrets.sh pulls these variables in:
# CAUTION: No spaces around = sign.
GIT_NAME="Wilson Mar"
GIT_ID="WilsonMar@gmail.com"
GIT_EMAIL="WilsonMar+GitHub@gmail.com"
GIT_USERNAME="hotwilson"
GPG_PASSPHRASE="only you know this 2 well"
GITS_PATH="~/gits"
GITHUB_ACCOUNT="hotwilson"
GITHUB_PASSWORD="change this to your GitHub account password"
GITHUB_REPO="sample"

# Lists can be specified below. The last one in a list is the Git default:
MAC_TOOLS="mariadb"
         # 1password, powershell, kindle, mas?
GIT_CLIENT=""
          # git, cola, github, gitkraken, smartgit, sourcetree, tower, magit, gitup
GIT_EDITOR=""
          # atom, code, eclipse, emacs, intellij, macvim, nano, pico, sts, sublime, textmate, textedit, vim
          # NOTE: pico, nano, and vim are built into MacOS, so no install.
          # NOTE: textwrangler is a Mac app manually installed from the Apple Store.
GIT_BROWSER=""
           # chrome, firefox, brave, phantomjs   NOT: Safari
BROWSER_TOOLS=""

GIT_TOOLS=""
         # none, hooks, tig, lfs, diff-so-fancy, grip, p4merge, git-flow, signing, hub
GUI_TEST=""
        # selenium, sikulix, golum, 
        # Drivers for scripting language depend on what is defined in $GIT_LANG.
GIT_LANG=""
        # python, python3, java, node, go
JAVA_TOOLS=""
          # maven, gradle, TestNG, Mockito, Cucumber, gcviewer, jmeter, jprofiler  # REST-Assured, Spock
          # (junit4, junit5, yarn are integrated using maven or gradle)
PYTHON_TOOLS=""
            # virtualenv, anaconda, jupyter, ipython, numpy, scipy, matplotlib, pytest, robot
            # See http://www.southampton.ac.uk/~fangohr/blog/installation-of-python-spyder-numpy-sympy-scipy-pytest-matplotlib-via-anaconda.html
NODE_TOOLS=""
          # bower, gulp, gulp-cli, npm-check, jscs, less, jshint, eslint, webpack, 
          # mocha, chai, protractor, 
          # browserify, express, hapi, angular, react, redux
          # graphicmagick, aws-sdk, mongodb, redis
CLOUD=""
     # none, aws, gcp, azure, cf, terraform, serverless, docker, vagrant, minikube  # NOT: openstack
   SAUCE_USERNAME=""
   SAUCE_ACCESS_KEY=""
TRYOUT=""  # smoke tests.
      # HelloJUnit5, TODO:virtuaenv, phantomjs, docker, hooks, jmeter, minikube, cleanup, editor
COMM_TOOLS=""
          # google-hangouts, hipchat, keybase, microsoft-lync, skype, slack, teamviewer, whatsapp, sococo, zoom
          # NO gotomeeting (32-bit)

# To upgrade, add parameter in the command line:
#    ./mac-git-install.sh upgrade
