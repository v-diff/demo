# Getting started

This demo is designed to show a bit of the value-add that v-diff will bring to your organization. It should be viewed in conjunction with this [~5.5 minute Loom](https://www.loom.com/share/c02e3ab23e2e4c5bad6e3c1a21e9e25b) that shows how our product integrates with your developer experience.

The infrastructure used here is very different than v-diff's (v-diff, for example, isn't a proxy at all). However, the UI/UX is a good approximation for how v-diff will display regressions (and by extension, latency bottlenecks).

## Running the example

NB: The scripts provided need to be run on [JDK 8](https://www.oracle.com/java/technologies/javase/javase-jdk8-downloads.html).

Clone this repository locally.

The `example.sh` script included here builds and launches example servers as well as a diffy instance. Verify
that the following ports are available (9000, 9100, 9200, 8880, 8881, & 8888) and run `./example/run.sh`.

After this, go to your browser at [http://localhost:8888](http://localhost:8888) to see how the candidate instance responses differed from the production server instances' responses.

You can send additional requests by running `./example/traffic.sh`.

## Digging deeper
Instead of using our code, you can compare old + new versions of your own service:

1. Deploy your old code to `localhost:9990`. This is your primary.
2. Deploy your old code to `localhost:9991`. This is your secondary.
3. Deploy your new code to `localhost:9992`. This is your candidate.
4. Download the latest Diffy binary from maven central or build your own from the code using `./sbt assembly`.
5. Run the Diffy jar (created via `/.sbt assembly`) with the following command line arguments:

    ```
    java -jar ./target/scala-2.12/diffy-server.jar \
    -candidate=localhost:9992 \
    -master.primary=localhost:9990 \
    -master.secondary=localhost:9991 \
    -responseMode='primary' \
    -service.protocol=http \
    -serviceName=Your-Service \
    -maxHeaderSize='32.kilobytes' \
    -maxResponseSize='5.megabytes' \
    -proxy.port=:8880 \
    -admin.port=:8881 \
    -http.port=:8888 \
    -rootUrl="localhost:8888" \
    -summary.email="" \
    -summary.delay="5"
    ```

6. Send a few test requests to your v-diff instance on its proxy port:

    ```
    curl localhost:8880/your/application/route?with=queryparams
    ```

7. Watch the differences show up in your browser at [http://localhost:8888](http://localhost:8888).

8. The ```responseMode``` flag can have one of 3 values - ```'primary'```, ```'secondary'```, or ```'candidate'```. The value assigned to this flag will determine which of the 3 response for any request sent to diffy will be returned to the client. If the flag is not explicitly assigned it defaults to ```'primary'```.

## FAQ's
   For safety reasons `POST`, `PUT`, ` DELETE ` are ignored by default . Add ` -allowHttpSideEffects=true ` to your command line arguments to enable these verbs.

## HTTPS
If you are trying to run Diffy over a HTTPS API, the config required is:

    -service.protocol=https

And in case of the HTTPS port be different than 443:

    -https.port=123
