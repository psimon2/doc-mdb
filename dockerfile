FROM docker.io/yottadb/octo
COPY javascript/ /home/javascript
COPY mumps/ /home/mumps/
COPY python/ /home/python/
COPY fhir/ /home/fhir/
COPY provision/ /home/provision
RUN [ "bash", "-c", "cd /home/provision && ./provision1.sh"]
EXPOSE 9080
EXPOSE 9081
WORKDIR /home/provision
ENTRYPOINT ["bash", "-c", "./provision2.sh"]