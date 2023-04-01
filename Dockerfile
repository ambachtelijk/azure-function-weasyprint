FROM mcr.microsoft.com/azure-functions/python:4-python3.10
# To disable ssh & remote debugging on app service change the base image to the one below
#FROM mcr.microsoft.com/azure-functions/python:4-python3.10-appservice

RUN apt-get update && apt upgrade -y

RUN apt-get install -y build-essential python3-pip python3-setuptools python3-wheel python3-cffi \
    libcairo2 libpango-1.0-0 libpangocairo-1.0-0 libgdk-pixbuf2.0-0 libffi-dev shared-mime-info

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true

COPY requirements.txt /
RUN pip install -r /requirements.txt

COPY . /home/site/wwwroot
