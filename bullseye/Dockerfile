###########################################################
# Dockerfile that builds a TF2 Gameserver
###########################################################
FROM cm2network/steamcmd:root AS build_stage

LABEL maintainer="walentinlamonos@gmail.com"

ENV STEAMAPPID 232250
ENV STEAMAPP tf
ENV STEAMAPPDIR "${HOMEDIR}/${STEAMAPP}-dedicated"
ENV DLURL https://raw.githubusercontent.com/Dodgeball-TF/TF2



RUN set -x \
	# Add i386 architecture
	&& dpkg --add-architecture i386 \
	# Install, update & upgrade packages
	&& apt-get update \
	&& apt-get install -y --no-install-recommends --no-install-suggests \
	curl \
	wget=1.21-1+deb11u1 \
	ca-certificates=20210119 \
	lib32z1=1:1.2.11.dfsg-2+deb11u2 \
	libncurses5:i386=6.2+20201114-2+deb11u2 \
	libbz2-1.0:i386=1.0.8-4 \
	libtinfo5:i386=6.2+20201114-2+deb11u2 \
	libcurl3-gnutls:i386=7.74.0-1.3+deb11u9 \
	&& curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
	&& install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
	&& mkdir -p "${STEAMAPPDIR}" \
	# Add entry script
	&& wget "${DLURL}/master/etc/entry.sh" -O "${HOMEDIR}/entry.sh" \
	&& wget "${DLURL}/master/etc/updater.sh" -O "${HOMEDIR}/updater.sh" \
	# Create autoupdate config
	&& { \
	echo '@ShutdownOnFailedCommand 1'; \
	echo '@NoPromptForPassword 1'; \
	echo 'force_install_dir '"${STEAMAPPDIR}"''; \
	echo 'login anonymous'; \
	echo 'app_update '"${STEAMAPPID}"''; \
	echo 'quit'; \
	} > "${HOMEDIR}/${STEAMAPP}_update.txt" \
	&& chmod +x "${HOMEDIR}/entry.sh" \
	&& chown -R "${USER}:${USER}" "${HOMEDIR}/entry.sh" "${STEAMAPPDIR}" "${HOMEDIR}/${STEAMAPP}_update.txt" \
	# Clean up
	&& rm -rf /var/lib/apt/lists/*

# Download and install kubectl
RUN 


FROM build_stage AS bullseye-base

ENV SRCDS_FPSMAX=300 \
	SRCDS_TICKRATE=66 \
	SRCDS_PORT=27015 \
	SRCDS_TV_PORT=27020 \
	SRCDS_NET_PUBLIC_ADDRESS="0" \
	SRCDS_IP="0" \
	SRCDS_MAXPLAYERS=16 \
	SRCDS_TOKEN=0 \
	SRCDS_STARTMAP="ctf_2fort" \
	SRCDS_REGION=3 \
	SRCDS_HOSTNAME="New \"${STEAMAPP}\" Server" \
	SRCDS_WORKSHOP_START_MAP=0 \
	SRCDS_HOST_WORKSHOP_COLLECTION=0 \
	SRCDS_WORKSHOP_AUTHKEY="" \
	SRCDS_CFG="server.cfg" \
	SRCDS_MAPCYCLE="mapcycle_default.txt" \
	SRCDS_SECURED=1 \
	AUTO_INSTALL=false

# Switch to user
USER ${USER}

WORKDIR ${HOMEDIR}

CMD ["bash", "entry.sh"]

# Expose ports
EXPOSE 27015/tcp \
	27015/udp \
	27020/udp

FROM bullseye-base AS bullseye-metamod

ENV METAMOD_VERSION 1.11

FROM bullseye-metamod AS bullseye-sourcemod

ENV SOURCEMOD_VERSION 1.11
