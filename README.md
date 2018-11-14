# KeycloakMedirad
Docker to create Keycloak for Medirad

## Environment Variables

### KEYCLOAK_USER

Need to be specified

### KEYCLOAK_PASSWORD

Need to be specified

### REALM

Specify realm name (default: irdbb)

### Client

Specify the client (default: irdbb-ui)

### DB_VENDOR

Supported values are :

* h2
* postgres
* mysql
* mariadb

If the DB can't be detected or DB_VENDOR not specified it will default to the embedded H2 database.

### DB_ADDR

Specify hostname of the database (optional)

### DB_PORT

Specify port of the database (optional, default is DB vendor default port)

### DB_DATABASE

Specify name of the database to use (optional, default is keycloak).

### DB_USER

Specify user to use to authenticate to the database (optional, default is keycloak).

### DB_PASSWORD

Specify user's password to use to authenticate to the database (optional, default is password).


### OTHERS

All environment variables specified in [jboss/keycloak]( https://hub.docker.com/r/jboss/keycloak/) can be used.
