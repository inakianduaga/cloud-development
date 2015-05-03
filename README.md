Cloud development
=================

> Multi-user environment to edit and preview server-based applications (php/nodejs)
 
# Infrastructure

## Host
 
The host lives at the the top level and will have several running containers and content folders.

### Folder structure

Each user will have a root folder with 2 subfolders, one used for configuration of the different services (authentication, 
github keys), and another for hosting the git repo from where the code will be served. So if we have 2 users `clark_kent`, 
and `bruce_wayne` the folder structure would look like

```sh
/var/cloud-dev/users/clark_kent/config
/var/cloud-dev/users/clark_kent/repo
/var/cloud-dev/users/bruce_wayne/config
/var/cloud-dev/users/bruce_wayne/repo
```

##### Config folder

This will have:

- Authentication configuration for this user, used by the doorman container.
- github keys (w/ passphrase pw), used by the editor to push/pull to the remote git repo.
- general configuration file with a unique id that is used to generate the port mapping for the user containers

so for a user `clark_kent`, the config folder `/var/cloud-dev/users/clark_kent/config` will look like

```sh
./remote_git_key
./authentication
./config
```

##### Repo folder

The application git repo folder. Must be cloned/configured manually. 

### Docker images

The following docker images should always exist on the host

- nginx frontend proxy
- auth proxy to handle authentication: [Custom Doorman](https://github.com/inakianduaga/doorman-auth-proxy) 
- code editor: CodeboxIde 

In addition, depending on the application being edited/previewed, there might be one or several webservers

- webserver: nginx/hhvm

### Docker containers 

- An nginx proxy container, that decides where to forward the request
- Per user, 4 containers
  - **Auth container**: Securing the webserver container
  - **Webserver container**: For example, nginx/hhvm for php application, express server for nodejs, etc. 
      The content will be served from a base folder living on the host and associated to the user only.
  - **Auth container**: Securing the code editor container
  - **Code editor container**: Linked to the same user folder, makes that folder available for editing.    

##### Nginx proxy container

