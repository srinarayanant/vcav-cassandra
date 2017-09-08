
rm -f /home/keystore1
rm -f /home/keystore2
rm -f /home/keystore3
rm -f /home/hcs1
rm -f /home/hcs2

rm -f /home/cloud-vcav-cassandra1.pem
rm -f /home/cloud-vcav-cassandra2.pem
rm -f /home/cloud-vcav-cassandra3.pem

rm -f /etc/cassandra/conf/.truststore 
rm -f /etc/cassandra/conf/.keystore


mkdir -p /etc/cassandra/conf/

echo "private key generation for cassandra , execute on node1 "

CASS_NODE=10.0.0.175
/opt/jdk1.7.0_79/bin/keytool -keystore /home/keystore1 \
-storepass vmware -validity 3650 -storetype JKS -genkey -keyalg RSA \
-alias ${CASS_NODE} \
-ext san=dns:vcav-cassandra3.easpnet.inc,dns:vcav-cassandra2.easpnet.inc,dns:vcav-cassandra1.easpnet.inc,ip:10.0.0.175,ip:10.0.0.176,ip:10.0.0.177 \
-dname "cn=${CASS_NODE}, ou=DR2C, o=VMware, c=US" \
-keypass vmware

CASS_NODE=10.0.0.176
/opt/jdk1.7.0_79/bin/keytool -keystore /home/keystore2 \
-storepass vmware -validity 3650 -storetype JKS -genkey -keyalg RSA \
-alias ${CASS_NODE} -dname "cn=${CASS_NODE}, ou=DR2C, o=VMware, c=US" \
-ext san=dns:vcav-cassandra3.easpnet.inc,dns:vcav-cassandra2.easpnet.inc,dns:vcav-cassandra1.easpnet.inc,ip:10.0.0.175,ip:10.0.0.176,ip:10.0.0.177 \
-keypass vmware

CASS_NODE=10.0.0.177
/opt/jdk1.7.0_79/bin/keytool -keystore /home/keystore3 \
-storepass vmware -validity 3650 -storetype JKS -genkey -keyalg RSA \
-alias ${CASS_NODE} -dname "cn=${CASS_NODE}, ou=DR2C, o=VMware, c=US" \
-ext san=dns:vcav-cassandra3.easpnet.inc,dns:vcav-cassandra2.easpnet.inc,dns:vcav-cassandra1.easpnet.inc,ip:10.0.0.175,ip:10.0.0.176,ip:10.0.0.177 \
-keypass vmware

echo "done generating keys,importing to "

echo "importing for  $CASS_NODE"
CASS_NODE=10.0.0.175

/opt/jdk1.7.0_79/bin/keytool -export -rfc \
-keystore /home/keystore1 -storepass vmware \
-file /home/cloud-${CASS_NODE}.pem -alias ${CASS_NODE}

/opt/jdk1.7.0_79/bin/keytool -noprompt -import -trustcacerts \
-alias ${CASS_NODE} -file /home/cloud-${CASS_NODE}.pem \
-keystore /etc/cassandra/conf/.truststore -storepass vmware

echo "importing for  $CASS_NODE"

CASS_NODE=10.0.0.176

/opt/jdk1.7.0_79/bin/keytool -export -rfc \
-keystore /home/keystore2	 -storepass vmware \
-file /home/cloud-${CASS_NODE}.pem -alias ${CASS_NODE}

/opt/jdk1.7.0_79/bin/keytool -noprompt -import -trustcacerts \
-alias ${CASS_NODE} -file /home/cloud-${CASS_NODE}.pem \
-keystore /etc/cassandra/conf/.truststore -storepass vmware

CASS_NODE=10.0.0.177

echo "importing for  $CASS_NODE"
/opt/jdk1.7.0_79/bin/keytool -export -rfc \
-keystore /home/keystore3 -storepass vmware \
-file /home/cloud-${CASS_NODE}.pem -alias ${CASS_NODE}

/opt/jdk1.7.0_79/bin/keytool -noprompt -import -trustcacerts \
-alias ${CASS_NODE} -file /home/cloud-${CASS_NODE}.pem \
-keystore /etc/cassandra/conf/.truststore -storepass vmware



HCS_NODE=10.0.0.157
echo "import HCS cert for $HCS_NODE"
openssl s_client -connect ${HCS_NODE}:5480 -tls1 \
< /dev/null 2>/dev/null | openssl x509 > /root/hcs1.crt

/opt/jdk1.7.0_79/bin/keytool -noprompt -import \
-trustcacerts -alias cloud-${HCS_NODE} \
-file /root/hcs1.crt \
-keystore /etc/cassandra/conf/.truststore \
-storepass vmware

HCS_NODE=10.0.0.158
echo "import HCS cert for $HCS_NODE"
openssl s_client -connect ${HCS_NODE}:5480 -tls1 \
< /dev/null 2>/dev/null | openssl x509 > /root/hcs2.crt

/opt/jdk1.7.0_79/bin/keytool -noprompt -import \
-trustcacerts -alias cloud-${HCS_NODE} \
-file /root/hcs2.crt \
-keystore /etc/cassandra/conf/.truststore \
-storepass vmware


echo "NEXT STEP -->copy keystore enter password of cass2 and cass3 "

echo '
scp /home/keystore1 root@vcav-cassandra1:/etc/cassandra/conf/.keystore 
scp /home/keystore2 root@vcav-cassandra2:/etc/cassandra/conf/.keystore
scp /home/keystore3 root@vcav-cassandra3:/etc/cassandra/conf/.keystore


scp /etc/cassandra/conf/.truststore root@vcav-cassandra2:/etc/cassandra/conf/.truststore 
scp /etc/cassandra/conf/.truststore root@vcav-cassandra3:/etc/cassandra/conf/.truststore 

'
scp /home/keystore1 root@vcav-cassandra1:/etc/cassandra/conf/.keystore 
scp /home/keystore2 root@vcav-cassandra2:/etc/cassandra/conf/.keystore
scp /home/keystore3 root@vcav-cassandra3:/etc/cassandra/conf/.keystore


scp /etc/cassandra/conf/.truststore root@vcav-cassandra2:/etc/cassandra/conf/.truststore 
scp /etc/cassandra/conf/.truststore root@vcav-cassandra3:/etc/cassandra/conf/.truststore 



/opt/jdk1.7.0_79/bin/keytool -list -keystore /etc/cassandra/conf/.truststore -storepass vmware  -v
