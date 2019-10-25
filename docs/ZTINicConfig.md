# ZTINicConfig.wsf patch

The ZTINicConfig.wsf script is responsible for saving and restoring the network settings.
The patch here:
* add a sleep command at a given stage as some combination of network drivers, OS and equipments have trouble to get the new settings immediately
* add the support for the DNS Suffix search order list

In order to set one or more DNS Search suffixes, the script searches for the following SMS/BDD Environment list variable in order
 - SetupDNSSuffixSearchOrder
 - DNSSuffixSearchOrder
 
 The resulting set of variables will be for example:

 * Example 1:
   * SetupDNSSuffixSearchOrder001=example.com
   * SetupDNSSuffixSearchOrder002=example.net

  to get a client which will search for example.com and example.net in that order

 * Example 2:
    * SetupDNSSuffixSearchOrder001 not defined
    * DNSSuffixSearchOrder001=mycompany.com
    * DNSSuffixSearchOrder002=myprovider.org

  to get a client which will search for mycompany.com and myprovider.org in that order.

  

