ARG DOCKIMG=scratch
FROM $DOCKIMG

ARG DEBSRCDEPS
ARG HTCHAIN_UID
ARG HTCHAIN_USER
ARG HTCHAIN_GID
ARG HTCHAIN_GROUP
ARG HTCHAIN_HOME

USER root

# Install basic tools
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get --yes update
# Somme docker minimize env by removing doc and doc tools. Force unminimize it
# for test inside docker (like perl)
RUN if [ -f /usr/local/sbin/unminimize ]; then yes | /usr/local/sbin/unminimize; fi
RUN apt-get --yes install sudo util-linux make locales $DEBSRCDEPS
RUN apt-get --yes clean
RUN echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen && locale-gen
# Make the htchain group a system group to prevent from GID space conflict with
# $HTCHAIN_GID user group created by scripts/dock_start.sh
RUN addgroup --system htchain
RUN umask 0337 && \
    echo '%htchain ALL=(ALL:ALL) NOPASSWD: /usr/bin/apt, /usr/bin/apt-get, /usr/bin/make' \
    > /etc/sudoers.d/htchain

RUN addgroup --gid $HTCHAIN_GID $HTCHAIN_GROUP >/dev/null
RUN adduser --uid $HTCHAIN_UID \
        --gid $HTCHAIN_GID \
        --home $HTCHAIN_HOME \
        --no-create-home \
        --disabled-password \
        --gecos '' \
        $HTCHAIN_USER >/dev/null
RUN adduser $HTCHAIN_USER htchain >/dev/null
RUN adduser $HTCHAIN_USER sudo >/dev/null

ENV USER=$HTCHAIN_USER
USER $HTCHAIN_USER
