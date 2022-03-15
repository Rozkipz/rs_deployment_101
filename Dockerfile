# In this demo I pull from the latest debian image, but please use a version and sha hash, along with dockerlock. You can read more about this in the relevant wiki section.
FROM debian:latest

# Lets install ping.
RUN apt update -y && apt install iputils-ping -y

# Lets copy in img.png the root of out container. We could use this file later if we wanted to.
COPY ./img.png /img.png

# Set the entry point to point at the ping binary. This is the default binary that is run when you run the container, rather than a shell.
ENTRYPOINT ["/bin/ping"]
