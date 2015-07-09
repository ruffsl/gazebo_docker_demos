# Get Docker Experimental
# https://github.com/docker/docker/tree/master/experimental
wget -qO- https://experimental.docker.com/ | sh

# setup docker group
# https://docs.docker.com/installation/ubuntulinux/
# log out, log in

# install docker swarm
# http://docs.docker.com/swarm/

# install docker compose
# https://docs.docker.com/compose/install/

# install docker machine
# https://docs.docker.com/machine/

# add your AWS cradentials to enviroment
export AWS_ACCESS_KEY_ID=####################
export AWS_SECRET_ACCESS_KEY=########################################



# what region the VM should be started
export AWS_REGION=us-west-2
# as well as what zone in the region's site (region specific)
export AWS_ZONE=b
# we'll specify what VM image to use (region specific)
# use the aws image to enable graphical hardware accelaration
export AWS_AMI_ID=ami-b7babb87
# we'll specify what hardware to use (region specific)
# use the GPU cluster for rendering images
export AWS_INSTANCE_TYPE=g2.2xlarge
# security group same as default, docker-machine, but with added http=80 + gzweb=7681 inbound.
# default being i.e. ssh=22 + dockerPort=2376 + swarmPort=3376 inbound
export AWS_SECURITY_GROUP=sg-3515d051
# Virtual Private Cloud network
export AWS_VPC_ID=vpc-e2eb6787


# Use docker_macine to make aws istance as swarm master
sid=docker-machine -D create \
    --driver amazonec2 \
    --amazonec2-vpc-id vpc-e2eb6787 \
    --amazonec2-security-group sg-3515d051 \
    --amazonec2-region us-west-2 \
    --amazonec2-zone b \
    --amazonec2-ami ami-b7babb87 \
    --amazonec2-instance-type g2.2xlarge \
    --swarm \
    --swarm-master \
    swarm-master

docker-machine -D create \
    --driver amazonec2 \
    --amazonec2-vpc-id vpc-722ea217 \
    --amazonec2-region us-west-2 \
    --amazonec2-zone b \
    --amazonec2-ami ami-b7babb87 \
    --amazonec2-instance-type g2.2xlarge \
    --swarm \
    --swarm-master \
    swarm-master

docker-machine --debug create \
    --driver amazonec2 \
    --amazonec2-vpc-id vpc-46251523 \
    --amazonec2-zone b \
    test1


# We'll use compose to tell our swarm master how to run gzserver on aws
# and begien gzclient GUI locally
#

# point docker client to the swarm master node
eval "$(docker-machine env swarm-master)"

# launch gazebo with gzserver and gzweb services
docker-compose -f gzweb5Nvidia.yml up
