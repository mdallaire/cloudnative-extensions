ARG CNPG_TAG

FROM ghcr.io/cloudnative-pg/postgresql:$CNPG_TAG-system-trixie

ARG CNPG_TAG
ARG VECTORCHORD_TAG
ARG TIMESCALE_TAG
ARG TARGETARCH

# drop to root to install packages
USER root

# Install VectorChord
ADD https://github.com/tensorchord/VectorChord/releases/download/$VECTORCHORD_TAG/postgresql-${CNPG_TAG%.*}-vchord_${VECTORCHORD_TAG#"v"}-1_$TARGETARCH.deb /tmp/vchord.deb
RUN apt-get install -y /tmp/vchord.deb && rm -f /tmp/vchord.deb

# Install TimescaleDB
RUN <<EOT
  set -eux

  # Install dependencies
  apt-get update
  apt-get install -y --no-install-recommends curl

  # Add Timescale apt repo
  . /etc/os-release 2>/dev/null
  echo "deb https://packagecloud.io/timescale/timescaledb/debian/ $VERSION_CODENAME main" >/etc/apt/sources.list.d/timescaledb.list
  curl -Lsf https://packagecloud.io/timescale/timescaledb/gpgkey | gpg --dearmor >/etc/apt/trusted.gpg.d/timescale.gpg

  # Install Timescale
  apt-get update
  pg_major=$(echo "$CNPG_TAG" | cut -d'.' -f1)
  ts_pkg="timescaledb-2-postgresql-$pg_major"
  ts_full_version=$(apt-cache show "$ts_pkg" | awk '/^Version:/{print $2}' | grep "^${TIMESCALE_TAG}~debian" | head -1)
  apt-get install -y --no-install-recommends "$ts_pkg=$ts_full_version"

  # Cleanup
  apt-get purge -y curl
  rm /etc/apt/sources.list.d/timescaledb.list /etc/apt/trusted.gpg.d/timescale.gpg
  rm -rf /var/cache/apt/*
EOT

USER postgres

