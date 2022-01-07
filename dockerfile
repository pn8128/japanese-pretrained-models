FROM python:3.10-buster as builder

WORKDIR /opt/app

COPY requirements.lock /opt/app
RUN pip3 install -r requirements.lock


# ここからは実行用コンテナの準備
FROM python:3.10-slim-buster as runner

COPY --from=builder /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages

ARG PY_USER="pyusr"
ARG PY_UID="1000"
ARG PY_GID="100"

RUN apt-get update --yes && \
    apt-get upgrade --yes && \
    apt-get install --yes --no-install-recommends wget 

# Configure environment
ENV SHELL=/bin/bash \
    PY_USER="${PY_USER}" \
    PY_UID=${PY_UID} \
    PY_GID=${PY_GID} 

ENV HOME="/home/${PY_USER}"
# Create PY_USER with name jovyan user with UID=1000 and in the 'users' group
# and make sure these dirs are writable by the `users` group.
RUN echo "auth requisite pam_deny.so" >> /etc/pam.d/su && \
    useradd -l -m -s /bin/bash -N -u "${PY_UID}" "${PY_USER}" && \
    chmod g+w /etc/passwd

USER ${PY_UID}

WORKDIR "${HOME}/src"
