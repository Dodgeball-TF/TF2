#!/bin/bash

output=$(bash "${STEAMCMDDIR}/steamcmd.sh" +force_install_dir "${STEAMAPPDIR}" \
         +login anonymous \
         +app_update "${STEAMAPPID}" \
         +quit 2>&1)

if echo "${output}" | grep -q "Success! App '${STEAMAPPID}' fully installed."; then
    echo "App fully installed. Restarting server(s)"

    LABEL_SELECTOR="${LABEL_SELECTOR:-app=special-app}"
    NAMESPACE="${NAMESPACE:-default}"
    # Get deployments with the specific label
    DEPLOYMENTS=$(kubectl get deployment -n $NAMESPACE -l $LABEL_SELECTOR -o name)

    # Loop through and restart each deployment
    for DEPLOYMENT in $DEPLOYMENTS; do
        kubectl rollout restart $DEPLOYMENT -n $NAMESPACE
        echo "Restarted $DEPLOYMENT"
    done

    echo "Server(s) restarted."

elif echo "${output}" | grep -q "Success! App '${STEAMAPPID}' already up to date."; then
    echo "App already up to date. No further action needed."
else
    echo "Error: Update not successful or status unknown."
    exit 1
fi

exit 0
