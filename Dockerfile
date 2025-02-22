# Use OpenJDK as the base image
FROM openjdk:11-jre

# Set environment variables for JMeter
ENV JMETER_VERSION=5.4.1
ENV JMETER_HOME=/opt/jmeter
ENV PATH="${JMETER_HOME}/bin:${PATH}"

# Install required dependencies
RUN apt-get update && apt-get install -y wget unzip git && rm -rf /var/lib/apt/lists/*

# Download and extract JMeter
RUN wget --quiet https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz \
    && tar -xzf apache-jmeter-${JMETER_VERSION}.tgz -C /opt \
    && mv /opt/apache-jmeter-${JMETER_VERSION} ${JMETER_HOME} \
    && rm apache-jmeter-${JMETER_VERSION}.tgz

# Download JMeter Plugins Manager
RUN wget --quiet https://repo.maven.apache.org/maven2/kg/apc/jmeter-plugins-manager/1.6/jmeter-plugins-manager-1.6.jar \
    -O ${JMETER_HOME}/lib/ext/jmeter-plugins-manager-1.6.jar

# Download CMDRunner for plugin management
RUN wget --quiet https://repo.maven.apache.org/maven2/kg/apc/cmdrunner/2.2/cmdrunner-2.2.jar \
    -O ${JMETER_HOME}/lib/cmdrunner-2.2.jar \
    && chmod +x ${JMETER_HOME}/lib/cmdrunner-2.2.jar

# Install CommandRunner and Plugin Manager
RUN java -cp ${JMETER_HOME}/lib/ext/jmeter-plugins-manager-1.6.jar org.jmeterplugins.repository.PluginManagerCMDInstaller

# Install all available plugins during the build
RUN ${JMETER_HOME}/bin/PluginsManagerCMD.sh install-all-except || echo "Plugin installation failed, continuing..."

# Set working directory
WORKDIR ${JMETER_HOME}

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Default command
ENTRYPOINT ["/entrypoint.sh"]