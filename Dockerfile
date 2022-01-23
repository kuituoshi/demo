FROM changel/springboot:8

COPY target/dependency /workdir/lib

COPY target/demo-0.0.1.jar /workdir/boot.jar