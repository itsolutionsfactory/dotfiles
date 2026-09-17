# Certificate Management

This module manages system and user certificates, including root CA certificates.

## What the certificate is

`root-ca.crt` is the **Monaco Telecom Group Root Certification Authority** (`O=Monaco Telecom, CN=Group Root Certification Authority`), a self-signed root valid from 2021-03-31 to 2041-04-01. It is not an ITSF certificate: it is the root of the group PKI that the NJJ / Monaco Telecom platform uses for its internal services.

Every service under `steelhome.internal` presents a certificate issued by `CA_2_NJJ_MTMC_Default`, itself signed by `Certification Authority mtMC`, which chains up to this root. Checked on 2026-09-14 for JFrog Artifactory, GitLab, the K8sv3 API and the MT Keycloak: the servers send the full chain, so trusting the root alone is enough (`openssl verify -CAfile root-ca.crt` returns `OK` on the served chain). The `setup-pc` repository ships the intermediates as well; they are only needed for a server that does not send its chain.

Renewal: the root does not expire before 2041. Replace this file only if the group PKI is re-keyed; the intermediates rotate on their own without any change here.

## Features

- Root CA certificate installation
- Certificate directory setup
- Automatic certificate updates
- Certificate verification

## Installation

To install the certificate configuration:

```bash
cd certs
./install.sh
```

The installation process includes:
1. Creating necessary certificate directories
2. Installing root CA certificates
3. Setting up certificate verification
4. Configuring certificate trust

## Configuration

The configuration includes:

- Root CA certificate installation
- Certificate directory structure
- Certificate verification setup
- Trust store configuration

## Usage

After installation, the certificates will be available system-wide:

- Root CA certificates are installed in the system trust store
- Certificates are automatically verified
- Certificate updates are managed through this module

## Requirements

- OpenSSL
- ca-certificates package
- sudo privileges (for system-wide installation) 