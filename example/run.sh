#!/usr/bin/env bash
echo "Please make sure ports 9000, 9100, 9200, 8880, 8881, & 8888 are available before running \"example/run.sh start\""
echo "Build Diffy" && \
#    ./sbt assembly

echo "Build primary, secondary, and candidate servers" && \
javac -d example src/test/scala/ai/diffy/examples/http/ExampleServers.java && \

echo "Deploy primary, secondary, and candidate servers" && \
java -cp example ai.diffy.examples.http.ExampleServers 9000 9100 9200 & \

echo "Deploy Diffy" && \
java -jar ./target/scala-2.12/diffy-server.jar \
-candidate='localhost:9200' \
-master.primary='localhost:9000' \
-master.secondary='localhost:9100' \
-responseMode='candidate' \
-service.protocol='http' \
-serviceName='V-Diff' \
-summary.delay='1' \
-summary.email='' \
-maxHeaderSize='32.kilobytes' \
-maxResponseSize='5.megabytes' \
-proxy.port=:8880 \
-admin.port=:8881 \
-http.port=:8888 & \

sleep 5
echo "Wait for server to deploy"
sleep 5

echo "Send some traffic to your Diffy instance"
for i in {1..10}
do
    sleep 0.1
    curl -s -i -H "Canonical-Resource : json" http://localhost:8880/json?Mixpanel
    sleep 0.1
    curl -s -i -H "Canonical-Resource : json" http://localhost:8880/json?Twitter
    sleep 0.1
    curl -s -i -H "Canonical-Resource : json" http://localhost:8880/json?Airbnb
done

echo "Your Diffy UI can be reached at http://localhost:8888"


