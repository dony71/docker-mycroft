FROM ubuntu:18.04

ENV TERM linux
ENV DEBIAN_FRONTEND noninteractive

# Install Server Dependencies for Mycroft
RUN set -x \
	&& sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list \
	&& apt-get update \
	&& apt-get -y install git python3 python3-pip locales sudo vim python3-rpi.gpio \
	&& pip3 install future msm \
	# Checkout Mycroft
	&& git clone https://github.com/MycroftAI/mycroft-core.git /opt/mycroft \
	&& cd /opt/mycroft \
	&& mkdir /opt/mycroft/skills \
	# git fetch && git checkout dev && \ this branch is now merged to master
	&& CI=true /opt/mycroft/./dev_setup.sh --allow-root -sm \
	&& mkdir /opt/mycroft/scripts/logs \
	&& touch /opt/mycroft/scripts/logs/mycroft-bus.log \
	&& touch /opt/mycroft/scripts/logs/mycroft-voice.log \
	&& touch /opt/mycroft/scripts/logs/mycroft-skills.log \
	&& touch /opt/mycroft/scripts/logs/mycroft-audio.log \
	&& /usr/local/bin/msm install https://github.com/dony71/respeaker-2mic-hat-skill.git \
	&& /usr/local/bin/msm install https://github.com/dony71/rpi-gpio-skill.git \
	&& apt-get -y autoremove \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl https://forslund.github.io/mycroft-desktop-repo/mycroft-desktop.gpg.key | apt-key add - 2> /dev/null && \
    echo "deb http://forslund.github.io/mycroft-desktop-repo bionic main" > /etc/apt/sources.list.d/mycroft-desktop.list
RUN apt-get update && apt-get install -y mimic

# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Create user and group
RUN addgroup --system --gid 370 gpio
RUN addgroup --system --gid 371 i2c
RUN addgroup --system --gid 372 spi
RUN addgroup --gid 1001 pi
RUN adduser --disabled-password --gecos '' --uid 1001 --gid 1001 pi
RUN usermod -G pi,gpio,i2c,spi pi

WORKDIR /opt/mycroft
COPY startup.sh /opt/mycroft
RUN chown -R pi:pi /opt/mycroft
COPY 99-com.rules /etc/udev/rules.d
ENV PYTHONPATH $PYTHONPATH:/mycroft/ai

RUN chmod +x /opt/mycroft/start-mycroft.sh \
	&& chmod +x /opt/mycroft/startup.sh

EXPOSE 8181

USER pi

RUN echo "PATH=$PATH:/opt/mycroft/bin" >> $HOME/.bashrc \
        && echo "source /opt/mycroft/.venv/bin/activate" >> $HOME/.bashrc

ENTRYPOINT "/opt/mycroft/startup.sh"
