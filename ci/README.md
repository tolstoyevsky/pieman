Here is the Jenkins Pipeline script for building on a daily basis the images of all supported operating systems for all supported devices. To know which devices and operating systems are supported by Pieman, see the [Documentation](https://github.com/tolstoyevsky/pieman#documentation).

## Working principle

First, the job is run with one of the following parameters:

* `Devuan Jessie (32bit)`
* `Raspbian Stretch (32bit)`
* `Ubuntu Xenial (32bit)`
* `Ubuntu Artful (32bit)`
* `Ubuntu Artful (64bit)`

Then, the job builds the Pieman docker image and runs Pieman in the container. Next, Pieman, in turn, builds the corresponding image. Finally, the image becomes available [here](https://cusdeb.com/images-built-by-pieman).


## Dependencies

The script requires [Pipeline](https://wiki.jenkins.io/display/JENKINS/Pipeline+Plugin) and [Docker Pipeline](https://wiki.jenkins.io/display/JENKINS/Docker+Pipeline+Plugin) plugins. Also [Parameterized Scheduler](https://wiki.jenkins.io/display/JENKINS/Parameterized+Scheduler+Plugin) might be used to run the job according to a schedule.