# Vagrantfile Readme
In the ADORe tools/vagrant directory you will find several Vagrantfiles.  

## Background
This project in `adore_tools/vagrant` provides two vagrant contexts for running
ADORe:
- Headless context: no display, command line only
- Headed context: virtual display and desktop environment

Both contexts will have all necessary dependencies installed, ADORe cloned, and
all ADORe core modules built.

## Getting Started
1. Install Virtualbox: [https://www.virtualbox.org/ 🔗](https://www.virtualbox.org/)
2. Install Vagrant: [https://www.vagrantup.com/ 🔗](https://www.vagrantup.com/)
3. Run vagrant with the provided make targets:
```bash
make up
```
or headless:
```bash
make up_headless
```

## Cleaning Up
There is a make target provided to clean up the virtual machines:
```bash
make destroy
```
