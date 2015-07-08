# Launching Gazebo with Docker and Amazon AWS
In this tutorial we'll use Docker to deploy Gazebo with gzserver and gzweb running in a GPU instance on AWS connected to our local host running gzclient.

## Dependencies

### Local
* [Docker](https://www.docker.com/) 1.8+
 * If you wish to run gzclient on your local system, you'll need not only the Docker client, but the full daemon install as well.
* [Docker Compose](https://docs.docker.com/compose/)
* [Docker Machine](https://docs.docker.com/machine/)
* [Docker Swarm](https://docs.docker.com/swarm/)
* [Nvidia](https://developer.nvidia.com/cuda-downloads)

### Remote
* [Docker](https://www.docker.com/) 1.8+
* [Nvidia](https://developer.nvidia.com/cuda-downloads)

### Images
* [Nvidia](https://developer.nvidia.com/cuda-downloads)

## Setup

### Local
For our local setup, we'll just need to install Docker along with the other Docker tools so that we can make the necessary API calls to deploy our remote setup. If you wish to run gzclient locally as well, we'll need to have the GPU drivers installed so that we can mount the necessary devices into the container runnin gzclient for rendering in the GUI.

### Remote
For our remote setup, we'll need an appropriate ami or virtual image to use for our GPU instance. So it'll need to have the Docker engine as well as the relevant Nvidia drivers installed. You can use a public image I've made @@here@@, but it is region specific to Origen. If you need to make you own, fallow the remote_setup.md for further instuctions.  
The other thing we'll need to do is make a security group with the appropriate inbound and outbound permissions, i.e. the port openings for gzweb and docker connections. Agian see the remote_setup.md for details.

### Images
For our image setup, we'll need to have Gazebo installed, meaning both gzserver and gzclient, as well as gzweb. We'll also need the matching Nvidia driver installed in the image to boot if we wish to have any of the sensors rendering properly. For this you can use the public image made available @@here@@.

## Deployment
So get things started we'll use docker-machine to an aws GPU instance for us using our desired configuration, designating it as our swam master. Then we'll add our local docker engine to the swarm cluster. Finally we'll launch gzserver and gzweb on the remote instance and attach a new network to the running container. Then we'll start gzclient in a locally running container attached to the same network allowing gzclient to connect to gzserver. Even once the server is running, we should be able point your web browser to the remote instance's external address and see our simulation's interface.

### Making a remote machine

### Starting gzserver and gzweb

### Loading gzweb

### Creating a network

### Connecting our local machine

### Starting gzclient


## Teardown

### Stopping the services

### Removing the machines

## Troubleshooting

## Sources
