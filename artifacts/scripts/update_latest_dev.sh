#!/bin/bash

latest_version=`curl -s "https://oss.sonatype.org/content/repositories/public/org/semoss/monolith/maven-metadata.xml" | grep "<latest>.*</latest>" | sed -e "s#\(.*\)\(<latest>\)\(.*\)\(</latest>\)\(.*\)#\3#g"`
last_updated=`curl -s "https://oss.sonatype.org/content/repositories/public/org/semoss/monolith/maven-metadata.xml" | grep "<lastUpdated>.*</lastUpdated>" | sed -e "s#\(.*\)\(<lastUpdated>\)\(.*\)\(</lastUpdated>\)\(.*\)#\3#g"`

if [ -f /opt/semoss-artifacts/ver.txt ]; then
        source /opt/semoss-artifacts/ver.txt
else
        version=0.0.1-SNAPSHOT
fi

echo SEMOSS_VERSION environment variable is $SEMOSS_VERSION
echo latest version is $latest_version
echo current version is $version
echo last updated is $last_updated

# If the version is being overridden, or the last updated is greater than the current, then update
if ! [[ -z "${SEMOSS_VERSION}" ]] || [[ (( $last_updated > $updated )) ]]; then
        # Always use the overridden version if provided 
        if [[ -z "${SEMOSS_VERSION}" ]]; then
                version=$latest_version
        else
                version="${SEMOSS_VERSION}"
        fi

        # Cleanup
        rm -rf /opt/semoss-artifacts/artifacts/home/semoss*
        rm -rf /opt/semoss-artifacts/artifacts/web/semoss*
        rm -rf /opt/semoss-artifacts/artifacts/war/monolith*
        rm -rf /opt/semoss-artifacts/artifacts/lib/monolith*
        rm -rf /root/.m2/repository/org/semoss
        cd /opt/semosshome
        find . -maxdepth 1 \! -name 'db' \! -name 'semoss-artifacts' \! -name '.' \! -name '..' -exec rm -rf {} +
        rm -rf /usr/share/tomcat/webapps/SemossWeb
        rm -rf /usr/share/tomcat/webapps/Monolith

        # Setup
        mkdir -p /usr/share/tomcat/webapps/SemossWeb
        mkdir -p /usr/share/tomcat/webapps/Monolith

        echo "Updating to version.. $version"
        cd /opt/semoss-artifacts/artifacts/home && mvn clean install -Dci.version=$version
        cp -r /opt/semoss-artifacts/artifacts/home/semoss*/* /opt/semosshome
        cd /opt/semoss-artifacts/artifacts/web && mvn clean install -Dci.version=$version
        cp -r /opt/semoss-artifacts/artifacts/web/semoss*/* /usr/share/tomcat/webapps/SemossWeb
        cd /opt/semoss-artifacts/artifacts/war && mvn clean install -Dci.version=$version
        cp -r /opt/semoss-artifacts/artifacts/war/monolith*/* /usr/share/tomcat/webapps/Monolith
        cd /opt/semoss-artifacts/artifacts/lib && mvn clean install -Dci.version=$version
        cp -r /opt/semoss-artifacts/artifacts/lib/monolith*/* /usr/share/tomcat/webapps/Monolith
        cp -r /opt/semoss-artifacts/x/RDF_Map.prop /opt/semosshome
        cp -r /opt/semoss-artifacts/x/social.properties /opt/semosshome
        cp -r /opt/semoss-artifacts/x/log4j.prop /opt/semosshome 
        cp -r /opt/semoss-artifacts/x/web.xml /usr/share/tomcat/webapps/Monolith/WEB-INF 

        # RDF bugfix
        mv /usr/share/tomcat/webapps/Monolith/WEB-INF/lib/dsiutils-2.4.2.jar /usr/share/tomcat/lib

        echo "version=$latest_version" > /opt/semoss-artifacts/ver.txt
        echo "updated=$last_updated" >> /opt/semoss-artifacts/ver.txt
else
        echo "Semoss is already up to date"
fi
