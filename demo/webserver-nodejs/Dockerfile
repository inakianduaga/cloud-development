FROM google/nodejs

WORKDIR /app

# Startup scripts
ADD start.sh /scripts/
RUN chmod 755 /scripts/*.sh

EXPOSE 8080

# Default command
CMD ["/scripts/start.sh"]
