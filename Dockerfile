FROM sowmyamaruthi.jfrog.io/default-docker-virtual/openjdk:8u171-jre-alpine3.7
USER root
RUN apk update \
    && java -version

ARG APP_JAR_FILE=app.jar
ARG APP_NAME
RUN echo APP_NAME ${APP_NAME}

# add user
RUN adduser appuser -S -G sys -h /home/appuser

WORKDIR /home/appuser
COPY ${APP_NAME}*.jar ${APP_JAR_FILE}
RUN chmod +x ${APP_JAR_FILE} \
    && chown appuser:sys ${APP_JAR_FILE}

USER appuser
ENTRYPOINT ["sh", "-c", "java -jar app.jar"]