#!/bin/bash

# Function to check if a plugin is installed
is_plugin_installed() {
    local plugin_name="$1"
    ${JMETER_HOME}/bin/PluginsManagerCMD.sh status | grep -q "$plugin_name"
    return $?
}

# Install missing plugins based on the JMX script
if [ -f "$JMX_FILE" ]; then
    echo "Checking plugins for JMX file: $JMX_FILE"
    REQUIRED_PLUGINS=$(${JMETER_HOME}/bin/PluginsManagerCMD.sh available-for-jmx "$JMX_FILE")

    for plugin in $REQUIRED_PLUGINS; do
        if ! is_plugin_installed "$plugin"; then
            echo "Installing missing plugin: $plugin"
            ${JMETER_HOME}/bin/PluginsManagerCMD.sh install "$plugin"
        else
            echo "Plugin already installed: $plugin"
        fi
    done
else
    echo "JMX file not found: $JMX_FILE"
    exit 1
fi

# Run JMeter
echo "Running JMeter with file: $JMX_FILE"
jmeter -n -t "$JMX_FILE" -l "$RESULTS_FILE" -e -o /opt/jmeter/results/report