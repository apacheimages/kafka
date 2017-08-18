FROM apacheimages/oracle-jre-server:latest
ENV KAFKA_VERSION=0.11.0.0
ENV SCALA_VERSION=2.11
ENV KAFKA_HOME=/opt/local/kafka-${KAFKA_VERSION}

ENV SBT_VERSION=0.13.15
ENV SBT_HOME=/usr/local/sbt
ENV PATH=${PATH}:/opt/jdk/bin:${SBT_HOME}/bin



WORKDIR /opt/local/src

RUN wget http://www-eu.apache.org/dist/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz && \
    tar zxf kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz && \
    mv kafka_${SCALA_VERSION}-${KAFKA_VERSION} ${KAFKA_HOME} && \
    rm -rf *.tar.gz && \
    apk del wget

RUN apk --no-cache --update add git ca-certificates openssl bash wget supervisor && mkdir -p "${SBT_HOME}"  && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub && \
    wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.25-r0/glibc-2.25-r0.apk && apk add glibc-2.25-r0.apk && \
    wget -q --no-check-certificate "https://dl.bintray.com/sbt/native-packages/sbt/$SBT_VERSION/sbt-${SBT_VERSION}.tgz" && \
    tar xzf  sbt-${SBT_VERSION}.tgz -C /usr/local/  && \
    echo -ne "- with sbt $SBT_VERSION\n" >> /root/.built

RUN git clone https://github.com/ldaniels528/trifecta.git && \
    cd trifecta && \
    ${SBT_HOME}/bin/sbt clean assembly && \
    mkdir -p /opt/lib && \
    find ./ -name "*.jar" |xargs -I{} mv {} /opt/lib/trifecta.jar



WORKDIR /opt/local
RUN ln -s ${KAFKA_HOME} /opt/local/kafka 
COPY supervisord.conf /etc/supervisord.conf
EXPOSE 8888 9092 2181
CMD ["/usr/bin/supervisord"]
