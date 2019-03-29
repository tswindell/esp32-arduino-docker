FROM ubuntu:18.04

# Install system dependencies
RUN apt-get -qq update
RUN apt-get install -y gcc git wget make libncurses-dev \
        flex bison gperf python python-pip python-setuptools \
        python-serial python-cryptography python-future python-pyparsing

RUN apt-get clean

# Get the ESP32 toolchain
ARG ESP32_TOOLCHAIN=https://dl.espressif.com/dl/xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz

ENV ESP32_BASEDIR /opt/local/espressif

RUN mkdir -p $ESP32_BASEDIR
RUN wget -O $ESP32_BASEDIR/esp32-toolchain.tar.gz $ESP32_TOOLCHAIN
RUN tar -xzf $ESP32_BASEDIR/esp32-toolchain.tar.gz -C $ESP32_BASEDIR/
RUN rm $ESP32_BASEDIR/esp32-toolchain.tar.gz

# Setup ESP32 IDF SDK and Arduino component
ARG IDF_SDK=https://github.com/espressif/esp-idf.git
ARG ESP32_ARDUINO=https://github.com/espressif/arduino-esp32.git

ENV IDF_PATH /opt/esp
RUN mkdir -p $IDF_PATH

RUN git clone --recursive $IDF_SDK $IDF_PATH
RUN python -m pip install -r $IDF_PATH/requirements.txt

RUN git clone --recursive $ESP32_ARDUINO $IDF_PATH/components/arduino

# Setup app project directory
RUN mkdir /app
WORKDIR /app

# Add the toolchain binaries to PATH
ENV PATH $ESP32_BASEDIR/xtensa-esp32-elf/bin:$ESP32_BASEDIR/esp32ulp-elf-binutils/bin:$IDF_PATH/tools:$PATH
