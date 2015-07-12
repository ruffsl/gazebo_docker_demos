# Launching Gazebo + Docker and Amazon AWS
In this tutorial we'll use Docker to deploy Gazebo with gzserver and gzweb running in a GPU instance on AWS connected to our local host running gzclient.

## Dependencies
Here is a breakdown of the dependencies across our demo application:

#### Local
* [Docker](https://www.docker.com/)
* [Docker Compose](https://docs.docker.com/compose/)
* [Docker Machine](https://docs.docker.com/machine/)
* [Docker Swarm](https://docs.docker.com/swarm/)
* [Nvidia](https://developer.nvidia.com/cuda-downloads)

#### Remote
* [Docker](https://www.docker.com/)
* [Nvidia](https://developer.nvidia.com/cuda-downloads)
* [AWS](http://aws.amazon.com/)

#### Image
* [Gazebo](http://gazebosim.org/)
* [Nvidia](https://developer.nvidia.com/cuda-downloads)

## Setup

### Local
For our local setup, we'll need to install Docker along with the other Docker tools so that we can make the necessary API calls to deploy our remote setup. If you wish to run gzclient locally as well, we'll need to have the GPU drivers installed so that we can mount the necessary devices into the container running gzclient for rendering in the GUI.

### Remote
For our remote setup, we'll need an appropriate ami or virtual image to use for our GPU instance, so the Docker engine as well as the relevant Nvidia drivers installed. You can use this public AMI `ami-77dbdb47`, however this AMI is region specific to Oregon. If you need to make you own, fallow the remote_setup.md for further instructions. The other thing we'll need to do is make a security group with the appropriate inbound and outbound permissions, i.e. the port openings for gzweb and docker connections. Again see the remote_setup.md for details.

### Images
For our image setup, we'll need to have Gazebo installed, meaning both gzserver and gzclient, as well as gzweb. We'll also need the matching Nvidia driver installed in the image to boot if we wish to have any of the sensors rendering properly. For this you can use the public docker image `osrf/gazebo:gzweb5Nvidia` available [here](https://registry.hub.docker.com/u/osrf/gazebo/). The Dockerfile to make this image is also within this tutorial.

## Deployment
So get things started we'll use docker-machine to create our aws GPU instance for us with our desired configuration, and designating it as our swam master. Then we'll launch gzserver and gzweb on the remote instance and attach a new network to the running container. Once the server is running, we should be able point your web browser to the remote instance's external address and see our simulation's interface. Finally we'll add our local docker engine to the swarm cluster and we'll start gzclient in a locally running container attached to the same network allowing gzclient to connect to gzserver.

### Making a remote machine
We'll need to use our AWS credentials, so add them to your shell session as environmental variables:
```shell
export AWS_ACCESS_KEY_ID=####################
export AWS_SECRET_ACCESS_KEY=########################################
```

> Now create our AWS GPU instance and swarm master
* what region the VM should be started
 * `us-west-2`
* as well as what zone in the region's site (region specific)
 * `b`
* we'll specify what VM image to use (region specific). Use the aws image to enable graphical hardware acceleration
 * `ami-6dd8d85d`
* we'll specify what hardware to use (region specific). Use the GPU cluster for rendering images
 * `g2.2xlarge`
* security group same as default, docker-machine, but with added http=80 + gzweb=7681 inbound. Default being i.e. ssh=22 + dockerPort=2376 + swarmPort=3376 inbound
 * `sg-3515d051`
* Virtual Private Cloud network corresponding to the used security group
 * `vpc-e2eb6787`  

>Use docker_macine to make aws instance as swarm master

```shell
docker-machine -D create \
    --driver amazonec2 \
    --amazonec2-vpc-id vpc-722ea217 \
    --amazonec2-region us-west-2 \
    --amazonec2-zone b \
    --amazonec2-ami ami-77dbdb47 \
    --amazonec2-instance-type g2.2xlarge \
    --swarm \
    --swarm-master \
    swarm-master
```

### Starting gzserver and gzweb
Now we'll point docker client to the swarm master node:
```shell
eval "$(docker-machine env swarm-master)"
```
And then launch the gzserver and gzweb services using the compose file from inside this demo directory
```shell
docker-compose -f gzweb5Nvidia.yml up
```

### Loading gzweb
**TODO** For some reason, docker-machine always wants to create a security group, never use the one given to it. So just let it make it's own group named `Docker+Machine`, and then edit that security group from the AWS console to allow for the http=80 + gzweb=7681 inbound rules.

Then point your browser to the AWS external address.

### Creating a network

### Connecting our local machine

### Starting gzclient


## Tear down


### Stopping the services
To stop the gzserver and gzweb services:
```shell
docker-compose -f gzweb5Nvidia.yml stop
docker-compose -f gzweb5Nvidia.yml rm
```

### Removing the machinesTo terminate the AWS instance and remove the remote docker engine, swarm-master:
```shell
docker-machine rm swarm-master
```

## Troubleshooting

* **Q: Do I need to use a GPU instance:**  
The GPU instance on EC2 are expensive. Doe this Gazebo demo requare I use them?

    **A: No, not neccesaraly**  
    The GPUs are only neccesary if you requare any cameras or scene rendering done by the server for computer vision related simulations. If the only visual aspect you need is for the client GUI, then that is graphic dependancy for the host running the client, not the server running the simulation, gzserver. So to modify this demo to use a cheeper instance, just comment out the docker-machine argument specifing the GPU instance. By defult, the AWS driver will use a t2.micro instance. You could also comment out the AMI image and use the defult, as the one specifed is  only customly modified for the added Nvidia drivers and enabeled X server setup for gzserver to work with. Lastly, you'll need to comment out the device lines in the compose file before using it. As the Nvidia device will not exsist on a t2.micro, and thus fail to be mounted into the container running gzserver.

* **Q: I can't create a new machine with docker-machine because of key pairs:**  
The error mentions that a key pair with the same name already exists.

   **A: Check your AWS console**  
   If you are having issues creating the machine, you may see an error about a key pair for `swarm-master` can not be created as as it already exists. This may be due to prior failed attempts in creating an engin and not being removed properly. Simply check your AWS web console and remove the old key pair so that is can be regenerated when you try agian.

* **Q: I can't create a new machine with docker-machine because it already exists:**  
The error mentions that a an engin with the same name already exists.

  **A: Check your list of docker-machines**  
  This may be due to not having removed the last machine named swarm-master from docker-machine. The name chosen, `swarm-master` in not special, as it only serves to help us identify the master of a paricular swarm. But if you try and make a second master with the same name as a machine that is still listed, it will fail. To list the existing machines use: `docker-machine ls` and to remove a particulare machine use" `docker-machine rm <name>`.

* **Q: I can't connect to gzweb with my browser:**  
The machine was created secsesfully, and the gzserver and gzweb services where started sucsesfully by docker-compose, but I still can't connect to gzweb through my web browser using the machine's public address.

    **A: Check your security group in the AWS console**  
    If everything was started succsesfuly and you can see the gzweb pinging the gzserver from the logging output, but still can not connect to gzweb, then you may need to check your AWS securaty groups. The default security group the docker-machine creates for the EC2 instance to use only provides inbound accsess for the three neccesary docker ports for remote API and SSH access. Using the AWS console you can edit the securaty group named `docker-machine` and add the additinal inbound rules for the HTTP port: 80 and gzweb port: 7681.

* **Q: I built my own docker image for gzweb and it doesn't look right:**  
I built my own docker image for gzweb from scratch using the Dockerfile provided for gzweb and it doesn't look right becuase many of the preview icons for the interface are missing.

    **A: The build procces for gzweb is a bit weird currently**  
    If you just use `docker build` to create the image for gzweb, you'll need to do a bit of extra handywork to complete the whole gzweb build prosses. The build requares rendering the collection of preview icons for all the 3D objects using gzserver. To do this gzserver needs desplay access, not somthing that is given in a docker build command. So after the `docker-build` is finished, I run a container from the image with x server and gpu hardware mounted, rerun the comilation with the added rendering argument, and commit the new state of the container to the same image tag. This is why I've done this for up and have shared it through Dcoker Hub regestry. Perhaps as we polish out gzweb, we'll find a simplermeanse of rendering durring the build process.
## Sources
