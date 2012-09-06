Description
===========

This rsync based script is used to automate a backup procedure by offering
some nice features.

Features
========

 *  **Normal mode**: This is a useful mode when the machine(s) that keep(s)
    backups are common PC, which you turn off regularly.
 *  **Always online mode**: This mode is used when the machine(s) that keep(s)
    backups are always online. In this mode to set the backup intervals 
    you have create an appropriate cron job.
 *  **Compression**: The older backups will be archived in tar.gz files.
 *  **Rotated backups:** You are able to rotate a certain number of backups so
    you wont run out disk.
 *  **Synchronized backup lists:** You are able to setup multiple machines
    to backup a single one.
 *  **Log keeping:** This way you will be able to know what happened and when.

Installation
============

  1. Download it and make it executable.
  2. Set all the configuration options that are mentioned below.
  3. Create a backup list file in the remote machine.
  4. If you want to fully automate the backups you should consider seting up 
     an key authenticated ssh connection between the computers running this script
     and the one that you want to backup.
  5. Test the execution. In this step you might want to temprary add "--dry-run"
     to RSYNC\_OPTIONS.
  6. If you want it fully automated you should add a cron job. In normal mode
     it is adviced to set a frequent cronjob to make sure that when you turn on
     your PC and the MIN\_DAYS have passed a backup will be taken. In always online
     mode you just have to set the cron job to the interval you want to backup.


Configuration
=============

Configuration options
---------------------

Edit the configuration section in the script.

 *  **BACKUP\_NAME**: This is used as a prefix in the tarball files.  
    Example: BACKUP\_NAME="Webserver";
 *  **BACKUP\_DIR**: The disk path where the backups will be located.  
    Example: BACKUP\_DIR="/home/foo/backup";
 *  **BACKUP\_LIST**: The filename of the rsync list that will be used for
    the backup.  
    Example: BACKUP\_LIST="backup.lst";
 *  **BACKUP\_LIST\_REMOTE_DIR**: Path of the backup list file on the remote
    computer.  
    Example: BACKUP\_LIST\_REMOTE\_DIR="/home/foo/";
 *  **USER**: User for the ssh connection.  
    Example: USER="conx";
 *  **RSYNC\_OPTIONS**: Options passed to the rsync.  
    Example: RSYNC\_OPTIONS="-ahog --delete";
 *  **TAR\_FILES\_NUM**: The number of the old backups you would like to have.
    This must be set to a value that suits your needs. If you want to have
    a large history of backup images (and you don't have a disk space issue)
    you can set this to a high value.  
    Example: TAR\_FILES\_NUM="3";
 *  **MIN\_DAYS**: This sets the interval in days of the backup for the normal mode.
    If this is set to zero the script will run in "Always online" mode.  
    Example: MIN\_DAYS="2";

Backup lists format
-------------------

Read the include/exclude patterns in rsync's man page. 

_Example_: 

     + etc/
     + etc/apache2**
     + var/
     + var/www**
     - **

Some useful details
===================

The script creates a directory named "cur" in which you will find the last taken backup uncompressed.  
There are also some logfiles located under the BACKUP\_DIR, the one that is in BACKUP\_DIR will have
messages for the backup that hasn't been completed yet. In the BACKUP\_DIR/cur dirctory you will 
find a logfile for the last taken backup and finally there are logfiles in every tar file and this way
you will know when the backup was taken.
