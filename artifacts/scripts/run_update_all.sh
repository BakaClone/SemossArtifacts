cd /opt/semoss-artifacts
# Because chmod looks like a chage to git
git checkout .
git pull
chmod 777 /opt/semoss-artifacts/artifacts/scripts/*
cd /opt/semoss-artifacts/artifacts/scripts
./update_latest_dev.sh
cd /usr/share/tomcat/bin
./catalina.sh run
