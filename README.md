# WeasyPrint template for Azure Function
The function is set up with the help of the [Azure Function quickstart guide](https://docs.microsoft.com/en-us/azure/azure-functions/functions-create-first-azure-function-azure-cli).
See also the [Azure custom Docker image tutorial](https://docs.microsoft.com/en-us/azure/app-service/containers/tutorial-custom-docker-image).
There is no need to init a new function with `func init <name>`, because the scaffold is already included in this document.

## Prerequisites
* Azure console
* Docker

## Setup project 
* Do not name your project or function `weasyprint`, because this may cause naming conflicts with the Python module WeasyPrint that is used in this template.
I chose for `pdf` as project name and `http-trigger` as function name, because different trigger types for PDF's may be created in the future.
* Rename `local.settings.json.dist` to `local.settings.json` and replace the variables `AzureWebJobsStorage` and `APPINSIGHTS_INSTRUMENTATIONKEY`.
The value for `AzureWebJobStorage` is the [Access Key connection string](https://stackoverflow.com/a/27584785) of the Azure storage account that is used with this function app.

## Setup local Docker
Follow this procedure in case you want to deploy your own Dockerfile.
Use `plankje/azure-function-weasyprint` from Docker Hub if you just want to deploy the WeasyPrint function.

Be aware that the image name of your container must match the pattern `<hub-user>/<repo-name>:<tag>` in order to be able to push to Docker Hub.
The tag name is not required, and the value `latest` will be used if left empty.
It's therefore recommended to first create a repository at Docker Hub, before building the container.
The variable `<image_name>` in these instructions refer to the image name, for example `plankje/azure-function-weasyprint`.

### Local setup

* The local Docker is not capable of doing any form of authentication, therefore set `authLevel` in `http-trigger/function.json` to `anonymous` for locally testing the container.
* Build the Docker image locally with `docker build --no-cache -t <image_name> .`  (do not omit the trailing dot).
* Make sure that port 8080 is not yet claimed by any other process.
Run the Docker image locally with `docker run -p 8080:80 -it <image_name>`.
* Verify that the project is running properly on http://localhost:8080.
You should see a default Azure page with the message "_Your Functions 2.0 app is up and running_".
Later in this tutorial will be explained how to call the HTTP trigger.

With every change you make, the container needs to be restarted and rebuild, because it directly copies the project sources to the container.

* Make sure that the Docker image is not yet running with `docker ps`. 
Kill any active containers if necessary with `docker stop <CONTAINER ID>`.
* Rebuild the Docker image locally with `docker build -t <image_name> .`.
* Run the Docker image locally with `docker run -p 8080:80 -it <image_name>`.

### Deploy container to Docker hub
If you changed anything to the Dockerfile, you should push the container to Docker hub (or any other Docker repository) in order to use it in Azure.
See the [Docker hub documentation](https://docs.docker.com/docker-hub/repos/) for more detailed instructions.

* Log in to docker with `docker login`.
* Push the container with `docker push <image-name>`.

## Deploy function to Azure
This procedure assumes that you already set up an Azure Python function app with the Docker container you created before. 
You can also create an Azure Python function app and use the Docker Hub image `plankje/azure-function-weasyprint`.
The variable `<app_name>` in these instructions refer to the _function app_ name in Azure. 
This is not to be confused with _function_ name `http-trigger`, which will be a function within your function app.

* Make sure that in the Azure portal the setting `FUNCTION_WORKER_RUNTIME` exists and is set to `python` under `Platform features > Configuration > Application settings`  
* Change the `authLevel` value of `http-trigger/function.json` to `function` if you want to enable key-based authentication. 
Caution: this value will not work in your local Docker environment, and cause the application to give a 500 internal server error.
* Publish the function app with `func azure functionapp publish <app_name> --build remote`. 
With this command you will publish all functions that you created.
It can take a few minutes before the `http-trigger` function becomes visible in the Azure portal.

You should now be able to send a POST request to `https://<app_name>.azurewebsites.net/api/http-trigger?code=<function_key>`.
The value for `<function_key>` is function specific and can found in the Azure portal under `http-trigger > Manage > Function keys > default`.
This is a base64 encoded secret that serves as key-based authentication, which is defined in the file `http-trigger/function.json` under `authLevel`. 
The query string key `code` in this URL is a conventional name by Azure.
See [this blog post](https://vincentlauzon.com/2017/12/04/azure-functions-http-authorization-levels/) for more information about authorization levels.
