FROM mcr.microsoft.com/powershell:6.1.0-ubuntu-18.04
COPY ./F5-LTM/ /opt/microsoft/powershell/6/Modules/F5-LTM/

# docker build -t posh-f5-ltm .
# docker run -it --rm posh-f5-ltm