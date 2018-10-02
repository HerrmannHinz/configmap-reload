FROM openshift/origin-base as builder
ENV GOPATH /go
RUN mkdir -p $GOPATH/bin
COPY . $GOPATH/src/github.com/jimmidyson/configmap-reload
RUN yum install -y golang make git && \
   cd $GOPATH/src/github.com/jimmidyson/configmap-reload && \
   PATH=$PATH:$GOPATH/bin make out/configmap-reload-linux-amd64 GOPATH=$GOPATH && cp $GOPATH/src/github.com/jimmidyson/configmap-reload/out/configmap-reload-linux-amd64 /usr/bin/configmap-reload && \
   yum erase -y golang make && yum clean all
LABEL io.k8s.display-name="configmap reload" \
      io.k8s.description="This is a component reloads another process if a configured configmap volume is remounted." \
      io.openshift.tags="kubernetes" \
      maintainer="Frederic Branczyk <fbranczy@redhat.com>"


FROM gcr.io/distroless/base
COPY --from=builder /go/src/github.com/jimmidyson/configmap-reload/out/configmap-reload-linux-amd64 /configmap-reload
ENTRYPOINT ["/configmap-reload"]
