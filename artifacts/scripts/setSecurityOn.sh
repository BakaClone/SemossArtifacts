sed -i '/<web-app.*/,/<\/web-app>/ {/<context-param>/,/<\/context-param>/ {/<param-name>security-enabled<\/param-name>/,/<param-value>/ s/false/true/}}' /usr/share/tomcat/webapps/Monolith/WEB-INF/web.xml
