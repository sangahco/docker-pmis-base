[![HitCount](http://hits.dwyl.io/sangahco/sangahco/docker-pmis-base.svg)](http://hits.dwyl.io/sangahco/sangahco/docker-pmis-base)
[![Jenkins](https://img.shields.io/jenkins/s/https/dev.builder.sangah.com/job/pmis-base.svg?style=flat-square)]()

# Base PMIS Image

This is a barebone image that require the archive 
file `stnd_pmis.war` in order to work.

## How to use it

Write a new `Dockerfile` on a new folder 
and put the build generated archive file inside this new folder.

The Dockerfile should have at least the FROM like below:

    FROM dev.sangah.com:5043/pmis-base

You don't need to put anything else, then build with:

    $ docker build -t someprojectname-pmis .

Then you are ready to use it.
