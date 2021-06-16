# Docker Tutorial

### Prequisites
* Clone this reposisitory locally
* Install & run [Docker for mac](https://docs.docker.com/docker-for-mac/install/)

## Background
Software containerization is named as such because it is analogous to shipping containers. 
The conformity of software containers greatly simplifies the complexity of running, sharing & deploying code.
Specifically the technology provides the following benefits:
* **Interoperable**: guarantees that a container that runs on a developer's computer will behave the same on a coworker's machine or a server in the cloud  
* **Isolated**: each container can manage its own dependencies making it simple to deploy multiple on a single machine to efficiently use all resources
* **Standardized**: regardless of what is running the process for increasing resources, viewing logs, or getting command line access are identical

## Docker Popularity
Although other software container tools exist the popularity and adoption of Docker has made it fairly synonymous with containers.  
The two main reasons for the popularity are that they are lightweight and easy to build.

#### Lightweight
Previous tools such as virtualization (think cloud servers) create an independent and complete machine. 
In other words it exactly mimics installing an OS on bare-metal.   

Containers on the other hand rely on the kernal of the host operating system which makes them smaller and therefore faster to create.
The Docker Daemon in charge of running containers insures interoperability that the container will work so long as it is running.   

#### Easy to Build
The standard way to define what will be inside & run within a container is the Dockerfile.
Although not required, a file named `Dockerfile` is a standard convention. 
It contains simple instructions to copy & manipulate files and typically ends with an instruction to run them when the container starts.  

## Dockerfile Basics & Images
A Docker image is the built by executing the instructions of a Dockerfile.
An image vs. container is analogous to the software installed on your disk and the container is the running software.

The other important feature of images is the concept of layering. 
Each command that Docker executes in your Dockerfile creates a new layer.
Layers are tranferrable, excutable, and cached so that subsequent builds execute more quickly. 
The final layer that is output from the build process are typically tagged and shared to make it easy to build other images from that layer.

## Docker Exercises
The following exercises will use a popular web server called NGINX to launch a sample personal website and teach the following:
* Creating Dockerfiles
* Building images
* Starting containers
* Operating running containers
* Using docker compose

All instructions intend to be executed from the terminal in the directory of this repository

### Dockerfile Basics & Building Images

#### Dockerfile & First Build
The very first line in a Dockerfile is the `FROM` command which establishes the base layer of your image

* Create a new file `Dockerfile` and add `FROM nginx` to the first line and save it
* Run `docker build .` which tells Docker to build `Dockerfile` (default filename) in the current directory, chosen by the `.`
* Tag your final layer with `docker build -t mysite .`

#### Adding Your Own Content
The `COPY` command is used to add files into the image

**Note:** `NGINX serves static content from /usr/share/nginx/html/`

* Add `COPY index.html /usr/share/nginx/html/` to the end of the Dockerfile
* Add `COPY style.css /usr/share/nginx/html/` to the end of the Dockerfile
* Rebuild your image `docker build -t mysite .`

### Running The Image
`run` is the command used to start a container from an image

**Note:** The NGINX process runs on port 80 of the container

#### Run the container
* start the container `docker run mysite`
* The container starts, and some logs from the nginx service will output
* There are a couple of problems with the first run:
    * There is no way to access the web server on the container from your browser
    * Your container doesn't have a consistent name, container ids can always be used by names are easier to remember      
    * The container is running the foreground and command line has been taken
* Stop the container by typing `ctrl+c`
* Start the container in the background and bind your local port 8080 to it `docker run -d -p 8080:80 --name mysite mysite` 
    * `-d` starts the container as a background process
    * `-p 8080:80` binds your local port 8080 -> port 80 on the container
    * `--name mysite` names your running container with a user defined label
* Visit your website at http://localhost:8080    

### Operating on Running Containers

#### Inspect the container
* Run `docker ps` to display your containers statistics
* From here you can observe if your container is running and other useful info

#### View container logs
* Run `docker logs -f mysite` to view the existing logs and follow the output
* Refresh your browser or make an additional request to http://localhost:8080
* Observe the requests that were made to root and the style sheet it loaded
* Note that without `-f` the output will only display the existing logs
* Stop following the logs by typing `ctrl+c`

#### Executing commands on a running container
* Run `docker exec mysite echo "hello from the container"` to execute an echo on the container
* For more flexible access to the container is typical to get an interactive bash shell with `docker exec -it mysite bash`
* Command breakdown:
  * `docker exec` is to execute commands on the container
  * `-it` gives an pseudo terminal and keeps standard input open
  * `mysite` specifies the container
  * `bash` is the command to execute
* Access the static directory `cd /usr/share/nginx/html/`
* Use the following command to replace the generic firstname in the index with you own:
   * Change the `YourName` string below
   * `sed -i s#@FirstName#YourName#g index.html`
* Refresh your browser to see the changes take effect immmediately

#### Stopping & removing containers
* Run `docker stop mysite` to stop the container
* Attempting to create a new container named mysite will result in an error `docker run -d -p 8080:80 --name mysite mysite`
* See stopped containers by running `docker ps -a`
* The `mysite` container and your previous unnamed containers will be listed
* Remove them using the name or id `docker rm mysite otherContainerId` 

### Additional Docker Run Techniques

#### Automatically remove a stopped container
By adding the `--rm` flag to the docker run command a stopped container will automatically be removed
* `docker run -d -p 8080:80 --name mysite --rm mysite`
* Stop the container: `docker stop mysite`
* Observe that the container is not stopped `docker ps -a`

#### Mounting files onto a running container
Sometimes it is useful to add files to a container without adding them into the image. 
This technique known as mounting can be accomplished with the `-v` argument to the run command
* `docker run -d -p 8080:80 --name mysite --rm -v $(pwd)/docker-logo-vector.svg:/usr/share/nginx/html/logo.svg mysite`
* Browse to http://localhost:8080/logo.svg
* Stop the container `docker stop mysite`

#### Modifying the initialization command
When a container starts it is instructed to run the entry point or command.
In order to replace that existing command simply add it to the end of the run command
* Display nginx command line help: `docker run -d -p 8080:80 --name mysite --rm mysite nginx -h`
* Run `docker logs mysite` to see the output of help

### Customizing The Image for Distribution
Making it easy to update the names in the personal website allows others to easily use the image

As previously mentioned when a container starts it runs a command to kick things off.
In the case of NGINX and our sample personal website the default start command is `nginx -g 'daemon off;'`
Until now the Dockerfile took advantage of this default inherited from the `nginx` base image
To allow users to customize the personal website, building on and replacing the default command is necessary

#### Updating the default command
* `CMD` is the Dockerfile directive used to set the start command
* Add `COPY startup.sh .` to add `startup.sh` to the image  
* Add `CMD ./startup.sh` to the end of your dockerfile
* This bash script will:
    * optionally replace the sample values in the personal website based on environment variables
    * delegate execution to nginx at the end
* Rebuild the image `docker build -t mysite .`  

#### Starting up with environment variables
Setting environment variables using the `docker run` command is a common way to customize a container.
* The `-e` flag is used to set environment variables, for example `-e "KEY=VALUE"`
* Modify the example command below with your personal information:
    * `docker run -d -p 8080:80 --name mysite --rm -e "FIRSTNAME=Asaf" -e "LASTNAME=Peleg" -e "EMAILHANDLE=asafpelegcodes" -e "EMAILHOST=gmail.com" mysite`
* Visit http://localhost:8080 to see your personalized website
* Stop the container with `docker stop mysite`

### Docker Compose & Putting it all Together
As you have seen, Docker commands can get fairly complex and lengthy. 
The solution to this problem is the Docker compose file, whose standard filename convention is `docker-compose.yaml`.
The compose file is yaml configuration which docker essentially translates into the arguments for one or more `docker run` executions.
`docker compose` also has equivalencies to most of the regular `docker` commands as you will see below.

The included compose file mimics the `docker run` command in the previous exercise but needs small changes.
* Open `docker-compose.yaml`
* Take note of:
    * The build context specifying where the images Dockerfile is located
    * The port mapping that forwards localhost:8080 -> port 80 of the container
    * The list of environment variables that are set to empty
* Set each environment to an appropriate value by typing a string on the right hand of the equals sign
* To execute the compose file run `docker compose up -d`
* Visit http://localhost:8080
* Check your containers status with `docker compose ps`
* Check your containers logs with `docker compose logs`
* Execute commands on your containers with `docker compose exec mysite echo hello`  
* To tear everything down run `docker compose down`

### [Dockerhub](https://hub.docker.com/)
Docker's public registry for images contains endless images to use or build from.

Anyone can upload images but the most common ones are those considered "Docker Official Images".
This curated list of images which can easily be distinguished by the tag since they have no namespace.
Examples include `nginx`, `mysql`, `ubuntu`, `java`, `python`, etc
These official images are an excellent building blocks for creating custom images but only represent a minute amount of all the images available.

##### References
* https://codepen.io/ZachSaucier/pen/aevDq
