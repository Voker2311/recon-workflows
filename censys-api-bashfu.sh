#!/bin/bash

for i in `cat subdomains.txt`;do                                                                                                                                                              
   dig +short +recurse A $i;                                                                                                                                                                  
done | grep -oE "[0-9]{1,3}.+" | grep -v "[a-z]" | sort -u > ips.txt     

# Getting list of ips from censys.io                                                                                                                                                  
echo "[*] Getting the list of ips associated to the target from censys"                                                                                                                       
API_KEY="api_key" # Change this                                                                                                                                  
SECRET="secret_key" # Change this                                                                                                                                       
TARGET="target.com"                                                                                                                                                                          
count=$(curl -s -u "$API_KEY":"$SECRET" -H 'Content-Type: application/json' "https://search.censys.io/api/v2/hosts/search?q=$TARGET&per_page=100" | jq -r .result.total)                      
iters=$(expr "$count" / 100 + 1)                                                                                                                                                              
cursor=""                                                                                                                                                                                     
for ((i = 1 ; i <= "$iters" ; i++));do                                                                                                                                                        
                curl -s -u "$API_KEY":"$SECRET" -H 'Content-Type: application/json' "https://search.censys.io/api/v2/hosts/search?q=$TARGET&per_page=100&cursor=$cursor" | jq -r .result.hits[
].ip >> ips.txt                                                                                                                                                                               
next=$(curl -s -u "$API_KEY":"$SECRET" -H 'Content-Type: application/json' "https://search.censys.io/api/v2/hosts/search?q=$TARGET&per_page=100&cursor=$cursor" | jq -r .result.links.next)   
if [[ ! -z "$next" ]];then                                                                                                                                                                    
   cursor=$next                                                                                                                                                                               
fi                                                                                                                                                                                            
done
