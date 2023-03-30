#!/bin/bash

CentOSX="${1}"

case ${CentOSX} in
  5)
   for i in {0..11}
   do
     echo -e "5.${i}:\n"
     curl -sk --retry 3 https://vault.centos.org/5.${i}/os/x86_64/CentOS/ | grep -o "href=\"kernel-devel.*rpm\">" | grep -oE "[0-9].*x86_64"
     curl -sk --retry 3 https://vault.centos.org/5.${i}/updates/x86_64/RPMS/ | grep -o "href=\"kernel-devel.*rpm\">" | grep -oE "[0-9].*x86_64"
     echo -e "\n\n"
   done
   ;;
  6)
   for i in {0..10}
   do
     echo -e "6.${i}:\n"
     curl -sk --retry 3 "https://vault.centos.org/6.${i}/os/x86_64/Packages/" | grep -o "href=\"kernel-devel.*rpm\">" |grep -oE "[0-9].*x86_64"
     headers=$(curl -sk --retry 3 "https://vault.centos.org/6.${i}/updates/x86_64/Packages/" | grep -o "href=\"kernel-devel.*rpm\">" |grep -oE "[0-9].*x86_64")
     if [[ ${headers} != "" ]];then
       echo "${headers}"
     else
       curl -sk --retry 3 "https://vault.centos.org/6.${i}/updates/x86_64/RPMS/" | grep -o "href=\"kernel-devel.*rpm\">" |grep -oE "[0-9].*x86_64"   #for 6.0
     fi
     echo -e "\n\n"
   done
   ;;
  7)
   centos7Version=(7.0.1406 7.1.1503 7.2.1511 7.3.1611 7.4.1708 7.5.1804 7.6.1810 7.7.1908 7.8.2003 7.9.2009)
   for version in ${centos7Version[*]}
   do
     echo -e "${version}:\n"
     if [[ ${version} != "7.9.2009" ]];then
       curl -sk --retry 3 "https://vault.centos.org/${version}/os/x86_64/Packages/" | grep -o "href=\"kernel-devel.*rpm\">" |grep -oE "[0-9].*x86_64"
       curl -sk --retry 3 "https://vault.centos.org/${version}/updates/x86_64/Packages/" | grep -o "href=\"kernel-devel.*rpm\">" |grep -oE "[0-9].*x86_64"
     else
       curl -sk --retry 3 "http://mirror.centos.org/centos/7.9.2009/os/x86_64/Packages/" | grep -o "href=\"kernel-devel.*rpm\">" |grep -oE "[0-9].*x86_64"
       curl -sk --retry 3 "http://mirror.centos.org/centos/7.9.2009/updates/x86_64/Packages/" | grep -o "href=\"kernel-devel.*rpm\">" |grep -oE "[0-9].*x86_64"
     fi
     echo -e "\n\n"
   done
   ;;
  8)
   centos7Version=(8.0.1905 8.1.1911 8.2.2004 8.3.2011 8.4.2105 8.5.2111)
   for version in ${centos7Version[*]}
   do
     echo -e "${version}:\n"
     curl -sk --retry 3 "https://vault.centos.org/${version}/BaseOS/x86_64/os/Packages/" | grep -o "href=\"kernel-devel.*rpm\">" |grep -oE "[0-9].*x86_64"
     echo -e "\n\n"
   done
   ;;
  el5|el6|el7|el8)
   echo -e "elrepo${CentOSX: -1}:\n"
   curl -sk --retry 3 http://193.49.22.109/elrepo/kernel/${CentOSX}/x86_64/RPMS/ | grep -oE "href=\"kernel-(lt|ml)-devel.*rpm\">" | grep -oE "(lt|ml).*.x86_64"
   echo -e "\n\n"
   ;;
  *)
   echo "please input one of [5,6,7,8,el5,el6,el7,el8]"
   exit 1
   ;;
esac
