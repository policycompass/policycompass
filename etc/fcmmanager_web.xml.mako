<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://java.sun.com/xml/ns/javaee" xmlns:web="http://java.sun.com/xml/ns/javaee/web-app_2_5.xsd" xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/web-app_3_0.xsd" id="WebApp_ID" version="3.0">
    <display-name>policycompass.fcmmanager</display-name>

    <filter>
        <filter-name>CorsFilter</filter-name>
        <filter-class>org.apache.catalina.filters.CorsFilter</filter-class>
        <init-param>
            <param-name>cors.allowed.methods</param-name>
            <param-value>GET,POST,HEAD,OPTIONS,PUT,DELETE</param-value>
        </init-param>
        <init-param>
            <param-name>cors.allowed.headers</param-name>
            <param-value>x-requested-with,content-type,accept,origin,authorization,x-csrftoken,x-user-path,x-user-token </param-value>
        </init-param>
    </filter>
    <filter-mapping>
        <filter-name>CorsFilter</filter-name>
        <url-pattern>/*</url-pattern>
    </filter-mapping>

    <welcome-file-list>
        <welcome-file>index.html</welcome-file>
        <welcome-file>index.htm</welcome-file>
        <welcome-file>index.jsp</welcome-file>
        <welcome-file>default.html</welcome-file>
        <welcome-file>default.htm</welcome-file>
        <welcome-file>default.jsp</welcome-file>
    </welcome-file-list>

    <servlet>
        <servlet-name>Jersey REST Service</servlet-name>
        <servlet-class>com.sun.jersey.spi.container.servlet.ServletContainer</servlet-class>
        <init-param>
            <param-name>com.sun.jersey.config.property.packages</param-name>
            <param-value>policycompass.fcmmanager</param-value>
        </init-param>
        <init-param>
            <param-name>com.sun.jersey.api.json.POJOMappingFeature</param-name>
            <param-value>true</param-value>
        </init-param>
        <load-on-startup>1</load-on-startup>
    </servlet>

    <servlet-mapping>
        <servlet-name>Jersey REST Service</servlet-name>
        <url-pattern>/v1/*</url-pattern>
    </servlet-mapping>

    <env-entry>
        <env-entry-name>adhocracy.api</env-entry-name>
        <env-entry-type>java.lang.String</env-entry-type>
        % if config_type=="dev":
        <env-entry-value>http://localhost:6541</env-entry-value>
        % elif config_type=="prod":
        <env-entry-value>https://adhocracy-prod.policycompass.eu/api</env-entry-value>
        % else:
        <env-entry-value>https://adhocracy-frontend-stage.policycompass.eu/api</env-entry-value>
        % endif
    </env-entry>
    <env-entry>
        <env-entry-name>adhocracy.god</env-entry-name>
        <env-entry-type>java.lang.String</env-entry-type>
        % if config_type=="dev":
        <env-entry-value>http://localhost:6541/principals/groups/gods/</env-entry-value>
        % elif config_type=="prod":
        <env-entry-value>https://adhocracy-prod.policycompass.eu/api/principals/groups/gods/</env-entry-value>
        % else:
        <env-entry-value>http://adhocracy-frontend-stage.policycompass.eu/api/principals/groups/gods/</env-entry-value>
        % endif
    </env-entry>
</web-app>
