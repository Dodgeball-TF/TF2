#!/bin/bash
mkdir -p "${STEAMAPPDIR}" || true  

if [ "${AUTO_UPDATE_ONLY}" = true ]; then
	bash "${STEAMCMDDIR}/steamcmd.sh" +force_install_dir "${STEAMAPPDIR}" \
					+login anonymous \
					+app_update "${STEAMAPPID}" \
					+quit

     exit 0
fi

if [ "${AUTO_INSTALL}" = true ]; then
	bash "${STEAMCMDDIR}/steamcmd.sh" +force_install_dir "${STEAMAPPDIR}" \
					+login anonymous \
					+app_update "${STEAMAPPID}" \
					+quit
fi

# Are we in a metamod container and is the metamod folder missing?
if  [ ! -z "$METAMOD_VERSION" ] && [ ! -d "${STEAMAPPDIR}/${STEAMAPP}/addons/metamod" ]; then
        LATESTMM=$(wget -qO- https://mms.alliedmods.net/mmsdrop/"${METAMOD_VERSION}"/mmsource-latest-linux)
        wget -qO- https://mms.alliedmods.net/mmsdrop/"${METAMOD_VERSION}"/"${LATESTMM}" | tar xvzf - -C "${STEAMAPPDIR}/${STEAMAPP}"
fi

# Are we in a sourcemod container and is the sourcemod folder missing?
if  [ ! -z "$SOURCEMOD_VERSION" ] && [ ! -d "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod" ]; then
        LATESTSM=$(wget -qO- https://sm.alliedmods.net/smdrop/"${SOURCEMOD_VERSION}"/sourcemod-latest-linux)
        wget -qO- https://sm.alliedmods.net/smdrop/"${SOURCEMOD_VERSION}"/"${LATESTSM}" | tar xvzf - -C "${STEAMAPPDIR}/${STEAMAPP}"
fi

# Is the config missing?
# if [ ! -f "${STEAMAPPDIR}/${STEAMAPP}/cfg/server.cfg" ]; then
#         # Download & extract the config
#         wget -qO- "${DLURL}/master/etc/cfg.tar.gz" | tar xvzf - -C "${STEAMAPPDIR}/${STEAMAPP}"

#         # Change hostname on first launch (you can comment this out if it has done its purpose)
#         sed -i -e 's/{{SERVER_HOSTNAME}}/'"${SRCDS_HOSTNAME}"'/g' "${STEAMAPPDIR}/${STEAMAPP}/cfg/server.cfg"
# fi

# Believe it or not, if you don't do this srcds_run shits itself
cd "${STEAMAPPDIR}"

SERVER_SECURITY_FLAG="-secured";

if [ "$SRCDS_SECURED" -eq 0]; then
        SERVER_SECURITY_FLAG="-insecured";
fi

DEBUG_ENABLED=""
if [ ! -z "${SRCDS_DEBUG_ENABLED}" ]; then
        DEBUG_ENABLED="-debug"
fi


# Check if SRCDS_STATIC_HOSTNAME is set and append it to hostname
HOSTNAME_PARAM=""
if [ ! -z "${SRCDS_STATIC_HOSTNAME}" ]; then
        HOSTNAME_PARAM="+hostname \"${SRCDS_STATIC_HOSTNAME}\""
fi

START_MAP=""
if [ ! -z "${SRCDS_STARTMAP}" ]; then
        START_MAP="+map \"${SRCDS_STARTMAP}\""
fi

bash "${STEAMAPPDIR}/srcds_run" -game "${STEAMAPP}" -console \
                        -steam_dir "${STEAMCMDDIR}" \
                        -steamcmd_script "${HOMEDIR}/${STEAMAPP}_update.txt" \
                        -usercon \
                        +fps_max "${SRCDS_FPSMAX}" \
                        -tickrate "${SRCDS_TICKRATE}" \
                        -port "${SRCDS_PORT}" \
			-ip "${SRCDS_IP}" \
                        +tv_port "${SRCDS_TV_PORT}" \
                        +clientport "${SRCDS_CLIENT_PORT}" \
                        +maxplayers "${SRCDS_MAXPLAYERS}" \
                        +sv_setsteamaccount "${SRCDS_TOKEN}" \
                        +rcon_password "${SRCDS_RCONPW}" \
                        +sv_password "${SRCDS_PW}" \
                        +sv_region "${SRCDS_REGION}" \
                        -authkey "${SRCDS_WORKSHOP_AUTHKEY}" \
                        +servercfgfile "${SRCDS_CFG}" \
                        +mapcyclefile "${SRCDS_MAPCYCLE}" \
                        ${SERVER_SECURITY_FLAG} \
                        -unrestricted_maxplayers \
			${HOSTNAME_PARAM} \
   			${DEBUG_ENABLED} \
                	${START_MAP}
